# ==============================================================================
# ACTIVIDAD 2: APLICACIÓN DE TÉCNICAS DE APRENDIZAJE SUPERVISADO SOBRE DATOS BIOLÓGICOS
# ==============================================================================
# Datos del estudiante:
# Nombre y apellidos: [Nombre y Apellidos del Estudiante]
# Fecha de entrega:   [Fecha]
# ==============================================================================

# --- SECCIÓN 1: CONFIGURACIÓN INTEGRAL DEL ENTORNO ---

# Paquetes de élite
required_packages <- c("readr", "dplyr", "caret", "randomForest", "e1071", 
                      "ggplot2", "gridExtra", "RColorBrewer", "reshape2", 
                      "tidyr", "pROC", "pheatmap", "Rtsne", "umap")

setup_environment <- function(packages) {
  cat(">> Verificando dependencias...\n")
  installed <- rownames(installed.packages())
  for (pkg in packages) {
    if (!pkg %in% installed) install.packages(pkg, repos = "https://cloud.r-project.org")
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }
}

setup_environment(required_packages)
set.seed(123)

# Definición de rutas relativas (Asumiendo ejecución desde la raíz del proyecto)
data_dir <- "Data/rna_cancer"
results_dir <- "Resultados_Analisis/Graficas"
if (!dir.exists("Resultados_Analisis")) dir.create("Resultados_Analisis")
if (!dir.exists(results_dir)) dir.create(results_dir)

# --- SECCIÓN 2: CARGA Y PREPROCESAMIENTO ---

cat(">> Procesando datos...\n")
expr_df   <- read_csv(file.path(data_dir, "data_500.csv"), col_types = cols())
labels_df <- read_csv(file.path(data_dir, "labels.csv"), col_types = cols())

full_dataset <- bind_cols(Class = as.factor(labels_df$Class), expr_df[, -1])

# QC: NZV y Normalización
nzv <- nearZeroVar(full_dataset[, -1])
full_dataset <- full_dataset[, c(TRUE, -nzv)]
full_dataset_proc <- predict(preProcess(full_dataset[, -1], method = c("center", "scale")), full_dataset)

# --- SECCIÓN 3: VISUALIZACIÓN Y CLUSTERING ---

cat(">> Generando visualizaciones (PCA, t-SNE, UMAP)...\n")
# PCA
pca_res <- prcomp(full_dataset_proc[, -1])
ggsave(file.path(results_dir, "02_PCA_Estructura.png"), 
       ggplot(as.data.frame(pca_res$x), aes(PC1, PC2, color = full_dataset_proc$Class)) + 
         geom_point(alpha=0.7) + theme_minimal() + labs(title="PCA"), width=8, height=6)

# UMAP
umap_res <- umap(as.matrix(full_dataset_proc[, -1]))
ggsave(file.path(results_dir, "11_UMAP_Expert_Projection.png"), 
       ggplot(as.data.frame(umap_res$layout), aes(V1, V2, color = full_dataset_proc$Class)) + 
         geom_point(alpha=0.8) + theme_minimal() + labs(title="UMAP"), width=8, height=6)

# --- SECCIÓN 4: MODELADO OPTIMIZADO ---

cat(">> Entrenando Random Forest con validación cruzada...\n")
train_idx <- createDataPartition(full_dataset_proc$Class, p = 0.75, list = FALSE)
model_rf <- train(Class ~ ., data = full_dataset_proc[train_idx, ], method = "rf", 
                 trControl = trainControl(method = "cv", number = 10, classProbs = TRUE))

# --- SECCIÓN 5: EVIDENCIAS FINALES ---

cat(">> Exportando resultados finales...\n")
# Heatmap Clusterizado
importance <- varImp(model_rf)
top50 <- rownames(importance$importance)[order(importance$importance[,1], decreasing = TRUE)][1:50]
heatmap_avg <- full_dataset_proc %>% select(Class, all_of(top50)) %>% group_by(Class) %>% summarise(across(everything(), mean)) %>% as.data.frame()
rownames(heatmap_avg) <- heatmap_avg$Class

png(file.path(results_dir, "07_Heatmap_Clusterizado.png"), width = 1000, height = 800)
pheatmap(heatmap_avg[,-1], main = "Heatmap Jerárquico de Biomarcadores", color = colorRampPalette(c("navy", "white", "firebrick3"))(50))
dev.off()

cat("\n>> PROCESO COMPLETADO EXITOSAMENTE.\n")
cat(sprintf(">> REVISE LA CARPETA: %s/\n", results_dir))
