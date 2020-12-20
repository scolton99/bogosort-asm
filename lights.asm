			.cdecls C,LIST,"msp430.h"       ; Include device header file
			.text
			.global LED0_ON,LED1_ON,LED0_OFF,LED1_OFF,LED0_TOGGLE,LED1_TOGGLE

			;; LED0_ON: turn on LED 0
			;;
			;; Arguments: none
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
LED0_ON		bis.b	#BIT0,&P1OUT
			ret
			.endasmfunc


			;; LED1_ON: turn on LED 1
			;;
			;; Arguments: none
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
LED1_ON		bis.b	#BIT1,&P1OUT
			ret
			.endasmfunc


			;; LED0_OFF: turn off LED 0
			;;
			;; Arguments: none
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
LED0_OFF	bic.b	#BIT0,&P1OUT
			ret
			.endasmfunc


			;; LED1_OFF: turn off LED 1
			;;
			;; Arguments: none
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
LED1_OFF	bic.b	#BIT1,&P1OUT
			ret
			.endasmfunc


			;; LED0_TOGGLE: toggle LED 0
			;;
			;; Arguments: none
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
LED0_TOGGLE	cmp.b	#~BIT0,&P1OUT
			jz		LED0T_ON
			call	#LED0_OFF
			jmp 	LED0T_DONE
LED0T_ON	call	#LED0_ON
LED0T_DONE	ret
			.endasmfunc


			;; LED1_TOGGLE: toggle LED 1
			;;
			;; Arguments: none
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
LED1_TOGGLE	cmp.b	#~BIT1,&P1OUT
			jz		LED1T_ON
			call	#LED1_OFF
			jmp 	LED1T_DONE
LED1T_ON	call	#LED1_ON
LED1T_DONE	ret
			.endasmfunc
