#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define MAX_RANGE 50

const unsigned int TILE_WIDTH = 32;


#define gpu_errchk(ans) { gpu_assert((ans), __FILE__, __LINE__); }

inline void gpu_assert(cudaError_t code, const char *file, int line,
                       bool abort = true) {
    if (code != cudaSuccess) {
        fprintf(stderr, "gpu_assert: %s %s %d\n",
                cudaGetErrorString(code), file, line);
        exit(code);
    }
}

__global__ void gpu_matrix_mult(float *a,float *b, float *c, int m, int n, int k)
{ 
    int row = blockIdx.y * blockDim.y + threadIdx.y; 
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int sum = 0;
    if( col < k && row < m) 
    {
        for(int i = 0; i < n; i++) 
        {
            sum += a[row * n + i] * b[i * k + col];
        }
        c[row * k + col] = sum;
    }
} 



int main(int argc, char **argv) {
    float *hostA; // The A matrix
    float *hostB; // The B matrix
    float *hostC; // The output C matrix
    float *hostComputedC;
    float *deviceA;
    float *deviceB;
    float *deviceC;

    // Please adjust rows and columns according to you need.
    int numARows = 2; // number of rows in the matrix A
    int numAColumns = 2; // number of columns in the matrix A
    int numBRows = 2; // number of rows in the matrix B
    int numBColumns = 2; // number of columns in the matrix B

    int numCRows; // number of rows in the matrix C (you have to set this)
    int numCColumns; // number of columns in the matrix C (you have to set this)

    hostA = (float *) malloc(sizeof(float) * numARows * numAColumns);
    hostB = (float *) malloc(sizeof(float) * numBRows * numBColumns);

    for (int i = 0; i < numARows * numAColumns; i++) {
        hostA[i] = (rand() % MAX_RANGE) / 2.0;
    }
    for (int i = 0; i < numBRows * numBColumns; i++) {
        hostB[i] = (rand() % MAX_RANGE) / 2.0;
    }

    // Setting numCRows and numCColumns
    numCRows = numARows;
    numCColumns = numBColumns;

    hostC = (float *) malloc(sizeof(float) * numCRows * numCColumns);
    hostComputedC = (float *) malloc(sizeof(float) * numCRows * numCColumns);

    // Allocating GPU memory
    gpu_errchk(cudaMalloc((void **) &deviceA, sizeof(float) * numARows * numAColumns));
    gpu_errchk(cudaMalloc((void **) &deviceB, sizeof(float) * numBRows * numBColumns));
    gpu_errchk(cudaMalloc((void **) &deviceC, sizeof(float) * numCRows * numCColumns));

    // Copy memory to the GPU 
    gpu_errchk(cudaMemcpy(deviceA, hostA, sizeof(float) * numARows * numAColumns, cudaMemcpyHostToDevice));
    gpu_errchk(cudaMemcpy(deviceB, hostB, sizeof(float) * numBRows * numBColumns, cudaMemcpyHostToDevice));

    // Initialize the grid and block dimensions 
    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);
    dim3 dimGrid((numCColumns / TILE_WIDTH) + 1, (numCRows / TILE_WIDTH) + 1, 1);
    
    gpu_matrix_mult<<<dimGrid, dimBlock>>>(deviceA, deviceB, deviceC, numARows, numBRows, numBColumns);
    
     gpu_errchk(cudaMemcpy(hostC, deviceC, sizeof(float) * numCRows * numCColumns, cudaMemcpyDeviceToHost));
     
     
    for (int i = 0; i < numCColumns * numCRows; i++) {
       
            printf("Row = %d Col = %d  --device[] %f\n", i / numCColumns,
                   i % numCColumns, hostC[i]);
           
    }
    // Free the GPU memory
    gpu_errchk(cudaFree(deviceA));
    gpu_errchk(cudaFree(deviceB));
    gpu_errchk(cudaFree(deviceC));

    free(hostA);
    free(hostB);
    free(hostC);
    free(hostComputedC);

    return 0;
}

