;=====================================================================
;ECOAR intel x64 project. Bezier curves of order 4.
;
; Author:      Pawel Paczuski
; Description: Function receives pointer to reserved image memory and 4 control points draws Bezier curve that interpolates between the points.
;			   Params: float* pointsX, float* pointsY, unsigned char* pixelArray, width, height 
;              int func(float* pointsX, float* pointsY, unsigned char* pixelArray, int width, int height);
; AMD x64 ABI
;=====================================================================

section	.text
global func 

func:
	push	rbp
	mov	rbp, rsp
	;r8 height
	;rcx width	
	mov	rax, rcx
	;mov	rax, DWORD [rbp+20]	;width 
	;mov	rdx, DWORD [rbp+16]	;pixelArray 

	;mov	rbx, DWORD [ebp+12]	;pointsY 
;	mov	eax, DWORD [ebp+18]	;pointsX 






;mov	eax, 666		;return 0
	mov rsp, rbp
	pop	rbp
	ret



