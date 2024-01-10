
We have run the following benchmarks to evaluate the performance(IPC) using different schedulers:
1. Hotspot
2. Pathfinder
3. 3D Conv
4. BFS
5. NN
6. 3MM

The inputs of some benchmarks are scaled down to reduce the execution time.

<img>![Performance](https://github.com/anish-g22/COA-LAB/assets/99261960/f84369d7-0548-46fa-b1d6-b684eb78416c)


## Table Statistics

**LRR Scheduler**

|                      | Hotspot | Pathfinder | 3D Conv | BFS | NN | 3MM |
| -------- | ------- | ------- | ------- | ------ | ------ | -------- |
| **Without warp sharing** | 2152.852 | 1892 | 38.621 | 97.86 | 159.965 | 93.1011 |
| **With warp sharing** | 2169.983 | 1866.04 | 38.631 | 98.653 | 160.076 | 92.74 |

<br>

**GTO Scheduler**

|                      | Hotspot | Pathfinder | 3D Conv | BFS | NN | 3MM |
| -------- | ------- | ------- | ------- | ------ | ------ | -------- |
| **Without warp sharing** | 2434.57 | 2085.122 | 38.711 | 101.379 | 159.565 | 93.629 |
| **With warp sharing** | 2433.192 | 2087.87 | 38.727 | 102.529 | 162.48 | 93.55 |

<br>

**KAWS Scheduler**

|                      | Hotspot | Pathfinder | 3D Conv | BFS | NN | 3MM |
| -------- | ------- | ------- | ------- | ------ | ------ | -------- |
| **Without warp sharing** | 2420.56 | 2090.236 | 38.694 | 102.622 | 161.605 | 93.585 |
| **With warp sharing** | 2434.771 | 2082.353 | 38.707 | 102.276 | 161.823 | 93.840 |

