global main

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
extern calloc
extern atoi

section .text

main:
call openFile
call totalBoth
mov rdi, rcx
push rdx
call printNum
pop rdi
call printNum

mov rax, 0
ret

totalBoth:
mov rcx, 0
mov rdx, 0

.loop:
push rcx
push rdx
mov rdi, [filetag]
call getLine

cmp rax, -1
je .done
cmp rax, 1
je .done

mov rdi, rbx
call get4Nums

pop rdx
pop rcx

call fullOverlap
add rcx, rax

call anyOverlap
add rdx, rax

jmp .loop

.done:
pop rdx
pop rcx
ret

get4Nums:
call numFromString
mov r12, rax
inc rdi
call numFromString
mov r13, rax
inc rdi
call numFromString
mov r14, rax
inc rdi
call numFromString
mov r15, rax
inc rdi
ret

fullOverlap:
cmp r12, r14
jl .lt
je .true
jmp .gt

; first one might fully contain the second one
.lt:
cmp r13, r15
jge .true
jmp .false

; second one might fully contain the first one
.gt:
cmp r13, r15
jle .true
jmp .false

.true:
mov rax, 1
ret

.false:
mov rax, 0
ret

anyOverlap:
cmp r12, r14
jl .lt
je .true
jmp .gt

.lt:
cmp r13, r14
jge .true
jmp .false

.gt:
cmp r15, r12
jge .true
jmp .false

.true:
mov rax, 1
ret

.false:
mov rax, 0
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d4.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
