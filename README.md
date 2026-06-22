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


- **TFM_COMPLETO.Rmd**: Este script de R abarca el núcleo del análisis transcriptómico a partir de la matriz generada en el paso anterior. Se divide en los siguientes apartados:

  - (1) *PREPARACIÓN Y NORMALIZACIÓN*: Limpieza de la matriz cruda, filtrado de aquellos genes con muy baja expresión y normalización de los datos (método de cuantiles) para homogeneizar las muestras y permitir su comparación.

  - (2) *VISUALIZACIÓN GLOBAL*: Generación de gráficos PCA (Análisis de Componentes Principales) para evaluar la variabilidad global y confirmar que las réplicas biológicas se agrupan correctamente según su tratamiento.

  - (3) *EXPRESIÓN DIFERENCIAL (DEGs)*: Uso del paquete estadístico limma para identificar qué genes cambian significativamente su expresión al comparar distintas condiciones (efecto de la adición/retirada de dexametasona, luz frente a oscuridad, y progresión temporal).

  - (4) *CLUSTERING Y HEATMAPS*: Agrupación de los genes diferencialmente expresados en clústeres según sus patrones de comportamiento, visualizándolos de forma masiva mediante mapas de calor (heatmaps) y gráficos de perfiles de expresión.

  - (5) *ENRIQUECIMIENTO FUNCIONAL*: Análisis de Gene Ontology (GO) para traducir esas listas de genes en información biológica, identificando qué procesos celulares (ej. fotosíntesis, división celular, respuestas a estrés) están enriquecidos en cada clúster.


- **TFM_BARPLOT_MISDATOS.Rmd**: Un script de R centrado exclusivamente en la visualización individualizada de un grupo reducido de genes clave para el estudio:

  - (1) *FILTRADO DE MARCADORES*: Aislamiento de 7 genes de interés específicos (marcadores conocidos de embriogénesis temprana y tardía) a partir de la matriz normalizada global.

  - (2) *ESTADÍSTICA DESCRIPTIVA*: Agrupación de las distintas réplicas de cada tratamiento para calcular automáticamente la media de expresión y su correspondiente error estándar (SEM).

  - (3) *GRÁFICOS DE BARRAS*: Generación de gráficos de barras personalizados y listos para su publicación en el documento final, facilitando la interpretación visual de la expresión de estos marcadores concretos.


- **TFM_DNA_MOTIFS_2.Rmd**: Script de R destinado al análisis computacional (in silico) de secuencias de ADN promotoras para buscar posibles interacciones moleculares:

  - (1) *LOCALIZACIÓN DE COORDENADAS*: Conexión automática con bases de datos genómicas (Ensembl Plants) para identificar las coordenadas de inicio de transcripción (TSS) de genes reguladores diana.

  - (2) *EXTRACCIÓN DE PROMOTORES*: Uso del genoma de referencia de Arabidopsis thaliana para extraer las secuencias de ADN exactas ubicadas justo antes del inicio de estos genes (ventana reguladora de -1000 a +100 pares de bases).

  - (3) *BÚSQUEDA DE MOTIVOS (MOTIFS)*: Escaneo automatizado de las secuencias extraídas en busca de patrones de nucleótidos concretos, identificando dónde se localizan los posibles sitios de unión para factores de transcripción embrionarios (como el motivo "CCAAT" de LEC1) y exportando los aciertos a una tabla de resultados.
