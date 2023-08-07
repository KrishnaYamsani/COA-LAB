#include<stdio.h>
#include<bits/stdc++.h>
#include<cuda_runtime.h>
#include<time.h>

using namespace std;

#define rep(i,a,b) for(int i = a;i<b;i++)

__global__ void matMul(int* A, int* B, int* C,int m,int n, int p)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    int temp_sum = 0;
    if((row<m)&&(col<n))
    {
        rep(k,0,p)
        {   
            temp_sum += A[row*p + k]*B[k*n + col];
        }
        C[row*n + col] = temp_sum;
    }
}

void init(int* A,int* B,int m,int n,int p)
{
    rep(i,0,m)
    {   
        rep(j,0,p)
            *(A+i*p+j) = 1;
    }

    rep(i,0,p)
    {   
        rep(j,0,n)
             *(B+i*n+j) = 2;
    }
   
}

int main()
{
    int *h_a, *h_b, *h_c; //host pointers
    int *d_a, *d_b, *d_c; //device pointers
    
    int m,p,n;

    m = 4, p = 2, n = 3; 

    size_t bytes_a = m*p*sizeof(int);
    size_t bytes_b = n*p*sizeof(int);
    size_t bytes_c = m*n*sizeof(int);

    h_a = (int*)malloc(bytes_a);
    h_b = (int*)malloc(bytes_b);
    h_c = (int*)malloc(bytes_c);

    init(h_a,h_b,m,n,p);

    cudaMalloc(&d_a,bytes_a);
    cudaMalloc(&d_b,bytes_b);
    cudaMalloc(&d_c,bytes_c);

    int block_size = 16;
    int grid_size = (int)ceil((float)32/block_size);

    

    dim3 grid(grid_size,grid_size);
    dim3 threads(block_size,block_size);

    // cout<<block_size<<" "<<grid_size<<"\n";

    cudaMemcpy(d_a,h_a,bytes_a,cudaMemcpyHostToDevice);
    cudaMemcpy(d_b,h_b,bytes_b,cudaMemcpyHostToDevice);
    cudaMemcpy(d_c,h_c,bytes_c,cudaMemcpyHostToDevice);

    

    matMul<<<grid,threads>>> (d_a,d_b,d_c,m,n,p);

    cudaMemcpy(h_c,d_c,bytes_c,cudaMemcpyDeviceToHost);

    rep(i,0,m)
    {
        rep(j,0,n)
            cout<<*(h_c+i*n+j)<<" ";
        cout<<"\n";
    }
    
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    free(h_a);
    free(h_b);
    free(h_c);

    return 0;
}