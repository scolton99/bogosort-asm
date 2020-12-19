;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
			.include "src/random.asm"

          	.data
ARR_LEN		.byte	9
ARR			.word	9, 7, 8, 5, 4, 6, 2, 1, 3
TEMP		.word	0, 0, 0, 0, 0, 0, 0, 0, 0

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
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
			bis.w	#SELA__VLOCLK|SELS__DCOCLK,&CSCTL2	; ACLK = VLO, SMCLK = DCO
			and.w 	#~MC__STOP,&TA2CTL		; Turn off Timer A2
			bis.w 	#TASSEL__SMCLK,&TA2CTL	; Timer A2 Clock = SMCLK (DCO)
			bis.w	#CM0|CCIS__CCIB|CAP|CCIE|SCS,&TA2CCTL0
			bis.w	#MC__CONTINUOUS,&TA2CTL


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
			jmp		CHK
RUN			call 	RANDOMIZE
CHK			call	CHK_SORT
			jz		RUN
			jmp		AEND


RANDOMIZE	push 	r5
			push	r6



			pop		r6
			pop		r5
			ret


CHK_SORT	push 	r5
			push 	r6
			xor.w	r5,r5
			mov.b	&ARR_LEN,r5
			dec.b	r5
			mov.w	ARR,r6
			jmp		CSC
CSL			cmp.w	0(r6),2(r6)
			jl		CSNS
			add.w	#2,r6
			dec.b	r5
CSC			cmp.b	#0,r5
			jl		CSL
			jmp		CSS
CSNS		setz
			jmp		CSE
CSS			clrz
CSE			pop 	r6
			pop 	r5
			ret

AEND		nop

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
            .sect 	TIMER2_A0_VECTOR
			.short 	RAND_UPD
            


