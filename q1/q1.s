    .text

# struct Node* make_node(int val)
# a0 = val
# returns pointer in a0
    .globl make_node
make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)

    mv s0, a0              # save val

    li a0, 24              # sizeof(struct Node)
    call malloc

    beqz a0, make_node_end # if malloc fails, return NULL

    sw s0, 0(a0)           # node->val = val
    sd zero, 8(a0)         # node->left = NULL
    sd zero, 16(a0)        # node->right = NULL

make_node_end:
    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 16
    ret


# struct Node* insert(struct Node* root, int val)
# a0 = root, a1 = val
# returns root in a0
    .globl insert
insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    mv s0, a0              # original root
    mv s1, a1              # val

    beqz s0, insert_empty  # if root == NULL, create new node

    mv s2, s0              # curr = root

insert_loop:
    lw t0, 0(s2)           # curr->val
    blt s1, t0, insert_left
    bgt s1, t0, insert_right
    j insert_done          # if equal, do nothing

insert_left:
    ld t1, 8(s2)           # curr->left
    beqz t1, insert_here_left
    mv s2, t1
    j insert_loop

insert_here_left:
    mv a0, s1
    call make_node
    sd a0, 8(s2)
    j insert_done

insert_right:
    ld t1, 16(s2)          # curr->right
    beqz t1, insert_here_right
    mv s2, t1
    j insert_loop

insert_here_right:
    mv a0, s1
    call make_node
    sd a0, 16(s2)
    j insert_done

insert_empty:
    mv a0, s1
    call make_node
    j insert_return

insert_done:
    mv a0, s0

insert_return:
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    ld s2, 0(sp)
    addi sp, sp, 32
    ret


# struct Node* get(struct Node* root, int val)
# a0 = root, a1 = val
# returns pointer to node or NULL
    .globl get
get:
get_loop:
    beqz a0, get_not_found

    lw t0, 0(a0)
    beq a1, t0, get_found
    blt a1, t0, get_go_left

    ld a0, 16(a0)          # root = root->right
    j get_loop

get_go_left:
    ld a0, 8(a0)           # root = root->left
    j get_loop

get_found:
    ret

get_not_found:
    li a0, 0
    ret


# int getAtMost(int val, struct Node* root)
# a0 = val, a1 = root
# return greatest value <= val, or -1 if none exists
    .globl getAtMost
getAtMost:
    li t0, -1              # best = -1

getAtMost_loop:
    beqz a1, getAtMost_done

    lw t1, 0(a1)           # curr->val

    ble t1, a0, getAtMost_take
    ld a1, 8(a1)           # go left
    j getAtMost_loop

getAtMost_take:
    mv t0, t1              # best = curr->val
    ld a1, 16(a1)          # try right for a larger valid value
    j getAtMost_loop

getAtMost_done:
    mv a0, t0
    ret