#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "png_util.h"
#define MAX_N 20000

char plate[2][(MAX_N + 2) * (MAX_N + 2)];
char* d_plate[2][(MAX_N + 2) * (MAX_N + 2)];
int* d_which;
int which = 0;
int n;
int live(int index, int* plate){
    return (plate[index - n - 3] 
        + plate[index - n - 2]
        + plate[index - n - 1]
        + plate[index - 1]
        + plate[index + 1]
        + plate[index + n + 1]
        + plate[index + n + 2]
        + plate[index + n + 3]);
}
__global__ void iteration(int * d_which, int** d_plate) {
    int index = threadIdx.x * (blockDim.x + 2) + threadIdx.y;
    int num = live(index, d_plate[*d_which]);
    if(d_plate[*d_which][index]){
        d_plate[!*d_which][index] = (num == 2 || num == 3) ? 1 : 0;
    }else{
        d_plate[!*d_which][index] = (num == 3);
    }
}
void print_plate(){
    if (n < 60) {
        for(int i = 1; i <= n; i++){
            for(int j = 1; j <= n; j++){
                printf("%d", (int) plate[which][i * (n + 2) + j]);
            }
            printf("\n");
        }
    } else {
        printf("Plate too large to print to screen\n");
    }
    printf("\0");
}

void plate2png(char* filename) {
    char * img = (char *) malloc(n*n*sizeof(char));

    image_size_t sz;
    sz.width = n;
    sz.height = n; 

    for(int i = 1; i <= n; i++){
        for(int j = 1; j <= n; j++){
            int pindex = i * (n + 2) + j;
            int index = (i-1) * (n) + j;
            if (plate[!which][pindex] > 0)
                img[index] = 255; 
            else 
                img[index] = 0;
        }
    }
    printf("Writing file\n");
    write_png_file(filename,(unsigned char *) img,sz);

    printf("done writing png\n"); 
    free(img);
    printf("done freeing memory\n");
}

int main() { 
    int M;
    char line[MAX_N];
    if(scanf("%d %d", &n, &M) == 2){
        if (n > 0) {
            memset(plate[0], 0, sizeof(char) * (n + 2) * (n + 2));
            memset(plate[1], 0, sizeof(char) * (n + 2) * (n + 2));
            for(int i = 1; i <= n; i++){
                scanf("%s", &line);
                for(int j = 0; j < n; j++){
                    plate[0][i * (n + 2) + j + 1] = line[j] - '0';
                }
            }
        } else {
            n = MAX_N; 
            for(int i = 1; i <= n; i++) 
                for(int j = 0; j < n; j++) 
                    plate[0][i * (n+2) +j + 1] = (char) rand() % 2;
        }

        cudaMalloc((void**)&d_plate, sizeof(char)*(n + 2)*(n + 2)*2);
        cudaMalloc((void**)&d_which, sizeof(int));
        dim3 grid_size(1); dim3 block_size(n + 2, n + 2);
        for(int i = 0; i < M; i++){
            printf("\nIteration %d:\n",i);
            print_plate();
            cudaMemcpy(d_plate, plate, sizeof(char)*(n + 2)*(n + 2)*2, cudaMemcpyHostToDevice);
            cudaMemcpy(d_which, &which, sizeof(int), cudaMemcpyHostToDevice);
            iteration<<<grid_size, block_size>>>(d_which, &d_plate);
            cudaMemcpy(plate, d_plate, sizeof(char)*(n + 2)*(n + 2)*2, cudaMemcpyDeviceToHost);
            which=!which;
        }
        printf("\n\nFinal:\n");
        plate2png("plate.png");
        print_plate();
    }
    return 0;
}
