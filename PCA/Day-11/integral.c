#include <stdio.h>
#include <stdlib.h>
#include <float.h>

int main(int argc, char *argv[])
{
    long long num_steps=atoll(argv[1]);
    double step;
    int i; double x,pi,sum=0.0;
    step = 1.0/(double) num_steps;
    for (i=0;i<num_steps;i++) 
    {
        x = (i + 0.5) * step;
        sum = sum+4.0/(1.0+x*x);
    }
    pi = step * sum;
    // Get longer rep. https://stackoverflow.com/questions/31861160/get-printf-to-print-all-float-digits
    printf("%.*f\n", DBL_DIG-1, pi);
}
