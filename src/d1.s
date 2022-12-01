global main

; from shared.s
extern getLine
extern insertList
extern printA
extern print
extern printNum

; from stdlib
extern atoi
extern fopen
extern getline
extern printf

section .text

main:
call openFile

mov rcx, 0

.loop:
call readElf

cmp rax, -1
je .done
mov rdx, rbx
mov rdi, topListStart
mov rsi, topListEnd
call insertList
jmp .loop

.done:
mov rdi, topListStart[0]
call printNum
mov rdi, topListStart[0]
mov rax, topListStart[8]
add rdi, rax
mov rax, topListStart[16]
add rdi, rax
call printNum

mov rax, 0
ret

; returns:
; rax: -1 if failed, 1 if succeeded
; rbx: total number
readElf:
mov rcx, 0 ; total

.loop:
push rcx
mov rdi, [filetag]
call getLine
cmp rax, 1
je .done
cmp rax, -1
je .done

mov rdi, rbx
call atoi

pop rcx
add rcx, rax
jmp .loop

.done:
pop rbx
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .data

fname: db `inputs/d1.txt`, 0
mode: db `r`, 0
filetag: dq 0

topListStart:
dq 0
dq 0
dq 0
topListEnd:
