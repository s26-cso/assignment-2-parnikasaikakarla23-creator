#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

typedef int (*op_func_t)(int, int);

int main(void) {
    char op[6];              // op is guaranteed to be at most 5 chars
    int num1, num2;

    while (scanf("%5s %d %d", op, &num1, &num2) == 3) {
        char libname[16];
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        void *handle = dlopen(libname, RTLD_NOW);
        if (handle == NULL) {
            fprintf(stderr, "Failed to load %s: %s\n", libname, dlerror());
            continue;
        }

        dlerror(); // clear any old error

        op_func_t func = (op_func_t)dlsym(handle, op);
        char *err = dlerror();
        if (err != NULL) {
            fprintf(stderr, "Failed to find symbol %s: %s\n", op, err);
            dlclose(handle);
            continue;
        }

        int result = func(num1, num2);
        printf("%d\n", result);

        dlclose(handle);
    }

    return 0;
}