#!/bin/bash
#SBATCH --job-name=Master_RNAseq
#SBATCH --array=1-14           # ¡Recuerda ajustar esto al total de muestras de lista_sra_abc.txt!
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --time=08:00:00        
#SBATCH --output=log_pipeline_%A_%a.out
#SBATCH --error=log_pipeline_%A_%a.err
#SBATCH --partition=standard

# ==============================================================================
# 1. CARGA DE MÓDULOS Y RUTAS
# ==============================================================================
module load FastQC/0.12.1-Java-11
module load STAR/2.7.11b-GCC-12.3.0

GENOME_INDEX="/home/aiglesias/TFM/genome/index/"
GTF_FILE="/home/aiglesias/TFM/genome/Arabidopsis_thaliana.TAIR10.62.gtf"
STRINGTIE_BIN="/lustre/home/aiglesias/TFM/stringtie-2.2.1.Linux_x86_64/stringtie"

# ==============================================================================
# 2. VARIABLES Y SELECCIÓN DE MUESTRA
# ==============================================================================
FOLDER="/lustre/home/aiglesias/TFM/samples/Muestras_GEO_antiguas/"
LISTA="/lustre/home/aiglesias/TFM/scripts/scripts_myriam/lista_srr_geo_antiguo.txt" 

# El clon lee su línea correspondiente
SRR_ID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $LISTA | tr -d '\r' | tr -d ' ')

cd $FOLDER

# ==============================================================================
# 3. DETECCIÓN AUTOMÁTICA (Single-End vs Paired-End)
# ==============================================================================
# Comprobamos si existe el archivo _2 (Paired-End)
if [ -f "${SRR_ID}_2.fastq.gz" ]; then
    TIPO="PAIRED-END"
    READS="${SRR_ID}_1.fastq.gz ${SRR_ID}_2.fastq.gz"
# Si no, miramos si existe el archivo _1 solo (Single-End)
elif [ -f "${SRR_ID}_1.fastq.gz" ]; then
    TIPO="SINGLE-END"
    READS="${SRR_ID}_1.fastq.gz"
# A veces el SRA no pone _1 en las single-end, comprobamos sin número por si acaso
elif [ -f "${SRR_ID}.fastq.gz" ]; then
    TIPO="SINGLE-END"
    READS="${SRR_ID}.fastq.gz"
else
    echo "ERROR CRÍTICO: No se han encontrado archivos .fastq.gz para $SRR_ID"
    exit 1
fi

echo "=========================================================="
echo "Iniciando Pipeline para la muestra: $SRR_ID ($TIPO)"
echo "Archivos a procesar: $READS"
echo "=========================================================="

# ==============================================================================
# 4. FASTQC
# ==============================================================================
echo "[$(date +'%H:%M:%S')] 1/3 - Ejecutando FastQC..."
# Le pasamos la variable READS, que puede tener 1 o 2 archivos
fastqc -t 8 $READS

# ==============================================================================
# 5. STAR (Alineamiento con descompresión)
# ==============================================================================
echo "[$(date +'%H:%M:%S')] 2/3 - Ejecutando STAR..."

STAR --runThreadN 8 \
     --genomeDir $GENOME_INDEX \
     --readFilesIn $READS \
     --readFilesCommand zcat \
     --outSAMtype BAM SortedByCoordinate \
     --limitBAMsortRAM 25000000000 \
     --outSAMstrandField intronMotif \
     --outFilterIntronMotifs RemoveNoncanonical \
     --alignIntronMax 300000 \
     --outFileNamePrefix ${SRR_ID}_

# ==============================================================================
# 6. STRINGTIE (Cuantificación)
# ==============================================================================
echo "[$(date +'%H:%M:%S')] 3/3 - Ejecutando StringTie..."

BAM_FILE="${SRR_ID}_Aligned.sortedByCoord.out.bam"

$STRINGTIE_BIN -e -p 8 -G $GTF_FILE -o ${SRR_ID}_quant.gtf -A ${SRR_ID}.tsv $BAM_FILE

echo "=========================================================="
echo "[$(date +'%H:%M:%S')] ¡Pipeline completado para $SRR_ID!"
echo "=========================================================="
