#include <sys/prctl.h>

#define ARRAYSIZE 1024
int a[ARRAYSIZE];
int b[ARRAYSIZE];
int c[ARRAYSIZE];
void subtract_arrays(int *a, int *b, int *c)
{
   for (int i = 0; i < ARRAYSIZE; i++)
     a[i] = b[i] - c[i];
}

int main()
{
   subtract_arrays(a, b, c);
   int rc,vl;

   rc = prctl (PR_SVE_GET_VL, 0, 0, 0, 0);

   vl = rc & PR_SVE_VL_LEN_MASK;

   /* Decrease vector length by 16 bytes.  */
   vl -= 16;

   rc = prctl (PR_SVE_SET_VL, vl, 0, 0, 0, 0);
   if (rc < 0)
     return 2;

   return 0;
}


