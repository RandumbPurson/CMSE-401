#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

//#define SAVE 1

double linspace(double *arr, double min, double max, int n){
    // Helper for initializing linearly-spaced array
    double stepSize=(max-min)/(n-1);
    for (int i=0; i < n; i++){
        arr[i] = min + i*stepSize;
    }
    return stepSize;
}

int zeroArr(double *arr, int n){
    // Helper for initializing entries of an array to 0
    for (int i = 0; i < n; i++){
        arr[i] = 0;
    }
    return 0;
}

// Function definitions of update rules
double estimateAcceleration(
    double yl, double yr, double y, 
    double dx, double gamma
){
    return gamma*(yr + yl - 2*y)/(pow(dx, 2));
}
double updatePosition(
    double y, double v, double dt
){
    return y + v*dt;
}
double updateVelocity(
    double v, double a, double dt
){
    return v + a*dt;
}

int update(
    double *yarr, double *varr, double *aarr,
    int nx, double dx, double dt,
    double gamma
) {
    // Update values at a specific time step, keeping end acceleration = 0
    yarr[0] = updatePosition(yarr[0], varr[0], dt);
    varr[0] = updateVelocity(varr[0], aarr[0], dt);
    for (int i=1; i < nx - 1; i++){
        aarr[i] = estimateAcceleration(yarr[i-1], yarr[i+1], yarr[i], dx, gamma);
        yarr[i] = updatePosition(yarr[i], varr[i], dt);
        varr[i] = updateVelocity(varr[i], aarr[i], dt);
    }
    yarr[nx] = updatePosition(yarr[nx], varr[nx], dt);
    varr[nx] = updateVelocity(varr[nx], aarr[nx], dt);
    return 0;
}

int fprintArr(FILE *arrFile, double *arr, int len){
    // Iterate through array and save single entry in csv format
    for (int i=0; i < len-1; i++) {
        fprintf(arrFile, "%f,", arr[i]);
    }
    fprintf(arrFile, "%f\n", arr[len]);
    return 0;
}

int main(void){
    // Init positional grid
    double xmin=0; double xmax=10;
    int nx=512;
    double* xarr=malloc(sizeof(double) * nx);
    double dx = linspace(xarr, xmin, xmax, nx);

    // Init discrete time units
    double tmin=0; double tmax=10;
    double nt=1000000;
    double* tarr=malloc(sizeof(double) * nt);
    double dt = linspace(tarr, tmin, tmax, nt);

    // Init starting pos. as a simple pulse
    double* yarr = malloc(sizeof(double) * nx);
    for (int i=0; i < nx; i++) {
        yarr[i] = exp(-pow(xarr[i] - 5, 2));
    }

    // Init velocity and acceleration arrays to 0
    double* varr = malloc(sizeof(double) * nx); zeroArr(varr, nx);
    double* aarr = malloc(sizeof(double) * nx); zeroArr(aarr, nx);
    double gamma = 1;

    #ifdef SAVE
        // Open file for writing
        FILE *yfile = fopen("y.csv", "w");
    #endif

    // Iterate through time steps
    for (int i=0; i < nt; i++){
        update(yarr, varr, aarr, nx, dx, dt, gamma);

        // Only save results to file if compiled with SAVE macro
        #ifdef SAVE
            fprintArr(yfile, yarr, nx);
        #endif
    }

    // Cleanup
    fclose(yfile);
    free(xarr); free(tarr); free(yarr); free(varr); free(aarr);
    return 0;
}
