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

mov rdi, rax
call printNum

mov rdi, 5
mov rsi, 10
mov rdx, [hashMapLoc]
call insertHashMap

mov rdi, 5
mov rsi, [hashMapLoc]
call lookupHashMap

mov rdi, rax
call printNum

mov rax, 0
ret

section .data

hashMapLoc: dq 0
