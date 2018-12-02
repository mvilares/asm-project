;
; 8BitCalculator.asm
;
; Created: 21/11/2018 10:16:43 AM
; Authors : Roko, Marti, Denis, Cristina, Michal
;

.def TEMP = R16											; Assign the specified register to a more descriptive name
.def FIRST_VALUE = R17									; ^
.def SECOND_VALUE = R18									; ^
.def BIT_MODIFIER = R19									; ^
.def BIT_COUNTER = R20									; ^
.def CHANGE_TO = R21									; ^
.def CALC_STAGE = R22									; ^
.def ML_OUTER = R23										; ^ ML = MAIN_LOOP
.def ML_MIDER = R24										; ^
.def ML_INNER = R25										; ^
.def D_OUTER = R26										; ^ D = DEBOUNCE
.def D_MIDER = R27										; ^
.def D_INNER = R28										; ^

.equ MLO_DELAY = 21										; MLO = MAIN_LOOP_OUTER, Define the delay values so they can be easily changed
.equ MLM_DELAY = 75										; MLM = MAIN_LOOP_MIDER (not exactly a word but it fits nicely length wise)
.equ MLI_DELAY = 191									; MLI = MAIN_LOOP_INNER

.equ DO_DELAY = 2										; DO = DEBOUNCE_OUTER
.equ DM_DELAY = 160										; DM = DEBOUNCE_MIDER
.equ DI_DELAY = 147										; DI = DEBOUNCE_INNER

.equ STOB_ON = 0b11110001								; STOB = SET_TO_ONE_BUTTON     		| Define the values for which the specific button is on, if you add more buttons the number of zeroes increases,
.equ STZB_ON = 0b11110010								; STZB = SET_TO_ZERO_BUTTON    		| ie. adding the 4th button would make the first value 0b11110001, second value 0b11110010 etc.
.equ OPPB_ON = 0b11110100								; OPPB = OPERATION_PLUS_BUTTON 		|
.equ OPSB_ON = 0b11111000								; OPPB = OPERATION_SUBSTRACT_BUTTON | idk if it should be 0b11111000 or 0b11111101

SETUP:													; This section is used for the calculator setup
	LDI		TEMP,  0xFF									; Load the hex value 0xFF into the TEMP registry
	OUT		DDRA,  TEMP									; Set Port A's bits to output
	OUT		DDRF,  TEMP									; Set Port F's bits to output
	LDI		TEMP,  0x00									; Load the hex value 0x00 into the TEMP registry
	OUT		DDRC,  TEMP									; Set Port C's bits to input

	LDI		TEMP,  0xFF									; Load the hex value 0xFF into the TEMP registry
	OUT		PORTC, TEMP									; Enable pull-up resistors on Port C

	LDI		FIRST_VALUE,  0x00							; Load the hex value 0x00 into the FIRST_VALUE registry
	LDI		SECOND_VALUE, 0x00							; Load the hex value 0x00 into the SECOND_VALUE registry
	LDI		BIT_MODIFIER, (1<<pa0)						; Load the binary value 0b00000001 into the BIT_MODIFIER registry
	LDI		BIT_COUNTER,  0x00							; Load the hex value 0x00 into the BIT_COUNTER registry
	LDI		CHANGE_TO,	  0x00							; Load the hex value 0x00 into the CHANGE_TO registry
	LDI		CALC_STAGE,   0x00							; Load the hex value 0x00 into the CALC_STAGE registry

