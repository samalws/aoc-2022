global main

; from shared.s
extern getLine
extern getNum
extern insertList
extern sumList
extern printList
extern printA
extern print
extern printNum
extern retLbl

; from stdlib
extern stdin
extern fopen
extern calloc

section .text

main:
call openFile

mov rdi, enterNMsg
call print

mov rdi, [stdin]
call getNum

mov rdi, rbx
shl rdi, 3 ; mul by 8
push rdi

mov rsi, 1
call calloc
mov [topListStart], rax

pop rbx
add rax, rbx

mov [topListEnd], rax

mov rcx, 0

.loop:
call readElf

cmp rax, -1
je .done
mov rdx, rbx
mov rdi, [topListStart]
mov rsi, [topListEnd]
call insertList
jmp .loop

.done:
mov rdi, topNMsg
call print

mov rdi, [topListStart]
mov rsi, [topListEnd]
call printList

mov rdi, sumMsg
call print

mov rdi, [topListStart]
mov rsi, [topListEnd]
call sumList

mov rdi, rax
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
call getNum
cmp rax, 1
je .done
cmp rax, -1
je .done

pop rcx
add rcx, rbx
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


section .rodata

fname: db `inputs/d1.txt`, 0
mode: db `r`, 0
enterNMsg: db `Enter n: `, 0
topNMsg: db `Top n:\n`, 0
sumMsg: db `Sum of top n:\n`, 0

section .data

filetag: dq 0
topListStart: dq 0
topListEnd: dq 0
