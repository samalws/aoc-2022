.global main

.text

main:
call openFile

mov $0, %rcx

mainLoop:
call readElf

cmp $-1, %rax
je .done
mov %rbx, %rdx
mov $topListStart, %rdi
mov $topListEnd, %rsi
call insertList
jmp mainLoop

.done:
mov topListStart, %rdi
call printNum
mov topListStart, %rdi
mov topListStart+8, %rax
add %rax, %rdi
mov topListStart+16, %rax
add %rax, %rdi
call printNum

# returns:
# rax: -1 if failed, 0 if succeeded
# rbx: total number
readElf:
mov $0, %rbx # total

readElfLoop:
push %rbx
call getLine
cmp $1, %rax
je readElfDone
cmp $-1, %rax
je readElfDone

mov lineptr, %rdi
call atoi

pop %rbx
add %rax, %rbx
jmp readElfLoop

readElfDone:
pop %rbx
ret

openFile:
mov $fname, %rdi
mov $mode, %rsi
call fopen
mov %rax, filetag
ret

getLine:
mov $0, %rdi
mov %rdi, lineptr
mov %rdi, numchrs

mov $lineptr, %rdi
mov $numchrs, %rsi
mov filetag, %rdx

jmp getline

# preserves rax thru rdx, also rdi and rsi

push %rdi
mov $a, %rdi
call print
pop %rdi
ret

# rdi: list start
# rsi: list end
# rdx: thing to insert
insertList:
cmp %rdi, %rsi
je retLbl

mov (%rdi), %rax
cmp %rax, %rdx
jg insertGreater
jmp insertLoopAround

insertGreater:
mov (%rdi), %rbx
mov %rdx, (%rdi)
mov %rbx, %rdx

insertLoopAround:
add $8, %rdi
jmp insertList

# preserves rax thru rdx, also rdi and rsi
printA:
push %rdi
mov $a, %rdi
call print
pop %rdi
ret

# preserves rax thru rdx, also rsi
print:
push %rsi
push %rax
push %rbx
push %rcx
push %rdx

mov %rdi, %rsi
mov $strFmt, %rdi
mov $0, %rax
call printf

pop %rdx
pop %rcx
pop %rbx
pop %rax
pop %rsi

ret

printNum:
mov %rdi, %rsi
mov $numFmt, %rdi
mov $0, %rax
jmp printf

retLbl:
ret


.data

fname: .asciz "inputs/d1.txt"
mode: .asciz "r"
filetag: .quad 0
lineptr: .quad 0
numchrs: .quad 0
numFmt: .asciz "%d\n"
strFmt: .asciz "%s\n"
a: .asciz "a"

topListStart:
.quad 0
.quad 0
.quad 0
topListEnd:
