# xrRNA project

## Data description

### NGS Sequencing

Note: some useful points for this include the sequencing machine and facility. 

- `/ifs/data/as6282_gp/share/raw_ngs/shape_20221010` - 
- `/ifs/data/as6282_gp/share/raw_ngs/shape_20221111` - 
- `/ifs/data/as6282_gp/share/raw_ngs/shape_20230411` - 

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
- `data/rnas/C_ST9_short.dbn` - The structure of the 54-nt active part of the ST9 RNA (from Jeanine)
- `data/rnas/C_ST9_short_pknot.dbn` - The structure of the 54-nt active part of the ST9 RNA, including a pseudoknot (from Jeanine)
- `data/rnas/C_ST9_short_open.dbn` - The structure based on a consensus fold (from Lena)

### Previous results

In writing the grant, we lost access to the cluster, so used intermediate results
from previous runs of shapemapper for the coloring of the figures in `data/intermediate`.
The colors are computed in `scripts/varna_colors.R`.

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

(Workflow is to convert 
`ln -s $(realpath work/00_fastq/SRC) work/01_links/DST
to include your fastq file source (SRC) and the destination (DST) file
)

```
mkdir work/01_links
ln -s $(realpath work/00_fastq/alpha-mut-G5-A3485-20230405.fastq.gz) work/01_links/alph-0003-01-m-s.fastq.gz
ln -s $(realpath work/00_fastq/alpha-DMSO-G6-A3484-20230405.fastq.gz) work/01_links/alph-0003-01-c-s.fastq.gz

ln -s $(realpath work/00_fastq/DENV-mut-G1-A3413-20230405.fastq.gz)  work/01_links/denv-0003-01-m-s.fastq.gz
ln -s $(realpath work/00_fastq/DENV-DMSO-G2-A3429-20230405.fastq.gz)  work/01_links/denv-0003-01-c-s.fastq.gz

bash scripts/link.sh A3461_S25_L001_R1_001.fastq.gz st91-0001-01-c-f.fastq.gz
bash scripts/link.sh A3461_S25_L001_R2_001.fastq.gz st91-0001-01-c-r.fastq.gz

bash scripts/link.sh A3479_S41_L001_R1_001.fastq.gz st91-0001-03-c-f.fastq.gz
bash scripts/link.sh A3479_S41_L001_R2_001.fastq.gz st91-0001-03-c-r.fastq.gz

bash scripts/link.sh A3481_S17_L001_R1_001.fastq.gz st91-0001-03-m-f.fastq.gz
bash scripts/link.sh A3481_S17_L001_R2_001.fastq.gz st91-0001-03-m-r.fastq.gz

bash scripts/link.sh A3482_S9_L001_R1_001.fastq.gz st91-0001-02-m-f.fastq.gz
bash scripts/link.sh A3482_S9_L001_R2_001.fastq.gz st91-0001-02-m-r.fastq.gz

bash scripts/link.sh A3489_S1_L001_R1_001.fastq.gz st91-0001-01-m-f.fastq.gz
bash scripts/link.sh A3489_S1_L001_R2_001.fastq.gz st91-0001-01-m-r.fastq.gz

bash scripts/link.sh A3498_S33_L001_R1_001.fastq.gz st91-0001-02-c-f.fastq.gz
bash scripts/link.sh A3498_S33_L001_R2_001.fastq.gz st91-0001-02-c-r.fastq.gz

bash scripts/link.sh A1_plate16-Well-A01_S289_L001_R1_001.fastq.gz st9h-0002-01-m-s.fastq.gz
bash scripts/link.sh A2_plate16-Well-A02_S297_L001_R1_001.fastq.gz st9h-0002-02-m-s.fastq.gz
bash scripts/link.sh A3_plate16-Well-A03_S305_L001_R1_001.fastq.gz st9h-0002-03-m-s.fastq.gz
bash scripts/link.sh A4_plate16-Well-A04_S313_L001_R1_001.fastq.gz st9h-0002-04-m-s.fastq.gz
bash scripts/link.sh A6_plate16-Well-A06_S329_L001_R1_001.fastq.gz st9h-0002-01-c-s.fastq.gz  
bash scripts/link.sh A7_plate16-Well-A07_S337_L001_R1_001.fastq.gz st9h-0002-02-c-s.fastq.gz
bash scripts/link.sh A8_plate16-Well-A08_S345_L001_R1_001.fastq.gz st9h-0002-03-c-s.fastq.gz
bash scripts/link.sh A9_plate16-Well-A09_S353_L001_R1_001.fastq.gz st9h-0002-04-c-s.fastq.gz
 
# TODO
bash scripts/link.sh
bash scripts/link.sh
```
2. Initial QC
```
qlogin -l mem=4G,time=:60:
cd /ifs/scratch/as6282_gp/rpz2103/xrrna
mkdir -p work/02_rawqc
module load fastqc python3 pyyaml multiqc
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
module load fastqc python3 pyyaml multiqc
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
for rna in alph-0001-01 denv-0001-01; do 
	 shapemapper --temp $TMPDIR --overwrite --verbose --name $rna --log $out/$rna.log.txt --out $out/$rna --target data/rnas/${rna%%-*}.fa --modified --U $src/$rna-m-s.trim.fastq.gz --untreated --U $src/$rna-c-s.trim.fastq.gz	
done
