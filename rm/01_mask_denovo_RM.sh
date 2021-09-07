#!/usr/bin/bash
#SBATCH -p batch,intel -n 24 --mem 96gb --out RM.%A.log -N 1
module unload miniconda3
module unload miniconda2
module load RepeatModeler
if [[ -z ${SLURM_CPUS_ON_NODE} ]]; then
    CPUS=1
else
    CPUS=${SLURM_CPUS_ON_NODE}
fi

NAME=Basidiobolus_ranarum_AG-B5.v1.sorted.fasta
PREFIX=$(basename $NAME .sorted.fasta)
if [ ! -f $PREFIX.nin ]; then
	BuildDatabase -engine rmblast -name $PREFIX $NAME
fi

RepeatModeler -pa $CPUS -database $PREFIX -LTRStruct

