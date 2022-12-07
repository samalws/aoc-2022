global getLine
global getNum
global insertList
global sumList
global printList
global printA
global printB
global print
global printNum
global retLbl

extern getline
extern printf
extern atoi

section .text

; rdi: filetag
; returns:
;   rax: num bytes read, or -1 if failed
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

; rdi: filetag
; returns:
;   rax: 0 if succeeded, -1 if failed, or 1 if read an empty line
;   rbx: number, assuming rax isn't -1 or 1
getNum:
call getLine
cmp rax, -1
je retLbl
cmp rax, 1
je retLbl

mov rdi, rbx
call atoi

mov rbx, rax
mov rax, 0
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

; preserves rax thru rdx, also rdi and rsi
printB:
push rdi
mov rdi, b
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

numFmt: db `%ld\n`, 0
strFmt: db `%s`, 0
a: db `a\n`, 0
b: db `b\n`, 0
