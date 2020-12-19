            .cdecls C,LIST,"msp430.h"       ; Include device header file
			.data
CRAND		.word	0
TRAND		.word	0
UPDTICK		.byte	0
			.byte 	0


RAND_UPD	push.w 	r5
			push.w 	r6

			mov.w 	&TRAND,r5
			mov.w 	&TA2CCR0,r6
			bis.w 	#1,r6
			rla.w 	r5
			bis.w 	r6,r5
			mov.w 	r5,&TRAND
			inc.b 	&UPDTICK
			cmp.b 	#16,&UPDTICK
			jnz 	END_RU

PNR			mov.w	&TRAND,&CRAND
			xor.b	&UPDTICK,&UPDTICK

END_RU		pop.w 	r6
			pop.w 	r5
			reti


