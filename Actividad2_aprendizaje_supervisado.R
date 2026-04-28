# Actividad 2: Aplicación de técnicas de aprendizaje supervisado sobre datos biológicos
# Objetivo: construir un clasificador de tipos de cáncer a partir de datos de expresión génica.

# --- 1. Preparación del entorno de trabajo ---
required_packages <- c("readr", "dplyr", "caret", "randomForest")
installed_packages <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# Fijar semilla para reproducibilidad
set.seed(123)

# --- 2. Carga y preparación de los datos ---
# Datos de expresión génica y etiquetas de clase
expr_path <- "Data/rna_cancer/data_500.csv"
label_path <- "Data/rna_cancer/labels.csv"

expr <- read_csv(expr_path, col_types = cols())
labels <- read_csv(label_path, col_names = c("SampleID", "Class"), col_types = cols())

# El primer campo de expr es un identificador de fila vacío en el CSV.
names(expr)[1] <- "SampleID"
expr <- expr %>% select(-SampleID)

# Verificar que existen el mismo número de muestras
stopifnot(nrow(expr) == nrow(labels))

# Convertir la variable objetivo a factor para clasificación
labels$Class <- as.factor(labels$Class)

# Eliminar características con varianza casi cero para limpiar el modelo
nzv <- nearZeroVar(expr)
if (length(nzv) > 0) {
  expr <- expr %>% select(-all_of(nzv))
}

# Construir el dataset final
dataset <- bind_cols(labels, expr)

# Mostrar resumen básico
cat("Número de muestras:", nrow(dataset), "\n")
cat("Número de variables después de NZV:", ncol(dataset) - 2, "(genes)\n")
cat("Clases presentes:\n")
print(table(dataset$Class))

# --- 3. División del conjunto de datos ---
train_index <- createDataPartition(dataset$Class, p = 0.70, list = FALSE)
train_data <- dataset[train_index, ]
test_data <- dataset[-train_index, ]

cat("Muestras de entrenamiento:", nrow(train_data), "\n")
cat("Muestras de prueba:", nrow(test_data), "\n")

# --- 4. Selección y entrenamiento del modelo ---
# Se utiliza random forest como método supervisado para clasificación multiclase.
train_control <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3
)

model_rf <- train(
  Class ~ ., 
  data = train_data,
  method = "rf",
  trControl = train_control,
  tuneLength = 3,
  importance = TRUE
)

cat("Modelo entrenado:\n")
print(model_rf)

# --- 5. Evaluación del modelo ---
predictions <- predict(model_rf, newdata = test_data)
cm <- confusionMatrix(predictions, test_data$Class)

cat("\nMatriz de confusión:\n")
print(cm$table)
cat("\nResultados de evaluación:\n")
print(cm$overall)

cat(sprintf("\nPrecisión general del modelo: %.4f\n", cm$overall["Accuracy"]))

# Importancia de variables
cat("\nImportancia de las variables (top 10):\n")
importance_df <- as.data.frame(varImp(model_rf)$importance)
importance_df$Gene <- rownames(importance_df)
importance_df <- importance_df %>% arrange(desc(Overall)) %>% select(Gene, Overall)
print(head(importance_df, 10))

# --- 6. Notas finales ---
# Si se desea usar el archivo completo Data/rna_cancer/data.csv, se puede reemplazar expr_path.
# El script está organizado para mantener la preparación, el entrenamiento y la evaluación separados.
