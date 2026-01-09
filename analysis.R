# Cycling Data Analysis for TU Dortmund Master Data Science Application
# Author: Statistical Analysis Report
# Date: January 2026

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(knitr)

# Load the dataset
data <- read.table("cycling.txt", header = TRUE, sep = " ", quote = "\"")

# Basic data exploration
cat("=== DATASET OVERVIEW ===\n")
cat("Dimensions:", dim(data), "\n")
cat("\nStructure:\n")
str(data)

cat("\n=== SUMMARY STATISTICS ===\n")
summary(data)

# Check for missing values
cat("\n=== MISSING VALUES ===\n")
cat("Total missing values:", sum(is.na(data)), "\n")
colSums(is.na(data))

# Unique values
cat("\n=== UNIQUE VALUES ===\n")
cat("Number of unique riders:", length(unique(data$all_riders)), "\n")
cat("Rider classes:", unique(data$rider_class), "\n")
cat("Stage classes:", unique(data$stage_class), "\n")
cat("Number of stages:", length(unique(data$stage)), "\n")

# Convert to factors
data$rider_class <- factor(data$rider_class)
data$stage_class <- factor(data$stage_class)

# Descriptive statistics by rider class
cat("\n=== DESCRIPTIVE STATISTICS BY RIDER CLASS ===\n")
desc_stats <- data %>%
  group_by(rider_class) %>%
  summarise(
    n = n(),
    mean_points = mean(points),
    sd_points = sd(points),
    median_points = median(points),
    min_points = min(points),
    max_points = max(points),
    q25 = quantile(points, 0.25),
    q75 = quantile(points, 0.75)
  )
print(desc_stats)

# Descriptive statistics by stage class
cat("\n=== DESCRIPTIVE STATISTICS BY STAGE CLASS ===\n")
desc_stage <- data %>%
  group_by(stage_class) %>%
  summarise(
    n = n(),
    mean_points = mean(points),
    sd_points = sd(points),
    median_points = median(points),
    min_points = min(points),
    max_points = max(points)
  )
print(desc_stage)

# Descriptive statistics by rider class AND stage class
cat("\n=== DESCRIPTIVE STATISTICS BY RIDER CLASS AND STAGE CLASS ===\n")
desc_combined <- data %>%
  group_by(rider_class, stage_class) %>%
  summarise(
    n = n(),
    mean_points = mean(points),
    sd_points = sd(points),
    median_points = median(points),
    .groups = 'drop'
  )
print(desc_combined)

# Save descriptive statistics tables
write.csv(desc_stats, "desc_stats_rider.csv", row.names = FALSE)
write.csv(desc_stage, "desc_stats_stage.csv", row.names = FALSE)
write.csv(desc_combined, "desc_stats_combined.csv", row.names = FALSE)

# ============= VISUALIZATIONS =============

# 1. Boxplot: Points by Rider Class
png("plot1_boxplot_rider_class.png", width = 800, height = 600, res = 120)
ggplot(data, aes(x = rider_class, y = points, fill = rider_class)) +
  geom_boxplot() +
  labs(title = "Distribution of Points by Rider Class",
       x = "Rider Class",
       y = "Points") +
  theme_bw() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))
dev.off()

# 2. Boxplot: Points by Stage Class
png("plot2_boxplot_stage_class.png", width = 800, height = 600, res = 120)
ggplot(data, aes(x = stage_class, y = points, fill = stage_class)) +
  geom_boxplot() +
  labs(title = "Distribution of Points by Stage Class",
       x = "Stage Class (Terrain Type)",
       y = "Points") +
  theme_bw() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))
dev.off()

# 3. Interaction plot: Rider Class x Stage Class
png("plot3_interaction_plot.png", width = 900, height = 600, res = 120)
ggplot(data, aes(x = stage_class, y = points, color = rider_class, group = rider_class)) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun = mean, geom = "line", size = 1) +
  labs(title = "Mean Points by Rider Class and Stage Class",
       x = "Stage Class (Terrain Type)",
       y = "Mean Points",
       color = "Rider Class") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        legend.position = "right")
