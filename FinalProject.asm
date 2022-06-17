INCLUDE Irvine32.inc

; //Author: Rohan Ballapragada
; //OSU email address: ballaprr@oregonstate.edu
; //Course Number: CS 271 001
; //Assignment: Final Project
; //Description: This program have four procedures: compute, encryption, decryption, and decoy
;			     Compute accepts parameters from the main procedure and based off the DWORD that is passed
;				          calls the respective procedure,  if DWORD is 0 encryption decoy is called, if 
;						  DWORD is -1 encryption is called, and if DWORD is -2 then decryption is called
;				 Decoy takes three parameters and returns the sums of two operands
;				 Encryption takes three parameters and encrypts the message based on the key that is passed
;				 Decryption takes three parameters and decrypts the message based on the key that is passed

COMMENT @
.data
	myKey		BYTE   "efbcdghijklmnopqrstuvwxyza", 0
	message     BYTE   "the contents of this message will be a mystery.",0
	dest		DWORD	0
	operand1	WORD	-32768
	operand2	WORD	-32768
@

.code
COMMENT @
	main PROC
		push	operand1
		push	operand2
		push	OFFSET dest
		call	compute
	main ENDP
@

; Procedure to calculate encryption, decryption, and decoy
; Recieves three parameters either a key, message, and a signed value or 
;		or two operands and a signed value
; Encryption and decryption return 12 and decoy returns 8
; All passing parameters need to be initilized
; Uses register esp to point to the stack of the parameters passing, uses 
;		ebp to point to the top of the stack, uses eax to store value
;		for comparison with edi register which stores the address of DWORD
; Description: Stores -1, -2, 0, and checks with the value of memorory address
;              destination to encrypt, decrypt, or decoy. If -1 then jump to encrypt,
;			   if -2 then jumpt to decrypt, and if 0 then jump to decoy.
;			   In encrypt and decrypt, pass the first parameter (myKey), the
;			   second parameter (message), and the third parameter (destination).
;			   In decoy, pass the first parameter (operand 1), second parameter
;			   (operand 2), and third parameter (destination).
compute PROC
	push	ebp     ; push ebp
	mov		ebp, esp  ; move esp to ebp
	mov		eax, -1   ; move -1 to eax
	mov		edi, [ebp + 8] ; move memory address of DWORD to edi
	cmp		[edi], eax	   ; compare eax to value at edi
	je		encrypt		   ; jumpt to encrypt if they equal each other
	mov		eax, -2		  
	cmp		[edi], eax   
	je		decrypt
	mov		eax, 0
	cmp		[edi], eax
	je		decoy_

	encrypt:
		push    [ebp+16] ; pushing key
		push    [ebp+12] ; pushing message
		push	[ebp+8]  ; pushing dest
		call	encryption ; calling encryption procedure
		pop		ebp
		ret		12    ; return 12
	decrypt:
		push	[ebp+16]  
		push	[ebp+12]
		push	[ebp+8]
		call	decryption
		pop		ebp
		ret		12
	decoy_:
		push	[ebp+14] ; pushing operation 1
		push	[ebp+12] ; pushing operation 2
		push	[ebp+8] ; pushing dest
		call	decoy ; calling decoy
		pop		ebp
		ret		8		; return 8
		
compute ENDP

; Procedure to encrypt the message with the key
; Recieves three parameters, a key, message, and destination (DWORD)
; Returns 12
; All passing parameters need to be initialized
; Uses register esp to point to the stack of the parameters passing, uses 
;		ebp to point to the top of the stack, used ecx to increment the 
;		message, uses esi to store the address of the key, uses edi to 
;		store the address of the message, uses eax for null termination
;		and to store index for key, I would use al register to store ascii value
;		and the bl register to store the character from "key," edx is used to 
;		store the contents of edi into edx to print. 
;Description: The code starts by checking for null termination, if there is 
;			 null termination, the jump to termination function if not, then
;			 continue iterating. Check if the character in the message is an 
;			 ascii value between 97 and 122, if it is not then jump to not
;			 lowercase where we increment index by one, if it is then jump
;			 to swap where we subtract the ascii value by 97 to get the index
;			 for key, I grab the character in the key associated with the index
;			 and store it into the message. 
encryption PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, 0 ; Initialize incrementaion at 
	mov		esi, [ebp+16] ; storing key in esi register
	mov		edi, [ebp+12] ; storing message in edx register
	Iterate:
		mov		eax, 0 ; NULL termination
		cmp		[edi + ecx], eax ; 
		je		Terminate

		mov		al, [edi + ecx] ; storing ascii value in al register
		cmp		al, 97			; compare ascii value to 97
		jl		not_lc			; if less than, then jump to not lowercase
		cmp		al, 122			; compare ascii value to 122
		jg		not_lc			; if great than, then jumpt to not uppercase
		jmp		swap

	not_lc:
		inc		ecx				; increment ecx
		jmp		Iterate			; jump back to Iterate to loop

	swap:
		sub		al, 97 ; subtract by 97 to get index 
		mov		bl, [esi + eax] ; get character from key 
		mov		[edi + ecx], bl	; store character in message with right index
		inc		ecx				; increment ecx
		jmp		Iterate			; jump to Iterate

	Terminate:
		mov		edx, edi	; store contents of message into edx register
		call	WriteString
		pop		ebp
		ret		12
