			.text
			.global RAND_RANGE
			.global SHUFFLE

			;; SHUFFLE: shuffle a list of WORDs
			;; TODO: inefficiency[loop runs at counter=length - 1 (no swapping can occur)]
			;;
			;; Arguments: r5 - ptr to first list element, r6 - length
			;; Uses: none
			;;
			;; Internal: r5 - counter, r7 - ptr to first list element, r8 - tmp val sto, r9 - tmp ptr1, r10 - tmp ptr2
			.asmfunc
SHUFFLE		push.w	r5
			push.w	r6
			push.w	r7
			push.w	r8
			push.w	r9
			push.w	r10

			mov.w	r5,r7			; Copy pointer to r7
			mov.w	r7,r9			; Copy pointer to r9
			xor.w	r5,r5			; counter = 0

			jmp 	SH_O_CHK

SH_O_ST		call	#RAND_RANGE		; r4 = rand in [counter, length)

			cmp.w	r4,r5			; if counter == random number,
			jz		SH_O_ND			; "continue" (no swapping occurs)

			mov.w	r7,r10
			rla.w	r4				; r4 *= 2 (word addressing)
			add.w	r4,r10			; r10 = arr + rand

			mov.w	0(r9),r8		; tmp = arr[counter]
			mov.w	0(r10),0(r9)	; arr[counter] = arr[rand]
			mov.w	r8,0(r10)		; arr[rand] = tmp

SH_O_ND		inc.w	r5				; inc counter
			incd.w	r9				; inc ptr by two bytes (word array)

			; Check if our counter >= the array length
			; If not, keep going
SH_O_CHK	cmp.w	r6,r5
			jl		SH_O_ST

			pop.w	r10
			pop.w	r9
			pop.w	r8
			pop.w	r7
			pop.w 	r6
			pop.w 	r5
			ret
			.endasmfunc
