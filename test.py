import socket
import os
import time

# get pid
print('starting at {}'.format(time.time()))
print(f'{socket.gethostname()=}')
print(f'{os.getpid()=}')

print(f'{os.environ["CUDA_VISIBLE_DEVICES"]=}')
print(f'{os.environ["SLURM_JOB_NODELIST"]=}')
print(f'{os.environ["SLURM_NNODES"]=}')
print(f'{os.environ["SLURM_GPUS_ON_NODE"]=}')
print(f'{os.environ["SLURM_CPUS_ON_NODE"]=}')


print(f'{os.environ["SLURM_NODEID"]=}')
print(f'{os.environ["SLURM_PROCID"]=}')
print(f'{os.environ["SLURM_LOCALID"]=}')

import torch
print(f'{torch.cuda.device_count()=}')

time.sleep(5)
print('done sleeping at {}'.format(time.time()))