global main
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
; rax: -1 if failed, 0 if succeeded
; rbx: total number
readElf:
mov rbx, 0 ; total

readElfLoop:
push rbx
call getLine
cmp rax, 1
je readElfDone
cmp rax, -1
je readElfDone

mov rdi, [lineptr]
call atoi

pop rbx
add rbx, rax
jmp readElfLoop

readElfDone:
pop rbx
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret

getLine:
mov rdi, 0
mov [lineptr], rdi
mov [numchrs], rsi

mov rdi, lineptr
mov rsi, numchrs
mov rdx, [filetag]

jmp getline

; rdi: list start
; rsi: list end
; rdx: thing to insert
insertList:
cmp rdi, rsi
je retLbl

mov rax, [rdi]
cmp rdx, rax
jg .greater
jmp .loopAround

.greater:
mov rbx, [rdi]
mov [rdi], rdx
mov rdx, rbx

.loopAround:
add rdi, 8
jmp insertList

; preserves rax thru rdx, also rdi and rsi
printA:
push rdi
mov rdi, a
call print
pop rdi
ret

; preserves rax thru rdx, also rsi
print:
push rsi
push rax
push rbx
push rcx
push rdx

mov rsi, rdi
mov rdi, strFmt
mov rax, 0
call printf

pop rdx
pop rcx
pop rbx
pop rax
pop rsi

ret

printNum:
mov rsi, rdi
mov rdi, numFmt
mov rax, 0
jmp printf

retLbl:
ret


section .data

fname: db `inputs/d1.txt`, 0
mode: db `r`, 0
filetag: dq 0
lineptr: dq 0
numchrs: dq 0
numFmt: db `%d\n`, 0
strFmt: db `%s\n`, 0
a: db `a`, 0

topListStart:
dq 0
dq 0
dq 0
topListEnd:
