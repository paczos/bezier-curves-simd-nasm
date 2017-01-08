;ECOAR intel x64 project. Bezier curves of order 4.
;
; Author:      Pawel Paczuski
; Description: Function receives pointer to reserved image memory and 4 control points draws Bezier curve that interpolates between the points.
;			   Params: float* pointsX, float* pointsY, unsigned char* pixelArray, width, height 
;              int func(char *a);
; AMD x64 ABI
;=====================================================================


section .data
	step_start: dq 0.0
	step_end: dq 1.0
	step: dq 0.5
	u: dd 0, 0, 0, 0 ; aligned
	u1: dd 0, 0, 0, 0	;aligned

section .bss
	inter_iter: resw 1
	sires: resw 1

section	.text
global func 

func:
	push	rbp
	mov	rbp, rsp
	;ABI calling convention:
	;r8 height
	;rcx width
	;rdx pixArray
	;rsi pointsY
	;rdi pointsX
	;xmm0 pointsX
	;xmm1 pointsY
	mov eax, 0


	fld qword [inter_iter]	;load inter_iter to st0
interpolate:
	fld qword [step_end]	; load step_end to st0, inter_iter in st1
	fcomp			;compare inter_iter st1  with step_end s0 and pop step_end
	jl end_interpolate	;end of interpolation

	;add eax, 1 ;loop test
	movaps xmm0, [rdi] ;load points x and y to the xmms
	movaps xmm1, [rsi]
store_iter:
	fstp qword [inter_iter]	;store progress from fpu to mem
	

	;load inter_iter as u to xmm2
	;ebx -> u
	mov ebx, [inter_iter]
	mov dword [u], ebx
	mov dword [u+4], ebx
	mov dword [u+8], ebx
	mov dword [u+12], ebx
	movups xmm2, [u]
	
	
	;fpu should be empty here
load:	
	fld qword [step_end];push 1.0 to the fpu
	fld qword [inter_iter];push iter to the fpu

	fsubp st1, st0
	fstp qword [sires];store at sires 1-u
	
loast:
	
	fld qword[inter_iter] ;reload interiter to fpu ;this shit corrupts mem
	
	mov ebx, [sires]
	; mov eax, ebx
	;prepare u1
	mov dword [u1], ebx
	mov dword [u1+4], ebx
	mov dword [u1+8], ebx
	mov dword [u1+12], ebx
	movups xmm3, [u1]


;ebx -> loop counter
;eax -> points num
	mov ebx, 1
	mov eax, 4 ;everything is calculated for 4 points
castelj:
	cmp ebx, eax
	jg end_castelj

	;we have the data, hardcore sse calcs go here
	movdqa xmm4, xmm0;copy contents of xmm0 to xmm4 for later
	mulps xmm0, xmm2 ;x1*u
	cvtps2dq xmm0, xmm0
	psrldq xmm0, 4;srli_si128
	cvtdq2ps xmm0, xmm0;_mm_cvtepi32_ps
	mulps xmm4, xmm3
	addps xmm0, xmm4
	
	;do the same for ys

	movdqa xmm4, xmm1
	mulps xmm1, xmm2 ;x1*u
	cvtps2dq xmm1, xmm1
	psrldq xmm1, 4;srli_si128
	cvtdq2ps xmm1, xmm1;_mm_cvtepi32_ps
	mulps xmm4, xmm3
	addps xmm1, xmm4

	add ebx, 1
	jmp castelj
end_castelj:

	mov rax, 0 ;reset eax after loop
	;extract x,y and store value in pixarray
	cvtps2dq xmm0, xmm0
	cvtps2dq xmm1, xmm1

	;movdqa [u], xmm0 ;x goes to u
	;movdqa [u1], xmm1;y goest to u1

	pextrw rax, xmm0, 0 ;x
	pextrw rbx, xmm1, 0 ;y

	mov qword[u+4], rdi
	mov rdi, 3
	imul rbx, rdi
	mov rdi, qword[u+4]
	imul rbx, rcx
	add rbx, rax
	add rbx, rdx
;	mov qword[rbx], 250;seg fault

	;pextrw rax, xmm0, 0

	;ddmo eax, dword [u]
	;store results in pixarray


finaladd:
	fld qword [step]
	faddp st1, st0;increase inter_iter
	jmp interpolate
end_interpolate:

	

	 
	mov eax, [step_end]





;mov	eax, 666		;return 0
	mov rsp, rbp
	pop	rbp
	ret



