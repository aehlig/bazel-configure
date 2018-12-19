#ifdef HAVE_STDIO_H
#include <stdio.h>
#endif
#ifdef HAVE_MATH_H
#include <math.h>
#endif

int main() {
  int i;
  for (i=0; i < 11; i++) {
    printf("sin(%.1f)=%f\n", i * 0.1, sin (i * 0.1));
  }
  return 0;
}
