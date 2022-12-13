global main

numMonkesAllowed equ 8
numItemsAllowed equ 8

; from shared.s
extern numFromString
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
extern malloc
extern calloc
extern atoi

section .text

main:
mov rdi, 20
call mainStuff

mov qword [divBy], 1
mov rdi, 10000
call mainStuff

mov rax, 0
ret

mainStuff:
push rdi
mov qword [modBy], 1
call openFile
call parseFile
pop rdi

call simMonkesN
call monkeyBusinessLevel
mov rdi, rax
call printNum

ret

; returns:
; rsi: number of monkes
; r9: ptr to monke info array
; r15: ptr to monke item throw list array (wait wtf did i mean by "item throw list array")
; clobbers everything
parseFile:
mov r12, 0

mov rdi, 8*8*numMonkesAllowed
call malloc
mov r13, rax
mov r14, rax

mov rdi, 8*numMonkesAllowed
call calloc
mov r15, rax

; r12: num monkes (becomes rsi)
; r13: current loc in monke info array
; r14: monke info array (becomes r9)
; r15: ptr to throw list array

.loop:
mov rdi, [filetag]
call getLine
; "Monkey 0:"

cmp rax, -1
je .done
cmp rax, 1
je .done

mov rdi, 8*numItemsAllowed
call malloc
mov [r14], rax
add r14, 8
mov rdx, rax

push rdx
mov rdi, [filetag]
call getLine
pop rdx
; "  Starting items: 73, 77"
add rbx, 18
mov rdi, rbx

.parseNumListLoop:
inc qword [r14]

push rdx
call numFromString
add rdi, 2
pop rdx
mov [rdx], rax
add rdx, 8

cmp byte [rdi], 0
jne .parseNumListLoop

add r14, 8

mov rdi, [filetag]
call getLine
; "  Operation: new = old * 5"
add rbx, 23
cmp [rbx], byte '+'
je .plusOp

; mul or squared
add rbx, 2
cmp [rbx], byte 'o'
jne .mulOp

; squared
mov qword [r14], 1
add r14, 8
mov qword [r14], 1
add r14, 8
mov qword [r14], 0
add r14, 8
jmp .doneOps

.mulOp:
mov rdi, rbx
call atoi
mov qword [r14], 0
add r14, 8
mov [r14], rax
add r14, 8
mov qword [r14], 0
add r14, 8
jmp .doneOps

.plusOp:
add rbx, 2

mov rdi, rbx
call atoi
mov qword [r14], 0
add r14, 8
mov qword [r14], 1
add r14, 8
mov [r14], rax
add r14, 8
; jmp .doneOps

.doneOps:

mov rdi, [filetag]
call getLine
; "  Test: divisible by 11"
add rbx, 21
mov rdi, rbx
call atoi
mov [r14], rax
add r14, 8

mov rdx, [modBy]
mul rdx
mov [modBy], rax

mov rdi, [filetag]
call getLine
; "    If true: throw to monkey 6"
add rbx, 29
mov rdi, rbx
call atoi
mov [r14], rax
add r14, 8

mov rdi, [filetag]
call getLine
; "    If false: throw to monkey 5"
add rbx, 29
mov rdi, rbx
call atoi
mov [r14], rax
add r14, 8

inc r12

mov rdi, [filetag]
call getLine
; empty line

jmp .loop

.done:
mov rsi, r12
mov r9, r13
ret

; rdi: niter
; rsi: number of monkes
; r9: ptr to monke info array
; r15: ptr to monke item throw list array (wait wtf did i mean by "item throw list array")
; clobbers all regs except rsi and rbx
simMonkesN:
call simMonkes
dec rdi
cmp rdi, 0
jne simMonkesN
ret

; rsi: number of monkes
; r9: ptr to monke info array
; r15: ptr to monke item throw list array
; clobbers other regs except for rdi
simMonkes:
mov rcx, 0

.loop:
call simMonke
inc rcx
cmp rcx, rsi
jne .loop

ret

