#!/bin/bash
#SBATCH --partition=xeon-g6-volta
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --exclusive
#SBATCH --mem=0
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:volta:2
#SBATCH --job-name sbatchtest
#SBATCH -o %x_%j.log

srun --output=%x_%j_%t.log --cpus-per-task=40 --cpu-bind=cores --accel-bind=gv  bash /home/gridsan/omoll/supercloud_util/test.bash