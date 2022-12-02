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
call getScores
mov rdi, rax
call printNum

mov rax, 0
ret

getScores:
mov rcx, 0

.loop:
push rcx
mov rdi, [filetag]
call getLine

cmp rax, -1
je .done
cmp rax, 1
je .done

mov rdi, rbx
call getIndividualScore
pop rcx
add rcx, rax
jmp .loop

.done:
pop rax
ret

; rdi: string
; returns rax: score
getIndividualScore:
mov rax, 0
mov rbx, 0
mov rcx, 0
mov bl, [rdi]
mov cl, [rdi+2]
sub bl, 'A'
sub cl, 'X'

add al, bl
add al, bl
add al, bl
add al, cl
add rax, lut

mov rbx, 0
mov bl, [rax]
mov rax, rbx

ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d2.txt`, 0
mode: db `r`, 0

lut0:
db 3+1 ; A X
db 6+2 ; A Y
db 0+3 ; A Z
db 0+1 ; B X
db 3+2 ; B Y
db 6+3 ; B Z
db 6+1 ; C X
db 0+2 ; C Y
db 3+3 ; C Z

lut:
db 0+3 ; A X
db 3+1 ; A Y
db 6+2 ; A Z
db 0+1 ; B X
db 3+2 ; B Y
db 6+3 ; B Z
db 0+2 ; C X
db 3+3 ; C Y
db 6+1 ; C Z

section .data

filetag: dq 0
