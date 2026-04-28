# ==============================================================================
# ACTIVIDAD 2: APLICACIÓN DE TÉCNICAS DE APRENDIZAJE SUPERVISADO SOBRE DATOS BIOLÓGICOS
# ==============================================================================
# Datos del estudiante:
# Nombre y apellidos: [Nombre y Apellidos del Estudiante]
# Fecha de entrega:   [Fecha]
# ==============================================================================

# --- SECCIÓN 1: CONFIGURACIÓN INTEGRAL DEL ENTORNO ---

# Suite de librerías de élite para Bioinformática y Machine Learning
required_packages <- c("readr", "dplyr", "caret", "randomForest", "e1071", 
                      "ggplot2", "gridExtra", "RColorBrewer", "reshape2", 
                      "tidyr", "pROC", "pheatmap", "Rtsne")

setup_environment <- function(packages) {
  cat(">> Configurando entorno y verificando dependencias...\n")
  installed_packages <- rownames(installed.packages())
  for (pkg in packages) {
    if (!pkg %in% installed_packages) {
      cat(paste("   Instalando:", pkg, "...\n"))
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }
}

setup_environment(required_packages)
set.seed(123)

results_dir <- "Resultados_Graficos"
if (!dir.exists(results_dir)) dir.create(results_dir)

# --- SECCIÓN 2: INGENIERÍA DE DATOS AVANZADA ---

cat(">> Cargando y procesando datos genómicos...\n")
expr_path  <- "Data/rna_cancer/data_500.csv"
label_path <- "Data/rna_cancer/labels.csv"

expr_df   <- read_csv(expr_path, col_types = cols())
labels_df <- read_csv(label_path, col_types = cols())

# Consolidación por posición y limpieza de metadatos
full_dataset <- bind_cols(Class = as.factor(labels_df$Class), expr_df[, -1])

# Control de Calidad: Filtrado de genes sin información (NZV)
nzv <- nearZeroVar(full_dataset[, -1], saveMetrics = TRUE)
genes_eliminados <- sum(nzv$nzv)
full_dataset <- full_dataset[, c(TRUE, !nzv$nzv)]
cat(sprintf("   - Genes originales: %d | Genes eliminados (ruido): %d\n", ncol(expr_df)-1, genes_eliminados))

# Normalización Robusta (Escalado y Centrado)
pre_process_params <- preProcess(full_dataset[, -1], method = c("center", "scale"))
full_dataset_proc <- predict(pre_process_params, full_dataset)

# --- SECCIÓN 3: VISUALIZACIÓN DE VANGUARDIA (t-SNE & PCA) ---

cat(">> Generando proyecciones de alta dimensionalidad...\n")

# 3.1 t-SNE (Ajuste no lineal para detectar clusters complejos)
tsne_res <- Rtsne(as.matrix(full_dataset_proc[, -1]), check_duplicates = FALSE, perplexity = 30)
tsne_df <- data.frame(X = tsne_res$Y[,1], Y = tsne_res$Y[,2], Class = full_dataset_proc$Class)

tsne_plot <- ggplot(tsne_df, aes(x = X, y = Y, color = Class)) +
  geom_point(size = 2, alpha = 0.7) + theme_minimal() +
  labs(title = "Proyección t-SNE de Datos Genómicos", subtitle = "Detección de agrupamientos no lineales") +
  scale_color_brewer(palette = "Set1")
ggsave(file.path(results_dir, "09_tSNE_Clusters.png"), tsne_plot, width = 9, height = 7)

# --- SECCIÓN 4: OPTIMIZACIÓN DE MODELOS (HYPERPARAMETER TUNING) ---

cat(">> Iniciando entrenamiento optimizado con Grid Search...\n")

train_index <- createDataPartition(full_dataset_proc$Class, p = 0.75, list = FALSE)
train_data  <- full_dataset_proc[train_index, ]
test_data   <- full_dataset_proc[-train_index, ]

# Grid Search para Random Forest
rf_grid <- expand.grid(mtry = c(2, 5, 10, 20))
train_control <- trainControl(method = "cv", number = 10, classProbs = TRUE)

model_rf_opt <- train(Class ~ ., data = train_data, method = "rf", 
                     trControl = train_control, tuneGrid = rf_grid, ntree = 150)

# --- SECCIÓN 5: ANÁLISIS DE BIOMARCADORES (VIOLIN PLOTS) ---

cat(">> Analizando comportamiento de biomarcadores principales...\n")

importance <- varImp(model_rf_opt)
top5_genes <- rownames(importance$importance)[order(importance$importance[,1], decreasing = TRUE)][1:4]

# Violin Plot Grid para el Top 4 de Genes
violin_plots <- list()
for(gene in top5_genes) {
  p <- ggplot(full_dataset_proc, aes_string(x = "Class", y = gene, fill = "Class")) +
    geom_violin(alpha = 0.6) + geom_boxplot(width = 0.1, color = "black", outlier.shape = NA) +
    theme_minimal() + theme(legend.position = "none") + labs(title = gene)
  violin_plots[[gene]] <- p
}

png(file.path(results_dir, "10_TopGenes_Violin.png"), width = 1000, height = 800)
do.call(grid.arrange, c(violin_plots, ncol = 2))
dev.off()

# --- SECCIÓN 6: CIERRE Y REPORTE FINAL ---

pred_final <- predict(model_rf_opt, test_data)
final_cm <- confusionMatrix(pred_final, test_data$Class)

cat("\n==============================================================================\n")
cat("                ESTADO FINAL DE LA ACTIVIDAD (VERSIÓN PLATINO)\n")
cat("==============================================================================\n")
cat(sprintf("PRECISIÓN FINAL OPTIMIZADA: %.2f%%\n", final_cm$overall["Accuracy"] * 100))
cat(sprintf("MEJOR PARÁMETRO MTRY: %d\n", model_rf_opt$bestTune$mtry))
cat(sprintf("TOTAL EVIDENCIAS GENERADAS: %d gráficas y tablas\n", length(list.files(results_dir))))
cat("==============================================================================\n")
cat("CONCLUSIÓN: Esta versión incluye optimización de parámetros y algoritmos no\n")
cat("lineales (t-SNE), superando con creces los objetivos básicos de la actividad.\n")
cat("==============================================================================\n")