; r9: ptr to monke info array: [{ item queue ptr, num elems in queue, square op (1 or 0), mul op, add op, div check, throw to if true, throw to if false }]
; r15: ptr to monke item throw list array
; rcx: monke num
; clobbers other regs except for rsi and rdi
simMonke:
mov r10, rcx
shl r10, 3+3
add r10, r9

mov r11, r10
add r11, 8
mov r11, [r11]

mov rbx, 0

; rbx: which item we're looking at
; r10: current monke info
; r11: num of things in queue

.loop:
cmp rbx, r11
je .done
call simMonkeItem
inc rbx
jmp .loop
.done:

; add r11 to monke num
add [r15+8*rcx], r11

; set queue count to 0
mov qword [r10+8], 0

ret

; r9: ptr to monke info array
; r10: ptr to our entry in monke info array
; rbx: item num
; rcx: monke num
; clobbers other regs except for rsi, rdi, and r11-r15
simMonkeItem:
push r11

; rax <- [r10][8*rbx]
mov rax, [r10]
mov rax, [rax+8*rbx] ; wtf i love x86 now

; rax is worry level

cmp qword [r10+8*2], 0 ; wtf i love x86 now
je .dontSquare

mul qword rax ; wtf i love x86 now
jmp .doneOpping

.dontSquare:

mov rdx, [r10+8*3]
cmp rdx, 1
je .dontMul

mul rdx
jmp .doneOpping

.dontMul:

mov rdx, [r10+8*4]
cmp rdx, 0
je .dontAdd

add rax, rdx
; jmp .doneOpping

.dontAdd:
.doneOpping:
; wtf?

push rcx

mov rdx, 0
mov rcx, [divBy]
div rcx

mov rdx, 0
mov rcx, [modBy]
div rcx
mov rax, rdx

pop rcx

push rax
mov rdx, 0
div qword [r10+8*5]
pop rax
cmp rdx, 0
jne .falseCond
; jmp .trueCond

.trueCond:
mov rdx, [r10+8*6]
jmp .condDone

.falseCond:
mov rdx, [r10+8*7]
; jmp .condDone

.condDone:
; rax: item worry lvl
; rdx: which monkey to throw it to

; (1) rdx <- r9+8*8*rdx
; (2) r11 <- [rdx+8]
; (3) [rdx+8] ++
; (4) [rdx][r11*8] <- rax

; (1)
shl rdx, 3+3
add rdx, r9
; (2)
mov r11, [rdx+8]
; (3)
inc qword [rdx+8]
; (4)
mov rdx, [rdx]
mov [rdx+r11*8], rax

pop r11
ret

