# Cycling Data Analysis for TU Dortmund Master Data Science Application
# Using Base R only

# Load the dataset
data <- read.table("cycling.txt", header = TRUE, sep = " ", quote = "\"", stringsAsFactors = TRUE)

# Basic data exploration
cat("=== DATASET OVERVIEW ===\n")
cat("Dimensions:", dim(data), "\n")
cat("\nStructure:\n")
str(data)

cat("\n=== SUMMARY STATISTICS ===\n")
print(summary(data))

# Check for missing values
cat("\n=== MISSING VALUES ===\n")
cat("Total missing values:", sum(is.na(data)), "\n")

# Unique values
cat("\n=== UNIQUE VALUES ===\n")
cat("Number of unique riders:", length(unique(data$all_riders)), "\n")
cat("Rider classes:", levels(data$rider_class), "\n")
cat("Stage classes:", levels(data$stage_class), "\n")
cat("Number of stages:", length(unique(data$stage)), "\n")
cat("Total observations:", nrow(data), "\n")

# Descriptive statistics by rider class
cat("\n\n=== DESCRIPTIVE STATISTICS BY RIDER CLASS ===\n")
rider_classes <- levels(data$rider_class)
for(rc in rider_classes) {
  subset_data <- data$points[data$rider_class == rc]
  cat("\n", rc, ":\n")
  cat("  N =", length(subset_data), "\n")
  cat("  Mean =", round(mean(subset_data), 2), "\n")
  cat("  SD =", round(sd(subset_data), 2), "\n")
  cat("  Median =", round(median(subset_data), 2), "\n")
  cat("  Min =", min(subset_data), "\n")
  cat("  Max =", max(subset_data), "\n")
  cat("  Q1 =", round(quantile(subset_data, 0.25), 2), "\n")
  cat("  Q3 =", round(quantile(subset_data, 0.75), 2), "\n")
}

# Descriptive statistics by stage class
cat("\n\n=== DESCRIPTIVE STATISTICS BY STAGE CLASS ===\n")
stage_classes <- levels(data$stage_class)
for(sc in stage_classes) {
  subset_data <- data$points[data$stage_class == sc]
  cat("\n", sc, ":\n")
  cat("  N =", length(subset_data), "\n")
  cat("  Mean =", round(mean(subset_data), 2), "\n")
  cat("  SD =", round(sd(subset_data), 2), "\n")
  cat("  Median =", round(median(subset_data), 2), "\n")
  cat("  Min =", min(subset_data), "\n")
  cat("  Max =", max(subset_data), "\n")
}

# Combined statistics
cat("\n\n=== DESCRIPTIVE STATISTICS BY RIDER CLASS AND STAGE CLASS ===\n")
for(rc in rider_classes) {
  cat("\n", rc, ":\n")
  for(sc in stage_classes) {
    subset_data <- data$points[data$rider_class == rc & data$stage_class == sc]
    if(length(subset_data) > 0) {
      cat("  ", sc, "- N:", length(subset_data),
          "Mean:", round(mean(subset_data), 2),
          "SD:", round(sd(subset_data), 2),
          "Median:", round(median(subset_data), 2), "\n")
    }
  }
}

# ============= VISUALIZATIONS =============

# Plot 1: Boxplot by Rider Class
png("plot1_boxplot_rider_class.png", width = 800, height = 600)
par(mar = c(5, 5, 4, 2))
boxplot(points ~ rider_class, data = data,
        main = "Distribution of Points by Rider Class",
        xlab = "Rider Class",
        ylab = "Points",
        col = c("lightblue", "lightgreen", "lightcoral", "lightyellow"),
        las = 1,
        cex.main = 1.5,
        cex.lab = 1.2)
dev.off()

# Plot 2: Boxplot by Stage Class
png("plot2_boxplot_stage_class.png", width = 800, height = 600)
par(mar = c(5, 5, 4, 2))
boxplot(points ~ stage_class, data = data,
        main = "Distribution of Points by Stage Class",
        xlab = "Stage Class (Terrain Type)",
        ylab = "Points",
        col = c("lightblue", "lightgreen", "lightcoral"),
        las = 1,
        cex.main = 1.5,
        cex.lab = 1.2)
dev.off()

# Plot 3: Interaction plot
png("plot3_interaction_plot.png", width = 900, height = 600)
par(mar = c(5, 5, 4, 8), xpd = TRUE)

