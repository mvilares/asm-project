# A Project for the AVR - Written in Assembler Language
## Definition of purpose
The purpose is to create a tool that allows us to calculate 8 bit operations precisely, and in a visual way.

## Problem statement
Ordinary calculators usually cannot perform binary operations.
* How to display information?
* How to input data to the calculator?
* What operations should the calculator be able to handle?
* How to choose the operation that the user wants to perform?

## Analysis and Design
### State-machine diagram
The state machine diagram offers a clear representation of the states the system encounters.
![alt text](https://raw.githubusercontent.com/mvilares/asm-project/master/StateMachine.PNG "State-machine diagram")

## Testing plan
To make sure that both code and electronic circuit work properly, the following needs to be tested:

* Connections of the electronic components
* Result of calculations
* Displaying data

### Test cases
![alt text](https://raw.githubusercontent.com/mvilares/asm-project/master/Testing.png "Test cases")

## Implementation
### Components
| Component         | Quantity |
|-------------------|----------|
| LEDs              | 16       |
| Small buttons     | 2        |
| Big buttons       | 2        |
| Red button cover  | 1        |
| Blue button cover | 1        |
| Wires             | 30       |
| Resistors (200Ω)  | 16       |
| Resistors (1kΩ)   | 4        |
| Arduino Mega 2560 | 1        |
| Breadboard        | 1        |
| USB Cable         | 1        |

The implementation schematic provided below shows how the electronic circuit can be constructed from the provided components.
![alt text](https://raw.githubusercontent.com/mvilares/asm-project/master/schematic.png "Schematic")

### The source code
[Source code file](https://github.com/mvilares/asm-project/blob/master/8BitCalculator/8BitCalculator/main.asm)
