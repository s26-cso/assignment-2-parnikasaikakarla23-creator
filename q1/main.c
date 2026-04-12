#include <stdio.h>
#include <stdlib.h>

struct Node {
    int val;
    struct Node* left;
    struct Node* right;
};

struct Node* make_node(int val);
struct Node* insert(struct Node* root, int val);
struct Node* get(struct Node* root, int val);
int getAtMost(int val, struct Node* root);

int main() {
    struct Node* root = NULL;

    // insert values
    root = insert(root, 10);
    root = insert(root, 5);
    root = insert(root, 15);
    root = insert(root, 3);
    root = insert(root, 7);
    root = insert(root, 12);

    // test get()
    struct Node* x = get(root, 7);
    if (x) printf("Found: %d\n", x->val);
    else printf("Not found\n");

    // test getAtMost()
    printf("<= 11: %d\n", getAtMost(11, root));
    printf("<= 5: %d\n", getAtMost(5, root));
    printf("<= 2: %d\n", getAtMost(2, root));

    return 0;
}