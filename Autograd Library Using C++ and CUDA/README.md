# Auto-differentiation Library in C++ and Parallelisation on GPU Using CUDA

---

## 1. Preface
_Computing gradients is an essential part of a large number of computer algorithms found in machine learning models, complex deep learning models like Convolutional Neural Networks (CNNs), Recurrent Neural Networks (RNNs), Transformers etc and sometimes even physics simulations involving differential equations. As these models become larger, the number of parameters that have to be tuned increase exponentially. As a result computing gradients for these parameters on a computer become difficult due to the requirement of large computational power, memory and accuracy._

First, its important that we build an intuition as to why auto-differentiation is required, forward mode and reverse mode auto-differentiation, and how it works under the hood in libraries like PyTorch for instance. I'll be explaining the implementation of a lightweight auto-differentiation library that I wrote in C++ as a project that I worked on for more than a month. Covering the working of Tensors, Computation Graphs and Mathematical operations. Further, we'll understand how GPUs are useful in the context of machine learning and how I made the library ready for more computationally heavy tasks like training large neural networks by writing CUDA kernels for handling basic linear algebra operations i.e. parallelization of these operations on GPUs.

Throughout the blog, I'll be using the words 'auto-differentiation' and 'autograd' interchangeably as both mean the same thing. It is assumed that the reader has some basic knowledge of how neural networks work and how models learn through backpropagation and gradient descent.

## 2. Numeric and Symbolic Differentiation
Before we begin with auto-differentiation, we can think of some intuitive ways of computing partial derivatives of functions with respect to its inputs using methods that we are already aware of. Numeric differentiation is one such way, where we use the first-principle to approximate the partial derivative by representing it as a limit. Consider a function with n parameters $\theta_1, \theta_2, \dots, \theta_n$ whose partial derivatives we want to calculate.

$$
f: \mathbb{R}^n \to \mathbb{R}
$$

$$
f(\theta_1, \theta_2, \dots, \theta_n)
$$

We can represent the partial derivative of the function with respect to some parameter $\theta_i$ as

$$
\frac{\partial f}{\partial \theta_i} = \frac{f(\theta_1, \dots, \theta_i + h, \dots, \theta_n) - f(\theta_1, \dots, \theta_n)}{h} + O(h)
$$

We nudge the function in a direction that aligns with the axis of the parameter that we are calculating the partial derivative with respect to. Since we can't take the limit at 0 programmatically, we can implement this in code by taking a very small value of h for example `1e-12` and introduce an error function $O(h)$ called the Truncation Error. The truncation error is defined as the error caused by cutting off some values from the Taylor series of $\frac{\partial f}{\partial \theta_i}$ and is directly proportional to $h$.

$$
O(h) = a_1 h + a_2 h^2 + \dots
$$

In theory, we could decrease this truncation error to the minimum possible value in two ways in order to get the best approximation of the derivative. We can either reduce the value of $h$ to a value extremely close to 0 or use a "central difference" rather than a one-sided difference. The central difference helps in decreasing truncation error by eliminating odd powers of $h$ in $O(h)$ .

$$
\frac{\partial f}{\partial \theta_i} = \frac{f(\theta_1, \dots, \theta_i + h, \dots, \theta_n) - f(\theta_1, \dots, \theta_i - h, \dots, \theta_n)}{2h} + O(h^2)
$$

This may seem like a very fundamentally correct method however, in practice, trying to reduce truncation error introduces another error called the Round-off Error which is related to the level of precision with which numbers (floats) are stored in computers. This limits how small we can make $h$ to reduce $O(h)$ . As a result, there is a trade-off between the truncation error and the round-off error (where the round-off error is inversely proportional to $h$). Thus numeric differentiation is not a scalable choice for large neural networks.

We could also think of computing derivatives by first finding the expression of the derivative using derivative expressions of commonly used functions and operations and then evaluating it on the actual values of the parameters. This is called Symbolic differentiation. However, for functions with large expressions, the derivative expression can become abnormally huge, making this method a very computationally expensive one.

Here is an example demonstrating swell due to combining the quotient and chain rules.

The function $g(x)$:

$$
g(x) = \frac{e^{x^2}}{\sqrt{\sin(3x) + 1}}
$$

The derivative $g'(x)$ rapidly increases in complexity:

$$
g'(x) = \frac{2xe^{x^2}\sqrt{\sin(3x)+1} - e^{x^2}\left( \frac{3\cos(3x)}{2\sqrt{\sin(3x)+1}} \right)}{(\sin(3x)+1)}
$$

In order to solve these issues and to build scalable solutions for effeciently computing large number of derivatives of complicated functions, the **auto-differentiation** algorithm was introduced.

## 3. Understanding Auto-differentiation

Auto-differentiation (or Autograd) from what we have understood so far is an algorithm that is capable of calculating derivatives of functions. Before diving into the C++ implementation, take some time to understand how **Forward** and **Reverse** mode auto-differentiation works.

### 3.1 Forward Mode
Forward mode auto-differentiation is an algorithm to compute the value as well as the partial derivative of a function with respect to an input simultaneously, by traversing (just once) through all intermediate variables that were used to construct the function. These intermediate variables could represent arithmetic operations (`+`, `-`, `*`, `/`) or transcendental functions like `log`, `exp`, `sin`, `cos`. Together the inputs, intermediate variables and outputs construct what is called a 'computation graph'. To build an intuition about the algorithm, consider a function with 2 inputs and 1 output:

