# ==============================================================================
# Script 3: GARCH Volatility Modeling
# ==============================================================================

# 1. Load Libraries and Cleaned Data
library(tidyverse)
library(rugarch)

data <- readRDS("../data/cleaned_merged_data.rds")

# 2. Calculate Log Returns
log_price_ts <- ts(na.omit(data$log_price), frequency = 365)
log_diff <- na.omit(diff(log_price_ts))

# 3. Specify and Fit GARCH(1,1) Model
garch_spec <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1,1)),
  mean.model = list(armaOrder = c(2,2), include.mean = TRUE),
  distribution.model = "std" # Student's t-distribution for heavy tails
)

garch_fit <- ugarchfit(spec = garch_spec, data = log_diff)

# Display model summary and parameters
show(garch_fit)
garch_params <- coef(garch_fit)
vol_persistence <- garch_params["alpha1"] + garch_params["beta1"]
cat("Volatility Persistence (alpha + beta):", vol_persistence, "\n")

# 4. Residual Diagnostics
garch_resid <- residuals(garch_fit)
acf(garch_resid^2, main = "ACF of Squared GARCH Residuals")

# 5. Forecast Volatility (30 days ahead)
garch_forecast <- ugarchforecast(garch_fit, n.ahead = 30)
vol_forecast <- sigma(garch_forecast)

# Plot Forecasted Volatility
plot(vol_forecast, type = "l", col = "darkred", lwd = 2,
     main = "Forecasted Volatility from GARCH(1,1)",
     ylab = "Volatility", xlab = "Days Ahead")