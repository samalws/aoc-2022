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
extern atoi

section .text

main:
call openFile
call simRope
mov rdi, rax
call printNum

mov rax, 0
ret

simRope:
push r15

mov rdi, 100
call allocHashMap
mov r15, rax

mov rdi, 0
mov rsi, 0

.loop:
push rdi
push rsi

mov rdi, [filetag]
call getLine

cmp rax, -1
je .done
cmp rax, 1
je .done

push rbx

mov rdi, rbx
add rdi, 2
call atoi
mov rcx, rax

pop rbx
mov dl, [rbx]

pop rsi
pop rdi

call multiMovement
jmp .loop

.done:
add rsp, 16
mov rdi, r15
call getHashMapSize
pop r15
x:
ret

; rdi: head pos
; rsi: tail pos
; dl: direction (char)
; rcx: movement amount
; r15: hashmap
; returns rdi and rsi: new head and tail positions
multiMovement:
push rdx
push rcx

push rsi

call moveHead
mov rdi, rax

pop rsi
push rdi

call moveTail

push rax

mov rdi, rax
mov rsi, 0
mov rdx, r15
call insertHashMap

pop rsi
pop rdi

pop rcx
pop rdx

dec rcx
cmp rcx, 0
jne multiMovement
ret

; rdi: head pos (x,y 32 bits each)
; dl: direction (char)
; returns rax: new head pos
; clobbers rdi, rsi, rdx, rbx
moveHead:
call directionLookup
mov rsi, rax
jmp addPositions

; rdi: head pos
; rsi: tail pos
; returns rax: new tail pos
; clobbers rdi, rsi, rdx, rbx
moveTail:
push rdi
push rsi

sub esi, edi
cmp esi, 2
je .moving
neg esi
cmp esi, 2
je .moving

pop rsi
pop rdi
push rdi
push rsi

shr rdi, 4*8
shr rsi, 4*8

sub esi, edi
cmp esi, 2
je .moving
neg esi
cmp esi, 2
je .moving

pop rax
add rsp, 8
ret

.moving:
pop rsi
pop rdi
push rdi
push rsi

shr rdi, 4*8
shr rsi, 4*8

cmp esi, edi
jl .goRight
jg .goLeft
pop rsi
jmp .doneLR

.goRight:
pop rdi ; used to be rsi
mov dl, 'R'
call moveHead
mov rsi, rax
jmp .doneLR

.goLeft:
pop rdi
mov dl, 'L'
call moveHead
mov rsi, rax
; jmp .doneLR

.doneLR:
pop rdi
cmp esi, edi
jl .goUp
jg .goDown

; eq
mov rax, rsi
ret

.goUp:
mov rdi, rsi
mov dl, 'U'
jmp moveHead

.goDown:
mov rdi, rsi
mov dl, 'D'
jmp moveHead

; rdi: pos 1
; rsi: pos 2
; returned into rax
; clobbers rbx
addPositions:
mov rbx, rdi
shr rbx, 4*8
mov rax, rsi
shr rax, 4*8
add ebx, eax
mov rax, 0
mov eax, edi
add eax, esi
shl rbx, 4*8
add rax, rbx
ret

; dl: direction (char)
; returns rax: direction as x,y
; doesn't clobber
directionLookup:
cmp dl, 'U'
je up
cmp dl, 'D'
je down
cmp dl, 'L'
je left
; cmp dl, 'R'
; je right

right:
mov eax, 1
shl rax, 4*8
ret

left:
mov eax, -1
shl rax, 4*8
ret

up:
mov rax, 1
ret

down:
mov rax, 0
mov eax, -1
ret

openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d9.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
