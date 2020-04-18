#include <stdio.h>

int read()
{
    int a = 0;
    scanf("%d", &a);
    return a;
}

int write(int a)
{
    printf("%d\n", a);
    return 0;
}

#include "a.cmm"