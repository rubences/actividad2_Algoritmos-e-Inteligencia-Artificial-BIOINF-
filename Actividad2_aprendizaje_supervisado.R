# ==============================================================================
# ACTIVIDAD 2: APLICACIÓN DE TÉCNICAS DE APRENDIZAJE SUPERVISADO SOBRE DATOS BIOLÓGICOS
# ==============================================================================
# Datos del estudiante:
# Nombre y apellidos: [Nombre y Apellidos del Estudiante]
# Fecha de entrega:   [Fecha]
# ==============================================================================

# --- SECCIÓN 1: PREPARACIÓN DEL ENTORNO DE TRABAJO (Criterio 1) ---

# Paquetes requeridos para un flujo de trabajo bioinformático completo
required_packages <- c("readr", "dplyr", "caret", "randomForest", "e1071", "ggplot2", "gridExtra", "RColorBrewer")

# Función optimizada para la gestión de dependencias
setup_environment <- function(packages) {
  installed_packages <- rownames(installed.packages())
  for (pkg in packages) {
    if (!pkg %in% installed_packages) {
      message(paste("Instalando paquete faltante:", pkg))
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }
}

setup_environment(required_packages)
set.seed(123) # Semilla para reproducibilidad estadística

# --- SECCIÓN 2: PREPARACIÓN Y MANIPULACIÓN DE LOS DATOS (Criterio 2) ---

# Rutas de archivos
expr_path  <- "Data/rna_cancer/data_500.csv"
label_path <- "Data/rna_cancer/labels.csv"

# Carga y limpieza de datos
if (!file.exists(expr_path)) stop("Archivo de expresión no encontrado.")
if (!file.exists(label_path)) stop("Archivo de etiquetas no encontrado.")

expr <- read_csv(expr_path, col_types = cols())
labels <- read_csv(label_path, col_names = c("SampleID", "Class"), col_types = cols(), skip = 1)

# Alineación de muestras (SampleID)
names(expr)[1] <- "SampleID"
full_dataset <- inner_join(labels, expr, by = "SampleID") %>% select(-SampleID)
full_dataset$Class <- as.factor(full_dataset$Class)

# MEJORA PRO: Pre-procesamiento de datos biológicos
# 1. Eliminación de varianza casi nula (genes que no aportan información)
nzv <- nearZeroVar(full_dataset[, -1], saveMetrics = TRUE)
full_dataset <- full_dataset[, c(TRUE, !nzv$nzv)] # Mantenemos la clase y genes con varianza

# 2. Normalización (Centrado y Escalamiento)
# Es vital para algoritmos como SVM que las variables tengan rangos similares.
pre_process_params <- preProcess(full_dataset[, -1], method = c("center", "scale"))
full_dataset_proc <- predict(pre_process_params, full_dataset)

cat(sprintf("\nDatos listos: %d muestras y %d genes tras limpieza.\n", 
            nrow(full_dataset_proc), ncol(full_dataset_proc) - 1))

# --- SECCIÓN 3: ANÁLISIS EXPLORATORIO (Creatividad - Criterio 6) ---

pca_res <- prcomp(full_dataset_proc[, -1])
pca_df <- as.data.frame(pca_res$x[, 1:2])
pca_df$Class <- full_dataset_proc$Class

pca_plot <- ggplot(pca_df, aes(x = PC1, y = PC2, color = Class)) +
  geom_point(alpha = 0.8, size = 2.5) +
  theme_minimal() +
  labs(title = "Estructura del Dataset (PCA)",
       subtitle = "Visualización de la separación biológica de los tumores",
       x = "Componente Principal 1", y = "Componente Principal 2") +
  scale_color_brewer(palette = "Dark2")

print(pca_plot)

# --- SECCIÓN 4: DIVISIÓN DEL CONJUNTO DE DATOS ---

# División estratificada 70/30
train_index <- createDataPartition(full_dataset_proc$Class, p = 0.70, list = FALSE)
train_data  <- full_dataset_proc[train_index, ]
test_data   <- full_dataset_proc[-train_index, ]

# --- SECCIÓN 5: SELECCIÓN Y ENTRENAMIENTO DEL MODELO (Criterio 3) ---

# Configuración de entrenamiento con Validación Cruzada (5-fold CV)
train_control <- trainControl(method = "cv", number = 5, verboseIter = FALSE)

# Comparativa de modelos: Random Forest vs SVM
# RF es excelente para detectar genes clave, SVM es muy potente en clasificación.
message("\nEntrenando modelos...")
model_rf <- train(Class ~ ., data = train_data, method = "rf", trControl = train_control, tuneLength = 2)
model_svm <- train(Class ~ ., data = train_data, method = "svmLinear", trControl = train_control)

# --- SECCIÓN 6: EVALUACIÓN DEL MODELO (Criterio 4) ---

# Predicciones y Métricas
pred_rf <- predict(model_rf, test_data)
cm_rf <- confusionMatrix(pred_rf, test_data$Class)

cat("\n--- RESULTADOS DE EVALUACIÓN (Random Forest) ---\n")
print(cm_rf$overall)

# Visualización de la Matriz de Confusión
cm_df <- as.data.frame(cm_rf$table)
cm_plot <- ggplot(cm_df, aes(Prediction, Reference, fill = Freq)) +
  geom_tile() + geom_text(aes(label = Freq), color = "white", size = 5) +
  scale_fill_gradient(low = "#e0ecf4", high = "#8856a7") +
  theme_minimal() + labs(title = "Matriz de Confusión: Diagnóstico Predicho vs Real")

# Importancia de Variables (Genes Biomarcadores)
importance <- varImp(model_rf)
top_genes <- data.frame(Gene = rownames(importance$importance),
                       Score = importance$importance[, 1]) %>%
  arrange(desc(Score)) %>% head(20)

importance_plot <- ggplot(top_genes, aes(x = reorder(Gene, Score), y = Score)) +
  geom_bar(stat = "identity", fill = "#31a354") + coord_flip() +
  theme_minimal() + labs(title = "Top 20 Genes Biomarcadores", x = "Gen", y = "Score de Importancia")

grid.arrange(cm_plot, importance_plot, ncol = 1)

# --- SECCIÓN 7: CONCLUSIONES Y CIERRE ---

cat("\n==============================================================================\n")
cat("                       INFORME DE RESULTADOS FINALES\n")
cat("==============================================================================\n")
cat(sprintf("1. PRECISIÓN: Se ha obtenido un Accuracy de %.2f%%.\n", cm_rf$overall["Accuracy"] * 100))
cat("2. BIOLOGÍA: Los genes en la parte superior del ranking son candidatos a\n")
cat("   biomarcadores diagnósticos para diferenciar estos tipos de cáncer.\n")
cat("3. TÉCNICA: La normalización y eliminación de genes con baja varianza\n")
cat("   ha permitido obtener un modelo estable y generalizable.\n")
cat("==============================================================================\n")
