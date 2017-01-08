;ECOAR intel x64 project. Bezier curves of order 4.
;
; Author:      Pawel Paczuski
; Description: Function receives pointer to reserved image memory and 4 control points draws Bezier curve that interpolates between the points.
;			   Params: float* pointsX, float* pointsY, unsigned char* pixelArray, width, height 
;              int func(char *a);
; AMD x64 ABI
;=====================================================================


section .data
	step_start: dd 0.0
	step_end: dd 1.0
	step: dd 0.01
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
	mov rax, 0
	;curr interiter into xmm5
	;step into xmm6
	;end into xmm7
	movss xmm5, [step_start]
	movss xmm6, [step]
	movss xmm7, [step_end]
	;broadcast  values
	shufps xmm5, xmm5, 0h
	shufps xmm6, xmm6, 0h
	shufps xmm7, xmm7, 0h
	movss xmm8, [step_start];second iter
	movss xmm9, [step_end];for end compare
	movss xmm10, [step];single step
interpolate:

	comiss xmm8, xmm9
after_check:
	ja end_interpolate	;end of interpolation

	;add eax, 1 ;loop test
	movaps xmm0, [rdi] ;load points x and y to the xmms
	movaps xmm1, [rsi]
store_iter:
	fstp qword [inter_iter]	;store progress from fpu to mem
	

	;load inter_iter as u to xmm2
	;xmm5 u
	;calc u1
	
	movss xmm2, [step_end]	;load const 1
	shufps xmm2, xmm2, 0h 	;broadcast const 1
	subps xmm2, xmm5	;xmm2 1-u

	;LEGACY xmmm3 u1, xmm2 u	new xmm5 u, xmm2 u1

	;ebx -> loop counter
	;eax -> points num
	mov ebx, 1
	mov eax, 4 ;everything is calculated for 4 points
castelj:
	cmp ebx, eax
	jg end_castelj

	;we have the data, hardcore sse calcs go here
	movdqa xmm4, xmm0;copy contents of xmm0 to xmm4 for later
	mulps xmm0, xmm5 ;x1*u
	cvtps2dq xmm0, xmm0
	psrldq xmm0, 4;srli_si128
	cvtdq2ps xmm0, xmm0;_mm_cvtepi32_ps
	mulps xmm4, xmm2
	addps xmm0, xmm4
	
	;do the same for ys

	movdqa xmm4, xmm1
	mulps xmm1, xmm5 ;x1*u
	cvtps2dq xmm1, xmm1
	psrldq xmm1, 4;srli_si128
	cvtdq2ps xmm1, xmm1;_mm_cvtepi32_ps
	mulps xmm4, xmm2
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

before_conv:
	pextrw eax, xmm0, 0 ;x
	pextrw ebx, xmm1, 0 ;y

after_conv:
	mov qword[u+4], rdi
	mov rdi, 3
	imul rbx, rdi
	mov rdi, qword[u+4]
	imul rbx, rcx
	add rbx, rax
	add rbx, rdx

	mov qword[rbx], 250;seg fault

	;pextrw rax, xmm0, 0

	;ddmo eax, dword [u]
	;store results in pixarray

	add eax, 1

finaladd:
	addps xmm5, xmm6
	addss xmm9, xmm10
	jmp interpolate
end_interpolate:

	

	 
;	mov eax, [step_end]





;mov	eax, 666		;return 0
	mov rsp, rbp
	pop	rbp
	ret



