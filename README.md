# A Project for the AVR - Written in Assembler Language
##Definition of purpose
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
To make sure that both code and electronic circuit work properly, it is needed to test the following:

* Connections of the electronic components
* Result of calculations
* Displaying data

### Test cases
![alt text](https://raw.githubusercontent.com/mvilares/asm-project/master/Testing.png "Test cases")

## Implementation
### Components
* LEDs - 16
* small buttons - 2
* big buttons - 2
* red cup -1
* blue cup -1
* wires - 30
* resisters -
..* 220Ω  - 16
..* 1kΩ - 4
* arduino board mega2560 - 1
* breadboard - 1
* usb cable - 1

### The source code
[Source code file](https://github.com/mvilares/asm-project/blob/master/8BitCalculator/8BitCalculator/main.asm)
