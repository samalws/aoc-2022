global allocHashMap
global insertHashMap
global lookupHashMap

extern malloc
extern calloc

; hashmap: map from int (8 bit) to int (8 bit)
; hashmap structure: capacity, space taken up, [capacity] buckets (pointers to linked lists)
; linked list structure: key, value, ptr to next linked list (or 0 if final element)

; -------------- ALLOC HASH MAP --------------

; rdi: initial capacity
; returns to rax
allocHashMap:
push rdi
shl rdi, 3
add rdi, 16
mov rsi, 1
call calloc
pop rdi
mov [rax], rdi
ret

; -------------- INSERT INTO HASH MAP --------------

; rdi: key
; rsi: value
; rdx: map
insertHashMap:
; TODO check if it needs to be resized

insertHashMapNoResize:
push rdx
call getBucket

; rdi: key
; rsi: value
; rdx: bucket
insertToBucket:
mov rbx, [rdx]
cmp rbx, 0
je allocLinkedList
mov rdx, rbx

; check that this elem doesn't have our key
mov rax, [rdx]
cmp rax, rdi
je .replaceThisOne

add rdx, 16
jmp insertToBucket ; loop around

.replaceThisOne:
add rdx, 8
mov [rdx], rsi
add rsp, 8 ; rdx value stored
ret

; rdi: key
; rsi: value
; rdx: where to put it
allocLinkedList:
push rdi
push rsi
push rdx

mov rdi, 24
call malloc

pop rdx
pop rsi
pop rdi

mov [rdx], rax
mov [rax], rdi
mov [rax+8], rsi
mov rbx, 0
mov [rax+16], rbx

; increase number elements by 1
pop rdx
add rdx, 8
mov rax, [rdx]
inc rax
mov [rdx], rax

ret

; -------------- LOOKUP IN HASH MAP --------------

; rdi: key
; rsi: map
; returns value to rax (0 if none found)
lookupHashMap:
mov rdx, rsi
call getBucket

; rdi: key
; rdx: bucket
; returns value to rax (0 if none found)
lookupInBucket:
mov rbx, [rdx]
cmp rbx, 0
je .noneFound
mov rdx, rbx
mov rax, [rdx]
cmp rax, rdi
je .found
add rdx, 16
jmp lookupInBucket ; loop around

.noneFound:
mov rax, 0
ret

.found:
mov rax, [rdx+8]
ret

; -------------- HELPERS --------------

; rdi: key
; rdx: map
; ret val goes into rdx
; clobbers rax only
getBucket:
call hash ; hash is in rax
shl rax, 3
add rdx, 16
add rdx, rax
ret

; rdi: num to hash
; ret val goes into rax
; other params?
; doesn't clobber anything
hash:
; mov rax, rdi
mov rax, 0
ret
