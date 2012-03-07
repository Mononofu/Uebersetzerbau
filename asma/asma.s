	.file	"asma.c"
	.text
	.globl	asma
	.type	asma, @function
asma:
.LFB0:
	.cfi_startproc
	rcrq $1, 8(%rdi)
	rcrq $1, (%rdi)
	ret
	.cfi_endproc
.LFE0:
	.size	asma, .-asma
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
