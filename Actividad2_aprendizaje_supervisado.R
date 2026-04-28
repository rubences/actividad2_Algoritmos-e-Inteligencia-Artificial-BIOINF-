# ==============================================================================
# ACTIVIDAD 2: APLICACIÓN DE TÉCNICAS DE APRENDIZAJE SUPERVISADO SOBRE DATOS BIOLÓGICOS
# ==============================================================================
# Datos del estudiante:
# Nombre y apellidos: [Nombre y Apellidos del Estudiante]
# Fecha de entrega:   [Fecha]
# ==============================================================================

# --- 1. PREPARACIÓN DEL ENTORNO DE TRABAJO ---

# Definición de paquetes necesarios
required_packages <- c("readr", "dplyr", "caret", "randomForest", "e1071", "ggplot2", "gridExtra")

# Función para instalar y cargar paquetes de forma automática
setup_environment <- function(packages) {
  installed_packages <- rownames(installed.packages())
  for (pkg in packages) {
    if (!pkg %in% installed_packages) {
      message(paste("Instalando paquete:", pkg))
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }
    library(pkg, character.only = TRUE)
  }
}

setup_environment(required_packages)

# Fijar semilla para asegurar que los resultados sean reproducibles
set.seed(123)

# --- 2. CARGA Y PREPARACIÓN DE LOS DATOS ---

# Definición de rutas (Basado en la estructura del proyecto)
# Nota: Si se dispone de 'data.csv' y 'variables.csv' en la raíz, cambiar estas rutas.
expr_path  <- "Data/rna_cancer/data_500.csv"
label_path <- "Data/rna_cancer/labels.csv"

# Verificación de existencia de archivos antes de cargar
if (!file.exists(expr_path) || !file.exists(label_path)) {
  stop("Error: No se han encontrado los archivos de datos en las rutas especificadas.")
}

# Carga de datos de expresión génica
# data_500.csv contiene una selección de 500 genes para mayor eficiencia
expr <- read_csv(expr_path, col_types = cols())

# Carga de etiquetas (variables de clase)
# Se asume que el archivo labels.csv contiene el identificador y la clase
labels <- read_csv(label_path, col_names = c("SampleID", "Class"), col_types = cols(), skip = 1)

# Limpieza inicial:
# El primer campo de 'expr' suele ser un índice vacío en el CSV. Lo renombramos para unir datasets.
names(expr)[1] <- "SampleID"

# Unión de datos y etiquetas por el identificador de muestra
full_data <- inner_join(labels, expr, by = "SampleID")

# Eliminamos la columna ID ya que no aporta información al modelo predictivo
full_data <- full_data %>% select(-SampleID)

# Convertir la variable objetivo a Factor (necesario para clasificación)
full_data$Class <- as.factor(full_data$Class)

# Limpieza avanzada: Eliminación de variables con varianza cercana a cero (NZV)
# Variables que no cambian apenas entre muestras no ayudan a discriminar y añaden ruido.
nzv <- nearZeroVar(full_data[, -1]) # Excluimos la columna 'Class'
if (length(nzv) > 0) {
  full_data <- full_data[, -(nzv + 1)] # +1 para compensar la columna Class
  message(paste("Se han eliminado", length(nzv), "variables por varianza casi nula."))
}

# --- 3. ANÁLISIS EXPLORATORIO CREATIVO (PCA) ---
# Demostramos visualmente cómo se agrupan los datos antes del entrenamiento.

pca_res <- prcomp(full_data[, -1], scale. = TRUE)
pca_df <- as.data.frame(pca_res$x[, 1:2])
pca_df$Class <- full_data$Class

