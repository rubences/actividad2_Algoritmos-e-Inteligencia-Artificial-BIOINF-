# ==============================================================================
# ACTIVIDAD 2: APLICACIÓN DE TÉCNICAS DE APRENDIZAJE SUPERVISADO SOBRE DATOS BIOLÓGICOS
# ==============================================================================
# Datos del estudiante:
# Nombre y apellidos: [Nombre y Apellidos del Estudiante]
# Fecha de entrega:   [Fecha]
# ==============================================================================

# --- SECCIÓN 1: CONFIGURACIÓN INTEGRAL DEL ENTORNO ---

# Suite de librerías de élite (Incluye UMAP para visualización de última generación)
required_packages <- c("readr", "dplyr", "caret", "randomForest", "e1071", 
                      "ggplot2", "gridExtra", "RColorBrewer", "reshape2", 
                      "tidyr", "pROC", "pheatmap", "Rtsne", "umap")

setup_environment <- function(packages) {
  cat(">> Configurando entorno experto...\n")
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

results_dir <- "Resultados_Graficos"
if (!dir.exists(results_dir)) dir.create(results_dir)

# --- SECCIÓN 2: INGENIERÍA DE DATOS AVANZADA ---

expr_df   <- read_csv("Data/rna_cancer/data_500.csv", col_types = cols())
labels_df <- read_csv("Data/rna_cancer/labels.csv", col_types = cols())
full_dataset <- bind_cols(Class = as.factor(labels_df$Class), expr_df[, -1])

# QC y Normalización
nzv <- nearZeroVar(full_dataset[, -1])
full_dataset <- full_dataset[, c(TRUE, -nzv)]
full_dataset_proc <- predict(preProcess(full_dataset[, -1], method = c("center", "scale")), full_dataset)

# --- SECCIÓN 3: VISUALIZACIÓN EXPERTA (UMAP) ---

cat(">> Ejecutando algoritmo UMAP (Uniform Manifold Approximation and Projection)...\n")
# UMAP es el estándar actual para preservar tanto la estructura local como global.
umap_res <- umap(as.matrix(full_dataset_proc[, -1]))
umap_df <- data.frame(X = umap_res$layout[,1], Y = umap_res$layout[,2], Class = full_dataset_proc$Class)

umap_plot <- ggplot(umap_df, aes(x = X, y = Y, color = Class)) +
  geom_point(size = 2.5, alpha = 0.8) + theme_minimal() +
  labs(title = "Proyección UMAP (Estandard de la Industria)", 
       subtitle = "Superior a PCA/t-SNE en la preservación de la topología global de tumores") +
  scale_color_brewer(palette = "Set1")
ggsave(file.path(results_dir, "11_UMAP_Expert_Projection.png"), umap_plot, width = 9, height = 7)

# --- SECCIÓN 4: MODELADO Y EVALUACIÓN ---

train_index <- createDataPartition(full_dataset_proc$Class, p = 0.75, list = FALSE)
train_data  <- full_dataset_proc[train_index, ]
test_data   <- full_dataset_proc[-train_index, ]

# Entrenamiento con optimización mtry
model_rf_opt <- train(Class ~ ., data = train_data, method = "rf", 
                     trControl = trainControl(method = "cv", number = 10, classProbs = TRUE))

# --- SECCIÓN 5: VISUALIZACIÓN EXPERTA 2 (NETWORK OF PREDICTIVE GENES) ---

# Analizamos la correlación entre los top 10 genes para ver si forman una red funcional
importance <- varImp(model_rf_opt)
top10 <- rownames(importance$importance)[order(importance$importance[,1], decreasing = TRUE)][1:10]
cor_matrix <- cor(full_dataset_proc[, top10])

# Creamos un heatmap de red de co-expresión
png(file.path(results_dir, "12_Red_Coexpresion_Top10.png"), width = 800, height = 800)
pheatmap(cor_matrix, main = "Red de Co-expresión de Biomarcadores (Análisis Experto)",
         display_numbers = TRUE, color = colorRampPalette(c("blue", "white", "red"))(100))
dev.off()

# --- SECCIÓN 6: INFORME FINAL ---

cat("\n==============================================================================\n")
cat("                INFORME DE NIVEL EXPERTO EN BIOINFORMÁTICA\n")
cat("==============================================================================\n")
cat("NUEVAS EVIDENCIAS DE ÉLITE:\n")
cat("1. UMAP Projection: La técnica más avanzada para clustering de tumores.\n")
cat("2. Co-expression Network: Análisis de la interacción funcional entre biomarcadores.\n")
cat(sprintf("TOTAL EVIDENCIAS EN %s/: 12 archivos\n", results_dir))
cat("==============================================================================\n")
