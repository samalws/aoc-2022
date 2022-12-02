global allocHashMap
global insertHashMap
global lookupHashMap
global deleteHashMap
global getHashMapSize
global enumerateHashMap

extern malloc
extern calloc
extern free

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
; returns 0 if not present, 1 if present, into rax
insertHashMap:
; TODO check if it needs to be resized

insertHashMapNoResize:
push rdx ; to backup in order to increase num elements; popped right before returning
call getBucket

; rdi: key
; rsi: value
; rdx: bucket
; top of stack: the map it came from
; returns 0 if not present, 1 if present, into rax
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
mov rax, 1
ret

; rdi: key
; rsi: value
; rdx: where to put it
; top of stack: the map it came from
; puts 0 into rax
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
mov rax, [rdx+8]
inc rax
mov [rdx+8], rax

mov rax, 0

ret

; -------------- LOOKUP IN HASH MAP --------------

; rdi: key
; rsi: map
; returns value to rax (0 if none found)
; puts a 0 into rbx if none found, 1 into rbx if something was found
lookupHashMap:
mov rdx, rsi
call getBucket

; rdi: key
; rdx: bucket
; returns value to rax (0 if none found)
; rbx: 0 if not found, 1 if found
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
mov rbx, 0
ret

.found:
mov rax, [rdx+8]
mov rbx, 1
ret

; -------------- DELETE FROM HASH MAP --------------

; rdi: key
; rsi: map
; returns 0 if not present, 1 if present, into rax
deleteHashMap:
mov rdx, rsi
push rdx
call getBucket

; rdi: key
; rdx: bucket
; top of stack: map it came from
; returns rax: 0 if not found, 1 if found
deleteInBucket:
mov rbx, [rdx] ; address of linked list
cmp rbx, 0
je .noneFound
mov rax, [rbx]
cmp rax, rdi
je .found
mov rdx, rbx
add rdx, 16
jmp deleteInBucket ; loop around

.noneFound:
mov rax, 0
add rsp, 8
ret

.found:
; rdx: pointer to prev bucket
; rbx: pointer to bucket containing key
; top of stack: map it came from
mov rax, [rbx+16]
mov [rdx], rax
mov rdi, rbx
call free

pop rdx
mov rax, [rdx+8]
dec rax
mov [rdx+8], rax

mov rax, 1
ret

; -------------- GET SIZE --------------

; rdi: map
; returns into rax
; doesn't clobber anything
getHashMapSize:
mov rax, [rdi+8]
ret

; -------------- ENUMERATE --------------

; rdi: map
; returns rax: list, rbx: end of list
enumerateHashMap:
push rdi

call getHashMapSize

cmp rax, 0
je .empty

shl rax, 3
shl rax, 1 ; key, value
push rax
call malloc

pop rbx
pop rdi
push rax

add rbx, rax

; rdi: map
; rax: list loc to write to
; rbx: end of list
; top of stack: beginning of list

add rdi, 16

.bucketLoop:
push rdi
call .linkedListLoop
pop rdi
add rdi, 8
jmp .bucketLoop ; loop around

; rdi: ptr to linked list
; rax: list loc to write to
; rbx: end of list
; top of stack: return addr
; second on stack: bucket we came from
; third on stack: beginning of list
.linkedListLoop:
mov rcx, [rdi]
cmp rcx, 0
je retLbl

mov rdx, [rcx] ; key
mov [rax], rdx
mov rdx, [rcx+8] ; value
mov [rax+8], rdx
add rax, 16

cmp rax, rbx
je .done

mov rdi, rcx
add rdi, 16
jmp .linkedListLoop ; loop around

.done:
add rsp, 16
pop rax
ret

.empty:
mov rax, 0
mov rbx, 0
add rsp, 8
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

retLbl:
ret
