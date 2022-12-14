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
extern malloc
extern calloc
extern atoi
extern exit

section .text

main:
call openFile
call runFile
mov r13, rax
mov rdi, r15
call printNum

call openFile
call runFile
mov rdi, r13
call printNum

mov rax, 0
ret

runFile:
mov rdi, [filetag]
call getLine
; cd /
; r13: smallest file above threshold found; given by main
mov r14, r13 ; threshold
sub r14, 40000000
mov r15, 0 ; sum size of dirs below 100000
call dirSize
ret

dirSize:
mov rdi, [filetag]
call getLine
; $ ls

mov rcx, 0 ; total size

.loop:
push rcx

mov rdi, [filetag]
call getLine

pop rcx

cmp rax, -1
je .done
cmp rax, 1
je .done

mov al, [rbx]

cmp al, 'd'
; dir name
je .loop

cmp al, '$'
; $ cd .. or $ cd name
je .cd

; 12345 filename
push rcx
mov rdi, rbx
call numFromString
pop rcx
add rcx, rax
jmp .loop

.cd:
add rbx, 5
mov al, [rbx]
cmp al, '.'
; cd ..
je .done

; cd name
push rcx
call dirSize
pop rcx
add rcx, rax
jmp .loop

.done:
mov rax, rcx

mov rdx, 0
cmp rcx, 100000
cmovle rdx, rcx
add r15, rdx

mov rdx, rcx
cmp rcx, r14
cmovl rcx, r13
cmp rcx, r13
cmovg rcx, r13
mov r13, rcx

ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d7.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
