# Actividad 2: Aprendizaje Supervisado sobre Datos Biológicos (RNA-seq)

## 1. Introducción y Objetivo
El objetivo de este proyecto es construir un sistema de clasificación de alta precisión capaz de predecir tipos de cáncer (BRCA, KIRC, LUAD, PRAD, COAD) basándose en perfiles de expresión de ARN. Este trabajo aplica técnicas avanzadas de Inteligencia Artificial para la identificación de biomarcadores moleculares.

### Archivos del Proyecto
- `Data/rna_cancer/data_500.csv`: Matriz de expresión con 500 genes seleccionados.
- `Data/rna_cancer/labels.csv`: Etiquetas diagnósticas para cada muestra.
- `Scripts/Actividad2_aprendizaje_supervisado.R`: Script principal con el flujo completo de análisis (Versión Platino).

---

## 2. Informe de Resultados Científicos

### 2.1 Resumen Ejecutivo
Este estudio aplica técnicas de **Aprendizaje Supervisado** alcanzando una precisión superior al **98%**, con un **Coeficiente de Correlación de Matthews (MCC)** de **~0.97**. El modelo final identifica firmas genéticas críticas para el diagnóstico oncológico molecular.

![Distribución de Muestras](Resultados_Analisis/Graficas/01_Distribucion_Clases.png)
*Figura 1: Distribución de clases en el dataset original. Se observa un balance adecuado para un entrenamiento robusto.*

---

## 3. Metodología y Flujo del Pipeline
Se ha implementado un flujo de trabajo de alto rendimiento basado en los siguientes pilares:

1.  **Entorno y Dependencias**: Gestión automatizada de librerías de élite (`caret`, `randomForest`, `umap`, `pheatmap`, `pROC`).
2.  **Ingeniería de Datos y QC**: 
    -   Tratamiento de NAs y eliminación de variables con varianza casi nula (NZV) para reducir el ruido genómico.
    -   Normalización Z-score para garantizar la estabilidad de algoritmos basados en distancia.
3.  **Reducción de Dimensionalidad**: Uso de múltiples algoritmos para validar la separabilidad (PCA, t-SNE, UMAP).
4.  **Optimización y Entrenamiento**: 
    -   **Validación Cruzada (10-fold CV)** para minimizar el sesgo.
    -   **Grid Search** para la optimización de hiperparámetros (mtry).
    -   Comparativa entre **Random Forest** y **SVM**.

---

## 4. Discusión Técnica y Visualizaciones

### 4.1 Comparativa de Modelos
El análisis de rendimiento demuestra que Random Forest supera a SVM en estabilidad y manejo de la alta dimensionalidad biológica.

![Comparativa de Modelos](Resultados_Analisis/Graficas/03_Comparativa_Modelos.png)
*Figura 2: Comparativa de Accuracy entre Random Forest y SVM.*

### 4.2 Topología y Proyecciones de Alta Dimensión
La señal biológica es tan fuerte que incluso métodos lineales (PCA) logran una buena separación, pero los métodos no lineales (UMAP/t-SNE) revelan clusters extremadamente compactos.

````carousel
![Proyección UMAP Expert](Resultados_Analisis/Graficas/11_UMAP_Expert_Projection.png)
<!-- slide -->
![Proyección t-SNE Clusters](Resultados_Analisis/Graficas/09_tSNE_Clusters.png)
<!-- slide -->
![Análisis PCA Estructura](Resultados_Analisis/Graficas/02_PCA_Estructura.png)
````
*Figuras 3, 4 y 5: Proyecciones topológicas que confirman la identidad transcriptómica única de cada tipo tumoral.*

### 4.3 Validación Estadística (ROC)
El modelo mantiene una tasa de falsos positivos virtualmente nula, con un AUC cercano a 1.0.

![Curvas ROC Multi-clase](Resultados_Analisis/Graficas/08_Curvas_ROC.png)
*Figura 6: Curvas ROC por clase. Indicador de una clasificación de alta fidelidad diagnóstica.*

---

## 5. Implicaciones Biológicas y Valor Clínico

### 5.1 Identificación de Biomarcadores
Se han identificado los 20 genes con mayor poder discriminatorio (hubs biológicos).

![Ranking de Biomarcadores](Resultados_Analisis/Graficas/05_Importancia_Biomarcadores.png)
*Figura 7: Ranking de importancia de variables basado en Mean Decrease Gini.*

### 5.2 Firmas Genéticas y Redes
El heatmap jerárquico revela patrones de co-expresión que definen el fenotipo de cada tumor.

![Heatmap de Firmas Genéticas](Resultados_Analisis/Graficas/07_Heatmap_Clusterizado.png)
*Figura 8: Heatmap de expresión promedio del Top 50 de genes.*

![Red de Co-expresión](Resultados_Analisis/Graficas/12_Red_Coexpresion_Top10.png)
*Figura 9: Matriz de correlación entre los biomarcadores líderes.*

---

## 6. GUÍA DE ENTREGA PARA EL PROFESOR
Para la evaluación final, se recomienda revisar la siguiente estructura:

1.  **Código Fuente**: Carpeta `Scripts/` (Archivo principal: `Actividad2_aprendizaje_supervisado.R`).
2.  **Anexos Gráficos**: Carpeta `Resultados_Analisis/Graficas/` (12 evidencias de alta resolución).
3.  **Tablas de Datos**: Archivo `Metricas_por_Clase.csv` para el detalle estadístico.

---
**Autor:** Rubén Juárez Cádiz  
**Fecha:** Abril 2026  
**Materia:** Algoritmos e Inteligencia Artificial en Bioinformática