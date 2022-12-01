global getLine
global insertList
global sumList
global printList
global printA
global print
global printNum
global retLbl

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
push rdi
push rdi

mov rdi, rsp
add rdi, 8
mov rsi, rsp

call getline
pop rbx
pop rbx
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

; rdi: list start
; rsi: list end
sumList:
mov rax, 0

.loop:
cmp rdi, rsi
je retLbl
mov rbx, [rdi]
add rax, rbx
add rdi, 8
jmp .loop

; rdi: list start
; rsi: list end
printList:
cmp rdi, rsi
je retLbl
push rdi
push rsi
mov rdi, [rdi]
call printNum
pop rsi
pop rdi
add rdi, 8
jmp printList

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


section .rodata

numFmt: db `%d\n`, 0
strFmt: db `%s`, 0
a: db `a\n`, 0
