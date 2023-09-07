#!/bin/bash

#SBATCH --partition=xeon-g6-volta
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --mem=0
#SBATCH --gres=gpu:volta:2
#SBATCH --exclusive
#SBATCH --job-name sbatchtest
#SBATCH -o %x_%j_%t.log

set -x 
srun bash /home/gridsan/omoll/supercloud_util/test.bash