#include "png_util.h"
#include <assert.h>
#include <iterator>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <iostream>
#define CUDA_CALL(x)                                                           \
  {                                                                            \
    cudaError_t cuda_error__ = (x);                                            \
    if (cuda_error__)                                                          \
      std::cout << "CUDA error: " << #x << " returned "                        \
                << cudaGetErrorString(cuda_error__) << std::endl;              \
  }

#define MAX_N 20000
#define BLOCK_SIZE 20

char plate[2][(MAX_N + 2) * (MAX_N + 2)];
char *d_plate;
int which = 0;
int *d_which;
int n;
int *d_n;

__device__ int live(char *d_plate, int index, int n) {
  return (d_plate[index - n - 3] + d_plate[index - n - 2] +
          d_plate[index - n - 1] + d_plate[index - 1] + d_plate[index + 1] +
          d_plate[index + n + 1] + d_plate[index + n + 2] +
          d_plate[index + n + 3]);
}
__global__ void iteration(char *d_plate, int *d_which, int *d_n) {
  int x = (BLOCK_SIZE * blockIdx.x) + threadIdx.x + 1;
  int y = (BLOCK_SIZE * blockIdx.y) + threadIdx.y + 1;
  if (x >= (*d_n + 2) || y >= (*d_n + 2)) {
    return;
  }
  int index = (*d_n + 2) * y + x;

  int srcIdx = (*d_which) * (MAX_N + 2) * (MAX_N + 2) + index;
  int dstIdx = (!*d_which) * (MAX_N + 2) * (MAX_N + 2) + index;

  int num = live(d_plate, srcIdx, *d_n);
  if (d_plate[srcIdx]) {
    d_plate[dstIdx] = (num == 2 || num == 3) ? 1 : 0;
  } else {
    d_plate[dstIdx] = (num == 3);
  }
}
void print_plate() {
  if (n < 60) {
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= n; j++) {
        printf("%d", (int)plate[which][i * (n + 2) + j]);
      }
      printf("\n");
    }
  } else {
    printf("Plate too large to print to screen\n");
  }
  printf("\0");
}

void plate2png(char *filename) {
  char *img = (char *)malloc(n * n * sizeof(char));

  image_size_t sz;
  sz.width = n;
  sz.height = n;

  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= n; j++) {
      int pindex = i * (n + 2) + j;
      int index = (i - 1) * (n) + j;
      if (plate[!which][pindex] > 0)
        img[index] = 255;
      else
        img[index] = 0;
    }
  }
  printf("Writing file\n");
  write_png_file(filename, (unsigned char *)img, sz);

  printf("done writing png\n");
  free(img);
  printf("done freeing memory\n");
}

int main() {
  int M;
  char line[MAX_N];
  if (scanf("%d %d", &n, &M) == 2) {
    if (n > 0) {
      memset(plate[0], 0, sizeof(char) * (n + 2) * (n + 2));
      memset(plate[1], 0, sizeof(char) * (n + 2) * (n + 2));
      for (int i = 1; i <= n; i++) {
        scanf("%s", &line);
        for (int j = 0; j < n; j++) {
          plate[0][i * (n + 2) + j + 1] = line[j] - '0';
        }
      }
    } else {
      n = MAX_N;
      for (int i = 1; i <= n; i++)
        for (int j = 0; j < n; j++)
          plate[0][i * (n + 2) + j + 1] = (char)rand() % 2;
    }

    CUDA_CALL(cudaMalloc((void **)&d_plate,
                         sizeof(char) * 2 * (MAX_N + 2) * (MAX_N + 2)));
    CUDA_CALL(cudaMalloc((void **)&d_which, sizeof(int)));
    CUDA_CALL(cudaMalloc((void **)&d_n, sizeof(int)));
    CUDA_CALL(cudaMemcpy(d_n, &n, sizeof(int), cudaMemcpyHostToDevice));

    dim3 grid_size(MAX_N / BLOCK_SIZE, MAX_N / BLOCK_SIZE);
    dim3 block_size(BLOCK_SIZE, BLOCK_SIZE);
    for (int i = 0; i < M; i++) {
      printf("\nIteration %d:\n", i);
      print_plate();
      CUDA_CALL(cudaMemcpy(d_plate, &plate,
                           sizeof(char) * 2 * (MAX_N + 2) * (MAX_N + 2),
                           cudaMemcpyHostToDevice));
      CUDA_CALL(
          cudaMemcpy(d_which, &which, sizeof(int), cudaMemcpyHostToDevice));
      iteration<<<grid_size, block_size>>>(d_plate, d_which, d_n);
      CUDA_CALL(cudaMemcpy(&plate, d_plate,
                           sizeof(char) * 2 * (MAX_N + 2) * (MAX_N + 2),
                           cudaMemcpyDeviceToHost));
      which = !which;
    }
    printf("\n\nFinal:\n");
    plate2png("plate.png");
    print_plate();
  }
  return 0;
}
