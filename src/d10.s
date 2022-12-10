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
extern malloc
extern atoi

section .text

main:
call openFile
call runFile
mov rdi, rax
call printNum

mov rax, 0
ret

runFile:
mov rcx, 0
push rcx
push rcx
mov rcx, 1
push rcx

; rsp: x
; rsp+8: niters
; rsp+16: part A total

.loop:
mov rdi, [filetag]
call getLine

cmp rax, 1
je .done
cmp rax, -1
je .done

mov al, [rbx]
cmp al, 'n'
je .nopGoto

call .incCmp
call .incCmp

mov rdi, rbx
add rdi, 5

call atoi
add [rsp], rax
jmp .loop

.nopGoto:
call .incCmp
jmp .loop

.done:
add rsp, 16
pop rax
ret

.incCmp:
mov rax, [rsp+8+8]
inc rax
mov [rsp+8+8], rax

cmp rax, 20
je .addTotal
cmp rax, 60
je .addTotal
cmp rax, 100
je .addTotal
cmp rax, 140
je .addTotal
cmp rax, 180
je .addTotal
cmp rax, 220
je .addTotal
ret

.addTotal:
mov rax, [rsp+8]
mov rcx, [rsp+8+8]
imul rcx
add [rsp+16+8], rax
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d10.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
