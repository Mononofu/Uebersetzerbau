	.file	"asmb.c"
	.text
	.globl	asmb
	.type	asmb, @function
asmb:
.LFB0:
	.cfi_startproc
	mov %rsi, %rcx		# start our counter with length of array
	cmp $0, %rcx			# compare once so zero flag 
start:
	jz end 						# if %rcx is 0, we have reached the end of the array
	dec %rcx					# this will set the zero flag, so no compare
	rcrq $1, (%rdi, %rcx, 8)	# shift the long at post %rcx to the right
	jmp start
end:
	ret
	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
