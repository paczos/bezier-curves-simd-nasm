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
	
	
	push rcx
	mov r9, rcx
	add rcx, r9
	add rcx, r9
	and rcx, 3
	mov r9, rcx
	sub r9, 4
	neg r9
	pop rcx

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
	ja end_interpolate	;end of interpolation

	;add eax, 1 ;loop test
	movaps xmm0, [rdi] ;load points x and y to the xmms
	movaps xmm1, [rsi]	

	;load inter_iter as u to xmm2
	;xmm5 u
	;calc u1
	
	movss xmm2, [step_end]	;load const 1
	shufps xmm2, xmm2, 0h 	;broadcast const 1
	subps xmm2, xmm5	;xmm2 1-u
	; xmm5 u, xmm2 u1

	;ebx -> loop counter
	;eax -> points num (4)
	mov ebx, 1
	mov eax, 4 ;everything is calculated for 4 points
castelj:
	cmp ebx, eax
	jge end_castelj

	;we have the data, hardcore sse calcs go here
	movdqa xmm4, xmm0	;copy contents of xmm0 to xmm4 for later
	mulps xmm0, xmm5 	;x1*u
	cvtps2dq xmm0, xmm0	;convert xmm0 to int
	psrldq xmm0, 4	;srli_si128 shift 4 places to left 
	cvtdq2ps xmm0, xmm0	;_mm_cvtepi32_ps convert to float
	mulps xmm4, xmm2	;mult x*u1  
	addps xmm0, xmm4	;x*u + 
	
	;do the same for ys

	movdqa xmm4, xmm1
	mulps xmm1, xmm5 	;y1*u
	cvtps2dq xmm1, xmm1
	psrldq xmm1, 4		;srli_si128
	cvtdq2ps xmm1, xmm1	;_mm_cvtepi32_ps
	mulps xmm4, xmm2
	addps xmm1, xmm4

	add ebx, 1
	jmp castelj
end_castelj:

	mov rax, 0 ;reset eax after loop
	;extract x,y and store value in pixarray
	cvtps2dq xmm0, xmm0
	cvtps2dq xmm1, xmm1

	pextrw rax, xmm0, 0 ;x extracted as an int
	pextrw rbx, xmm1, 0 ;y same

	;rax x
	;rbx y
	;rdi pointsx	
	;rcx width
	push rdi;store on stack as we need this reg now
	mov rdi, 3
	imul rdi, rcx ;width*3
add_offset:
	add rdi, r9;offset   width*3+4
	imul rdi, rbx ;y(width*3+4)
	mov rbx,rdi ;rbx has y(width*3+4)
	;imul rbx, rdi	;3*y
	pop rdi	;restore points x into rdi
	add rbx, rax	;y(width*3+4)+x
	add rbx, rdx   ;pixarray+position
	;imul rbx, rcx	;3*y*width
	;add rbx, rax;	;3*y*width+x
	;add rbx, rdx	;pixarray+3*y*width+x

	mov qword[rbx], 250

	addps xmm5, xmm6
	addss xmm8, xmm10
	jmp interpolate
end_interpolate:

	mov rax, 0 ;return 0	
	mov rsp, rbp
	pop	rbp
	ret



