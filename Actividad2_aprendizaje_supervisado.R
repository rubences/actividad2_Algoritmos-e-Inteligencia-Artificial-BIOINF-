# ============================================================
# Datos del estudiante
# Nombre y apellidos: [Escribe aquí tu nombre y apellidos]
# Fecha de entrega: [dd/mm/aaaa]
# ============================================================
# Actividad 2. Aplicación de técnicas de aprendizaje supervisado
# sobre datos biológicos (clasificación de tipos de cáncer).
# ============================================================

# ------------------------------
# 1) Preparación del entorno
# ------------------------------
required_packages <- c("readr", "dplyr", "caret", "randomForest", "rpart")
installed_packages <- rownames(installed.packages())

for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# Semilla para reproducibilidad de partición y entrenamiento.
set.seed(123)

# ------------------------------
# 2) Carga y manipulación de datos
# ------------------------------
# NOTA: Si tu profesor te dio archivos con otro nombre (por ejemplo data.csv
# y variables.csv), actualiza estas rutas.
expr_path <- "Data/rna_cancer/data_500.csv"
labels_path <- "Data/rna_cancer/labels.csv"

expr <- read_csv(expr_path, col_types = cols())
labels <- read_csv(labels_path, col_types = cols())

# En data_500.csv la primera columna viene sin nombre ("").
# La renombramos para dejar claro que es el identificador de muestra.
colnames(expr)[1] <- "SampleID"

# Comprobaciones básicas de integridad.
stopifnot("SampleID" %in% colnames(expr))
stopifnot("Class" %in% colnames(labels))
stopifnot(nrow(expr) == nrow(labels))

# Unimos por identificador para garantizar alineación correcta entre expresión y clase.
dataset <- labels %>%
  inner_join(expr, by = "SampleID")

# Convertimos la variable objetivo a factor (clasificación supervisada).
dataset$Class <- as.factor(dataset$Class)

# Separamos variables predictoras (genes) y eliminamos columnas no predictoras.
x <- dataset %>% select(-SampleID, -Class)

# Eliminación de predictores con varianza casi cero.
# Esto mejora estabilidad y tiempo de entrenamiento.
nzv_idx <- nearZeroVar(x)
if (length(nzv_idx) > 0) {
  x <- x[, -nzv_idx, drop = FALSE]
}

# Reconstituimos dataset final para modelado.
dataset_model <- bind_cols(dataset %>% select(SampleID, Class), x)

cat("Resumen del conjunto de datos:\n")
cat("- Número de muestras:", nrow(dataset_model), "\n")
cat("- Número de genes utilizados:", ncol(dataset_model) - 2, "\n")
cat("- Distribución de clases:\n")
print(table(dataset_model$Class))

# ------------------------------
# 3) División del conjunto de datos
# ------------------------------
# Estratificada para mantener proporciones de clase.
train_idx <- createDataPartition(dataset_model$Class, p = 0.70, list = FALSE)
train_data <- dataset_model[train_idx, ]
test_data <- dataset_model[-train_idx, ]

cat("\nPartición realizada:\n")
cat("- Entrenamiento:", nrow(train_data), "muestras\n")
cat("- Prueba:", nrow(test_data), "muestras\n")

# ------------------------------
# 4) Selección y entrenamiento del modelo
# ------------------------------
# Se aplica validación cruzada repetida para comparar dos algoritmos.
# (Elemento creativo: comparar modelos y seleccionar el mejor por accuracy CV).
ctrl <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3
)

# Modelo 1: Random Forest
set.seed(123)
model_rf <- train(
  Class ~ .,
  data = train_data %>% select(-SampleID),
  method = "rf",
  trControl = ctrl,
  tuneLength = 3,
  importance = TRUE
)

# Modelo 2: Árbol de decisión (rpart)
set.seed(123)
model_rpart <- train(
  Class ~ .,
  data = train_data %>% select(-SampleID),
  method = "rpart",
  trControl = ctrl,
  tuneLength = 10
)

# Comparamos accuracy promedio en validación cruzada.
acc_rf <- max(model_rf$results$Accuracy)
acc_rpart <- max(model_rpart$results$Accuracy)

if (acc_rf >= acc_rpart) {
  final_model <- model_rf
  final_model_name <- "Random Forest"
} else {
  final_model <- model_rpart
  final_model_name <- "Árbol de decisión (rpart)"
}

cat("\nComparación de modelos (Accuracy CV):\n")
cat("- Random Forest:", round(acc_rf, 4), "\n")
cat("- rpart:", round(acc_rpart, 4), "\n")
cat("Modelo seleccionado:", final_model_name, "\n")

# ------------------------------
# 5) Evaluación del modelo final
# ------------------------------
preds <- predict(final_model, newdata = test_data %>% select(-SampleID))
cm <- confusionMatrix(preds, test_data$Class)

cat("\nMatriz de confusión:\n")
print(cm$table)
cat("\nMétricas globales:\n")
print(cm$overall)

cat(sprintf("\nPrecisión (Accuracy) en test: %.4f\n", cm$overall["Accuracy"]))
cat(sprintf("Kappa en test: %.4f\n", cm$overall["Kappa"]))

# Métricas por clase (sensibilidad, especificidad, etc.)
cat("\nMétricas por clase:\n")
print(cm$byClass)

# Importancia de variables si el modelo final la permite (RF sí la permite).
if (final_model_name == "Random Forest") {
  imp <- as.data.frame(varImp(final_model)$importance)
  imp$Gene <- rownames(imp)
  imp <- imp %>% arrange(desc(Overall)) %>% select(Gene, Overall)

  cat("\nTop 10 genes más importantes:\n")
  print(head(imp, 10))
}

# ------------------------------
# 6) Conclusión breve (en consola)
# ------------------------------
cat("\nConclusión:\n")
cat("Se entrenó un clasificador supervisado para predecir el tipo de cáncer ")
cat("a partir de perfiles de expresión génica.\n")
cat("La evaluación se realizó sobre un conjunto de prueba independiente.\n")
