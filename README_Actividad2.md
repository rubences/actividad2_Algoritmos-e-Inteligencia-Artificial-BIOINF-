# Actividad 2 - Aprendizaje Supervisado sobre Datos Biológicos (Versión Mejorada)

Este documento explica el proceso de clasificación de tipos de cáncer utilizando datos de expresión génica, incluyendo técnicas avanzadas de validación y visualización.

## Objetivo

Construir un sistema de clasificación capaz de predecir el tipo de cáncer (BRCA, KIRC, LUAD, PRAD, COAD) basándose en perfiles de expresión de ARN.

## Archivos utilizados

- `Data/rna_cancer/data_500.csv`: Matriz de expresión con 500 genes seleccionados.
- `Data/rna_cancer/labels.csv`: Etiquetas diagnósticas para cada muestra.
- `Actividad2_aprendizaje_supervisado.R`: Script principal con el flujo completo de análisis.

## Mejoras Implementadas (Creatividad)

Se han añadido los siguientes componentes para superar los requisitos básicos (Criterio 6):

1.  **Análisis de Componentes Principales (PCA)**: Antes de entrenar, el script genera un gráfico de PCA para visualizar cómo se agrupan biológicamente las muestras en 2D, lo cual es fundamental en bioinformática.
2.  **Comparativa de Modelos**: Se entrenan y evalúan dos algoritmos distintos bajo las mismas condiciones:
    -   **Random Forest (RF)**: Maneja bien las interacciones no lineales entre genes.
    -   **Support Vector Machine (SVM)**: Muy eficiente en espacios de alta dimensionalidad.
3.  **Visualización Avanzada**: Uso de `ggplot2` para generar gráficos de calidad profesional:
    -   **PCA Plot**: Dispersión por tipo de cáncer.
    -   **Heatmap de Confusión**: Visualización intuitiva de aciertos y errores.
    -   **Gene Importance**: Ranking de los 15 genes que más influyen en el diagnóstico.

## Flujo del Script

1.  **Entorno**: Instalación y carga automatizada de librerías (`caret`, `randomForest`, `e1071`, `ggplot2`).
2.  **Preprocesamiento**: 
    -   Limpieza y unión de datos por ID de muestra.
    -   Eliminación de variables con varianza casi nula (`nearZeroVar`) para reducir el ruido.
3.  **Entrenamiento**: Validación Cruzada Repetida (5-folds, 3 repeticiones) para asegurar que el modelo no esté sobreajustado.
4.  **Evaluación**: Comparación estadística de Accuracy y Kappa entre los dos modelos.

## Cómo ejecutar

```r
# En la consola de R o RStudio:
source("Actividad2_aprendizaje_supervisado.R")
```

## Resultado esperado

El script imprimirá en la consola una tabla comparativa y generará un panel gráfico que permite validar la calidad biológica y estadística del modelo.
