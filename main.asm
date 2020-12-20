;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
			.global MOD,SHUFFLE,RAND_UPD,LED1_ON,LED0_ON,LED1_OFF,LED0_OFF
          	.data
ARR_LEN		.byte	5
ARR			.word	6, 1, 3, 4, 2
ARR_OUT		.word	0, 0, 0, 0, 0

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
;-------------------------------------------------------------------------------

RESET       mov.w   #__STACK_END,SP         				; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  				; Stop watchdog timer

			nop
			eint
			nop

			; =========== Setup Timer A2 =========
			and.w 	#~MC__STOP,&TA2CTL						; Turn off Timer A2
			mov.w	#CSKEY,&CSCTL0
			bis.w	#SELA__VLOCLK|SELS__DCOCLK,&CSCTL2		; ACLK = VLO, SMCLK = DCO
			bis.w 	#TASSEL__SMCLK,&TA2CTL					; Timer A2 Clock = SMCLK (DCO)

			; Timer A2: capture on low-high, use CCI2B as input,
			; capture mode on, synchronous capture
			bis.w	#CM__RISING|CCIS__CCIB|CAP|CCIE|SCS,&TA2CCTL0

			; Timer A2: continuous mode
			bis.w	#MC__CONTINUOUS,&TA2CTL
			; =========== End Setup Timer A2 =========

			and.w 	#~LOCKLPM5,&PM5CTL0						; Turn off high-impedance mode
			mov.w	#0,&P1OUT
			mov.w	#BIT1|BIT0,&P1DIR						; Setup LED output

			; Array setup
			mov.w 	#6,&ARR
			mov.w	#1,&ARR+2
			mov.w	#3,&ARR+4
			mov.w	#4,&ARR+6
			mov.w	#2,&ARR+8
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
			mov.w	&ARR_LEN,r5
			mov.w	#ARR,r6
			mov.w	#ARR_OUT,r7
			call	#COPY
			mov.w	#ARR_OUT,r5
			mov.w	&ARR_LEN,r6
			jmp		CHK
RUN			call	#LED0_ON
			call 	#SHUFFLE
			call	#LED0_OFF
CHK			call	#LED1_ON		; Turn on LED 1 (indicating chk_sort happening)
			call	#CHK_SORT
			push.w	SR				; Save status register
			call	#LED1_OFF		; Turn off LED 1
			pop.w	SR
			jnz		RUN
			jmp		AEND

			;; CHK_SORT: check if an array is sorted
			;; Returns value using SR(Z)
			;;
			;; Arguments: r5 - ptr to array start, r6 - length
			;; Uses: SR
			;;
			;; Internal: r5 - "ptr", r6 - (length - 1), r7 - counter
			.asmfunc
CHK_SORT	push.w	r5
			push.w	r6
			push.w	r7

			dec.w	r6				; length -= 1

			xor.w	r7,r7			; Zero counter

			jmp		CS_CHK

CS_ST		cmp.w	0(r5),2(r5)		; compare arr[counter + 1] - arr[counter]
			jl		CS_RF			; if arr[counter + 1] < arr[counter], return false

			inc.w	r7				; increment counter and pointer
			incd.w	r5

CS_CHK		cmp.w	r6,r7			; (counter - length) < 0?
			jl		CS_ST			; continue if so
			setz					; otherwise, return true
			jmp		CS_ND
CS_RF		clrz					; Return false

CS_ND		pop.w	r7
			pop.w	r6
			pop.w 	r5
			ret
			.endasmfunc

			;; COPY: copy n WORD values from ptr1 to ptr2
			;;
			;; Arguments: r5 - n, r6 - ptr1, r7 - ptr2
			;; Uses: none
			;;
			;; Internal: none
			.asmfunc
COPY		push.w	r5
			push.w	r6
			push.w	r7

			jmp		COPY_CHK
COPY_ST		mov.w	@r6,0(r7)
			incd.w	r6
			incd.w	r7
			dec.w	r5
COPY_CHK	tst.w	r5
			jnz		COPY_ST

			pop.w	r7
			pop.w	r6
			pop.w	r5
			ret
			.endasmfunc

AEND		nop
			bic.w	#CCIE,&TA2CCTL0
			call	#LED0_ON
			call	#LED1_ON
			jmp 	AEND
			nop

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            


