#!/bin/bash -l
#SBATCH -p intel --time 3-0:00:00 --ntasks 24 --nodes 1 --mem 96G --out logs/predict.%a.log

module load funannotate
module load workspace/scratch

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

BUSCO=mucoromycota_odb10
#fungi_odb10 # This could be changed to the core BUSCO set you want to use
INDIR=genomes
OUTDIR=$(realpath annotate)
PREDS=$(realpath prediction_support)
mkdir -p $OUTDIR
SAMPFILE=samples.csv
INFORMANT=$(realpath lib/informant_proteins.aa)
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`

if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
# make genemark key link required to run it

IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN VERSION PHYLUM BIOSAMPLE BIOPROJECT LOCUSTAG
do
    SEQCENTER=UCR_Harvard
    BASE=$(echo -n ${SPECIES}_${STRAIN}.${VERSION} | perl -p -e 's/\s+/_/g')
    echo "sample is $BASE"
    MASKED=$(realpath $INDIR/$BASE.masked.fasta)
    if [ ! -f $MASKED ]; then
      echo "Cannot find $BASE.masked.fasta in $INDIR - may not have been run yet"
      exit
    fi
    pushd $SCRATCH
    if [[ -f $PREDS/$BASE.genemark.gtf ]]; then
	funannotate predict --cpus $CPU --keep_no_stops --SeqCenter $SEQCENTER --busco_db $BUSCO --optimize_augustus \
            --strain $STRAIN --min_training_models 100 --AUGUSTUS_CONFIG_PATH $AUGUSTUS_CONFIG_PATH \
            -i $MASKED --name $LOCUSTAG --protein_evidence $INFORMANT \
            -s "$SPECIES"  -o $OUTDIR/$BASE 
    else
	funannotate predict --cpus $CPU --keep_no_stops --SeqCenter $SEQCENTER --busco_db $BUSCO --optimize_augustus \
	    --strain $STRAIN --min_training_models 100 --AUGUSTUS_CONFIG_PATH $AUGUSTUS_CONFIG_PATH \
	    -i $MASKED --name $LOCUSTAG --protein_evidence $INFORMANT \
	    -s "$SPECIES"  -o $OUTDIR/$BASE 
    fi
    popd
done
