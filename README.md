# Cocoa Commodity Price Forecasting & Volatility Analysis 🍫📈

## 📌 Project Overview
This project introduces statistical modeling methods to predict daily cocoa prices based on time series and regression models, focusing on the influence of climatic conditions in Ghana on market behavior. The project employs historical cocoa price data from the International Cocoa Organization and daily climatic data from Ghana. The overall objective is to compare a range of modeling frameworks (ARIMA, ARIMAX, and GARCH) to ascertain which offers the best balance of accuracy, interpretability, and forecasting capability.

## 🛠️ Tech Stack & Methods
* **Language:** R (forecast, rugarch, tseries, dplyr, ggplot2, car)
* **Time Series Modeling:** ARIMA, ARIMAX (with exogenous climate regressors)
* **Volatility Modeling:** GARCH(1,1) with Student's t-distribution
* **Statistical Diagnostics:** Augmented Dickey-Fuller (ADF) test, Ljung-Box test, Variance Inflation Factor (VIF), Cross-Correlation Function (CCF)

## 📊 Key Business Insights & Results

### 1. Climate-Driven Forecasting (ARIMAX vs. ARIMA)
Proved that external climate factors (e.g., lagged precipitation and temperature) act as leading indicators for cocoa price shocks. By incorporating these exogenous variables, the ARIMAX model improved the AIC by over 12,500 units compared to the univariate baseline, successfully capturing price spikes that traditional models missed. This provides actionable signals for proactive commodity procurement.
![ARIMAX vs ARIMA](images/arimax_forecast.png)

### 2. Market Risk & Volatility (GARCH)
Fitted a GARCH(1,1) model to quantify conditional variance, revealing a strong volatility persistence ($\alpha + \beta = 0.96$). This confirms a "long memory" in market shocks, providing a critical quantitative foundation for options pricing and risk hedging strategies in highly volatile commodity markets.

![GARCH Volatility](images/garch_volatility.png)

## 📂 Repository Structure
* data: Contains aggregated historical cocoa prices (ICCO) and Ghana climate data (NOAA).
* cript: Modularized R scripts for reproducibility.
  * 01_data_cleaning_and_eda.R: Data merging, log-transformations, and STL decomposition.
  * 02_arimax_forecasting.R: VIF feature selection and ARIMA/ARIMAX model training.
  * 03_garch_volatility.R: Conditional variance modeling using rugarch.
* images: Visualizations of model diagnostics and forecasts, including STL decomposition and residual plots.

## 🚀 How to Run
1. Clone this repository: git clone https://github.com/NanLi-1217/Cocoa-Commodity-Volatility-Forecasting
2. Ensure you have R installed along with the required packages: install.packages(c("tidyverse", "forecast", "rugarch", "tseries", "car", "Metrics"))
3. Run the scripts in the script folder sequentially.

## 🔮 Future Work
* **Dynamic Climate Inputs:** The current ARIMAX forecast assumes static future climate variables (naive hold approach). Integrating live weather forecast APIs would enhance real-world predictive power.
* **Hybrid Modeling:** Developing a combined ARIMAX-GARCH model to jointly forecast price levels and uncertainty simultaneously.