MAIN_LOOP:												; The main loop of the calculator running at 250ms + overhead, here we display values, blink the LED to indicate value to be set and detect buttons
	CPI		CALC_STAGE, 0x03							; Compare CALC_STAGE and the hex value 0x03
	BREQ	MAIN_LOOP_DELAY_SETUP						; If the above values are equal it means both values needed for the calculations are set and we can skip to the loop delay part
	CPI		CALC_STAGE, 0x00							; Compare CALC_STAGE and the hex value 0x00
	BRNE	MAIN_LOOP_SV								; If the above values are not equal the first calculation value is set and we can skip to entering the second one

	MAIN_LOOP_FV:										; The section in the main loop which deals with blinking the LED the user has to set for the first value
		MOV		FIRST_VALUE, CHANGE_TO					; Copy the CHANGE_TO register into the FIRST_VALUE register, the CHANGE_TO register is used to set the currently selected bit so it can be re-used for every value
		EOR		CHANGE_TO,	 BIT_MODIFIER				; Use EOR which is XOR to toggle the bit selected by BIT_MODIFIER, this causes the LED to blink and tell the user he is setting the value of that LED,
		EOR		FIRST_VALUE, BIT_MODIFIER				; we have to toggle both the CHANGE_TO and FIRST_VALUE because otherwise it will get copied and toggled to the same value in each loop cycle
		OUT		PORTA,		 FIRST_VALUE				; Output the FIRST_VALUE to Port A, for each bit that is set to one a LED will light up

	CPI		CALC_STAGE, 0x00							; Compare CALC_STAGE and the hex value 0x00
	BREQ	MAIN_LOOP_DELAY_SETUP						; If the above values are equal it means that the first value is still being set therefore we can skip to the loop delay part

	MAIN_LOOP_SV:										; The section in the main loop which deals with blinking the LED the user has to set for the second value
		CPI		CALC_STAGE, 0x01						; Compare CALC_STAGE and the hex value 0x01
		BRNE	SKIP_RESET_CT							; If the above values are not equal that means CALC_STAGE is 0x02 and we already reset CHANGE_TO
		LDI		CHANGE_TO,  0x00						; Reset the CHANGE_TO register (this process has to be done here because it's needed until the last moment for the previous value)
		INC		CALC_STAGE								; Increment CALC_STAGE to 0x02
	SKIP_RESET_CT:										; Used to skip CHANGE_TO reset
		MOV		SECOND_VALUE, CHANGE_TO					; Copy the CHANGE_TO register into the SECOND_VALUE register, the CHANGE_TO register is used to set the currently selected bit so it can be re-used for every value
		EOR		CHANGE_TO,	  BIT_MODIFIER				; Use EOR which is XOR to toggle the bit selected by BIT_MODIFIER, this causes the LED to blink and tell the user he is setting the value of that LED,
		EOR		SECOND_VALUE, BIT_MODIFIER				; we have to toggle both the CHANGE_TO and SECOND_VALUE because otherwise it will get copied and toggled to the same value in each loop cycle
		OUT		PORTF,		  SECOND_VALUE				; Output the FIRST_VALUE to Port F, for each bit that is set to one a LED will light up
		

	MAIN_LOOP_DELAY_SETUP:								; The section used to setup the 250ms delay of the MAIN_LOOP
		LDI		ML_OUTER, MLO_DELAY						; Load the MAIN_LOOP_OUTER_DELAY value into MAIN_LOOP_OUTER
		LDI		ML_MIDER, MLM_DELAY						; Load the MAIN_LOOP_MIDER_DELAY value into MAIN_LOOP_MIDER
		LDI		ML_INNER, MLI_DELAY						; Load the MAIN_LOOP_INNER_DELAY value into MAIN_LOOP_INNER

	MAIN_LOOP_DELAY:									; The section delaying the MAIN_LOOP 250ms
		SET_TO_ONE_BUTTON:								; The handler that detects if the SET_TO_ONE button has been pressed
			IN		TEMP, PINC							; Read the value from Port C and put it into TEMP
			CPI		TEMP, STOB_ON						; Compare TEMP and SET_TO_ONE_BUTTON_ON
			BRNE	STO_CONTINUE						; If the above values are not equal that means the button is not pressed and we can skip the call to its operation
			CALL	SET_TO_ONE							; Call the SET_TO_ONE subroutine
		STO_CONTINUE:									; Used to skip the call
			
		SET_TO_ZERO_BUTTON:								; The handler that detects if the SET_TO_ZERO button has been pressed
			IN		TEMP, PINC							; Read the value from Port C and put it into TEMP
			CPI		TEMP, STZB_ON						; Compare TEMP and SET_TO_ZERO_BUTTON_ON
			BRNE	STZ_CONTINUE						; If the above values are not equal that means the button is not pressed and we can skip the call to its operation
			CALL	SET_TO_ZERO							; Call the SET_TO_ZERO subroutine
		STZ_CONTINUE:									; Used to skip the call

		OP_PLUS_BUTTON:									; The handler that detects if the OPERATION_PLUS_BUTTON has been pressed
			IN		TEMP, PINC							; Read the value from Port C and put it into TEMP
			CPI		TEMP, OPPB_ON						; Compare TEMP and OPERATION_PLUS_BUTTON_ON
			BRNE	OPP_CONTINUE						; If the above values are not equal that means the button is not pressed and we can skip the call to its operation
			CALL	OP_PLUS								; Call the OPERATION_PLUS subroutine
		OPP_CONTINUE:									; Used to skip the call
		
		
		OP_SUBSTRACT_BUTTON:							; The handler that detects if the OPERATION_SUBSTRACT_BUTTON has been pressed
			IN		TEMP, PINC							; Read the value from Port C and put it into TEMP
			CPI		TEMP, OPSB_ON						; Compare TEMP and OPERATION_PLUS_BUTTON_ON
			BRNE	OPS_CONTINUE						; If the above values are not equal that means the button is not pressed and we can skip the call to its operation
			CALL	OP_SUB								; Call the OPERATION_SUBSTRACT subroutine
		OPS_CONTINUE:

	CONTINUE_MAIN_LOOP_DELAY:							; Used to continue the main loop delay after one of the setter buttons has been pressed
		DEC		ML_INNER								; Decrement the inner loop value
		BRNE	MAIN_LOOP_DELAY							; ^
		DEC		ML_MIDER								; ^
		BRNE	MAIN_LOOP_DELAY							; ^
		DEC		ML_OUTER								; ^
		BRNE	MAIN_LOOP_DELAY							; ^
		NOP												; Extra cycle needed to make it 250ms, does nothing
	
	RJMP	MAIN_LOOP									; Go back to the start of the MAIN_LOOP after the delay is finished


SET_TO_ONE:												; The subroutine that deals with the instructions the SET_TO_ONE button has to execute
	CALL	DEBOUNCE									; Call DEBOUNCE (just another 20ms delay) in order to stabilize the input we get from the button, otherwise you get inconsistent behaviour
	IN		TEMP, PINC									; Read the value from Port C and put it into TEMP
	CPI		TEMP, STOB_ON								; Compare TEMP and SET_TO_ONE_BUTTON_ON
	BREQ	SET_TO_ONE									; If the above values are equal that means the button is still being pressed, we want the functionality to be executed ONCE on release so we keep looping

	CPI		BIT_COUNTER, 0								; Compare BIT_COUNTER with the decimal value 0, this means that we are working on the first bit of a value
	BRNE	SKIP_SET_FB									; If the above values are not equal that means we are not working on the first bit and can continue checking the next bits
	CALL	SET_FIRST_BIT								; Call the SET_FIRST_BIT subroutine
SKIP_SET_FB:											; Use to skip the call, FB = FIRST_BIT
	CPI		BIT_COUNTER, 1								; ^
	BRNE	SKIP_SET_SB									; ^
	CALL	SET_SECOND_BIT								; ^
SKIP_SET_SB:											; ^ SB = SECOND_BIT
	CPI		BIT_COUNTER, 2								; ^
	BRNE	SKIP_SET_TB									; ^
	CALL	SET_THIRD_BIT								; ^
SKIP_SET_TB:											; ^ TB = THIRD_BIT
	CPI		BIT_COUNTER, 3								; ^
	BRNE	SKIP_SET_FOB								; ^
	CALL	SET_FOURTH_BIT								; ^
SKIP_SET_FOB:											; ^ FOB = FOURTH_BIT
	CPI		BIT_COUNTER, 4								; ^
	BRNE	SKIP_SET_FIB								; ^
	CALL	SET_FIFTH_BIT								; ^
SKIP_SET_FIB:											; ^ FIB = FIFTH_BIT
	CPI		BIT_COUNTER, 5								; ^
	BRNE	SKIP_SET_SIB								; ^
	CALL	SET_SIXTH_BIT								; ^
SKIP_SET_SIB:											; ^ SIB = SIXTH_BIT
	CPI		BIT_COUNTER, 6								; ^
	BRNE	SKIP_SET_SEB								; ^
	CALL	SET_SEVENTH_BIT								; ^
SKIP_SET_SEB:											; ^ SEB = SEVENTH_BIT
	CPI		BIT_COUNTER, 7								; ^
	BRNE	SKIP_SET_EB									; ^
	CALL	SET_EIGHTH_BIT								; ^

	FINAL_UPDATE_FV:									; FV = FIRST_VALUE, This section deals with setting the final bit of the first value, has to be done here because the loop goes on to the second value
		CPI		CALC_STAGE,   0x01						; Compare CALC_STAGE and the hex value 0x01
		BRNE	FINAL_UPDATE_SV							; If the values above are not equal that means we are not dealing with the first value and can skip setting it
		MOV		FIRST_VALUE,  CHANGE_TO					; Copy the CHANGE_TO register into the FIRST_VALUE register
		OUT		PORTA,		  FIRST_VALUE				; Output the FIRST_VALUE to Port A, this and the previous line work the same as in the MAIN_LOOP
	FINAL_UPDATE_SV:									; ^ SV = SECOND_VALUE
		CPI		CALC_STAGE,   0x03						; ^
		BRNE	NO_UPDATE_REQ							; ^
		MOV		SECOND_VALUE, CHANGE_TO					; ^
		OUT		PORTF,		  SECOND_VALUE				; ^
	NO_UPDATE_REQ:										; Used to skip updating the final values if it's not the time to do it
		RET												; Return from the subroutine earlier than usual because we don't want it to execute the operations below and break the next value
SKIP_SET_EB:											; EB = EIGHTH_BIT
	INC		BIT_COUNTER									; Increment the BIT_COUNTER
	LSL		BIT_MODIFIER								; Left shift the BIT_MODIFIER value which means 0b00000001 -> 0b00000010 so it will be operating on a different bit in the EORs
	RET													; Return from the subroutine
	
SET_TO_ZERO:											; The subroutine that deals with the instructions the SET_TO_ZERO button has to execute, the same as SET_TO_ONE but with different operations
	CALL	DEBOUNCE									; ^
	IN		TEMP, PINC									; ^
	CPI		TEMP, STZB_ON								; ^
	BREQ	SET_TO_ZERO									; ^
														; ^
	CPI		BIT_COUNTER, 0								; ^
	BRNE	SKIP_SET_FBZ								; ^
	CALL	SET_FIRST_BITZ								; ^
SKIP_SET_FBZ:											; ^
	CPI		BIT_COUNTER, 1								; ^
	BRNE	SKIP_SET_SBZ								; ^
	CALL	SET_SECOND_BITZ								; ^
SKIP_SET_SBZ:											; ^
	CPI		BIT_COUNTER, 2								; ^
	BRNE	SKIP_SET_TBZ								; ^
	CALL	SET_THIRD_BITZ								; ^
SKIP_SET_TBZ:											; ^
	CPI		BIT_COUNTER, 3								; ^
	BRNE	SKIP_SET_FOBZ								; ^
	CALL	SET_FOURTH_BITZ								; ^
SKIP_SET_FOBZ:											; ^
	CPI		BIT_COUNTER, 4								; ^
	BRNE	SKIP_SET_FIBZ								; ^
	CALL	SET_FIFTH_BITZ								; ^
SKIP_SET_FIBZ:											; ^
	CPI		BIT_COUNTER, 5								; ^
	BRNE	SKIP_SET_SIBZ								; ^
	CALL	SET_SIXTH_BITZ								; ^
SKIP_SET_SIBZ:											; ^
	CPI		BIT_COUNTER, 6								; ^
	BRNE	SKIP_SET_SEBZ								; ^
	CALL	SET_SEVENTH_BITZ							; ^
SKIP_SET_SEBZ:											; ^
	CPI		BIT_COUNTER, 7								; ^
	BRNE	SKIP_SET_EBZ								; ^
	CALL	SET_EIGHTH_BITZ								; ^
														; ^
	FINAL_UPDATE_FVZ:									; ^
		CPI		CALC_STAGE,   0x01						; ^
		BRNE	FINAL_UPDATE_SVZ						; ^
		MOV		FIRST_VALUE,  CHANGE_TO					; ^
		OUT		PORTA,		  FIRST_VALUE				; ^
	FINAL_UPDATE_SVZ:									; ^
		CPI		CALC_STAGE,   0x03						; ^
		BRNE	NO_UPDATE_REQZ							; ^
		MOV		SECOND_VALUE, CHANGE_TO					; ^
		OUT		PORTF,		  SECOND_VALUE				; ^
	NO_UPDATE_REQZ:										; ^
		RET												; ^
SKIP_SET_EBZ:											; ^
	INC		BIT_COUNTER									; ^
	LSL		BIT_MODIFIER								; ^
	RET													; ^

SET_FIRST_BIT:											; The subroutine that deals with setting the first bit to one
	SBRS	CHANGE_TO, 0								; Check if the CHANGE_TO's first bit is set to one, if it is skip the next operation
	EOR		CHANGE_TO, BIT_MODIFIER						; If the CHANGE_TO's first bit is zero, toggle it to one
	RET													; Return from the subroutine
SET_SECOND_BIT:											; ^
	SBRS	CHANGE_TO, 1								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_THIRD_BIT:											; ^
	SBRS	CHANGE_TO, 2								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_FOURTH_BIT:											; ^
	SBRS	CHANGE_TO, 3								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_FIFTH_BIT:											; ^
	SBRS	CHANGE_TO, 4								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_SIXTH_BIT:											; ^
	SBRS	CHANGE_TO, 5								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_SEVENTH_BIT:										; ^
	SBRS	CHANGE_TO, 6								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_EIGHTH_BIT:											; ^
	SBRS	CHANGE_TO, 7								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
														; Since we are setting the final BIT we do the following operations
	INC		CALC_STAGE									; Increment CALC_STAGE
	LDI		BIT_COUNTER,  0x00							; Reset BIT_COUNTER
	LDI		BIT_MODIFIER, (1<<pa0)						; Rset BIT_MODIFIER back to the first bit, 0b00000001
	RET													; Return from the subroutine


SET_FIRST_BITZ:											; ^
	SBRC	CHANGE_TO, 0								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_SECOND_BITZ:										; ^
	SBRC	CHANGE_TO, 1								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_THIRD_BITZ:											; ^
	SBRC	CHANGE_TO, 2								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_FOURTH_BITZ:										; ^
	SBRC	CHANGE_TO, 3								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_FIFTH_BITZ:											; ^
	SBRC	CHANGE_TO, 4								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_SIXTH_BITZ:											; ^
	SBRC	CHANGE_TO, 5								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_SEVENTH_BITZ:										; ^
	SBRC	CHANGE_TO, 6								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
	RET													; ^
SET_EIGHTH_BITZ:										; ^
	SBRC	CHANGE_TO, 7								; ^
	EOR		CHANGE_TO, BIT_MODIFIER						; ^
														; ^
	INC		CALC_STAGE									; ^
	LDI		BIT_COUNTER,  0x00							; ^
	LDI		BIT_MODIFIER, (1<<pa0)						; ^
	RET													; ^


OP_PLUS:												; The subroutine that deals with the addition operation, we use the FIRST_VALUE to display the result
	CALL	DEBOUNCE									; Call DEBOUNCE (just another 20ms delay) in order to stabilize the input we get from the button, otherwise you get inconsistent behaviour
	IN		TEMP,		 PINC							; Read the value from Port C and put it into TEMP
	CPI		TEMP,		 OPPB_ON						; Compare TEMP and OPERATION_PLUS_BUTTON_ON
	BREQ	OP_PLUS										; If the above values are equal that means the button is still being pressed, we want the functionality to be executed ONCE on release so we keep looping

	LDI		TEMP,		 0x00							; Load the hex value 0x00 into the TEMP registry
	OUT		PORTF,		 TEMP							; Output TEMP to Port A, turn off all LEDs

	ADD		FIRST_VALUE, SECOND_VALUE					; Add the FIRST_VALUE and the SECOND_VALUE, store the result into FIRST_VALUE
	OUT		PORTA,		 FIRST_VALUE					; Output the result from the FIRST_VALUE
	BRCC	NO_CARRY									; Check if the carry flag is on, if it is not skip setting the carry
	LDI		SECOND_VALUE, (1<<pa0)						; Load the binary value 0b00000001 into the SECOND_VALUE registry
	OUT		PORTF,		  SECOND_VALUE					; Output the carry from the SECOND_VALUE
NO_CARRY:												; Used to skip setting the carry

	RET													; Return from the subroutine

	
OP_SUB:													; The subroutine that deals with the substraction operation, we use the FIRST_VALUE to display the result
	CALL	DEBOUNCE									; Call DEBOUNCE (just another 20ms delay) in order to stabilize the input we get from the button, otherwise you get inconsistent behaviour
	IN		TEMP,		 PINC							; Read the value from Port C and put it into TEMP
	CPI		TEMP,		 OPSB_ON						; Compare TEMP and OPERATION_SUBSTRACT_BUTTON_ON
	BREQ	OP_SUB										; If the above values are equal that means the button is still being pressed, we want the functionality to be executed ONCE on release so we keep looping

	LDI		TEMP,		 0x00							; Load the hex value 0x00 into the TEMP registry
	OUT		PORTF,		 TEMP							; Output TEMP to Port A, turn off all LEDs

	SUB		FIRST_VALUE, SECOND_VALUE					; Substract the SECOND_VALUE to the FIRST_VALUE, store the result into FIRST_VALUE
	OUT		PORTA,		 FIRST_VALUE					; Output the result from the FIRST_VALUE
	BRCC	NO_CARRY_S									; Check if the carry flag is on, if it is not skip setting the carry
	LDI		SECOND_VALUE, (1<<pa0)						; Load the binary value 0b00000001 into the SECOND_VALUE registry
	OUT		PORTF,		  SECOND_VALUE					; Output the carry from the SECOND_VALUE
NO_CARRY_S:												; Used to skip setting the carry

	RET													; Return from the subroutine

	

DEBOUNCE:												; The subroutine that provides the 20ms delay used to debounce (stabilize) button read, works the same as main loop delay
	DEBOUNCE_DELAY_SETUP:								; ^
		LDI		D_OUTER, DO_DELAY						; ^
		LDI		D_MIDER, DM_DELAY						; ^
		LDI		D_INNER, DI_DELAY						; ^
	DEBOUNCE_DELAY:										; ^
		DEC		D_INNER									; ^
		BRNE	DEBOUNCE_DELAY							; ^
		DEC		D_MIDER									; ^
		BRNE	DEBOUNCE_DELAY							; ^
		DEC		D_OUTER									; ^
		BRNE	DEBOUNCE_DELAY							; ^
		NOP												; ^
		RET												; ^