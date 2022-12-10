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
push rcx
mov rcx, 1
push rcx

; rsp: x
; rsp+8: x position
; rsp+16: cycle number
; rsp+24: part A total

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

call .execCycle
call .execCycle

mov rdi, rbx
add rdi, 5

call atoi
add [rsp], rax
jmp .loop

.nopGoto:
push .loop
; jmp .execCycle

; doesn't clobber rbx
; (a function lol)
.execCycle:
mov rax, [rsp+16+8]
inc rax
mov [rsp+16+8], rax

mov rax, [rsp+8+8]
inc rax

cmp rax, 41
je .loopY
cmp rax, 20
je .addTotal
mov [rsp+8+8], rax
jmp .doneIncX

.loopY:
mov rax, 1
mov [rsp+8+8], rax
mov rdi, newlineMsg
call print
mov rax, [rsp+8+8]
jmp .doneIncX

.addTotal:
mov [rsp+8+8], rax
mov rax, [rsp+8]
mov rcx, [rsp+16+8]
imul rcx
add [rsp+24+8], rax
mov rax, [rsp+8+8]
; jmp .doneIncX

.doneIncX:
mov rcx, [rsp+8]
sub rax, rcx
cmp rax, 0
je .printHash
cmp rax, 1
je .printHash
cmp rax, 2
je .printHash
; jmp .printDot

.printDot:
mov rdi, dotMsg
jmp print

.printHash:
mov rdi, hashMsg
jmp print

.done:
mov rdi, newlineMsg
call print
add rsp, 24
pop rax
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
hashMsg: db `#`, 0
dotMsg: db ` `, 0
newlineMsg: db `\n`, 0

section .data

filetag: dq 0
