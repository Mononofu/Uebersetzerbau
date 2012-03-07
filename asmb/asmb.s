	.file	"asmb.c"
	.text
	.globl	asmb
	.type	asmb, @function
asmb:
.LFB0:
	.cfi_startproc
	mov %rsi, %rcx		# start our counter with length of array
start:
	cmp $0, %rcx
	je end
	dec %rcx
	rcrq $1, (%rdi, %rcx, 8)
	jmp start
end:
	ret
	.cfi_endproc
.LFE0:
	.size	asmb, .-asmb
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