# Calculate means for interaction plot
means_matrix <- tapply(data$points, list(data$stage_class, data$rider_class), mean)

# Plot
matplot(1:nrow(means_matrix), means_matrix,
        type = "b", pch = 19, lty = 1, lwd = 2,
        col = 1:ncol(means_matrix),
        xlab = "Stage Class", ylab = "Mean Points",
        main = "Mean Points by Rider Class and Stage Class",
        xaxt = "n",
        cex.main = 1.5,
        cex.lab = 1.2)
axis(1, at = 1:nrow(means_matrix), labels = rownames(means_matrix))
legend("topright", inset = c(-0.25, 0),
       legend = colnames(means_matrix),
       col = 1:ncol(means_matrix),
       lty = 1, lwd = 2, pch = 19,
       title = "Rider Class")
dev.off()

# Plot 4: Multiple boxplots
png("plot4_grouped_boxplot.png", width = 1000, height = 700)
par(mfrow = c(1, 3), mar = c(8, 4, 4, 2))

for(sc in stage_classes) {
  subset_data <- data[data$stage_class == sc, ]
  boxplot(points ~ rider_class, data = subset_data,
          main = paste("Points on", sc, "stages"),
          xlab = "",
          ylab = "Points",
          las = 2,
          col = c("lightblue", "lightgreen", "lightcoral", "lightyellow"))
}
dev.off()

# ============= HYPOTHESIS TESTS =============

cat("\n\n=== HYPOTHESIS TESTING ===\n")

# Test 1: Kruskal-Wallis test for rider classes
cat("\n--- TEST 1: Difference between Rider Classes (Overall) ---\n")
kw_rider <- kruskal.test(points ~ rider_class, data = data)
print(kw_rider)

# Post-hoc pairwise comparisons
if(kw_rider$p.value < 0.05) {
  cat("\nPost-hoc pairwise Wilcoxon tests (Bonferroni correction):\n")
  pairwise_rider <- pairwise.wilcox.test(data$points, data$rider_class,
                                          p.adjust.method = "bonferroni")
  print(pairwise_rider)
}

# Test 2: Kruskal-Wallis test for stage classes
cat("\n--- TEST 2: Difference between Stage Classes (Overall) ---\n")
kw_stage <- kruskal.test(points ~ stage_class, data = data)
print(kw_stage)

# Post-hoc pairwise comparisons
if(kw_stage$p.value < 0.05) {
  cat("\nPost-hoc pairwise Wilcoxon tests (Bonferroni correction):\n")
  pairwise_stage <- pairwise.wilcox.test(data$points, data$stage_class,
                                          p.adjust.method = "bonferroni")
  print(pairwise_stage)
}

# Test 3: Two-way analysis using aligned rank transform
cat("\n--- TEST 3: Two-Way Analysis (Rider Class × Stage Class) ---\n")
data$rank_points <- rank(data$points)
model_ranks <- lm(rank_points ~ rider_class * stage_class, data = data)
anova_result <- anova(model_ranks)
print(anova_result)

# Test 4: Rider class differences within each stage class
cat("\n--- TEST 4: Rider Class Differences within Each Stage Class ---\n")

for(sc in stage_classes) {
  cat("\n", sc, "stages:\n")
  subset_data <- data[data$stage_class == sc, ]
  kw_test <- kruskal.test(points ~ rider_class, data = subset_data)
  print(kw_test)

  if(kw_test$p.value < 0.05) {
    cat("Post-hoc pairwise Wilcoxon tests:\n")
    pw_test <- pairwise.wilcox.test(subset_data$points, subset_data$rider_class,
                                     p.adjust.method = "bonferroni")
    print(pw_test)
  }
}

# Test 5: Stage class differences within each rider class
cat("\n--- TEST 5: Stage Class Differences within Each Rider Class ---\n")

for(rc in rider_classes) {
  cat("\n", rc, ":\n")
  subset_data <- data[data$rider_class == rc, ]
  kw_test <- kruskal.test(points ~ stage_class, data = subset_data)
  print(kw_test)

  if(kw_test$p.value < 0.05) {
    cat("Post-hoc pairwise Wilcoxon tests:\n")
    pw_test <- pairwise.wilcox.test(subset_data$points, subset_data$stage_class,
                                     p.adjust.method = "bonferroni")
    print(pw_test)
  }
}

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("All visualizations saved as PNG files.\n")
