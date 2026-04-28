# Actividad 2 - Aprendizaje Supervisado sobre Datos Biológicos

Este documento explica paso a paso la resolución de la actividad 2 utilizando los datos de expresión génica disponibles en `Data/rna_cancer`.

## Objetivo

Construir un modelo de clasificación supervisada que prediga el tipo de cáncer a partir de datos de expresión génica.

## Archivos utilizados

- `Data/rna_cancer/data_500.csv`: matriz de expresión génica con 500 genes seleccionados.
- `Data/rna_cancer/labels.csv`: etiquetas de clase para cada muestra.
- `Actividad2_aprendizaje_supervisado.R`: script de R que realiza la carga de datos, preparación, entrenamiento, evaluación y salida de resultados.

## Pasos realizados

### 1. Preparación del entorno de trabajo

El script instala y carga los paquetes necesarios si no están disponibles:

- `readr`
- `dplyr`
- `caret`
- `randomForest`

Esto permite leer datos CSV, manipular tablas, entrenar modelos y calcular métricas de evaluación.

### 2. Carga y limpieza de datos

- Se lee `data_500.csv` como dataset de características.
- Se lee `labels.csv` para obtener las clases de cada muestra.
- Se elimina la primera columna vacía de `data_500.csv` que corresponde a un identificador de fila.
- Se convierte la variable `Class` a factor para clasificación.
- Se eliminan las variables con varianza casi cero usando `nearZeroVar()` para mejorar la calidad del modelo.

### 3. División del conjunto de datos

- Se crea una partición de entrenamiento/prueba con el 70% de las muestras para entrenamiento y el 30% restante para evaluación.
- El muestreo se realiza de forma estratificada según la clase para mantener la distribución de etiquetas.

### 4. Selección y entrenamiento del modelo

- Se selecciona `randomForest` como método supervisado.
- Se entrena el modelo con validación cruzada repetida (`5` folds y `3` repeticiones).
- Se utiliza `caret::train()` para facilitar el proceso de entrenamiento y ajuste del modelo.

### 5. Evaluación del modelo

El script calcula:

- matriz de confusión
- precisión global (`Accuracy`)
- resultados generales de evaluación
- importancia de variables (top 10 genes más relevantes)

## Cómo ejecutar el script

1. Abrir R o RStudio.
2. Ir al directorio raíz del proyecto.
3. Ejecutar el script:

```r
source("Actividad2_aprendizaje_supervisado.R")
```

O, si `Rscript` está disponible en la terminal:

```bash
Rscript --vanilla Actividad2_aprendizaje_supervisado.R
```

## Resultado esperado

Al ejecutarlo, el script muestra en consola:

- número de muestras
- número de genes utilizados
- distribución de clases
- número de muestras de entrenamiento y prueba
- resumen del modelo entrenado
- matriz de confusión
- métricas de evaluación
- precisión general
- top 10 genes importantes para la clasificación

## Notas adicionales

- Si se desea usar el archivo completo `data.csv` en lugar de `data_500.csv`, basta con cambiar la ruta en `expr_path` dentro del script.
- El script está comentado para explicar cada bloque de código y facilitar su lectura.
