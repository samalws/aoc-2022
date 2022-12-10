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
extern strcpy

section .text

main:
call openFile
call runFile
mov rdi, rax
call printNum

mov rax, 0
ret

runFile:
call parseFile
call checkAllDirsAllLocs
jmp sumBoolMap

; returns:
; r9: x size
; r10: y size
; r11: map
; r15: bool map
parseFile:
mov rdi, 10000 ; lol
call calloc
mov r15, rax

mov rdi, 10000 ; lol
call calloc ; lol
push rax ; for returning map (r11)
mov r14, rax ; the tmp version for writing to

mov r13, 0 ; will be y size (r10), we move it later

.loop:

push r9
mov rdi, [filetag]
call getLine
pop r9

cmp rax, 1
je .done
cmp rax, -1
je .done

dec rax

push rax

mov rdi, r14
mov rsi, rbx
call strcpy

pop r9

add r14, r9
inc r13

jmp .loop

.done:
pop r11
mov r10, r13
ret

; r9: x size
; r10: y size
; r11: map
; r15: bool map
checkAllDirsAllLocs:
mov rcx, 0
mov rdx, 1
call checkDirAllLocs

mov rcx, 0
mov rdx, -1
call checkDirAllLocs

mov rdx, 0
mov rcx, 1
call checkDirAllLocs

mov rdx, 0
mov rcx, -1
jmp checkDirAllLocs

; rcx: dx
; rdx: dy
; r9: x size
; r10: y size
; r11: map
; r15: bool map
; only clobbers rax and rbx
checkDirAllLocs:
push r15

mov rax, 0
mov rbx, 0

push r11
mov r11, r15
call lookupMapLoc
mov r15, r11
pop r11

; rax: x
; rbx: y
; r15: our loc in bool map

.loop:
push rax
call checkDir
or [r15], al
pop rax

inc rax
inc r15

cmp rax, r9
jl .loop
; jmp .xLoop

.xLoop:
mov rax, 0
inc rbx

cmp rbx, r10
jl .loop
; jmp .done

.done:
pop r15
ret

; rax: x
; rbx: y
; rcx: dx
; rdx: dy
; r9: x size
; r10: y size
; r11: map
; returns into al
; doesn't clobber
checkDir:
push rbx
push r11
push r12
push r13

call lookupMapLoc
call getMoveIncrement
call readMapLoc
mov r13, r14

; r11: map index for point we're looking at
; r12: increment to add to r11 each time we move
; r13: value of starting point

.loop:

add r11, r12
add rax, rcx
add rbx, rdx

cmp rax, -1
je .true
cmp rax, r9
je .true
cmp rbx, -1
je .true
cmp rbx, r10
je .true

call readMapLoc
.compare:
cmp r13, r14
jg .loop
; jmp .false

.false:
mov al, 0
jmp .done

.true:
mov al, 1
; jmp .done

.done:
pop r13
pop r12
pop r11
pop rbx
ret

; r11: loc in map
; returns into r14
; doesn't clobber
readMapLoc:
push rax
mov rax, 0
mov al, [r11]
mov r14, rax
pop rax
ret

; rcx: dx
; rdx: dy
; r9: x size
; returns into r12
; doesn't clobber
; r12 <- rcx + (rdx*r9)
getMoveIncrement:
push rax
push rdx

mov rax, r9
imul rdx
mov r12, rax
add r12, rcx

pop rdx
pop rax

ret

; rax: x
; rbx: y
; r9: x size
; r11: map
; returns into r11
; doesn't clobber
; r11 <- r11 + rax + (rbx*r9)
lookupMapLoc:
push rdx
push rax
mov rax, r9
imul rbx
add r11, rax
pop rax
add r11, rax
pop rdx
ret

; r9: x size
; r10: y size
; r15: bool map
; returns into rax
; clobbers
sumBoolMap:
; r14 gets limit
; r14 <- r15 + r9*r10

mov rax, r9
imul r10
mov r14, r15
add r14, rax

mov rax, 0
mov rbx, 0

.loop:
mov bl, [r15]
add rax, rbx

inc r15
cmp r15, r14
jne .loop
; jmp .done

.done:
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d8.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
