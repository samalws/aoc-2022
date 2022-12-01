global getLine
global insertList
global printA
global print
global printNum

extern getline
extern printf

section .text

; rdi: filetag
; returns:
;   rax: num bytes read
;   rbx: string pointer
getLine:
mov rdx, rdi

mov rdi, 0
mov [lineptr], rdi
mov [numchrs], rsi

mov rdi, lineptr
mov rsi, numchrs

call getline
mov rbx, [lineptr]
ret

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

lineptr: dq 0
numchrs: dq 0
numFmt: db `%d\n`, 0
strFmt: db `%s\n`, 0
a: db `a`, 0
