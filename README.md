# xrRNA project

## Data description

### NGS Sequencing

Note: some useful points for this include the sequencing machine and facility. 

- `/ifs/data/as6282_gp/share/raw_ngs/shape_20230528` - 
- `/ifs/data/as6282_gp/share/raw_ngs/shape_20230529` - 
- `/ifs/data/as6282_gp/share/raw_ngs/shape_20230530` - 

### Trimmomatic adaptors

- `data/adaptors/miniseq.fa` - 
- ...

### Reference sequences
- `data/rnas/A.fa` - 
- `data/rnas/A_singleSL_150nt.fa` - 
- `data/rnas/B_DENV_150nt.fa` - 
- `data/rnas/C_ST9_native_150nt.fa` - 
- `data/rnas/alpha-140.fasta` - 
- `data/rnas/denv-140.fasta` - 

## Pipeline

0. Setup
```
mkdir -p work/00_fastq
cp  /ifs/data/as6282_gp/share/raw_ngs/shape_202305{28,29,30}/* work/00_fastq/
```

1. Link files

Here we create a naming convention. Here's a suggestion:

`NNNN-XXXX-VV-M-D.fastq.gz` where 
- `NNNN` is identifier for the RNA
- `XXXX` is the experiment identifier (could use fewer digits if you expect fewer)
- `VV` is the replicate. If really we are only doing one replicate per experiment, or the experiment is the replicate, this can be merged with the previous identifier.
- `M` mutational status in `{m,c}`
- `D` is the read direction, can be `F` (forward) `R` (reverse) `S` (single).

For example 
`alpha-mut-G5-A3485-20230405.fastq.gz` -> `alph-0001-01-m-S.fastq.gz`
`alpha-DMSO-G6-A3484-20230405.fastq.gz` -> `alph-0001-01-c-S.fastq.gz`

eventually the results will just be `alph-0001-01` for that example as the last parts of the file name will merge with it. The number is arbitrary and if it helps to track with the numbering system that you have for the plate and well, that can also be accommodated instead.


```
mkdir work/01_links
ln -s $(realpath work/00_fastq/alpha-mut-G5-A3485-20230405.fastq.gz) work/01_links/alph-0001-01-m-s.fastq.gz
ln -s $(realpath work/00_fastq/alpha-DMSO-G6-A3484-20230405.fastq.gz) work/01_links/alph-0001-01-c-s.fastq.gz

ln -s $(realpath work/00_fastq/DENV-mut-G1-A3413-20230405.fastq.gz)  work/01_links/denv-0001-01-m-s.fastq.gz
ln -s $(realpath work/00_fastq/DENV-DMSO-G2-A3429-20230405.fastq.gz)  work/01_links/denv-0001-01-c-s.fastq.gz
```

2. Initial QC
```
qlogin -l mem=4G,time=:60:
mkdir -p work/02_rawqc
module load fastqc
fastqc -o work/02_rawqc work/01_links/*
multiqc -o work/02_rawqc work/02_rawqc
```

3. Trimming
```
qlogin -l mem=4G,time=:60:
mkdir -p work/03_trim
module load trimmomatic
for f in work/01_links/*s.fastq.gz; do 
	trimmomatic SE -phred33 $f work/03_trim/$(basename $f .fastq.gz).trim.fastq.gz ILLUMINACLIP:data/adaptors/miniseq.fa:2:30:10:8:TRUE LEADING:3 TRAILING:3 SLIDINGWINDOW:3:15 MINLEN:35
done
```

4. Trimmed QC
```
qlogin -l mem=4G,time=:60:
mkdir -p work/04_trimqc
module load fastqc multiqc
fastqc -o work/04_trimqc work/03_trim/*
multiqc -o work/04_trimqc work/04_trimqc
```

5. ShapeMAP
```
qlogin -l mem=4G,time=:60:
out=work/05_sm
src=work/03_trim
mkdir -p $out
module load shapemapper
shapemapper --overwrite --verbose --name alph-0001-01 --out work/05_sm/alph-0001-01 --target data/rnas/alpha-140.fasta --modified --U work/03_trim/alph-0001-01-m-s.trim.fastq.gz --untreated --U work/03_trim/alph-0001-01-c-s.trim.fastq.gz
for rna in alph-0001-01 denv-0001-01; do 
	echo shapemapper --temp $TMPDIR --overwrite --verbose --name $rna --log $out/$rna.log.txt --out $out/$rna --target data/rnas/${rna%%-*}.fa --modified --U $src/$rna-m-s.trim.fastq.gz --untreated --U $src/$rna-c-s.trim.fastq.gz	
done
