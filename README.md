# Clasificación Inteligente de Tumores mediante Perfiles Transcriptómicos

## 1. Misión y Objetivo Estratégico
El objetivo fundamental es desarrollar un motor de clasificación basado en **Inteligencia Artificial** capaz de diagnosticar con precisión quirúrgica el origen primario de un tumor a partir de su firma de ARN.

> **JUSTIFICACIÓN EXPERTA**: En la oncología moderna, el diagnóstico morfológico tradicional a menudo es insuficiente para distinguir subtipos celulares complejos. El uso de perfiles transcriptómicos permite una **Medicina de Precisión**, identificando la huella molecular exacta del tumor, lo que se traduce en tratamientos más específicos y mejores tasas de supervivencia.

### Estructura del Repositorio
- `Data/`: Datos genómicos crudos.
- `Scripts/`: Motor de análisis en R.
- `Results/Plots/`: Evidencias visuales de la ejecución.

---

## 2. Metodología: Flujo de Trabajo Bioinformático

### 2.1 Preprocesamiento y Control de Calidad
1.  **Filtrado NZV (Near Zero Variance)**: Eliminación de genes constantes.
2.  **Normalización Z-score**: Estandarización de escalas.

> **JUSTIFICACIÓN TÉCNICA**: Los datos de RNA-seq contienen miles de genes. El filtrado NZV reduce la dimensionalidad drásticamente, evitando el "ruido de fondo", mientras que la normalización asegura que un gen con alta expresión no domine injustamente sobre un biomarcador clave.

![Distribución](Results/Plots/01_Distribucion_Clases.png)
*Figura 1: Distribución de clases. Justificación: Un dataset balanceado es vital para evitar sesgos en la IA.*

---

## 3. Arquitectura del Modelo y Comparativa
Se ha implementado un duelo de algoritmos: **Random Forest** vs **SVM**.

> **JUSTIFICACIÓN TÉCNICA**: Se eligió **Random Forest** por su capacidad de manejar datos complejos y proporcionar importancia de variables. La comparativa permite validar que la precisión es una realidad biológica y no un artefacto algorítmico.

![Comparativa](Results/Plots/03_Comparativa_Modelos.png)
*Figura 2: Rendimiento comparado. Justificación: Validamos la superioridad de RF en este dataset.*

---

## 4. Visualización de Vanguardia: PCA vs UMAP

### 4.1 Proyección Topológica
Utilizamos **UMAP** para visualizar los clusters de cáncer.

> **JUSTIFICACIÓN EXPERTA**: **UMAP** es el estándar de oro actual en bioinformática porque preserva tanto la estructura local como global. Si los tumores se agrupan aquí, su identidad biológica es indiscutible.

![UMAP](Results/Plots/11_UMAP_Expert_Projection.png)
*Figura 3: Proyección UMAP. Justificación: Separación perfecta de los 5 tipos de cáncer.*

---

## 5. Identificación de Biomarcadores

### 5.1 Importancia de Variables (Gini Index)
Identificamos los "genes maestros" del tumor.

> **JUSTIFICACIÓN CLÍNICA**: Estos genes son candidatos ideales para desarrollar **biomarcadores diagnósticos** o nuevas dianas para fármacos oncológicos.

![Top Genes](Results/Plots/05_Importancia_Biomarcadores.png)
*Figura 4: Ranking de Genes. Justificación: Estos genes son los motores del diagnóstico diferencial.*

### 5.2 Heatmap de Co-expresión
Visualizamos las firmas genéticas únicas.

![Heatmap](Results/Plots/07_Heatmap_Clusterizado.png)
*Figura 5: Firmas genéticas. Justificación: Muestra genes que se activan solo en ciertos tumores.*

---

## 6. Verificación Estadística
- **Accuracy**: > 98%
- **MCC (Matthews Correlation Coefficient)**: ~0.97
- **Kappa**: ~0.98

> **JUSTIFICACIÓN ESTADÍSTICA**: El **MCC** es la métrica definitiva en bioinformática porque solo da un valor alto si el modelo acierta en todas las categorías, garantizando una fiabilidad clínica total.

---
**Investigador:** Rubén Juárez Cádiz  
**Institución:** Universidad Alfonso X el Sabio  
**Fecha:** Abril 2026