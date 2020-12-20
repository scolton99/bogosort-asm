			.cdecls C,LIST,"msp430.h"       ; Include device header file
			.global MOD,RAND_RANGE
			.data
CRAND		.word	0
TRAND		.word	0
UPDTICK		.byte	0
			.byte 	0

			.text

			;; MOD: take a % b
			;;
			;; Arguments: r5 - a, r6 - b
			;; Uses: r4 (return value)
			;;
			;; Internal: r5 - "a"
MOD			push.w	r5

			jmp		MODCHK
MODST		sub.w	r6,r5		; a -= b
MODCHK		cmp.w	r6,r5		; a <? b
			jge		MODST		; if not, keep going

			mov.w	r5,r4
			pop.w	r5
			ret


RAND_RANGE	;; RAND_RANGE: get a random number in a range [a, b)
			;;
			;; Arguments: r5 - a, r6 - b
			;; Uses: r4 - return value
			;;
			;; Internal: r6 - (b - a), r7 - tmp random
			.asmfunc
			push.w	r5
			push.w	r6
			push.w	r7

			call	#GEN_RAND	; r4 is now a random number
			sub.w	r5,r6		; r6 = b - a

			mov.w	r5,r7		; r5 = random number, r7 = a
			mov.w	r4,r5
			call	#MOD

			add.w	r7,r4		; Add "a" back on

			pop.w	r7
			pop.w	r6
			pop.w	r5
			ret
			.endasmfunc


			;; GEN_RAND: retrieve a new random number
			;;
			;; Arguments: none
			;; Uses: r4 (return value)
			;;
			;; Internal:
			.asmfunc
GEN_RAND	cmp.w 	#0,&CRAND		; If we don't have a random value generated yet,
			jnz		GEN_RDY			; wait until one has been.
			bis.w	#CCIE,&TA2CCTL0	; Enable interrupts on timer
GEN_CMP		cmp.w	#0,&CRAND		; Check again
			jz		GEN_CMP			; Repeat until we have a number
GEN_RDY		mov.w	&CRAND,r4
			mov.w	#0,&CRAND		; Clear CRAND so that it will start generating again
			bis.w	#CCIE,&TA2CCTL0	; Re-enable timer interupts
			ret
			.endasmfunc


			;; (isr) RAND_UPD: append a digit to the random number
			;; https://www.ti.com/lit/an/slaa338a/slaa338a.pdf
			;;
			;; Arguments: none
			;; Uses: none
			;;
			;; Internal: r4 = temporary random number, r5 = timer value
			.asmfunc
RAND_UPD	push.w 	r4
			push.w 	r5

			cmp.w	#0,&CRAND			; If we currently have an unused random value, don't do anything
			jnz		RAND_UPDND

			mov.w  	&TRAND,r4			; Load temporary random value
			mov.w 	&TA2CCR0,r5			; Load current timer value

			and.w 	#1,r5				; Eliminate all of the timer value except LSB
			rla.w 	r4					; Shift temporary random left 1
			bis.w 	r5,r4				; Append timer LSB to temporary random
			mov.w	r4,&TRAND

			inc.b 	&UPDTICK
			cmp.b 	#16,&UPDTICK		; If we haven't yet done this 16 times, quit now
			jnz 	RAND_UPDND

			xor.b	&UPDTICK,&UPDTICK	; Otherwise, clear counter and update the random value
			mov.w	&TRAND,&CRAND
			bic.w	#0x8000,&CRAND		; Make number positive
			bic.w	#CCIE,&TA2CCTL0		; Disable timer interrupts

RAND_UPDND	pop.w 	r5
			pop.w 	r4
			reti
			.endasmfunc

            .sect 	TIMER2_A0_VECTOR
			.short 	RAND_UPD
