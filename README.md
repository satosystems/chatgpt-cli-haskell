# ChatGPT CLI

## How to install

```shell-session
$ stack install
...
$
```

## How to use

```shell-session
$ chat How to use stack of Haskell.
{"id":"chatcmpl-*****************************","object":"chat.completion","created":1684652156,"model":"gpt-3.5-turbo-0301","usage":{"prompt_tokens":15,"completion_tokens":379,"total_tokens":394},"choices":[{"message":{"role":"assistant","content":"In Haskell, stacks can be implemented using lists. Here is an example of how you can create and use a stack in Haskell:\n\n1. Define the stack and its operations\n\nFirst, you need to define the stack and its operations. Here is an example of a stack data type:\n\n```\ntype Stack a = [a]\n\npush :: a -> Stack a -> Stack a\npush x xs = x:xs\n\npop :: Stack a -> (Maybe a, Stack a)\npop [] = (Nothing, [])\npop (x:xs) = (Just x, xs)\n```\n\nIn this example, the `Stack` type is just a type alias for a list of elements of type `a`. The `push` function takes an element `x` and a stack `xs` and returns the new stack with `x` added to the top. The `pop` function takes a stack and returns a tuple with the top element of the stack (if there is one) and the new stack with the top element removed.\n\n2. Create a stack and perform operations on it\n\nOnce you have defined the stack operations, you can create a stack and use them. Here is an example of how you can create a stack of integers and push and pop elements from it:\n\n```\nmain = do\n    let s = []\n    let s' = push 1 s\n    let s'' = push 2 s'\n    let (Just x, s''') = pop s''\n    print x -- prints 2\n```\n\nIn this example, we start with an empty stack `s`. We then push the integers 1 and 2 onto the stack using the `push` function. We then pop the top element off the stack using the `pop` function, which gives us the integer 2. We print this value using the `print` function."},"finish_reason":"stop","index":0}]}
$
```