pca_plot <- ggplot(pca_df, aes(x = PC1, y = PC2, color = Class)) +
  geom_point(alpha = 0.7, size = 2) +
  theme_minimal() +
  labs(title = "Visualización de Datos mediante PCA",
       subtitle = "Exploración de la separabilidad de tipos de cáncer",
       x = paste0("PC1 (", round(summary(pca_res)$importance[2, 1] * 100, 1), "%)"),
       y = paste0("PC2 (", round(summary(pca_res)$importance[2, 2] * 100, 1), "%)")) +
  scale_color_brewer(palette = "Set1")

print(pca_plot)

# --- 4. DIVISIÓN DEL CONJUNTO DE DATOS ---

# Dividimos el dataset en 70% Entrenamiento y 30% Prueba de forma estratificada
train_index <- createDataPartition(full_data$Class, p = 0.70, list = FALSE)
train_data  <- full_data[train_index, ]
test_data   <- full_data[-train_index, ]

cat("\nResumen de la división:\n")
cat("- Muestras para entrenamiento:", nrow(train_data), "\n")
cat("- Muestras para prueba (test):", nrow(test_data), "\n")

# --- 5. SELECCIÓN Y ENTRENAMIENTO DEL MODELO ---

# Configuración de Validación Cruzada (Cross-Validation)
# Usamos 5-fold CV repetido 3 veces para asegurar la robustez del modelo.
train_control <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3,
  verboseIter = FALSE
)

# MODELO A: Random Forest (Bosques Aleatorios)
message("\nEntrenando Modelo A: Random Forest...")
model_rf <- train(
  Class ~ ., 
  data = train_data,
  method = "rf",
  trControl = train_control,
  tuneLength = 3,
  importance = TRUE
)

# MODELO B: Support Vector Machine (SVM) - Aporta el valor de creatividad/comparativa
message("Entrenando Modelo B: SVM (Linear Kernel)...")
model_svm <- train(
  Class ~ ., 
  data = train_data,
  method = "svmLinear",
  trControl = train_control,
  tuneLength = 3
)

# --- 6. CÁLCULO DE PRECISIÓN Y EVALUACIÓN ---

# Predicciones sobre el conjunto de test
pred_rf  <- predict(model_rf, test_data)
pred_svm <- predict(model_svm, test_data)

# Matrices de confusión
cm_rf  <- confusionMatrix(pred_rf, test_data$Class)
cm_svm <- confusionMatrix(pred_svm, test_data$Class)

# Comparativa de Accuracy
results <- data.frame(
  Modelo = c("Random Forest", "SVM (Linear)"),
  Accuracy = c(cm_rf$overall["Accuracy"], cm_svm$overall["Accuracy"]),
  Kappa = c(cm_rf$overall["Kappa"], cm_svm$overall["Kappa"])
)

cat("\n--- COMPARATIVA DE MODELOS ---\n")
print(results)

# --- 7. VISUALIZACIÓN DE RESULTADOS ---

# A. Heatmap de la Matriz de Confusión (Modelo Random Forest)
cm_table <- as.data.frame(cm_rf$table)
cm_plot <- ggplot(cm_table, aes(Prediction, Reference, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), color = "white") +
  scale_fill_gradient(low = "gray90", high = "#2c7fb8") +
  theme_minimal() +
  labs(title = "Matriz de Confusión (Random Forest)",
       subtitle = paste("Precisión Global:", round(cm_rf$overall["Accuracy"], 4)))

# B. Importancia de los Genes (Variables)
importance <- varImp(model_rf)
imp_df <- data.frame(Gene = rownames(importance$importance),
                    Importance = importance$importance[, 1]) %>%
  arrange(desc(Importance)) %>%
  head(15)

imp_plot <- ggplot(imp_df, aes(x = reorder(Gene, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Importancia de Variables (Top 15 Genes)",
       x = "Gen", y = "Importancia Relativa")

# Mostrar gráficos finales
grid.arrange(cm_plot, imp_plot, ncol = 1)

# Finalización del script
cat("\nActividad completada con éxito. El modelo Random Forest ha sido seleccionado para la visualización final por su capacidad de medir la importancia de las variables.\n")