dev.off()

# 4. Grouped boxplot
png("plot4_grouped_boxplot.png", width = 1000, height = 600, res = 120)
ggplot(data, aes(x = rider_class, y = points, fill = stage_class)) +
  geom_boxplot() +
  labs(title = "Distribution of Points by Rider Class and Stage Class",
       x = "Rider Class",
       y = "Points",
       fill = "Stage Class") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        legend.position = "right")
dev.off()

# ============= HYPOTHESIS TESTS =============

cat("\n\n=== HYPOTHESIS TESTING ===\n")

# Test 1: Kruskal-Wallis test for rider classes
cat("\n--- TEST 1: Difference between Rider Classes (Overall) ---\n")
kw_rider <- kruskal.test(points ~ rider_class, data = data)
print(kw_rider)

# Post-hoc pairwise comparisons using Wilcoxon test
if(kw_rider$p.value < 0.05) {
  cat("\nPost-hoc pairwise Wilcoxon tests:\n")
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
  cat("\nPost-hoc pairwise Wilcoxon tests:\n")
  pairwise_stage <- pairwise.wilcox.test(data$points, data$stage_class,
                                          p.adjust.method = "bonferroni")
  print(pairwise_stage)
}

# Test 3: Two-way analysis - interaction between rider class and stage class
cat("\n--- TEST 3: Interaction between Rider Class and Stage Class ---\n")

# Prepare data for Scheirer-Ray-Hare test (non-parametric two-way ANOVA)
# Using aligned rank transform
cat("\nUsing aligned ranks for two-way analysis:\n")

# Calculate ranks
data$rank_points <- rank(data$points)

# Fit linear model on ranks (approximation of two-way non-parametric ANOVA)
model_ranks <- lm(rank_points ~ rider_class * stage_class, data = data)
anova_ranks <- anova(model_ranks)
print(anova_ranks)

# Test 4: Individual tests for each stage class
cat("\n--- TEST 4: Rider Class Differences within Each Stage Class ---\n")

for(stage_type in unique(data$stage_class)) {
  cat("\n", stage_type, "stages:\n")
  subset_data <- data[data$stage_class == stage_type, ]
  kw_test <- kruskal.test(points ~ rider_class, data = subset_data)
  print(kw_test)

  if(kw_test$p.value < 0.05) {
    cat("Post-hoc tests:\n")
    pw_test <- pairwise.wilcox.test(subset_data$points, subset_data$rider_class,
                                     p.adjust.method = "bonferroni")
    print(pw_test)
  }
}

# Test 5: Individual tests for each rider class
cat("\n--- TEST 5: Stage Class Differences within Each Rider Class ---\n")

for(rider_type in unique(data$rider_class)) {
  cat("\n", as.character(rider_type), ":\n")
  subset_data <- data[data$rider_class == rider_type, ]
  kw_test <- kruskal.test(points ~ stage_class, data = subset_data)
  print(kw_test)

  if(kw_test$p.value < 0.05) {
    cat("Post-hoc tests:\n")
    pw_test <- pairwise.wilcox.test(subset_data$points, subset_data$stage_class,
                                     p.adjust.method = "bonferroni")
    print(pw_test)
  }
}

# Additional summary table for the report
cat("\n=== FINAL SUMMARY TABLE ===\n")
summary_table <- data %>%
  group_by(rider_class, stage_class) %>%
  summarise(
    N = n(),
    Mean = round(mean(points), 2),
    SD = round(sd(points), 2),
    Median = round(median(points), 2),
    .groups = 'drop'
  ) %>%
  arrange(rider_class, stage_class)

print(summary_table)
write.csv(summary_table, "summary_table_report.csv", row.names = FALSE)

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("All plots and tables have been saved to the working directory.\n")
