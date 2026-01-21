# Auto-differentiation Library in C++ and Parallelisation on GPU Using CUDA

_This blog is an explanation of how I built my own auto-differentiation library called diffoDL from scratch in C++ and CUDA over a period of 2 months. Through this write-up I want to share the intuition of forward mode and reverse mode auto-differentiation algorithms, their use-cases and implementation in C++ as a lightweight library that is optimized to run on the GPU using CUDA. We will also explore the magic of GPUs in parallel computation. Further, I share the results of training a digit classification model (MNIST) using my autograd library on a T4 GPU (Google Colab)_

---

## 1. Preface
Computing gradients is an essential part of a large number of computer algorithms found in machine learning models, complex deep learning models like Convolutional Neural Networks (CNNs), Recurrent Neural Networks (RNNs), Transformers etc and sometimes even physics simulations involving differential equations. As these models become larger, the number of parameters that have to be tuned increase exponentially. As a result computing gradients for these parameters on a computer become difficult due to the requirement of large computational power, memory and accuracy.

First, its important that we build an intuition as to why auto-differentiation is required, forward mode and reverse mode auto-differentiation, and how it works under the hood in libraries like PyTorch for instance. I'll be explaining the implementation of a lightweight auto-differentiation library that I wrote in C++ as a project that I worked on for more than a month. Covering the working of Tensors, Computation Graphs and Mathematical operations. Further, we'll understand how GPUs are useful in the context of machine learning and how I made the library ready for more computationally heavy tasks like training large neural networks by writing CUDA kernels for handling basic linear algebra operations i.e. parallelization of these operations on GPUs.

Throughout the blog, I'll be using the words 'auto-differentiation' and 'autograd' interchangeably as both mean the same thing. It is assumed that the reader has some basic knowledge of how neural networks work, how models learn through backpropagation and gradient descent and intricacies of C++ like smart pointers, polymorphism in object oriented programming etc.

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

## 4. Building the Library

The first step to building the library was deciding what the API would look like and how different parts inside the library would interact with each other. I took inspiration from PyTorch's (a famous tensor library for deep learning in python) minimalistic API which is both easy to use and easy to understand. I wanted to divide the library API into two parts: Forward mode and Reverse mode, since both have different use cases and different algorithms. I quickly setup a new C++ project with a CMake build ecosystem since I wanted to make it easy for people to begin using my library.

### 4.1 Forward Mode Auto-differentiation With Dual Numbers

In order to prevent the hastle of building a computation graph for the forward mode and traversing different 'paths' in the computation graph, I took an easier route i.e. using Dual numbers and operator overloading (a feature of C++ classes). 

A dual number fundamentally is of the form $x=a+b\epsilon$ where $\epsilon^2 = 0$. The number **a** is the numerical value of the dual and **b** is the partial derivative of the dual with respect to some input variable (this input is also a Dual with b=0 or 1 where b is the seed). In my library I have implemented dual numbers as a class named Dual.  The Dual class object will have 2 public attributes: value and grad which mimic **a** and **b**. Essentially b represents $\dot{x}$ in table 3.1.

> **Recap:**
 In forward mode auto-differentiation, there is a forward accumulation of gradients and numerical values of expressions simultaneously through the nodes of > a computation graph. The gradients are calculated per node with respect to the inputs. Each input is given a seed (1 or 0) in a one-hot fashion (forexample a_seed=1, b_seed=0, c_seed=0 or a_seed=0, b_seed=1, c_seed=0). This seed represents the partial derivatives of inputs with respect to particular input.

<p align="center">
<img width="300"  alt="ForwardAD" src="https://github.com/user-attachments/assets/f165e1c1-b340-41a3-8580-e2d7fe5d54b7" /></p><br/>

https://en.wikipedia.org/wiki/Automatic_differentiation

Let's take an example of the function $f=ab$ for two dual numbers $a=x+\dot{x}\epsilon$ and $b=y+\dot{y}\epsilon$. Naturally $f$ is also a dual number which results from multiplying $a$ and $b$ as follows:

$$
f = ab
$$

$$
f = (x+\dot{x}\epsilon)(y+\dot{y}\epsilon)
$$

$$
f = xy + \dot{x}y\epsilon + \dot{y}x\epsilon + \dot{x}\dot{y}\epsilon^2
$$

Now $\epsilon^2 = 0$

$$
f = xy + (x\dot{y} + y\dot{x})\epsilon
$$

It is evident that the term accompanying $\epsilon$ represents $x\frac{\partial f}{\partial y} + y\frac{\partial f}{\partial x}$. If we pass a seed $\dot{x} =1$ and $\dot{y}=0$. We obtained $f = xy + y\epsilon$. The term accompanying epsilon automatically becomes $\frac{\partial f}{\partial x}$. This is the beauty of Dual numbers.

This computation graph can be imagined using arithmetic operators and simple math function operations. Thus operator overloading on Duals help to mimic operations like add, sub, mul, div as well as additional math functions like sin, cos, tan, pow, hyperbolic, inverse trigonometric, inverse hyperbolic which I created under namespace. These functions can act on Dual objects and simulate the forward pass automatically. In each of these functions the expression's value and derivative are calculated simultaneously.

Here's an example of how Dual arithmetic and functions can be implemented in C++.

