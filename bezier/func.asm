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
	step: dq 0.01
	u: dq 0.0, 0.0, 0.0, 0.0
	u1: dq 0, 0, 0, 0

section .bss
	inter_iter: resq 1


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
	;fld qword [step_end]	load step_end  to st1
	;fld qword [step]	;load step to st2
interpolate:
	fld qword [step_end]	; load step_end to st1
	fcomip st0, st1		;compare
	jbe end_interpolate	;end of interpolation

	;add eax, 1 ;loop test
	movaps xmm0, [rdi] ;load points x and y to the xmms
	movaps xmm1, [rsi]
	fst qword[inter_iter]	;store progress from fpu to mem
load1:;loading works
	;load inter_iter as u to xmm2
	;ebx -> u
	mov ebx, [inter_iter]
	mov dword [u], ebx
	mov dword [u+4], ebx
	mov dword [u+8], ebx
	mov dword [u+12], ebx
	movups xmm2, [u]
	mov eax, ebx;
load2:;loading works
	;prepare u1
	sub ebx, 1	;u-1
	neg ebx 	;-(u-1)= 1-u  
	mov dword [u1], ebx
	mov dword [u1+4], ebx
	mov dword [u1+8], ebx
	mov dword [u1+12], ebx
	movups xmm3, [u1]

	;on the stack: inter_iter, calculate u
;	fld qword [inter_iter] ;another inter_iter st1
;	fld qword [step_end]	;1.0 st2

	mov eax, [inter_iter]
	

	fld qword [step]
	fadd st0, st1;increase inter_iter
	fstp (st1)
	jmp interpolate
end_interpolate:

	

	 






;mov	eax, 666		;return 0
	mov rsp, rbp
	pop	rbp
	ret



