TITLE Prime Numbers       (Project04.asm)

; This program calculates and displays the number of prime numbers specified by the user.  
; It prompts the user to enter the number of primes to display in the range [1 .. 200].  It then
; verifies that 1 <= n <= 200.  If  n is out of range, the user is re-prompted until the value entered is in range.
; It then calculates and displays the all of the primes up to and including the nth prime.

INCLUDE Irvine32.inc

UPPER = 200
TRUE = 1
FALSE = 0

.data
	intro		BYTE	"Prime Numbers           Rebecca Sagalyn",0
	prompt_1	BYTE	"Enter the number of primes you would like to see",0
	prompt_2	BYTE	"I'll accept orders for up to 200 primes.",0
	prompt_3	BYTE	"Enter the number of primes to display [1..200]:  ",0
	n			DWORD	?														;number of primes
	error_1		BYTE	"Out of range. Try again.",0
	bye_str		BYTE	"Results certified by Rebecca.  Goodbye.",0	
	bPrime		BYTE	0
	spc			BYTE	"   ",0
	colNum		DWORD	1				; column counter; < 10 to print next number 
	count		DWORD	1				; counter for number of primes we've printed (<= n)
	check		DWORD	?
	factor		DWORD	?
	arr			DWORD 200 DUP(?)
	arrsize		DWORD	0
.code

main PROC
; Display programmer & program name & instruct user to enter number of primes to be displayed
	call	introduction
; Prompt for integer in range [1...200] and validate 1 <= n <= 200
	call	getUserData
; Calc and display all primes up to and including nth prime
	call	showPrimes
; Say goodbye
	call	goodbye
	exit
main ENDP

;-------------------------------------------------------------------------
introduction PROC
; Displays program and programmer name and instructs user what program will do
; receives: intro, prompt_1, prompt_1
; returns: none
; preconditions: edx initialized
; registers changed: edx
;-------------------------------------------------------------------------
	mov	edx, OFFSET intro
	call	WriteString			; display program + programmer name
	call	Crlf
	call	Crlf
	mov		edx, OFFSET prompt_1
	call	WriteString			
	call	Crlf
	mov		edx, OFFSET prompt_2
	call	WriteString			; display instructions for user
	call	Crlf
	call	Crlf
	ret
introduction ENDP
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
getUserData PROC
; This procedure prompts user to enter an integer in [1..200] and
; verifies it is in the range. If out of range, it re-prompts until
; valid number is entered.
; receives: n is a global variable
; returns: n with user input
; preconditions: n in range [1..200], edx initialized
; registers changed: eax, edx
;-------------------------------------------------------------------------
GetNum:
	mov		edx, OFFSET prompt_3
	call	WriteString					; prompt user to enter number
	call	ReadDec						; read number into n
	mov		n, eax
	cmp		n, 1
	jl		InvalidInput				; if n < 1, invalid number
	cmp		n, 200
	jg		InvalidInput				; if n > 200, invalid number
	ret
InvalidInput:
	mov		edx, OFFSET error_1			; error message
	call	WriteString
	call	Crlf
	jmp		GetNum						; try again
	ret
getUserData ENDP
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
showPrimes PROC
; Calculates and displays all of the prime numbers up to and including the
; nth prime, 10 per line with at least 3 spaces between
; receives: n, count, colNum, bPrime are global variables
; returns: none
; preconditions: n is in [1..200], colNum = 1, count = 1
; registers changed: eax, ebx, ecx, edx
;-------------------------------------------------------------------------
	; Print first prime, 2, before looping thru odds
		mov		eax, 2
		call	Crlf
		call	WriteDec						; print 2
		mov		edx, OFFSET spc
		call	WriteString						; print spaces
		inc		colNum
		cmp		n, 1							; If n = 1, all done, so exit
		je		primesDone
		inc		count							; else, increase count & continue		
		mov		esi, OFFSET arr					; point to array
		mov		[esi], eax						; move 2 to first index
		inc		arrsize							; inc size
	; Starting with 3, loop thru odd numbers using ecx until count > n
		mov		ecx, 3
LoopPrimes:
		mov		eax, count
		cmp		eax, n
		jg		PrimesDone						; while count <= n
		pushad
 		call	isPrime							; call isPrime procedure
		popad
		cmp		bPrime, TRUE					; if isPrime(ecx)
		jne		AddTwo							; jump to end of loop
		; If ecx = prime
			mov	esi, OFFSET arr
			mov	eax, 4
			mul	arrsize
			add	esi, eax
			mov	[esi], ecx
			inc	arrsize
			mov	eax, [esi]			
			cmp		colNum, 10
			jle		SameLine	
			mov		colNum, 1						; if colNum > 10 reset to 1
			call	Crlf							; start new line
	SameLine:
			mov		eax, ecx
			call	WriteDec						; print prime
			mov		edx, OFFSET spc
			call	WriteString						; print spaces
			inc		colNum							; increment column number
			inc		count							; increment count
	; Else
	AddTwo:
		add		ecx, 2							; increment ecx to next odd num
		jmp		LoopPrimes						; loop
PrimesDone:
		call	Crlf
		ret
showPrimes ENDP
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
isPrime PROC
; Determines whether a number is prime
; receives: factor, bPrime, check are global vars, ecx has the number to check
; returns: bool result in global variable bPrime
; preconditions: ecx is in [1..200], arraysizse > 0
; registers changed: eax, ebx, ecx, edx
;-------------------------------------------------------------------------
		mov		ebx, 0							; ebx = current array index
		mov		esi, OFFSET arr					; esi = ptr to index in ebx
		mov		check, ecx						; number to find out if prime
		cmp		ecx, 3
		je		PrimeNum
	PrimeLoop:									; divide check by every number in array		
		cmp		ebx, arrsize					; while ebx < arrsize and check % factor != 0
		jge		PrimeNum						; reached end of array, no divisors found, so it's prime
		mov		ecx, [esi]						; move value
		mov		edx, 0
		mov		eax, check
		div		ecx
		cmp		edx, 0
		je		NotPrime						; if remainder = 0, not prime
		add		esi, 4							; else continue searching array
		inc		ebx
		jmp		PrimeNum
PrimeNum:	
	mov bPrime, TRUE
	ret
NotPrime:
	mov bPrime, FALSE
	ret
isPrime ENDP
;-------------------------------------------------------------------------

;-------------------------------------------------------------------------
goodbye PROC
;Displays a farewell message
;receives: bye_str is a global variable
;returns: nothing
;preconditions: edx initialized
;registers changed: edx
;-------------------------------------------------------------------------
	call	Crlf
	mov		edx, OFFSET bye_str
	call	WriteString							; say bye
	call	Crlf
	ret
goodbye ENDP
;-------------------------------------------------------------------------
END main