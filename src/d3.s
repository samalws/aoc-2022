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

section .text

main:
call openFile
call part1GetScores
mov rdi, rax
call printNum

call openFile
call part2GetScores
mov rdi, rax
call printNum

mov rax, 0
ret

part1GetScores:
mov rcx, 0

.loop:
push rcx
mov rdi, [filetag]
call getLine

cmp rax, -1
je .done
cmp rax, 1
je .done

call part1LetterInCommon
pop rcx
add rcx, rax

jmp .loop

.done:
pop rax
ret

; rax: length
; rbx: str
; returns to rax
part1LetterInCommon:
push rax
push rbx

mov rdi, rax
call allocHashMap
mov rcx, rax

pop rbx
pop rax

shr rax, 1

.firstHalfLoop:
mov rdx, 0
mov dl, [rbx]
mov rdi, rdx
mov rdx, rcx

push rax
push rbx
push rcx

mov rsi, 1
call insertHashMap

pop rcx
pop rbx
pop rax

inc rbx
dec rax
cmp rax, 0
jne .firstHalfLoop

.secondHalfLoop:
mov rdx, 0
mov dl, [rbx]
mov rdi, rdx
mov rsi, rcx

push rdi
push rbx
push rcx

call lookupHashMap

pop rcx
pop rbx
pop rdi

inc rbx

cmp rax, 1
jne .secondHalfLoop

call letterToScore
ret

part2GetScores:
mov rcx, 0

.loop:
push rcx
mov rdi, [filetag]
call getLine

cmp rax, -1
je .done
cmp rax, 1
je .done

mov r12, rax
mov r13, rbx

mov rdi, [filetag]
call getLine

mov r14, rax
mov r15, rbx

mov rdi, [filetag]
call getLine

mov r10, rax
mov r11, rbx

call part2LetterInCommon
pop rcx
add rcx, rax

jmp .loop

.done:
pop rax
ret

; r10,r11; r12,r13; r14,r15
; rcx and rdx: hash maps
part2LetterInCommon:

push r10
push r11
mov rdi, r10
call allocHashMap
pop r11
pop r10

mov rdx, rax

.loop1:
mov rax, 0
mov al, [r11]
mov rdi, rax
mov rsi, 1

push r10
push r11
push rdx
call insertHashMap
pop rdx
pop r11
pop r10

dec r10
inc r11
cmp r10, 1
jne .loop1

push rdx

mov rdi, r12
call allocHashMap

mov rdx, rax

.loop2:
mov rax, 0
mov al, [r13]
mov rdi, rax
mov rsi, 1

push rdx
call insertHashMap
pop rdx

dec r12
inc r13
cmp r12, 1
jne .loop2

pop rcx

.loop3:
mov rax, 0
mov al, [r15]
mov rdi, rax
mov rsi, 1

inc r15

push rdi
push rdx
push rcx
mov rsi, rdx
call lookupHashMap
pop rcx
pop rdx
pop rdi

cmp rax, 0
je .loop3

push rdi
push rdx
push rcx
mov rsi, rcx
call lookupHashMap
pop rcx
pop rdx
pop rdi

cmp rax, 0
je .loop3

call letterToScore
ret

letterToScore:
cmp rdi, 'Z'
jg .lowercase
add rdi, 27
sub rdi, 'A'
mov rax, rdi
ret

.lowercase:
add rdi, 1
sub rdi, 'a'
mov rax, rdi
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d3.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
