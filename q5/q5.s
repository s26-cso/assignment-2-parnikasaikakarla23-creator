    .section .data
filename:
    .asciz "input.txt"

yes_msg:
    .asciz "Yes\n"

no_msg:
    .asciz "No\n"

    .section .bss
    .align 1
left_char:
    .space 1
right_char:
    .space 1

    .section .text
    .globl _start

_start:
    # openat(AT_FDCWD, "input.txt", O_RDONLY, 0)
    li a0, -100              # AT_FDCWD
    la a1, filename
    li a2, 0                 # O_RDONLY
    li a3, 0
    li a7, 56                # syscall: openat
    ecall
    bltz a0, print_no        # if fd < 0 => fail
    mv s0, a0                # s0 = fd

    # size = lseek(fd, 0, SEEK_END)
    mv a0, s0
    li a1, 0
    li a2, 2                 # SEEK_END
    li a7, 62                # syscall: lseek
    ecall
    bltz a0, close_and_no
    mv s1, a0                # s1 = file size

    # empty string => palindrome
    beqz s1, close_and_yes

    li s2, 0                 # s2 = left = 0
    addi s3, s1, -1          # s3 = right = size - 1

loop_check:
    # while (left < right)
    bge s2, s3, close_and_yes

    # lseek(fd, left, SEEK_SET)
    mv a0, s0
    mv a1, s2
    li a2, 0                 # SEEK_SET
    li a7, 62                # lseek
    ecall
    bltz a0, close_and_no

    # read(fd, &left_char, 1)
    mv a0, s0
    la a1, left_char
    li a2, 1
    li a7, 63                # read
    ecall
    li t0, 1
    bne a0, t0, close_and_no

    # lseek(fd, right, SEEK_SET)
    mv a0, s0
    mv a1, s3
    li a2, 0                 # SEEK_SET
    li a7, 62                # lseek
    ecall
    bltz a0, close_and_no

    # read(fd, &right_char, 1)
    mv a0, s0
    la a1, right_char
    li a2, 1
    li a7, 63                # read
    ecall
    li t0, 1
    bne a0, t0, close_and_no

    # compare left_char and right_char
    la t1, left_char
    lbu t2, 0(t1)

    la t1, right_char
    lbu t3, 0(t1)

    bne t2, t3, close_and_no

    addi s2, s2, 1           # left++
    addi s3, s3, -1          # right--
    j loop_check

close_and_yes:
    # close(fd)
    mv a0, s0
    li a7, 57                # close
    ecall
    j print_yes

close_and_no:
    # close(fd)
    mv a0, s0
    li a7, 57                # close
    ecall
    j print_no

print_yes:
    li a0, 1                 # stdout
    la a1, yes_msg
    li a2, 4                 # length of "Yes\n"
    li a7, 64                # write
    ecall

    li a0, 0
    li a7, 93                # exit
    ecall

print_no:
    li a0, 1                 # stdout
    la a1, no_msg
    li a2, 3                 # length of "No\n"
    li a7, 64                # write
    ecall

    li a0, 0
    li a7, 93                # exit
    ecall