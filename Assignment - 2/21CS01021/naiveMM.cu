#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>


// This code assumes that your device support block size of 1024
#define MAX_RANGE 9999

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

// Compute C = A * B
__global__ void matrixMultiplyShared(float *A, float *B, float *C,
                                     int numARows, int numAColumns,
                                     int numBRows, int numBColumns,
                                     int numCRows, int numCColumns) {
    int Row = blockDim.y * blockIdx.y + threadIdx.y;
    int Col = blockDim.x * blockIdx.x + threadIdx.x;
    float Cvalue = 0.0;

   if((Row < numARows) && (Col < numBColumns)){
	   for(int k = 0; k < numAColumns; k++){
	   	Cvalue += (A[Row * numAColumns + k] * B[k * numBColumns + Col]);
	   }
	   
	   C[Row * numCColumns + Col] = Cvalue;   
   }
    
}


int main(int argc, char **argv) {
    float *hostA; // The A matrix
    float *hostB; // The B matrix
    float *hostC; // The output C matrix

    float *deviceA;
    float *deviceB;
    float *deviceC;

    // Please adjust rows and columns according to you need.
    int numARows = 3; // number of rows in the matrix A
    int numAColumns = 2; // number of columns in the matrix A
    int numBRows = 2; // number of rows in the matrix B
    int numBColumns = 2; // number of columns in the matrix B
    
    printf("Enter number of Rows of A : ");
    scanf("%d", &numARows);

    printf("Enter number of Columns of A : ");
    scanf("%d", &numAColumns);
    
    printf("Enter number of Rows of B : ");
    scanf("%d", &numBRows);

    printf("Enter number of Columns of A : ");
    scanf("%d", &numBColumns);
    
    int numCRows = numARows;; // number of rows in the matrix C 
    int numCColumns = numBColumns; // number of columns in the matrix C 

    hostA = (float *) malloc(sizeof(float) * numARows * numAColumns);
    hostB = (float *) malloc(sizeof(float) * numBRows * numBColumns);
    
    // Take input A, B
    printf("Enter A\n");
    for (int i = 0; i < numARows * numAColumns; i++) {
        scanf("%f", hostA+i);
    }    

    printf("Enter B\n");
    for (int i = 0; i < numBRows * numBColumns; i++) {
        scanf("%f", hostB+i);
    }    
 

    hostC = (float *) malloc(sizeof(float) * numCRows * numCColumns);

    // Allocating GPU memory
    gpu_errchk(cudaMalloc((void **) &deviceA, sizeof(float) * numARows * numAColumns));
    gpu_errchk(cudaMalloc((void **) &deviceB, sizeof(float) * numBRows * numBColumns));
    gpu_errchk(cudaMalloc((void **) &deviceC, sizeof(float) * numCRows * numCColumns));

    // Copy memory to the GPU 
    gpu_errchk(cudaMemcpy(deviceA, hostA, sizeof(float) * numARows * numAColumns, cudaMemcpyHostToDevice));
    gpu_errchk(cudaMemcpy(deviceB, hostB, sizeof(float) * numBRows * numBColumns, cudaMemcpyHostToDevice));

    // Initialize the grid and block dimensions 
    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);
    dim3 dimGrid((numCColumns + TILE_WIDTH - 1)/ TILE_WIDTH, (numCRows + TILE_WIDTH - 1)/ TILE_WIDTH, 1);

    //@@ Launch the GPU Kernel here
    matrixMultiplyShared <<<dimGrid, dimBlock>>>
                                       (deviceA, deviceB, deviceC, numARows, numAColumns, numBRows, numBColumns, numCRows, numCColumns);

    // Copy the result matrix from the device to the host
    gpu_errchk(cudaMemcpy(hostC, deviceC, sizeof(float) * numCRows * numCColumns, cudaMemcpyDeviceToHost));

    // Printing result
    printf("Result\n");
    for(int i = 0; i < numCRows; i++){
    	for(int j = 0; j < numCColumns; j++){
    	    printf("%f ", hostC[i*numCColumns + j]);
    	}
    	printf("\n");
    }
        
    // Free the GPU memory
    gpu_errchk(cudaFree(deviceA));
    gpu_errchk(cudaFree(deviceB));
    gpu_errchk(cudaFree(deviceC));

    free(hostA);
    free(hostB);
    free(hostC);


    return 0;
}
