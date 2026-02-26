# ==============================================================================
# Script 1: Data Cleaning and Exploratory Data Analysis (EDA)
# ==============================================================================

# 1. Load Required Libraries
library(tidyverse)
library(lubridate)
library(zoo)
library(imputeTS)
library(forecast)
library(tseries)
library(GGally)

# 2. Load and Clean Cocoa Price Data
coco <- read_csv("../data/Daily Prices_ICCO.csv") %>%
  rename_with(tolower) %>%
  mutate(date = dmy(date)) %>%
  rename(price = `icco daily price (us$/tonne)`)

# 3. Load and Clean Ghana Climate Data
climate <- read_csv("../data/Ghana_data.csv") %>%
  rename(prcp = PRCP, tavg = TAVG, tmin = TMIN, tmax = TMAX, date = DATE) %>%
  mutate(
    date = as.Date(date),
    across(c(prcp, tavg, tmin, tmax), as.numeric)
  ) %>%
  arrange(date)

# Aggregate climate data to daily averages
climate_daily_avg <- climate %>%
  group_by(date) %>%
  summarise(across(c(prcp, tavg, tmin, tmax), ~ mean(.x, na.rm = TRUE)))

# 4. Merge Datasets
data <- coco %>%
  inner_join(climate_daily_avg, by = "date") %>%
  drop_na() %>%
  dplyr::select(date, price, tavg, tmin, tmax, prcp)

# 5. Exploratory Data Analysis (EDA)
# Correlation Matrix
GGally::ggpairs(data %>% dplyr::select(price, tavg, tmin, tmax, prcp))

# Histogram of Prices
ggplot(data, aes(x = price)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white") +
  labs(title = "Histogram of Daily Cocoa Prices", x = "Price (USD/tonne)", y = "Frequency") +
  theme_minimal()

# Seasonality & Trends (STL Decomposition)
ts_data <- ts(data$price, frequency = 365)
plot(stl(ts_data, s.window = "periodic"), main = "STL Decomposition of Daily Cocoa Prices")

# 6. Data Transformation (Log & Differencing)
data <- data %>%
  mutate(
    log_price = log(price),
    log_diff = c(NA, diff(log_price))
  )

# Stationarity Check
adf.test(na.omit(data$log_diff))

# Save the cleaned dataframe for the next scripts (optional, but good practice)
saveRDS(data, file = "../data/cleaned_merged_data.rds")