$$
f(x, y) = xy + log(x+y)
$$

The computation graph of this function will be a Directed Acyclic Graph (DAG) where the inputs $x$ and $y$ are the root nodes and $f(x,y)$ is the leaf node. 

<p align="center">
<img width="45%" alt="image" src="https://github.com/user-attachments/assets/d2a4c0bc-8f61-4b6e-b095-8d3e66973b53" />
</p>

The idea is to compute the partial derivative of each intermediate node with respect to an input at every node and passing this derivative forward along with the value computed by the node to the nodes ahead. These gradients flow forward in the graph and are accumulated (through multiplication) as per the chain rule. The final value and partial derivative of the function with respect to an input is thus populated to the leaf node $f(x,y)$. 

The variable $x$ affects $f$ through two distinct paths:
1.  $x \to v_1 \to v_4 \to f$
2.  $x \to v_2 \to v_3 \to v_4 \to f$

$$
\frac{\partial f}{\partial x} = \underbrace{\frac{\partial f}{\partial v_4} \frac{\partial v_4}{\partial v_1} \frac{\partial v_1}{\partial x}}_{\text{Path 1}} + \underbrace{\frac{\partial f}{\partial v_4} \frac{\partial v_4}{\partial v_3} \frac{\partial v_3}{\partial v_2} \frac{\partial v_2}{\partial x}}_{\text{Path 2}}
$$

Similarly, $y$ affects $f$ through two paths:
1.  $y \to v_1 \to v_4 \to f$
2.  $y \to v_2 \to v_3 \to v_4 \to f$

$$
\frac{\partial f}{\partial y} = \underbrace{\frac{\partial f}{\partial v_4} \frac{\partial v_4}{\partial v_1} \frac{\partial v_1}{\partial y}}_{\text{Path 1}} + \underbrace{\frac{\partial f}{\partial v_4} \frac{\partial v_4}{\partial v_3} \frac{\partial v_3}{\partial v_2} \frac{\partial v_2}{\partial y}}_{\text{Path 2}}
$$

Forward mode autograd makes this simple. To calculate the partial derivative $\frac{\partial f}{\partial x}$ we pass 'seeds' to the root nodes $x$ and $y$ which represent $\frac{\partial x}{\partial x} = 1$ and $\frac{\partial y}{\partial x} = 0$ as x and y are independent variables. We now traverse through all nodes up till $f(x,y)$. Take for example $x=1$ and $y=2$.

| Node | Operation | Value ($v_i$) | Derivative ($\dot{v}_i = \frac{\partial v_i}{\partial x}$) |
| :--- | :--- | :--- | :--- |
| $x$ | Input | $1$ | $\dot{x} = 1$ (seed) |
| $y$ | Input | $2$ | $\dot{y} = 0$ |
| $v_1$ | $x \cdot y$ | $1 \cdot 2 = 2$ | $\dot{v}_1 = \dot{x}y + x\dot{y} = 1(2) + 1(0) = 2$ |
| $v_2$ | $x + y$ | $1 + 2 = 3$ | $\dot{v}_2 = \dot{x} + \dot{y} = 1 + 0 = 1$ |
| $v_3$ | $\log(v_2)$ | $\ln(3) \approx 1.099$ | $\dot{v}_3 = \frac{\dot{v}_2}{v_2} = \frac{1}{3} \approx 0.333$ |
| $v_4$ | $v_1 + v_3$ | $2 + 1.099 \approx 3.099$ | $\dot{v}_4 = \dot{v}_1 + \dot{v}_3 = 2 + 0.333 = 2.333$ |
| **$f$** | **Output** | **$3.099$** | **$\frac{\partial f}{\partial x} = 2.333$** |

The same process can be repeated for $\frac{\partial f}{\partial y}$ by taking $\dot{x} = 0$ and $\dot{y} = 1$.

In general for a function $f: \mathbb{R}^m \to \mathbb{R}^n$ with m inputs and n outputs, we can compute the jacobian of the function in m forward passes through the computation graph (one for each input, using one hot encoding for input seeds). Here each forward pass gives one column of the jacobian matrix.

$$
\mathbf{J}_{n \times m} = \begin{bmatrix}
\frac{\partial y_1}{\partial x_1} & \cdots & \frac{\partial y_1}{\partial x_m} \\
\vdots & \ddots & \vdots \\
\frac{\partial y_n}{\partial x_1} & \cdots & \frac{\partial y_n}{\partial x_m}
\end{bmatrix}
$$

It is evident that the partial derivatives of large number of outputs with respect to one input can be calculated in a single forward pass. Thus forward mode auto-differentiation is useful for functions with **small number of inputs and large number of outputs**. This method of auto-differentiation is not particularly useful for machine learning since neural networks contain very large number of input parameters compared to just a few outputs (loss function during backpropagation with weights and biases as parameters). We'll still look into how we can implement forward mode autograd using **Dual Numbers** (to be introduced in further sections), but for now lets understand Reverse Mode auto-differentiation, which is the exact algorithm used during backpropagation in neural networks.

### 3.2 Reverse Mode
