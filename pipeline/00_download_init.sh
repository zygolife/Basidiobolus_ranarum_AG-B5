#!/usr/bin/bash -l
#SBATCH -N 1 -n 1 --time 12:00:00 -p batch

PASS=$JGIPASS
USER=jason.stajich@ucr.edu
FILE=10789.6.179465.GTTTCG.anqrpht.fastq.gz
BASE=Basidiobolus_ranarum_AGB5_
mkdir -p lib/RNASeq/Basidiobolus_ranarum
pushd lib/RNASeq/Basidiobolus_ranarum

if [ ! -f cookies ]; then
	curl 'https://signon.jgi.doe.gov/signon/create' --data-urlencode 'login='$USER --data-urlencode "password=$JGIPASS" -c cookies > /dev/null
fi
if [ ! -f 10789.6.179465.GTTTCG.anqrpht.fastq.gz ]; then
	curl -o $FILE  'https://genome.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=/Basrannscriptome_P/download/_JAMO/57c4ba7b7ded5e0c8713c932/10789.6.179465.GTTTCG.anqrpht.fastq.gz' -b cookies
fi
if [ ! -f Basidiobolus_ranarum_AG-B5.transcriptome.fasta ]; then
	curl -O -b cookies 'https://genome.jgi.doe.gov/portal/ext-api/downloads/get_tape_file?blocking=true&url=/Basrannscriptome/download/_JAMO/5ee3bd66bb87891e8a30c874/Basidiobolus_ranarum_AG-B5.transcriptome.fasta'
fi
if [ ! -f ${BASE}R1.fq.gz ]; then
	module load BBMap
	reformat.sh in=$FILE out=${BASE}R1.fq.gz out2=${BASE}R2.fq.gz
	ln -s ${BASE}R1.fq.gz Forward.fq.gz
	ln -s ${BASE}R2.fq.gz Reverse.fq.gz
fi
