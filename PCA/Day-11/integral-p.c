#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <omp.h>

int main(int argc, char *argv[])
{
    long long num_steps=atoll(argv[1]);
    double step = 1.0/(double) num_steps;

    // Set nthreads
    int nthreads = (int) num_steps/10;
    omp_set_num_threads(nthreads);
    // Get steps per thread
    int steps_per_thread=(int) (num_steps / nthreads);
    int extra_steps = num_steps % nthreads;

    // Init sum array
    double sum[nthreads];

    #pragma omp parallel
    {
        // Init vars
        double x;
        int id = omp_get_thread_num();
        sum[id] = 0.0;
        int start, stop;
        if (id < extra_steps) {
            start = (steps_per_thread + 1)*id;
            stop = start + steps_per_thread + 1;
        } else {
            start = (steps_per_thread + 1)*extra_steps + steps_per_thread*(id - extra_steps);
            stop = start + steps_per_thread;
        }

        // For 
        for (int i=start; i<stop; i++) {
            x = (i + 0.5) * step;
            sum[id] = sum[id]+4.0/(1.0+x*x);
        }
    }
    double pi=0.0;
    for (int i=0; i<nthreads; i++) pi += sum[i]*step;
    // Get longer rep. https://stackoverflow.com/questions/31861160/get-printf-to-print-all-float-digits
    printf("%.*f\n", DBL_DIG-1, pi);
}