encryption ENDP

; Procedure to decrypt the message with the key
; Recieves three parameters, a key, message, and destination (DWORD)
; Returns 12
; All passing parameters need to be initialized
; Uses register esp to point to the stack of the parameters passing, uses 
;		ebp to point to the top of the stack, used ecx to increment the 
;		message, uses esi to store the address of the key, uses edi to 
;		store the address of the message, uses eax for null termination
;		and to store index for key, use al register to store ascii value
;		and the bl register to store the character from "key," dl register to 
;		store the content of al, edx is used to store the contents of edi 
;		into edx to print. 
;Description: The code starts by checking for null termination, if there is 
;			 null termination, the jump to termination function if not, then
;			 continue iterating. Check if the character in the message is an 
;			 ascii value between 97 and 122, if it is not then jump to not
;			 lowercase where we increment index by one, if it is then jump
;			 to Find where increment the key until we find the ascii value
;			 equal to the one from the encrypted message. If we do find it 
;			 then take the index, add 97, and move it to the message for 
;			 decryption.
decryption PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, 0 ; Initializing ecx at 0
	mov		esi, [ebp+16] ; storing key
	mov		edi, [ebp+12] ; storing message
	Iterate:
		mov 	eax, 0 ; Moves 0 to eax
		cmp		[edi + ecx], eax ; compares character at message to 0
		je		Terminate

		mov		al, [edi + ecx] ; storing message with letter at index in al
		cmp		al, 97			; compare ascii value to 97
		jl		not_lc
		cmp		al, 122			; compare ascii value to 122
		jg		not_lc
		mov		dl, al
		mov		eax, 0   ; index for key
		jmp		Find

	not_lc:
		inc		ecx    ; increment by one
		jmp		Iterate

	Find:
		mov		bl, [esi + eax] ; bl used to store character from key
		cmp		dl, bl         ; compare dl (character from message) to bl (character from key)
		je		Replace        ; jump to replace if equal
		inc		eax			   ; increment index
		jmp		Find

	Replace:
		add		eax, 97		  ; add ax to 97 to get character
		mov		[edi + ecx], al ; move character to message
		inc		ecx          ; increment by one
		jmp		Iterate

	Terminate:
		mov		edx, edi
		call	WriteString
		pop		ebp
		ret		12
decryption ENDP


; Procedure to get the sum of two 16-bit operands by value
; Recieves three parameters, two operands, and destination (DWORD)
; Returns 8
; All passing parameters need to be initialized
; Uses register esp to point to the stack of the parameters passing, uses 
;			ebp to point to the top of the stack, uses edx to store the 
;			memory address of destination (DWORD), uses ax to store operand 2, uses
;			bx to store operand 1, (extra credit) uses eax to store the content
;			of ax, uses ebx to store the content of bx.
;Description: The code starts by storing the memory address of destination (DWORD), 
;			moving value of memory address to ax, storing the value of memory
;			address of bx, storing those in eax and ebx registers, and adding those
;			we then store eax into the memory address of destination (DWORD)
decoy PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 8] ; storing dest (DWORD)
	mov		ax, [ebp + 12] ; storing operand 2
	movsx	eax, ax		   ; moving to 32 bit register
	mov		bx, [ebp + 16] ; storing operand 1
	movsx	ebx, bx		   ; moving to 32 bit register
	add		eax, ebx	   ; adding 32 bit registers
	mov		[edx], eax	  ; storing in address of dest (DWORD)
	mov		eax, dest
	call	WriteInt
	pop		ebp
	ret		8	; return 8
decoy ENDP

END main

