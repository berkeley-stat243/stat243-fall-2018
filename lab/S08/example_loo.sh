#!/bin/bash
# Job name:
#SBATCH --job-name=looFit
#
# Account:
#SBATCH --account=ic_stat243
#
# Partition:
#SBATCH --partition=savio
#
# Wall clock limit (30 seconds here):
#SBATCH --time=00:00:30
#
## Command(s) to run:
module load r r-packages
R CMD BATCH --no-save example_loo.R looFit.out
