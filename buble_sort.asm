;=============================================
;
;=============================================

format ELF64 executable

;=============================================
;================== DATA =====================
;=============================================

segment readable writeable
;=============================================
;                 variables
;=============================================
time_start dq 0
time_stop dq 0
time_of_executing dq 0

one_unit dq 5			; measure

tmp dq 0			; tmp
negative dq 0			; negative

msg_time db 0xA,'Время выполнения(в секундах) = ',0
msg_time_size = $ - msg_time

msg_mark db 0xA,'Оценка к единице измерения = ',0
msg_mark_size = $ - msg_mark



one: times 12 db 0		; the first part of answer
one_size = $ - one		; actual size of 'one'

two: times 12 db 0		; the second part of answer
two_size = $ - two		; actual size of 'two'

executing_time: times 12 db 0		
executing_time_size = $ - executing_time		

minus db '-',0			; just a '-' char + null char
minus_size = $ - minus		; actial size of 'minus'

point db '.',0			; just a '.' char + null char
point_size = $ - point		; actual size of 'point'

newline db 0xA,0		; just a '\n' char + null char
newline_size = $ - newline	; actual size of 'newline'

array  dd 10,9,4,1,12,23,12,33,22,34,12,54,32,35,64,39,23,23,53,23,34,45,23,54,32,55,7,64,7,4,3,56,75,34,57,34,67,32,753,568,443,66,443,67,856,445,45,876,23,34,56,67,75,3456,675,345,676,53,577,456,864,3466,764,356,67,344,54,345,46,76,47,8677,434,56,75,456,345,46,345,345,643,45,67,869,345,765,456,74,379,346,936,935,96,357,385,755,56
len  dd 96







;=============================================
;================== CODE =====================
;=============================================

segment readable executable

;=============================================

entry $

;=============================================
;               test
;=============================================

     

      mov 	eax, 13				; get in rax time in seconds since 1970
      xor 	ebx, ebx
      int 	0x80
      mov 	[time_start], rax		; put the initial time in time_start 
      
      mov 	rbx, 1000000			; the number of times repeated sorting
      
DO_WHILE:					; repeat sorting 1000000 times
      call 	BUBLE_SORT
      dec 	rbx
      cmp 	rbx, 0
      jne 	DO_WHILE

      mov 	eax, 13
      xor 	ebx, ebx			; get in rax time in seconds since 1970
      int 	0x80
      mov 	[time_stop], rax		; put end time in time_stop

      mov 	rax, [time_stop]		; calculate execting time
      mov 	rbx, [time_start]
      sub 	rax, rbx
      mov 	[time_of_executing], rax	; put it in a variable
      
      lea	rbx,[executing_time+executing_time_size-1]
      call	TO_STR				; convert string to integer
    
      mov 	rax, [time_of_executing]	; calculate our mark
      mov 	rbx, [one_unit]
      xor 	rdx, rdx
      div 	rbx
      mov 	[tmp], rdx

      lea	rbx,[one+one_size-1]		; integer part of a number
      call	TO_STR				; convert string to integer
      
      mov 	rax, [tmp]
      lea	rbx,[two+two_size-1]		; fractional part of a number
      call	TO_STR				; convert string to integer
      
      call 	PRINT_ANSWER			; print result
      
      call 	EXIT				; exit

;=============================================
;               buble sort
;=============================================        

BUBLE_SORT:
      push 	rbp rsp
      mov 	ecx, [len]
      
BUBLE_SORT_O:
      xor 	ebp, ebp
      
BUBLE_SORT_I:
      mov 	eax, dword[array+ebp*4+4]
      cmp 	dword[array+ebp*4], eax
      jb 	BUBLE_SORT_C
      xchg 	eax, dword[array+ebp*4]
      
      mov	dword[array+ebp*4+4], eax
BUBLE_SORT_C:
      add 	ebp, 1
      cmp 	ebp, ecx
      jb	BUBLE_SORT_I
      loop 	BUBLE_SORT_O 	
      
      pop 	rsp rbp
ret
 
 ;=============================================
;       convert integer value to string
;=============================================

TO_STR:
      push	rbp				; save rbp on the stack
      mov	rbp, rsp			; replace rbp with esp since we will be using

      mov	cx, 10				; divider

TO_STR_LOOP:
      xor	dx, dx				; clear dx register
      idiv	cx				; division by ten
      dec	bx				; move pointer to the previous string byte
      add	dx, 30h				; ASCII offset
      mov	[rbx], dl			; move char to the string
      cmp	ax, 0				; is it zero char?
      jne	TO_STR_LOOP			; if not do it again

      pop	rbp				; get rbp from the stack
ret						; return from the function
	
;=============================================
;                 print answer
;=============================================

PRINT_ANSWER:
      push rbp rsp
      
      lea	rsi, [msg_time]			; answer formatter symbol
      mov	ecx, msg_time_size		; message size
      call	MSG				; print in the terminal
      
      lea	rsi, [executing_time]		; answer formatter symbol
      mov	ecx, executing_time_size	; message size
      call	MSG				; print in the terminal
    
      
      lea	rsi,[newline]			; '\n' char + null char
      mov	ecx,newline_size		; message size
      call	MSG				; print in the terminal
      
      lea	rsi,[msg_mark]			; answer formatter symbol
      mov	ecx,msg_mark_size		; message size
      call	MSG				; print in the terminal

MINUS:
      cmp	[negative], 1
      jne	FIRST_PART
      lea	rsi, [minus]			; answer formatter symbol
      mov	ecx, minus_size			; message size
      call	MSG

FIRST_PART:
      lea	rsi, [one]			; first part of the answer 
      mov	ecx, one_size			; message size
      call	MSG				; print in the terminal

POINT:
      lea	rsi, [point]			; '.' char + null char
      mov	ecx, point_size			; message size
      call	MSG				; print in the terminal

SECOND_PART:
      lea	rsi, [two]			; second part of the answer
      mov	ecx, two_size			; message size
      call	MSG				; print in the terminal

NEWLINES:
      lea	rsi, [newline]			; '\n' char + null char
      mov	ecx, newline_size		; message size
      call	MSG				; print in the terminal

      lea	rsi, [newline]			; '\n' char + null char
      mov	ecx, newline_size		; message size
      call	MSG				; print in the terminal
	
      pop rsp rbp
ret

;=============================================
;               write to terminal
;=============================================

MSG:
    push	rax rbx rdx rbp			; save rbp on the stack
    mov		rbp, rsp			; replace rbp with esp since we will be using

    mov		edx, ecx

    mov		edi, 1				; STDOUT
    mov		eax, 1				; sys_write
    syscall					; system call

    pop		rax rbx rdx rbp			; get rbp from the stack
ret						; return from the function
;=============================================
;                 exit segment
;=============================================
 
EXIT:
    ;xor  	edi, edi  		        ; exit code 0
    mov		eax, 1               		; sys_exit
    mov  	ebx, 0              		; error code
    int 	0x80                 		; system call
ret






