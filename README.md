# Pan-Cancer Transcriptomic Classification using Ensemble Learning and Dimensionality Reduction

**Author:** Rubén Juárez Cádiz  
**Institution:** Universidad UNED  
**Date:** April 2026  

---

## Abstract
This study presents a high-performance computational framework for the classification of five major solid tumor types (BRCA, LUAD, PRAD, KIRC, COAD) based on RNA-seq gene expression profiles. By integrating advanced preprocessing, non-linear dimensionality reduction (UMAP/t-SNE), and optimized Ensemble Learning (Random Forest), we achieved a classification accuracy of >98% and a Matthews Correlation Coefficient (MCC) of 0.97. The pipeline identifies robust molecular biomarkers and demonstrates the feasibility of automated precision diagnostics in oncology.

---

## 1. Introduction
The identification of tumor origin and molecular subtype is critical for effective precision medicine. Traditional pathology often struggles with high-dimensional molecular data. This study leverages supervised learning to decode transcriptomic signatures, providing a rigorous statistical approach to cancer classification and biomarker discovery.

---

## 2. Materials and Methods

### 2.1 Dataset and Quality Control (QC)
The primary dataset consists of 802 samples with expression levels for 500 pre-selected genes.
1.  **Normalization**: Z-score standardization (center and scale) was applied to ensure feature comparability.
2.  **Variance Filtering**: Near Zero Variance (NZV) analysis was performed to eliminate non-informative features and reduce computational noise.

### 2.2 Model Selection and Optimization
We compared **Random Forest (RF)** and **Support Vector Machines (SVM)**. Model tuning was performed via **Grid Search** for the `mtry` parameter in RF, and validation was secured through a **10-fold Cross-Validation (CV)** scheme to minimize selection bias and overfitting.

---

## 3. Results and Discussion

### 3.1 Exploratory Data Analysis and Feature Distribution
Initial class distribution analysis confirmed a balanced dataset, essential for preventing model bias towards specific tumor types.

![Figure 1: Class Distribution](Results/Plots/01_Distribucion_Clases.png)
*Figure 1: Distribution of samples across the five cancer classes. The balance ensures robust training for all categories.*

### 3.2 Dimensionality Reduction and Cluster Integrity
To evaluate the biological signal strength, we performed Linear (PCA) and Non-linear (t-SNE, UMAP) projections.

![Figure 2: PCA Analysis](Results/Plots/02_PCA_Estructura.png)
*Figure 2: Principal Component Analysis (PCA). PCA captures 30-40% of the variance, showing clear but slightly overlapping separations in linear space.*

![Figure 3: t-SNE Clusters](Results/Plots/09_tSNE_Clusters.png)
*Figure 3: t-SNE Projection. t-SNE reveals well-defined non-linear manifolds, indicating strong transcriptomic identities.*

![Figure 4: UMAP Expert Projection](Results/Plots/11_UMAP_Expert_Projection.png)
*Figure 4: UMAP Embedding. UMAP provides superior preservation of global topology, showcasing extremely compact and isolated tumor clusters.*

### 3.3 Model Performance and Comparative Evaluation
Random Forest demonstrated statistical superiority over SVM in terms of stability and Cohen's Kappa index.

![Figure 5: Model Comparison](Results/Plots/03_Comparativa_Modelos.png)
*Figure 5: Accuracy distribution across 10-fold CV. RF consistently outperformed SVM in high-dimensional genomic space.*

### 3.4 Diagnostic Reliability and Validation
Model performance was validated using Confusion Matrices and ROC curves.

![Figure 6: Confusion Matrix](Results/Plots/04_Matriz_Confusion_RF.png)
*Figure 6: Heatmap of the RF Confusion Matrix. The diagonal dominance confirms a near-zero misclassification rate across all classes.*

![Figure 7: ROC Curves](Results/Plots/08_Curvas_ROC.png)
*Figure 7: Multi-class ROC Curves. The Area Under the Curve (AUC) for all classes is >0.99, demonstrating exceptional sensitivity and specificity.*

---

## 4. Molecular Biomarker Discovery

### 4.1 Feature Importance (Mean Decrease Gini)
The model identified specific genes that serve as the primary drivers of tumor classification.

![Figure 8: Biomarker Ranking](Results/Plots/05_Importancia_Biomarcadores.png)
*Figure 8: Top 20 Genes by Importance. These genes represent critical oncogenic hubs or metabolic regulators.*

### 4.2 Single-Gene Validation and Distribution
We analyzed the expression profile of the top-ranked biomarkers to validate their discriminatory power.

![Figure 9: Single Gene Profile](Results/Plots/06_Perfil_Biomarcador.png)
*Figure 9: Boxplot of the Top 1 Biomarker. The significant expression variance between classes confirms its utility as a diagnostic marker.*

![Figure 10: Violin Plot Grid](Results/Plots/10_TopGenes_Violin.png)
*Figure 10: Expression density for the Top 4 Genes. Violin plots reveal the underlying probability density of gene expression across tumor types.*

### 4.3 Genomic Signatures and Co-expression Networks
Hierarchical clustering and correlation analysis revealed co-regulated gene modules.

![Figure 11: Hierarchical Heatmap](Results/Plots/07_Heatmap_Clusterizado.png)
*Figure 11: Clustered Heatmap of the Top 50 Genes. The clear color blocks represent unique "genomic fingerprints" for each cancer.*

![Figure 12: Co-expression Network](Results/Plots/12_Red_Coexpresion_Top10.png)
*Figure 12: Correlation matrix of the Top 10 genes. This network suggests functional interactions between the most predictive biomarkers.*

---

## 5. Conclusion
This study successfully developed an AI-driven pipeline for precision cancer classification. The integration of UMAP for topological visualization and Random Forest for robust classification yields a high-fidelity diagnostic tool. The identified biomarkers provide a foundation for future clinical validation and therapeutic targeting.

---

## 6. Repository Structure
- **`Scripts/`**: Source R code (optimized for 10-fold CV and UMAP).
- **`Results/Plots/`**: 12 High-resolution scientific figures.
- **`Results/Metrics.csv`**: Detailed statistical performance metrics.
- **`Data/`**: Raw RNA-seq expression matrices.