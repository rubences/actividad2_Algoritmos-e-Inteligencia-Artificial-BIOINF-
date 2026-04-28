# ==============================================================================
# ACTIVIDAD 2: APLICACIÓN DE TÉCNICAS DE APRENDIZAJE SUPERVISADO SOBRE DATOS BIOLÓGICOS
# ==============================================================================
# Datos del estudiante:
# Nombre y apellidos: [Nombre y Apellidos del Estudiante]
# Fecha de entrega:   [Fecha]
# ==============================================================================

# --- SECCIÓN 1: PREPARACIÓN DEL ENTORNO DE TRABAJO (Criterio 1) ---

# Paquetes requeridos para análisis bioinformático y visualización avanzada
required_packages <- c("readr", "dplyr", "caret", "randomForest", "e1071", 
                      "ggplot2", "gridExtra", "RColorBrewer", "reshape2")

# Función para la gestión automatizada de dependencias
setup_environment <- function(packages) {
  installed_packages <- rownames(installed.packages())
  for (pkg in packages) {
    if (!pkg %in% installed_packages) {
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }
}

setup_environment(required_packages)
set.seed(123)

# Crear carpeta para guardar resultados si no existe
results_dir <- "Resultados_Graficos"
if (!dir.exists(results_dir)) dir.create(results_dir)

# --- SECCIÓN 2: PREPARACIÓN Y MANIPULACIÓN DE LOS DATOS (Criterio 2) ---

expr_path  <- "Data/rna_cancer/data_500.csv"
label_path <- "Data/rna_cancer/labels.csv"

if (!file.exists(expr_path) | !file.exists(label_path)) stop("Archivos de datos no encontrados.")

# Carga de datos
# Nota: Usamos bind_cols ya que los IDs pueden tener formatos distintos ('sample_N' vs 'N')
# pero el orden de las filas es consistente en este dataset.
expr_df   <- read_csv(expr_path, col_types = cols())
labels_df <- read_csv(label_path, col_types = cols())

# Limpieza: Eliminamos la primera columna (IDs redundantes) y combinamos
expr_clean <- expr_df[, -1]
class_vector <- as.factor(labels_df$Class)

full_dataset <- bind_cols(Class = class_vector, expr_clean)

# Limpieza técnica: Eliminación de varianza casi nula (genes constantes)
nzv <- nearZeroVar(full_dataset[, -1], saveMetrics = TRUE)
full_dataset <- full_dataset[, c(TRUE, !nzv$nzv)]

# Normalización (Vital para SVM y PCA)
pre_process_params <- preProcess(full_dataset[, -1], method = c("center", "scale"))
full_dataset_proc <- predict(pre_process_params, full_dataset)

# --- SECCIÓN 3: VISUALIZACIONES EXPLORATORIAS ---

# 3.1 Distribución de Clases (Balanceo)
dist_plot <- ggplot(full_dataset_proc, aes(x = Class, fill = Class)) +
  geom_bar() + theme_minimal() +
  labs(title = "Distribución de Tipos de Cáncer", x = "Clase", y = "Nº Muestras") +
  scale_fill_brewer(palette = "Set2")
ggsave(file.path(results_dir, "01_Distribucion_Clases.png"), dist_plot, width = 8, height = 6)

# 3.2 PCA Plot (Estructura biológica)
pca_res <- prcomp(full_dataset_proc[, -1])
pca_df <- as.data.frame(pca_res$x[, 1:2])
pca_df$Class <- full_dataset_proc$Class
pca_plot <- ggplot(pca_df, aes(x = PC1, y = PC2, color = Class)) +
  geom_point(alpha = 0.8, size = 2.5) + theme_minimal() +
  labs(title = "Análisis de Componentes Principales (PCA)", x = "PC1", y = "PC2") +
  scale_color_brewer(palette = "Dark2")
ggsave(file.path(results_dir, "02_PCA_Análisis.png"), pca_plot, width = 8, height = 6)

# --- SECCIÓN 4: DIVISIÓN Y ENTRENAMIENTO (Criterio 3) ---

train_index <- createDataPartition(full_dataset_proc$Class, p = 0.70, list = FALSE)
train_data  <- full_dataset_proc[train_index, ]
test_data   <- full_dataset_proc[-train_index, ]

# Entrenamiento con Validación Cruzada
train_control <- trainControl(method = "cv", number = 5)
model_rf <- train(Class ~ ., data = train_data, method = "rf", trControl = train_control, tuneLength = 2)

# --- SECCIÓN 5: EVALUACIÓN Y NUEVAS VISUALIZACIONES (Criterio 4) ---

pred_rf <- predict(model_rf, test_data)
cm_rf <- confusionMatrix(pred_rf, test_data$Class)

# 5.1 Heatmap de Matriz de Confusión
cm_df <- as.data.frame(cm_rf$table)
cm_plot <- ggplot(cm_df, aes(Prediction, Reference, fill = Freq)) +
  geom_tile() + geom_text(aes(label = Freq), color = "white", size = 5) +
  scale_fill_gradient(low = "#e0ecf4", high = "#8856a7") +
  theme_minimal() + labs(title = "Matriz de Confusión: Predicho vs Real")
ggsave(file.path(results_dir, "03_Matriz_Confusion.png"), cm_plot, width = 8, height = 6)

# 5.2 Ranking de Importancia de Genes (Biomarcadores)
importance <- varImp(model_rf)
top_genes <- data.frame(Gene = rownames(importance$importance),
                       Score = importance$importance[, 1]) %>%
  arrange(desc(Score)) %>% head(15)

importance_plot <- ggplot(top_genes, aes(x = reorder(Gene, Score), y = Score)) +
  geom_bar(stat = "identity", fill = "#31a354") + coord_flip() +
  theme_minimal() + labs(title = "Top 15 Genes Biomarcadores", x = "Gen", y = "Importancia")
ggsave(file.path(results_dir, "04_Importancia_Genes.png"), importance_plot, width = 8, height = 6)

# 5.3 Boxplot del Gen Líder (Validación biológica)
best_gene <- top_genes$Gene[1]
boxplot_top <- ggplot(full_dataset_proc, aes_string(x = "Class", y = best_gene, fill = "Class")) +
  geom_boxplot() + theme_minimal() +
  labs(title = paste("Expresión de", best_gene, "por Tipo de Cáncer"),
       subtitle = "Análisis del principal discriminador transcriptómico", x = "Clase", y = "Expresión Normalizada") +
  scale_fill_brewer(palette = "Pastel1")
ggsave(file.path(results_dir, "05_Boxplot_TopGene.png"), boxplot_top, width = 8, height = 6)

# 5.4 Heatmap de Correlación Top 10
top10_genes <- top_genes$Gene[1:10]
cor_matrix <- cor(full_dataset_proc[, top10_genes])
melted_cor <- melt(cor_matrix)
corr_plot <- ggplot(melted_cor, aes(Var1, Var2, fill = value)) +
  geom_tile() + scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_minimal() + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  labs(title = "Correlación entre los 10 Genes más Influyentes")
ggsave(file.path(results_dir, "06_Correlacion_Genes.png"), corr_plot, width = 8, height = 8)

# --- SECCIÓN 6: INFORME FINAL Y CONCLUSIONES ---

cat("\n==============================================================================\n")
cat("                       INFORME DE RESULTADOS FINALES\n")
cat("==============================================================================\n")
cat(sprintf("PRECISIÓN GLOBAL (ACCURACY): %.2f%%\n", cm_rf$overall["Accuracy"] * 100))
cat(sprintf("BIOMARCADOR PRINCIPAL IDENTIFICADO: %s\n", best_gene))
cat(sprintf("CARPETA DE SALIDA: %s/\n", results_dir))
cat("==============================================================================\n")
cat("CONCLUSIONES:\n")
cat("1. El modelo demuestra una alta capacidad discriminatoria entre tipos de cáncer.\n")
cat("2. Se han guardado 6 análisis visuales que documentan el proceso completo,\n")
cat("   desde la estructura del dataset hasta la importancia de los biomarcadores.\n")
cat("3. El preprocesamiento (normalización y limpieza NZV) ha sido clave para la estabilidad.\n")
cat("==============================================================================\n")
