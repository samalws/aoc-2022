global main

; from shared.s
extern getLine
extern getNum
extern insertList
extern sumList
extern printList
extern printA
extern printB
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
extern calloc
extern atoi

section .text

main:
mov r15, 4
call mainStuff

call clearLetterMap

mov r15, 14
call mainStuff

mov rax, 0
ret

mainStuff:
call openFile
mov rdi, [filetag]
call getLine
call totalPackets
mov rdi, rax
call printNum
ret

; r15: num of packets in a row
; rbx: string
totalPackets:
mov r12, rbx
mov r13, rbx
mov r14, 0

; r12: early pointer
; r13: late pointer
; r14: current index
; r15: num of packets in a row

.loop:

; add late letter to map
mov rax, 0
mov al, [r13]
sub rax, 'a'

mov rbx, [letterMap+rax*8]
inc rbx
mov [letterMap+rax*8], rbx

inc r13
inc r14

cmp r14, r15
jle .loop

; remove early letter from map
mov rax, 0
mov al, [r12]
sub rax, 'a'

mov rbx, [letterMap+rax*8]
dec rbx
mov [letterMap+rax*8], rbx

inc r12

call letterMapHasDups
cmp rax, 0
jne .loop

; done
mov rax, r14
ret

letterMapHasDups:
mov rax, letterMap
; rax: loc in letterMap
.loop:
mov rbx, [rax]
cmp rbx, 1
jg .true

add rax, 8

cmp rax, letterMap+8*26
jne .loop
; jmp .false

.false:
mov rax, 0
ret

.true:
mov rax, 1
ret

clearLetterMap:
mov rax, letterMap
mov rbx, 0
.loop:
mov [rax], rbx
add rax, 8
cmp rax, letterMap+8*26
jne .loop
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d6.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0

letterMap:
times 26 dq 0
