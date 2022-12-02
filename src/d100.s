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

mov rdi, 20
call allocHashMap
mov [hashMapLoc], rax

mov rdi, 5
mov rsi, [hashMapLoc]
call lookupHashMap

push rbx
mov rdi, rax
call printNum
pop rdi
call printNum

mov rdi, 5
mov rsi, 10
mov rdx, [hashMapLoc]
call insertHashMap

mov rdi, 7
mov rsi, 20
mov rdx, [hashMapLoc]
call insertHashMap


mov rdi, [hashMapLoc]
call enumerateHashMap

mov rdi, rax
mov rsi, rbx
call printList

mov rdi, [hashMapLoc]
call getHashMapSize

mov rdi, rax
call printNum

mov rdi, 5
mov rsi, [hashMapLoc]
call lookupHashMap

push rbx
mov rdi, rax
call printNum
pop rdi
call printNum

mov rdi, 5
mov rsi, [hashMapLoc]
call deleteHashMap

mov rdi, rax
call printNum

mov rdi, [hashMapLoc]
call getHashMapSize

mov rdi, rax
call printNum

mov rdi, 5
mov rsi, [hashMapLoc]
call lookupHashMap

push rbx
mov rdi, rax
call printNum
pop rdi
call printNum

mov rax, 0
ret

section .data

hashMapLoc: dq 0
