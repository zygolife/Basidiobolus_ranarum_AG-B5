#!/usr/bin/bash
#SBATCH -p batch,intel -n 48 --mem 96gb --out RM.%A.log -N 1

module load RepeatModeler
if [[ -z ${SLURM_CPUS_ON_NODE} ]]; then
    CPUS=1
else
    CPUS=${SLURM_CPUS_ON_NODE}
fi

NAME=Entomophthora_muscae_UCB.Nanopore10X_v2.sorted.fasta
PREFIX=$(basename $NAME .sorted.fasta)
if [ ! -f $PREFIX.nin ]; then
	BuildDatabase -engine rmblast -name $PREFIX $NAME
fi

RepeatModeler -pa $CPUS -database $PREFIX -LTRStruct

#RepeatModeler -recoverDir RM_28988.FriAug61029192021 -database Entomophthora_muscae_UCB.Nanopore10X_v2 -LTRStruct
