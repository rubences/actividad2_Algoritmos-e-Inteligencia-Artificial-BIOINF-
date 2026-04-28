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

expr <- read_csv(expr_path, col_types = cols())
labels <- read_csv(label_path, col_names = c("SampleID", "Class"), col_types = cols(), skip = 1)

names(expr)[1] <- "SampleID"
full_dataset <- inner_join(labels, expr, by = "SampleID") %>% select(-SampleID)
full_dataset$Class <- as.factor(full_dataset$Class)

# Limpieza: Varianza casi nula
nzv <- nearZeroVar(full_dataset[, -1], saveMetrics = TRUE)
full_dataset <- full_dataset[, c(TRUE, !nzv$nzv)]

# Normalización (Centrado y Escalamiento)
pre_process_params <- preProcess(full_dataset[, -1], method = c("center", "scale"))
full_dataset_proc <- predict(pre_process_params, full_dataset)

# --- SECCIÓN 3: VISUALIZACIONES EXPLORATORIAS ---

# 3.1 Distribución de Clases
dist_plot <- ggplot(full_dataset_proc, aes(x = Class, fill = Class)) +
  geom_bar() +
  theme_minimal() +
  labs(title = "Distribución de Tipos de Cáncer", x = "Clase", y = "Número de Muestras") +
  scale_fill_brewer(palette = "Set2")
ggsave(file.path(results_dir, "01_Distribucion_Clases.png"), dist_plot, width = 8, height = 6)

# 3.2 PCA Plot (Estructura del Dataset)
pca_res <- prcomp(full_dataset_proc[, -1])
pca_df <- as.data.frame(pca_res$x[, 1:2])
pca_df$Class <- full_dataset_proc$Class
pca_plot <- ggplot(pca_df, aes(x = PC1, y = PC2, color = Class)) +
  geom_point(alpha = 0.8, size = 2.5) +
  theme_minimal() +
  labs(title = "Análisis de Componentes Principales (PCA)", x = "PC1", y = "PC2") +
  scale_color_brewer(palette = "Dark2")
ggsave(file.path(results_dir, "02_PCA_Análisis.png"), pca_plot, width = 8, height = 6)

# --- SECCIÓN 4: DIVISIÓN Y ENTRENAMIENTO (Criterio 3) ---

train_index <- createDataPartition(full_dataset_proc$Class, p = 0.70, list = FALSE)
train_data  <- full_dataset_proc[train_index, ]
test_data   <- full_dataset_proc[-train_index, ]

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
  theme_minimal() + labs(title = "Matriz de Confusión")
ggsave(file.path(results_dir, "03_Matriz_Confusion.png"), cm_plot, width = 8, height = 6)

# 5.2 Ranking de Importancia de Genes
importance <- varImp(model_rf)
top_genes <- data.frame(Gene = rownames(importance$importance),
                       Score = importance$importance[, 1]) %>%
  arrange(desc(Score)) %>% head(15)

importance_plot <- ggplot(top_genes, aes(x = reorder(Gene, Score), y = Score)) +
  geom_bar(stat = "identity", fill = "#31a354") + coord_flip() +
  theme_minimal() + labs(title = "Top 15 Genes Biomarcadores", x = "Gen", y = "Score")
ggsave(file.path(results_dir, "04_Importancia_Genes.png"), importance_plot, width = 8, height = 6)

# 5.3 Boxplot del Gen más Importante (Comportamiento biológico)
best_gene <- top_genes$Gene[1]
boxplot_top <- ggplot(full_dataset_proc, aes_string(x = "Class", y = best_gene, fill = "Class")) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = paste("Expresión de", best_gene, "por Tipo de Cáncer"),
       subtitle = "Visualización del biomarcador principal", x = "Clase", y = "Expresión Normalizada") +
  scale_fill_brewer(palette = "Pastel1")
ggsave(file.path(results_dir, "05_Boxplot_TopGene.png"), boxplot_top, width = 8, height = 6)

# 5.4 Correlación entre el Top 10 de Genes
top10_genes <- top_genes$Gene[1:10]
cor_matrix <- cor(full_dataset_proc[, top10_genes])
melted_cor <- melt(cor_matrix)
corr_plot <- ggplot(melted_cor, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  labs(title = "Correlación entre Genes Top 10", x = "", y = "")
ggsave(file.path(results_dir, "06_Correlacion_Genes.png"), corr_plot, width = 8, height = 8)

# --- SECCIÓN 6: INFORME FINAL Y CONCLUSIONES ---

cat("\n==============================================================================\n")
cat("                       INFORME DE RESULTADOS FINALES\n")
cat("==============================================================================\n")
cat(sprintf("PRECISIÓN GLOBAL: %.2f%%\n", cm_rf$overall["Accuracy"] * 100))
cat(sprintf("BIOMARCADOR LÍDER: %s\n", best_gene))
cat(sprintf("RESULTADOS GUARDADOS EN: %s/\n", results_dir))
cat("==============================================================================\n")
cat("CONCLUSIÓN: El modelo ha identificado firmas transcriptómicas claras que permiten\n")
cat("una clasificación precisa de los tumores. Las visualizaciones guardadas permiten\n")
cat("validar la solidez estadística y biológica del estudio.\n")
cat("==============================================================================\n")
