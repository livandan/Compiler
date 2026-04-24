# Codegen

## general idea
### builtin
This part is certain, so output directly.
### non-builtin
For each function, the processing method is as follows:
#### move pc

$- \Delta \text{pc} = \text{space}_\text{alloca} + \text{space}_\text{function parameters passed in stack} + \text{space}_\text{variables}$

Function parameters of array/struct types are passed on stack,
while parameters of other types are passed through registers (unless there are no more $a$ registers).

#### translate instructions

