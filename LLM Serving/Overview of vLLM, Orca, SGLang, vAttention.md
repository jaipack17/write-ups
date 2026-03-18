# Literature Review on LLM Serving  
Jaikaran Singh

Indian Institute of Technology, Roorkee

---

In this review I’ll be giving an intuitive overview of different methods for fast and memory optimized LLM serving systems which have been introduced in the past few years. I chose this topic for writing the lit review because I was interested in learning about how such huge models are actually deployed and distributed for large numbers of people to use them simultaneously. I remember when ChatGPT was first launched, in its early days I used to get rate-limited by their website saying that there are “ too many requests at this point of time”, but now it’s completely free of those issues. This must have been due to rapid improvement of how they scale the distribution of their models by optimizing memory management, building better serving infrastructure and using a large number of gpu workers in parallel.

What makes LLM serving possible? Systems like vLLM, Orca, FasterTransformer, DeepSpeed, TensorRT, SGLang are built in a way to speed up inference both cost effectively and while catering to a large number of users. Here I read the following papers:

1. [Orca: A Distributed Serving System for Transformer-Based Generative Models | USENIX](https://www.usenix.org/conference/osdi22/presentation/yu)  
2. [\[2309.06180\] Efficient Memory Management for Large Language Model Serving with PagedAttention](https://arxiv.org/abs/2309.06180)  
3. [\[2312.07104\] SGLang: Efficient Execution of Structured Language Model Programs](https://arxiv.org/abs/2312.07104)  
4. [\[2405.04437\] vAttention: Dynamic Memory Management for Serving LLMs without PagedAttention](https://arxiv.org/abs/2405.04437)

LLM serving functions in a simple workflow: The developers upload a pre-trained model and its weights ahead of time. At runtime, clients submit requests for that model to a serving system which queues the requests, schedules them to different available GPUs, processes those requests through the model using an execution engine, and then returns the results. It is very crucial to optimize memory management and request scheduling in such a way that it maximizes throughput and minimizes latency of LLM response.

An execution engine runs the model on a batch of requests using multiple GPU workers in parallel.

The throughput of models is highly dependent on batch-size (no. of requests processed simultaneously) as GPUs prefer high computation workload. Also, during inference, different requests may have different prompt sizes and different response lengths (unpredictable). Some requests may finish early while some may take a lot of time.

KVCache grows and shrinks dynamically, and for a large number of requests, it needs to be managed properly. LLM inference is **memory bound**.

## Paper-1: Orca Serving System (2022)
Orca is a distributed serving system that helps scale and serve LLMs at high speed. It introduces **iteration-level scheduling** and **selective batching** which are essential improvements in the way requests are handled before models process them.  
In previous works, models used to process batches only when enough requests had filled the batch and the engine used to return the responses only after the entire batch was done processing (prevents early return of completed request, high latency) keeping all new requests waiting till its done.  
<img width="408" height="218" alt="image" src="https://github.com/user-attachments/assets/4eabb4b7-4eff-4f17-bd5f-6d2ee92ae6ae" />

1. **Iteration-level Scheduling:** Schedule request execution at every model iteration. The engine selects requests to run next (batch) → engine executes one decoding step (iteration) on the batch → receives results, removes completed requests, adds new requests. The requests are processed on a first-come-first-serve basis.  
2. **Model Parallelism:**  
   1. **Inter-layer Parallelism:** Orca engine helps in splitting the model across consecutive layers and assigning them to different GPU workers. (Pipeline parallelism)  
   2. **Intra-layer Parallelism:** It also helps in splitting the layer operations like matrix multiplications, attention etc. across different GPUs for parallel computing (tensor parallelism)

Batching requests is difficult because it’s difficult to create tensors for attention keys, values, queries for different requests as they may be in different stages of processing (different no. of tokens). This is solved using **selective batching**.

3. **Selective batching**: Requests are processed in batches for operations like layer norm, activation, feed forward layer etc. Whereas for attention operations, the requests are split across the batch dimension and processed separately and later combined. Kernel fusion is also used.  
4. **KV Cache memory management**: A fixed amount of memory is pre-allocated for storing KV cache of max sequence length number of tokens (per request).

The shortcoming of this engine was in its poor KV cache memory management. Since allocation for KV cache was done equally for each request in a contiguous manner, it led to problems like [**memory fragmentation**](https://en.wikipedia.org/wiki/Fragmentation_\(computing\)) and **redundant duplication** which limited the batch size, reduced throughput, increased latency. This is solved in **vLLM**.

## Paper-2: vLLM and PagedAttention (2023) 
**vLLM** is a serving engine that solves the above problem by using on-demand **paging** of KV cache similar to how the operating system does it. The idea is to divide the KV cache virtual memory into non-contiguous blocks (pages) that store a fixed number of contiguous tokens for some head of some layer (say N). This N is relatively small hence it prevents memory fragmentation. These virtual blocks are mapped to their respective physical memory block locations using a block table. They can be freed once the request is completed. **PagedAttention** is the attention algorithm in vLLM for calculating self attention scores using KV cache stored in non-contiguous paged memory.  
<img width="1119" height="349" alt="image" src="https://github.com/user-attachments/assets/8c93edec-a9df-4a26-a77f-d2ac53ab4a4f" />

PagedAttention is simply: take softmax of similarity between query of a token with keys of tokens in a block. This gives a vector of similarity of query with each token in the block. Stack these vectors for a given block and multiply by the value vector of that block to get attention scores for this block.

vLLM also uses iteration-level scheduling & kernel fusion. Moreover, some requests require the model to generate multiple responses (eg. parallel sampling), we can store the kv cache of the prompt just once and reference it in different output sequences using block tables. vLLM also supports multi-GPU worker systems.

The shortcoming however is the tedious nature of PagedAttention and the way in which blocks are managed in vLLM. There is a runtime overhead due to management and lookup of block tables. Also, sharing prompts across multiple responses has limited support. KVcache of completed requests are immediately freed which might have been useful for future requests. These are solved by **SGLang** and **vAttention**

## Paper-3: SGLang (Structured Generation Language) and RadixAttention (2024)
SGLang is a serving system that provides a simple low-level python API (frontend) for writing **LM programs** (multiple logical LLM calls with control flow, used in agents) with parallelism control and introduces **RadixAttention** for KVCache reuse across multiple requests (backend runtime).

**Runtime optimizations:**

1. **RadixAttention**: Instead of discarding KVcache after a request is complete, SGLang stores the mappings of cache of the prompts and generations in a [**radix tree**](https://en.wikipedia.org/wiki/Radix_tree) for fast **prefix matching and reuse**. Requests that have the same prefix are grouped under the same node. The tree uses a **least recently used kvcache** eviction (removal)  policy and **cache aware scheduling.** This enhances **cache hit rate** (total cached input tokens / total input tokens). It is compatible with continuous batching, PagedAttention and tensor parallelism.  
   1. **LRU Policy**: These kvcache tensors are stored as non-contiguous pages. The least recently used tensor **leaf** is removed first  
   2. **Cache aware scheduling**: Requests with longer matching prefixes (compared with cache) are processed first. This order is the **depth first search (DFS) order**.

<img width="1007" height="287" alt="image" src="https://github.com/user-attachments/assets/8b99d33a-92c8-401d-91eb-c21ecf1d4962" />

2. **Fast Constrained Decoding**: SGLang also has fast constrained decoding (generating structured output using regex, eg. JSON decoding), it uses [compressed finite state machines](https://lmsys.org/blog/2024-02-05-compressed-fsm/) to guide decoding algorithms to generate **multiple** “obvious” tokens at the same time.  
3. **API Speculative Execution for Cost efficient API calling**: For saving api calls to API only models like GPT-4, in the first LLM call, few extra tokens are generated beyond the stop token (in hopes of predicting output of the next call) which are matched and used during the next LLM call.

It shows that a higher cache hit-rate leads to larger batch size, high throughput and lower latency. 

Shortcomings: The current prefix caching in RadixAttention relies on **exact matches** of token prefixes. It can't recognize when two prompts have similar meaning but not identical, missing cache reuse opportunities. Also, cache aware scheduling may inevitably de-prioritize some requests that do not have matching prefixes.

## Paper-4: vAttention: Serving LLMs without PagedAttention (2025)
The paper argues that PagedAttention is tedious (adds runtime overhead), increases software complexity and doesn’t actually follow the OS style paging. It says that PagedAttention unnecessarily changes the virtual memory layout to non-contiguous and has 2 layers of memory management (one of them is redundant, duplicate) which defeats the OS-style paging purpose.  
<img width="409" height="206" alt="image" src="https://github.com/user-attachments/assets/274a7c42-12ec-4118-82df-b19b23b8cdff" />

vAttention aims to solve memory fragmentation while retaining the contiguous nature of virtual KVCache memory. It is a simpler and more performant alternative to PagedAttention.  
Instead of allocating virtual and physical memory at the same time, vAttention decouples them. Since virtual memory is abundant (in 100s of TBs, fragmentation of virtual mem is not an issue), it uses **contiguous** allocation of a large memory pool for virtual KV tensors ahead of time and defers the work of mapping to physical memory for runtime. Mapping to physical memory is only done when a page/page-group starts to become full.  
<img width="824" height="276" alt="image" src="https://github.com/user-attachments/assets/4fa56a4d-aecb-43f2-a306-45ec3caa1161" />

It supports continuous batching by maintaining a mapping of  Q tensors to the virtual KV tensors. It also supports multiple page sizes.  
If it knows that the next iteration is going to need physical memory, it launches a background thread that does the physical memory mapping before the next iteration runs. (saves latency)  
During the prefill stage, it may defer the removal of the cache of a completed request and just reuse this memory for the cache of a **new** request to save physical memory space.  
Limitations: Only provides substantial performance gain during the prefill stage, decoding performance is similar to PagedAttention. Does not support prefix matching (essential for KVcache reuse). It requires modifying open source NVidia drivers to support small page sizes (like 64Kb) which is a concern as future drivers may change. 