monkeyBusinessLevel:
;                                                               @                                                                                       
;                                                          @@@@@@@@@@@@@@@@@@@                                                                          
;                                                            @@@@@@@@@@@@@@ @@@@ @@@@                                                                   
;                                                        @@@@@@@ @@ @@@@@@@@@  @@@@@@@@@@@@  @@                                                         
;                                                    @@@@@@@@@@@@@@@@@@@@@ @@@@ @@ @@@@@  @@@@@@@@                                                      
;                                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@  @@@@@@@@@@                                                     
;                                              @ @@@ @@@ @@@@@@ @@@@@@@@@@@@ @@@@@@@@ @@@@ @@@@@@ @@@                                                   
;                                               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @ @@@@@@@@@@@@@@@@@@@@@                                                 
;                                             @@ @@@@@@@    @@@@@@@@@@ @@@@@@@ @@@ @@@  @@@@@ @@@@@@@@ @@                                               
;                                           @@@@@@@@@         @@@@@@@@@@@@@@@@@@@@@@@@ @@@@   @@@@@@@@@@@                                               
;                                          @@@ @@@@@               @ @@@@@@@@@@@@@@@@@@@@  @   @ @@@@@@@ @                                              
;                                        @@@@@@@ @@                     @      @@@@@  @@         @@@@@@@@@@                                             
;                                      @@@@@@@@@@@                                                 @@@@@ @@@                                            
;                                        @@@@@@@@            @@@@@@@@@@@@@@@@@                       @@@@@ @                                            
;                                        @@@@@@@                              @@@@@@@@@@              @@@@@@@                                           
;                                        @@ @@@@                                                       @@@@@@@                                          
;                                        @@@@@@@@@                                                   @@ @@@@@@                                          
;                                        @@@@@@@                                     @@@@@@@@@@@       @@ @@@@                                          
;                                        @@@@@@              @@@@@              @@@@@@@@@@@@@@@@@@@    @@@@@ @                                          
;                                        @@@@@@       @@@@@@@@@@@@@            @@@  @@@@@@@@@@@@@@      @@@@@@@@@                                       
;                                         @@ @    @@@@@@@@@@@@@@@@            @@                    @@@@@@@@@    @                                      
;                                         @@@@ @@@@@       @@@@     @@@@@@@@@@    @ @@@@@@  @@      @@@  @@@     @                                      
;                                       @   @@@        @ @@@@@   @   @       @@                     @     @@   @ @                                      
;                                       @   @ @       @@@@@@@@@      @       @ @                  @@            @@                                      
;                                       @ @   @@                   @@        @   &@@@@@@@@@@               @@@ @@                                       
;                                        @                             @     @                             @@ @                                         
;                                        @@ @@@@                       @      @                              @                                          
;                                         @@ @@                        @                                    @                                           
;                                          @@ @                   @@                 @                      @                                           
;                                            @                    @                 @@                      @                                           
;                                             @@                  @@  @@@@@@@@@                            @                                            
;                                               @                      @@ @@ @@  @@@                       @                                            
;                                               @@                     @  @@@@ @@ @@@@@@@@@ @              @@@@                                         
;                                            @@   @            @ @ @   @@@   @@@  @@@@    @@@              @@    @@@                                    
;                                       @@@         @        @@@@@@@@@@  @  @@@@@@@@@@@@ @@ @@@           @  @         @@@@                             
;                                  @@@               @         @  @@@@@@@@@@@@@@@@@@@@@@@ @@ @@          @    @                @@                       
;                            @@@                      @         @ @ @@@@@@@@@@@@@@@@@@@@  @  @@         @     @@                    @@@                 
;                        @@                             @      @@@ @  @@@@@@@@@@@@@@@@   @ @@@@@     @ @@      @                          @@@           
;                  @@@                                   @    @@@@@@@@@  @@@@@@@@@@     @    @@ @ @@   @@@     @                                   @@@  
;            @@@                                          @@@@   @@@    @@             @     @@ @@@ @@@@@      @                                        
;       @@                                                 @@@@@  @@       @@       @@    @@@@@@@ @ @          @                                        
;  @@@                                                     @@  @@@@                          @@@@@@@          @                                         
;                                                           @    @@@ @@                      @@ @@          @                                           
;                                                            @      @ @@@                  @@ @@          @                                             
;                                                              @    @@@@@@@  @@           @@@@          @                                               
;                                                               @@   @@@@@@@ @@@  @@ @@@@@@          @@                                                 
;                                                                    @@@   @   @@  @     @       @@                                                     
;                                                                             @@@@@@@@@@@@@@@@                                                          
; rsi: number of monkes
; r15: ptr to monke item throw list array
; returns into rax
; clobbers rdx

push rsi
push r12
push r13
push r14
push r15

mov r13, 0
mov r14, 0

; rsi: monkes left
; r12: current num
; r13: highest num
; r14: second highest num
; r15: pointer to our place in monke list

.loop:
mov r12, [r15]

cmp r12, r13
jle .doneSwap13

mov rax, r13
mov r13, r12
mov r12, rax

.doneSwap13:
cmp r12, r14
jle .doneSwap14

mov rax, r14
mov r14, r12
mov r12, rax

.doneSwap14:

add r15, 8
dec rsi
cmp rsi, 0
jne .loop

mov rax, r13
mul r14

pop r12
pop r13
pop r14
pop r15
pop rsi
ret


openFile:
mov rdi, fname
mov rsi, mode
call fopen
mov [filetag], rax
ret


section .rodata

fname: db `inputs/d11.txt`, 0
mode: db `r`, 0

section .data

filetag: dq 0
divBy: dq 3
modBy: dq 1
