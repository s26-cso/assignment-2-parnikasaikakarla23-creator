    .section .rodata
fmt_first:
    .string "%d"
fmt_rest:
    .string " %d"
fmt_nl:
    .string "\n"

    .text
    .globl main

# int main(int argc, char **argv)
main:
    addi sp, sp, -96
    sd ra, 88(sp)
    sd s0, 80(sp)
    sd s1, 72(sp)
    sd s2, 64(sp)
    sd s3, 56(sp)
    sd s4, 48(sp)
    sd s5, 40(sp)
    sd s6, 32(sp)
    sd s7, 24(sp)
    sd s8, 16(sp)
    sd s9, 8(sp)
    sd s10, 0(sp)

    mv s0, a0                  # argc
    mv s1, a1                  # argv

    addi s2, s0, -1            # n = argc - 1
    blez s2, only_newline

    # arr = malloc(4*n)
    slli a0, s2, 2
    call malloc
    mv s3, a0

    # result = malloc(4*n)
    slli a0, s2, 2
    call malloc
    mv s4, a0

    # stack = malloc(4*n)   (stores indices)
    slli a0, s2, 2
    call malloc
    mv s5, a0

    # parse argv[1..] into arr[0..n-1]
    li s6, 0                   # i = 0
parse_loop:
    bge s6, s2, init_result

    addi t0, s6, 1             # argv index = i+1
    slli t1, t0, 3             # 8 bytes per argv pointer
    add t2, s1, t1
    ld a0, 0(t2)
    call atoi

    slli t3, s6, 2
    add t4, s3, t3
    sw a0, 0(t4)

    addi s6, s6, 1
    j parse_loop

    # result[i] = -1
init_result:
    li s6, 0
init_loop:
    bge s6, s2, nge_start
    slli t0, s6, 2
    add t1, s4, t0
    li t2, -1
    sw t2, 0(t1)
    addi s6, s6, 1
    j init_loop

nge_start:
    li s6, -1                  # top = -1
    addi s7, s2, -1            # i = n-1

outer_loop:
    bltz s7, print_ans

while_loop:
    bltz s6, after_while       # if top < 0, stack empty

    # idx = stack[top]
    slli t0, s6, 2
    add t1, s5, t0
    lw t2, 0(t1)               # t2 = stack[top]

    # arr[idx]
    slli t3, t2, 2
    add t4, s3, t3
    lw t5, 0(t4)

    # arr[i]
    slli t6, s7, 2
    add a1, s3, t6
    lw a2, 0(a1)

    ble t5, a2, pop_stack
    j after_while

pop_stack:
    addi s6, s6, -1
    j while_loop

after_while:
    bltz s6, push_i

    # result[i] = stack[top]
    slli t0, s6, 2
    add t1, s5, t0
    lw t2, 0(t1)

    slli t3, s7, 2
    add t4, s4, t3
    sw t2, 0(t4)

push_i:
    addi s6, s6, 1             # ++top
    slli t0, s6, 2
    add t1, s5, t0
    sw s7, 0(t1)               # stack[top] = i

    addi s7, s7, -1
    j outer_loop

print_ans:
    li s7, 0

    # print first
    slli t0, s7, 2
    add t1, s4, t0
    lw a1, 0(t1)
    la a0, fmt_first
    call printf

    addi s7, s7, 1

print_loop:
    bge s7, s2, print_nl

    slli t0, s7, 2
    add t1, s4, t0
    lw a1, 0(t1)
    la a0, fmt_rest
    call printf

    addi s7, s7, 1
    j print_loop

print_nl:
    la a0, fmt_nl
    call printf
    j done

only_newline:
    la a0, fmt_nl
    call printf

done:
    li a0, 0
    ld ra, 88(sp)
    ld s0, 80(sp)
    ld s1, 72(sp)
    ld s2, 64(sp)
    ld s3, 56(sp)
    ld s4, 48(sp)
    ld s5, 40(sp)
    ld s6, 32(sp)
    ld s7, 24(sp)
    ld s8, 16(sp)
    ld s9, 8(sp)
    ld s10, 0(sp)
    addi sp, sp, 96
    ret