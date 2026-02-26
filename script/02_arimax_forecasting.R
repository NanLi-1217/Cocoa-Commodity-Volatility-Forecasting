# ==============================================================================
# Script 2: ARIMA and ARIMAX Forecasting Models
# ==============================================================================

# 1. Load Libraries and Cleaned Data
library(tidyverse)
library(forecast)
library(MASS)
library(car)
library(Metrics)
library(zoo)

data <- readRDS("../data/cleaned_merged_data.rds")

# 2. Feature Engineering: Create Lag Variables
data2 <- data %>%
  mutate(
    tavg_lag3 = lag(tavg, 3),
    prcp_lag7 = lag(prcp, 7)
  ) %>%
  drop_na()

# Variable Selection via StepAIC and VIF
model_full <- lm(log_price ~ tavg + prcp + tavg_lag3 + prcp_lag7 + tmin + tmax, data = data2)
model_step <- stepAIC(model_full, direction = "both", trace = FALSE)

# Final linear model excluding highly collinear variables (e.g., tmin)
model_linear <- lm(log_price ~ tavg + prcp + tavg_lag3 + prcp_lag7 + tmax, data = data2)
vif(model_linear) # Check multicollinearity

# 3. Monthly Aggregation for Time Series Modeling
monthly_data2 <- data2 %>%
  mutate(month = as.yearmon(date)) %>%
  group_by(month) %>%
  summarise(
    price = mean(price, na.rm = TRUE),
    tavg = mean(tavg, na.rm = TRUE),
    prcp = mean(prcp, na.rm = TRUE),
    tavg_lag3 = mean(tavg_lag3, na.rm = TRUE),
    prcp_lag7 = mean(prcp_lag7, na.rm = TRUE),
    tmax = mean(tmax, na.rm = TRUE)
  ) %>%
  mutate(log_price = log(price)) %>%
  drop_na()

log_price_ts <- ts(monthly_data2$log_price, frequency = 12,
                   start = c(year(min(monthly_data2$month)), month(min(monthly_data2$month))))

# 4. Baseline ARIMA Model
arima_model <- auto.arima(log_price_ts)
forecast_arima <- forecast(arima_model, h = 12)
forecast_arima_exp <- exp(forecast_arima$mean) # Back-transform

# 5. ARIMAX Model with Climate Regressors
xreg_matrix <- as.matrix(monthly_data2 %>% dplyr::select(tavg, prcp, tavg_lag3, prcp_lag7, tmax))
arimax_model <- auto.arima(log_price_ts, xreg = xreg_matrix)

# Forecast ARIMAX (using last 12 months of climate data as future inputs)
future_xreg <- tail(xreg_matrix, 12)
arimax_forecast <- forecast(arimax_model, xreg = future_xreg, h = 12)
arimax_pred <- exp(arimax_forecast$mean)

# 6. Model Comparison (RMSE, MAE, AIC)
actual <- tail(monthly_data2$price, 12)
pred_arima <- tail(as.numeric(forecast_arima_exp), 12)
pred_arimax <- tail(as.numeric(arimax_pred), 12)

model_comparison <- data.frame(
  Model = c("ARIMA(0,1,1)", "ARIMAX (Climate Variables)"),
  RMSE = c(rmse(actual, pred_arima), rmse(actual, pred_arimax)),
  MAE  = c(mae(actual, pred_arima), mae(actual, pred_arimax)),
  AIC  = c(arima_model$aic, arimax_model$aic)
)

print(model_comparison)