# ==============================================================================
# Lecture 1: Introduction to Regression — Student Demo Script
# ==============================================================================
#
# This script reproduces all examples from Lecture 1.
# Run it interactively in R or RStudio to follow along.
#
# Required packages: ggplot2
# ==============================================================================

library(ggplot2)

set.seed(12345)

# --- Project palette ---
navy          <- "#003366"
steel_blue    <- "#4682B4"
gray          <- "#6B7280"
gold          <- "#D4A843"

theme_lecture <- function(base_size = 16) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", color = navy, size = 18),
      plot.subtitle = element_text(color = gray, size = 14),
      axis.title = element_text(color = navy, size = 14),
      axis.text = element_text(color = gray, size = 12),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#E5E7EB"),
      legend.position = "bottom"
    )
}

# ==============================================================================
# 1. Simulate the dataset
# ==============================================================================

n <- 50
hours <- round(runif(n, 1, 10), 1)
scores <- 45 + 5.2 * hours + rnorm(n, 0, 8)
scores <- pmin(pmax(round(scores), 0), 100)
exam_data <- data.frame(hours = hours, score = scores)

head(exam_data)

# ==============================================================================
# 2. Scatter plot (raw data)
# ==============================================================================

ggplot(exam_data, aes(x = hours, y = score)) +
  geom_point(color = steel_blue, size = 3, alpha = 0.7) +
  labs(
    title = "Exam Scores vs. Study Hours",
    subtitle = "n = 50 students",
    x = "Hours Studied",
    y = "Exam Score"
  ) +
  theme_lecture()

# ==============================================================================
# 3. Fit the regression model
# ==============================================================================

model <- lm(score ~ hours, data = exam_data)

# View coefficients
model

# Full summary
summary(model)

# ==============================================================================
# 4. Extract and interpret coefficients
# ==============================================================================

b0 <- coef(model)[1]  # Intercept
b1 <- coef(model)[2]  # Slope

cat(sprintf("Intercept (b0): %.2f\n", b0))
cat(sprintf("Slope (b1):     %.2f\n", b1))
cat(sprintf("\nInterpretation: Each additional hour of study is associated\n"))
cat(sprintf("with a %.1f-point increase in exam score.\n", b1))

# ==============================================================================
# 5. Scatter plot with fitted line
# ==============================================================================

ggplot(exam_data, aes(x = hours, y = score)) +
  geom_point(color = steel_blue, size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE,
              color = navy, fill = steel_blue,
              alpha = 0.15, linewidth = 1.2) +
  labs(
    title = "Exam Score vs. Study Hours",
    subtitle = paste0("Fitted line: Score = ", round(b0, 1),
                      " + ", round(b1, 1), " x Hours"),
    x = "Hours Studied",
    y = "Exam Score"
  ) +
  theme_lecture()

# ==============================================================================
# 6. Residuals
# ==============================================================================

exam_data$fitted <- predict(model)
exam_data$residual <- residuals(model)

# Visualize residuals
ggplot(exam_data, aes(x = hours, y = score)) +
  geom_segment(aes(xend = hours, yend = fitted),
               color = gold, alpha = 0.5, linewidth = 0.6) +
  geom_point(color = steel_blue, size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE,
              color = navy, linewidth = 1.2) +
  labs(
    title = "Residuals: Distance from Each Point to the Line",
    x = "Hours Studied",
    y = "Exam Score"
  ) +
  theme_lecture()

# ==============================================================================
# 7. Practice: Try with mtcars
# ==============================================================================

# Does car weight predict fuel efficiency?
car_model <- lm(mpg ~ wt, data = mtcars)
summary(car_model)

ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point(color = steel_blue, size = 3) +
  geom_smooth(method = "lm", se = TRUE,
              color = navy, fill = steel_blue, alpha = 0.15) +
  labs(
    title = "Miles per Gallon vs. Car Weight",
    subtitle = "Practice example using mtcars",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon"
  ) +
  theme_lecture()
