# Actividad 2: Aprendizaje Supervisado sobre Datos Biológicos (RNA-seq)

## 1. Introducción y Objetivo
El objetivo de este proyecto es construir un sistema de clasificación de alta precisión capaz de predecir tipos de cáncer (BRCA, KIRC, LUAD, PRAD, COAD) basándose en perfiles de expresión de ARN. Este trabajo aplica técnicas avanzadas de Inteligencia Artificial para la identificación de biomarcadores moleculares.

### Archivos del Proyecto
- `Data/rna_cancer/data_500.csv`: Matriz de expresión con 500 genes seleccionados.
- `Data/rna_cancer/labels.csv`: Etiquetas diagnósticas para cada muestra.
- `Scripts/Actividad2_aprendizaje_supervisado.R`: Script principal con el flujo completo de análisis.

---

## 2. Informe de Resultados Científicos

### 2.1 Resumen Ejecutivo
Este estudio aplica técnicas de **Aprendizaje Supervisado** alcanzando una precisión superior al **98%**, con un **Coeficiente de Correlación de Matthews (MCC)** de **~0.97**. El modelo final identifica firmas genéticas críticas para el diagnóstico oncológico molecular.

<p align="center">
  <img src="./Resultados_Analisis/Graficas/01_Distribucion_Clases.png" alt="Distribución de Muestras" width="700">
</p>
<p align="center"><i>Figura 1: Distribución de clases en el dataset original. Se observa un balance adecuado para un entrenamiento robusto.</i></p>

---

## 3. Metodología y Flujo del Pipeline
Se ha implementado un flujo de trabajo de alto rendimiento basado en los siguientes pilares:

1.  **Entorno y Dependencias**: Gestión automatizada de librerías de élite (`caret`, `randomForest`, `umap`, `pheatmap`, `pROC`).
2.  **Ingeniería de Datos y QC**: Tratamiento de NAs, filtrado NZV y normalización Z-score.
3.  **Reducción de Dimensionalidad**: Validación de la separabilidad mediante PCA, t-SNE y UMAP.
4.  **Optimización**: Grid Search para hiperparámetros y validación cruzada de 10 pliegues.

---

## 4. Discusión Técnica y Visualizaciones

### 4.1 Comparativa de Modelos
El análisis de rendimiento demuestra que Random Forest supera a SVM en estabilidad.

<p align="center">
  <img src="./Resultados_Analisis/Graficas/03_Comparativa_Modelos.png" alt="Comparativa de Modelos" width="600">
</p>
<p align="center"><i>Figura 2: Comparativa de Accuracy entre Random Forest y SVM.</i></p>

### 4.2 Topología y Proyecciones
La señal biológica permite clusters extremadamente compactos detectados por algoritmos no lineales.

<p align="center">
  <img src="./Resultados_Analisis/Graficas/11_UMAP_Expert_Projection.png" alt="Proyección UMAP" width="700">
</p>
<p align="center"><i>Figura 3: Proyección UMAP (Estado del arte en bioinformática).</i></p>

<p align="center">
  <img src="./Resultados_Analisis/Graficas/09_tSNE_Clusters.png" alt="Proyección t-SNE" width="700">
</p>
<p align="center"><i>Figura 4: Proyección t-SNE (Visualización de clusters no lineales).</i></p>

### 4.3 Validación Estadística (ROC)
El modelo mantiene una tasa de falsos positivos nula, con un AUC cercano a 1.0.

<p align="center">
  <img src="./Resultados_Analisis/Graficas/08_Curvas_ROC.png" alt="Curvas ROC" width="600">
</p>
<p align="center"><i>Figura 5: Curvas ROC por clase. Indicador de alta fidelidad diagnóstica.</i></p>

---

## 5. Implicaciones Biológicas

### 5.1 Identificación de Biomarcadores
Se han identificado los 20 genes con mayor poder discriminatorio.

<p align="center">
  <img src="./Resultados_Analisis/Graficas/05_Importancia_Biomarcadores.png" alt="Ranking de Biomarcadores" width="700">
</p>
<p align="center"><i>Figura 6: Ranking de importancia de variables.</i></p>

### 5.2 Firmas Genéticas
El heatmap jerárquico revela patrones de co-expresión únicos por tumor.

<p align="center">
  <img src="./Resultados_Analisis/Graficas/07_Heatmap_Clusterizado.png" alt="Heatmap Jerárquico" width="800">
</p>
<p align="center"><i>Figura 7: Heatmap de expresión del Top 50 de genes.</i></p>

---

## 6. GUÍA DE ENTREGA PARA EL PROFESOR
1.  **Código**: Carpeta `Scripts/`.
2.  **Gráficas**: Carpeta `Resultados_Analisis/Graficas/`.
3.  **Métricas**: Archivo `Resultados_Analisis/Metricas_por_Clase.csv`.

---
**Autor:** Rubén Juárez Cádiz  
**Fecha:** Abril 2026  
**Materia:** Algoritmos e Inteligencia Artificial en Bioinformática