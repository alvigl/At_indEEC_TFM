# At_indEEC_TFM

Este repositorio de código consta de 4 archivos:

- **pipeline.mezcla**: Un archivo .slurm lanzado en el servidor Hércules del Centro Informático Científico de Andalucía (CICA). Se compone de los siguientes apartados:

  - (1) *CARGA DE MÓDULOS Y RUTAS*: Cargar modulos de herramientas que han requerido descarga externa al servidor como FastQC o STAR y definición de directorios de archivos necesarios para el flujo de trabajo como el genoma o el archivo de anotación .gtf.
 
  - (2) *VARIABLES Y SELECCIÓN DE MUESTRA*: Definir directorios en los que encontramos las muestras a analizar.
 
  - (3) *DETECCIÓN AUTOMÁTICA*: Este script tiene capacidad para detectar automáticamente si estamos trabajando con distintos tipos de muestras dependiendo de como han sido secuenciadas: Single-End (1 archivo.fastq.gz / muestra) o Paired-End (2 archivos.fastaq.gz / muestra).
 
  - (4) *FASTQC*: Ejecutamos un control de calidad de la secuenciación de las muestras como comprobación inicial.
 
  - (5) *STAR*: Ejecutamos el alineamiento, a la vez que la descompresión, de los archivos .fastq.gz con el genoma previamente indexado del organismo
 
  - (6) *STRINGTIE*: Lanzamos la cuantificación de las muestras, generando archivos .gtf de cada una de ellas a partir de los archivos.bam, que contienen las coordenadas de mapeo exitoso hecho con STAR.
 
  - (7) *BUCLE DE RECOLECCIÓN*: Se trata de un bucle que busca en los directorios ,previamente definidos, los .gtf de cada muestra y los recolecta para crear la matriz de conteos puros.
 
  - (8) *PYTHON*: Mediante el comando python3 y el objeto generado en el paso anterior, obtenemos las matrices de conteos crudas en formato .csv
 
Al lanzar este archivo a una cola slurm y ser ejecutado, obtendremos la matriz de conteos (unidades en CPM) que nos dará información sobre el nivel de expresión de cada gen en cada una de nuestras condiciones experimentales. Con ello, podremos avanzar al análisis estadístico de dicha matriz.