```cpp
// Basic wireframe of the class Dual

class Dual {
public:
    // The actual value
    double value;

    // The derivative value (gradient)
    double grad;

    Dual();
    Dual(double scalar, int seed = 1);

    void zero_grad();
}
```

Some arithmetic operations on Dual numbers using operator overloading. In all cases, chain, product and quotient rules are followed. 

```cpp
// x + y
Dual Dual::operator+ (const Dual& d) {
    Dual result;
    result.value = value + d.value;
    result.grad = grad + d.grad;
    return result;
}

// x - y
Dual Dual::operator- (const Dual& d) {
    Dual result;
    result.value = value - d.value;
    result.grad = grad - d.grad;
    return result;
}

// x * y
Dual Dual::operator* (const Dual& d) {
    Dual result;
    result.value = d.value * value;
    result.grad = d.value * grad + value * d.grad; // product rule
    return result;
}

// x / y
Dual Dual::operator/ (const Dual& d) {
    Dual result;
    result.value = value / d.value;
    result.grad = (d.value * grad - value * d.grad)/(d.value*d.value);
    return result;
}
```

We can handle edge cases like operations between Dual numbers and constants like `int`, `double`, `float` etc separately to make the API friendly. One example is:

```cpp
// 1 - x
Dual operator- (const double& a, const Dual& d) {
    Dual result;
    result.value = a - d.value;
    result.grad = -d.grad;
    return result;
}
```

Here are some simple math functions like trigonometric, exponential, logarithmic, hyperbolic and inverse functions.

```cpp
#include <cmath>

namespace ddl
{
    Dual sin (const Dual& d) {
        Dual result;
        result.value = std::sin(d.value);
        result.grad = std::cos(d.value) * d.grad; // chain rule on sin(d)  
        return result;
    }
    // similarly cos and tan

    Dual exp (const Dual& d) {
        Dual result;
        result.value = std::exp(d.value);
        result.grad = std::exp(d.value) * d.grad; // chain rule on e^d
        return result;
    }

    Dual log (const Dual& d) {
        Dual result;
        result.value = std::log(d.value);
        result.grad = (1/d.value) * d.grad; // chain rule on log(d)
        return result;
    }
    
    Dual pow (const Dual& d, double n) {
        Dual result;
        result.value = std::pow(d.value, n);
        result.grad = n * std::pow(d.value, n-1) * d.grad; // n * d^n-1
        return result;
    }

    Dual atan (const Dual& d) {
        Dual result;
        result.value = std::atan(d.value);
        result.grad = d.grad * 1/(1+std::pow(d.value, 2)); // 1/(1+d^2)
        return result;
    }

    // similarly asin, acos

    Dual sinh (const Dual& d) {
        Dual result;
        result.value = std::sinh(d.value);
        result.grad = std::cosh(d.value) * d.grad;
        return result;
    }

    Dual tanh (const Dual& d) {
        Dual result;
        result.value = std::tanh(d.value);
        result.grad = d.grad * (1 - std::pow(std::tanh(d.value), 2)); // 1-(tanh(d))^2
        return result;
    }

    // similarly cosh

    Dual asinh (const Dual& d) {
        Dual result;
        result.value = std::asinh(d.value);
        result.grad = d.grad * 1/std::sqrt(1+std::pow(d.value, 2)); // 1/sqrt(1+d^2)
        return result;
    }

    // similarly acosh, atanh
}
```

Another feature is the [Jacobian](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant). The `jacobian()` function under `diffodl/jacobian.hpp` takes in 2 parameters. The first parameter is a callback function which takes in a vector of Duals as inputs and returns a vector Duals as outputs (a representation of vector functions). And the second parameter is a vector of doubles which act as values of inputs or the values at which derivatives are computed. The `jacobian()` function then returns an [`Eigen::MatrixXd`](https://libeigen.gitlab.io/eigen/docs-nightly/group__TutorialMatrixClass.html) object containing all partial derivatives. The matrix is of the form:
<p align="center"><img width="200" alt="image" src="https://github.com/user-attachments/assets/93c11142-a7cc-46a0-b336-d66418657bd2" /></p>


Code Example:
```cpp
#include <iostream>
#include <diffodl/dual.hpp>
#include <diffodl/jacobian.hpp>
#include <eigen3/Eigen/Dense>

std::vector<Dual> polar_to_cartesian(const std::vector<Dual>& inputs) {
    Dual r = inputs[0];
    Dual theta = inputs[1];

    Dual x = r * ddl::cos(theta);
    Dual y = r * ddl::sin(theta);

    return {x, y};
}


int main() {
    std::vector<double> polar_point = {1, 3.14159265358979323846/2}; // (r=1, theta=pi/2)
    Eigen::MatrixXd J2 = jacobian(polar_to_cartesian, polar_point);

    std::cout << J2 << std::endl;
    std::cout << J2.determinant() << std::endl; // = r = 1

    return 0;
}
```

In your main.cpp
```cpp
#include <diffodl/dual.hpp>
#include <diffodl/jacobian.hpp>
#include <Eigen/Dense> // if required

using namespace ddl; // for math functions
```

If you want to run unit tests, install Catch2. Go into the tests/ directory of diffoDL.
```
mkdir build
cd build
cmake --build .
./runtests
```

Thanks!

