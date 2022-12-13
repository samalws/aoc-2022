global main

numMonkesAllowed equ 8
numItemsAllowed equ 8

; from shared.s
extern numFromString
extern getLine
extern getNum
extern insertList
extern sumList
extern printList
extern printA
extern print
extern printNum
extern retLbl

; from hashMap.s
extern allocHashMap
extern insertHashMap
extern lookupHashMap
extern deleteHashMap
extern getHashMapSize
extern enumerateHashMap

; from stdlib
extern stdin
extern fopen
extern malloc
extern calloc
extern atoi

section .text

main:
call openFile
call runFileA
mov rdi, rax
call printNum

mov rax, 0
ret

runFileA:
mov r12, 1 ; index
mov r13, 0 ; sum

.loop:
mov rdi, [filetag]
call getLine

cmp rax, -1
je .done
cmp rax, 1
je .done

push rbx

mov rdi, [filetag]
call getLine
push rbx

mov rdi, [filetag]
call getLine

pop rsi
pop rdi

call compare

mov rbx, 0
cmp rax, 0
cmove rbx, r12
add r13, rbx

inc r12
jmp .loop

.done:
mov rax, r13
ret

; rdi: first string
; rsi: second string
; returns rax: 1 if greater, 0 if less
; clobbers rax thru rdx, and rdi and rsi, also r15
compare:

; rax: read from first num
; rbx: read from second num
mov rcx, 0 ; depth
; rdx used for conditions
mov r15, 0

.loop:
mov al, [rdi]
mov bl, [rsi]
cmp al, bl

mov rdx, 1
cmp al, '0'
cmovl rdx, r15
cmp al, '9'
cmovg rdx, r15
cmp bl, '0'
cmovl rdx, r15
cmp bl, '9'
cmovg rdx, r15
cmp rdx, 0
je .a
; if both are numeric: (else .a)
push .loop
jmp .cmpNums

.a:
cmp al, bl
jne .b
; elif al = bl (else .b)
inc rdi
inc rsi
jmp .loop

.b:
mov rdx, 1
cmp al, '0'
cmovl rdx, r15
cmp al, '9'
cmovg rdx, r15
cmp bl, '['
cmovne rdx, r15
cmp rdx, 0
je .c
; elif al is numeric and bl = '[' (else .c)
inc rcx
inc rsi
jmp .loop

.c:
mov rdx, 1
cmp al, '['
cmovne rdx, r15
cmp bl, '0'
cmovl rdx, r15
cmp bl, '9'
cmovg rdx, r15
cmp rdx, 0
je .d
; elif al = '[' and bl is numeric (else .d)
inc rcx
inc rdi
jmp .loop

.d:
cmp al, ']'
jne .e
; elif al = ']' (else .e)

cmp rcx, 0
jle .less
;   if depth > 0 (else .less)
inc rdi
dec rcx
jmp .loop

.e:
cmp rcx, 0
jle .greater
;   if depth > 0 (else .greater)
inc rsi
dec rcx
jmp .loop

.greater:
mov rax, 1
ret

.less:
mov rax, 0
ret

; rdi: first num
; rsi: second num
; returns from the function if not equal, otherwise returns normally, where rdi and rsi become a pointer to directly after the num
; clobbers rax and rbx
.cmpNums:
call .cmpNumLengths
; now assumed num lengths are equal

.cmpNumsLoop:
inc rdi
inc rsi
cmp al, bl
jl .numLess
jg .numGreater

cmp al, '0'
jl .numEqual
cmp al, '9'
jg .numEqual
jmp .cmpNumsLoop

.numEqual:
ret

.numGreater:
add rsp, 8 ; return address
jmp .greater

.numLess:
add rsp, 8 ; ^
jmp .less

.cmpNumLengths:
push rdi
push rsi
push rcx
push rdx

.cmpNumLengthsLoop:
mov al, [rdi]
mov bl, [rsi]

mov rcx, 1
cmp al, '0'
cmovl rcx, r15
cmp al, '9'
cmovg rcx, r15

mov rdx, 1
cmp bl, '0'
cmovl rdx, r15
cmp bl, '9'
cmovg rdx, r15

cmp rcx, 0
je .cmpNumLengthsFirstNonNumerical

.cmpNumLengthsFirstNumerical:
cmp rdx, 0
je .numLengthGreater
inc rdi
inc rsi
jmp .cmpNumLengthsLoop

.cmpNumLengthsFirstNonNumerical:
cmp rdx, 0
jne .numLengthLess
; jmp .numLengthEqual

.numLengthEqual:
pop rdx
pop rcx
pop rsi
pop rdi
ret ; to .numLengths

.numLengthGreater:
add rsp, 8*4+8 ; rdi, rsi, rcx, rdx, return address for cmpNumLengths
jmp .numGreater

.numLengthLess:
add rsp, 8*4+8 ; ^
jmp .numLess


openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d13.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
divBy: dq 3
modBy: dq 1
