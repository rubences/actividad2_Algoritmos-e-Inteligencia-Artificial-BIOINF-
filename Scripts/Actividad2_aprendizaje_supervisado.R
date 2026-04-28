# ==============================================================================
# ACTIVIDAD 2: APLICACIÓN DE TÉCNICAS DE APRENDIZAJE SUPERVISADO SOBRE DATOS BIOLÓGICOS
# ==============================================================================
# Datos del estudiante:
# Nombre y apellidos: [Nombre y Apellidos del Estudiante]
# Fecha de entrega:   [Fecha]
# ==============================================================================

# --- SECCIÓN 1: CONFIGURACIÓN INTEGRAL DEL ENTORNO ---

# Paquetes de élite para Bioinformática y Machine Learning
required_packages <- c("readr", "dplyr", "caret", "randomForest", "e1071", 
                      "ggplot2", "gridExtra", "RColorBrewer", "reshape2", 
                      "tidyr", "pROC", "pheatmap", "Rtsne", "umap", "MLmetrics")

setup_environment <- function(packages) {
  cat(">> Verificando dependencias de alto nivel...\n")
  installed <- rownames(installed.packages())
  for (pkg in packages) {
    if (!pkg %in% installed) install.packages(pkg, repos = "https://cloud.r-project.org")
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }
}

setup_environment(required_packages)
set.seed(123)

data_dir <- "Data/rna_cancer"
results_dir <- "Resultados_Analisis/Graficas"
if (!dir.exists("Resultados_Analisis")) dir.create("Resultados_Analisis")
if (!dir.exists(results_dir)) dir.create(results_dir)

# --- SECCIÓN 2: INGENIERÍA DE DATOS Y QC ---

cat(">> Cargando y procesando datos genómicos...\n")
expr_df   <- read_csv(file.path(data_dir, "data_500.csv"), col_types = cols())
labels_df <- read_csv(file.path(data_dir, "labels.csv"), col_types = cols())

full_dataset <- bind_cols(Class = as.factor(labels_df$Class), expr_df[, -1])

# Filtrado NZV y Normalización Z-score
nzv <- nearZeroVar(full_dataset[, -1])
full_dataset <- full_dataset[, c(TRUE, -nzv)]
pre_params <- preProcess(full_dataset[, -1], method = c("center", "scale"))
full_dataset_proc <- predict(pre_params, full_dataset)

# --- SECCIÓN 3: VISUALIZACIÓN MULTI-ALGORITMO ---

cat(">> Generando proyecciones topológicas (PCA, UMAP)...\n")
# PCA (Varianza Global)
pca_res <- prcomp(full_dataset_proc[, -1])
ggsave(file.path(results_dir, "02_PCA_Estructura.png"), 
       ggplot(as.data.frame(pca_res$x), aes(PC1, PC2, color = full_dataset_proc$Class)) + 
         geom_point(alpha=0.7, size=3) + theme_minimal() + labs(title="Análisis PCA"), width=9, height=7)

# UMAP (Vecindad Local y Estructura Global)
umap_res <- umap(as.matrix(full_dataset_proc[, -1]))
ggsave(file.path(results_dir, "11_UMAP_Expert_Projection.png"), 
       ggplot(as.data.frame(umap_res$layout), aes(V1, V2, color = full_dataset_proc$Class)) + 
         geom_point(alpha=0.8, size=3) + theme_minimal() + labs(title="Proyección UMAP"), width=9, height=7)

# --- SECCIÓN 4: MODELADO Y OPTIMIZACIÓN (RANDOM FOREST) ---

cat(">> Iniciando entrenamiento con 10-fold Cross-Validation...\n")
train_idx <- createDataPartition(full_dataset_proc$Class, p = 0.75, list = FALSE)
train_data <- full_dataset_proc[train_idx, ]
test_data  <- full_dataset_proc[-train_idx, ]

train_control <- trainControl(method = "cv", number = 10, classProbs = TRUE, summaryFunction = multiClassSummary)
model_rf <- train(Class ~ ., data = train_data, method = "rf", trControl = train_control, tuneLength = 3)

# --- SECCIÓN 5: EVIDENCIAS Y MÉTRICAS DE NIVEL EXPERTO ---

cat(">> Calculando métricas avanzadas (Kappa, MCC, F1)...\n")
pred_final <- predict(model_rf, test_data)
final_cm <- confusionMatrix(pred_final, test_data$Class)

# Matthews Correlation Coefficient (MCC) - La métrica más fiable para clasificación
mcc_val <- MCC(y_pred = pred_final, y_true = test_data$Class)

# Exportación de Heatmap Jerárquico
importance <- varImp(model_rf)
top50 <- rownames(importance$importance)[order(importance$importance[,1], decreasing = TRUE)][1:50]
heatmap_avg <- full_dataset_proc %>% select(Class, all_of(top50)) %>% group_by(Class) %>% summarise(across(everything(), mean)) %>% as.data.frame()
rownames(heatmap_avg) <- heatmap_avg$Class

png(file.path(results_dir, "07_Heatmap_Clusterizado.png"), width = 1000, height = 800)
pheatmap(heatmap_avg[,-1], main = "Firmas Genéticas (Top 50 Biomarcadores)", color = colorRampPalette(c("navy", "white", "firebrick3"))(50))
dev.off()

# --- SECCIÓN 6: REPORTE FINAL ---

cat("\n==============================================================================\n")
cat("                ACTIVIDAD 2: INFORME DE RENDIMIENTO EXPERTO\n")
cat("==============================================================================\n")
cat(sprintf("ACCURACY (Precisión Global):   %.2f%%\n", final_cm$overall["Accuracy"] * 100))
cat(sprintf("COHEN'S KAPPA (Consistencia): %.4f\n", final_cm$overall["Kappa"]))
cat(sprintf("MATTHEWS CORR. COEF. (MCC):   %.4f\n", mcc_val))
cat(sprintf("BIOMARCADOR PRINCIPAL:         %s\n", top50[1]))
cat("==============================================================================\n")
cat(">> REVISE EL INFORME_RESULTADOS_ESTUDIO.md PARA LA INTERPRETACIÓN CLÍNICA.\n")
cat("==============================================================================\n")
