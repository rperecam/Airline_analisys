# Bloque 1: Carga de librerías y datos iniciales

# Carga de las librerías necesarias
library(tidyverse) # Para manipulación de datos
library(ggplot2)   # Para visualización de datos
library(corrplot)  # Para gráficos de correlación
library(reticulate) # Para interactuar con Python

# Carga de los datos desde archivos CSV
df_clh <- read.csv('data/clh.csv', sep = ';')
df_cfa <- read.csv('data/cfa.csv', sep = ';')

# Exploración inicial de los datos
# Muestra la estructura de los dataframes
str(df_clh)
str(df_cfa)
# Muestra un resumen estadístico de los dataframes
summary(df_clh)
summary(df_cfa)

# Bloque 2: Limpieza y transformación de datos

# Limpieza del dataframe df_clh
# Cálculo de los cuartiles 1 y 3 de la columna 'Salary'
Q1 <- quantile(df_clh$Salary, 0.25)
Q3 <- quantile(df_clh$Salary, 0.75)
# Filtrado de filas y eliminación de la columna 'Country'
df_clh <- df_clh %>%
  filter(Salary >= Q1, Salary <= Q3) %>%
  select(-Country)
# Formateo de la columna 'Enrollment.Month' y creación de 'Enrollment.Date'
df_clh <- df_clh %>%
  mutate(`Enrollment.Month` = str_pad(`Enrollment.Month`, 2, pad = "0"),
         `Enrollment.Date` = as.Date(paste(`Enrollment.Year`, `Enrollment.Month`, "01", sep = "-"))) %>%
  select(-`Enrollment.Year`, -`Enrollment.Month`)

# Limpieza del dataframe df_cfa
# Creación de la columna 'Date' y eliminación de 'Year' y 'Month'
df_cfa <- df_cfa %>%
  mutate(Date = as.Date(paste(Year, Month, "01", sep = "-"))) %>%
  select(-Year, -Month)

# Corrección del nombre de la columna 'ï..Loyalty.Number' en df_cfa
colnames(df_cfa)[colnames(df_cfa) == "ï..Loyalty.Number"] <- "Loyalty.Number"
# Se reasigna el dataframe df_cfa para forzar la actualización
df_cfa <- df_cfa

# Muestra los nombres de las columnas de los dataframes
colnames(df_clh)
colnames(df_cfa)

# Bloque 3: Análisis exploratorio de datos (EDA)

# Matriz de correlación para df_cfa
# Visualiza la correlación entre variables numéricas
corrplot(cor(df_cfa %>% select_if(is.numeric)), method = "color")

# Cálculo y visualización del descuento por punto
# Calcula el descuento por punto y el promedio
df_cfa <- df_cfa %>%
  mutate(`Discount.per.Point` = `Dollar.Cost.Points.Redeemed` / `Points.Redeemed`)
average_discount_per_point <- mean(df_cfa$`Discount.per.Point`, na.rm = TRUE)
# Imprime el descuento promedio por punto en la consola
cat("El descuento promedio por punto es:", average_discount_per_point, "\n")
# Visualiza la media de puntos acumulados por fecha
df_cfa %>%
  group_by(Date) %>%
  summarise(mean_points = mean(`Points.Accumulated`)) %>%
  ggplot(aes(x = Date, y = mean_points)) +
  geom_line() +
  labs(title = "Media de puntos acumulados por fecha", x = "Fecha", y = "Media de puntos acumulados")
# Visualiza el descuento por punto por fecha
df_cfa %>%
  group_by(Date) %>%
  summarise(mean_discount = mean(`Discount.per.Point`, na.rm = TRUE)) %>%
  ggplot(aes(x = Date, y = mean_discount)) +
  geom_line() +
  labs(title = "Descuento por punto por fecha", x = "Fecha", y = "Descuento por punto")

# Visualización del número de altas de clientes por fecha
df_clh %>%
  group_by(`Enrollment.Date`) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = `Enrollment.Date`, y = count)) +
  geom_line() +
  labs(title = "Altas de clientes por fecha", x = "Fecha", y = "Altas de clientes")

# Visualización de las ventas de vuelos por fecha
df_cfa %>%
  group_by(Date) %>%
  summarise(mean_flights = mean(`Flights.Booked`)) %>%
  ggplot(aes(x = Date, y = mean_flights)) +
  geom_line() +
  labs(title = "Ventas de vuelos por fecha", x = "Fecha", y = "Ventas de vuelos")

# Bloque 4: Creación del dataframe para modelado

# Unión de los dataframes df_clh y df_cfa
df <- df_clh %>%
  left_join(df_cfa %>% select(`Loyalty.Number`, `Points.Redeemed`), by = "Loyalty.Number") %>%
  filter(!is.na(`Points.Redeemed`), `Points.Redeemed` != 0) %>%
  group_by(`Loyalty.Number`) %>%
  mutate(`Total Points Redeemed` = sum(`Points.Redeemed`, na.rm = TRUE)) %>%
  distinct(`Loyalty.Number`, .keep_all = TRUE) %>%
  ungroup() %>%
  select(-`Points.Redeemed`, -`Enrollment.Date`, -`Loyalty.Number`) %>%
  filter(Salary != 0)

# Guarda el dataframe resultante en un archivo CSV
write.csv(df, 'data/model.csv', row.names = FALSE)
# Muestra un resumen estadístico del dataframe final
summary(df)

# Bloque 5: Modelado predictivo usando Python y reticulate

# Carga el script de Python
source_python("model.py")

# Llama a la función de Python para entrenar y evaluar el modelo
results <- train_and_evaluate_model()

# Imprime los resultados del modelo
print(results$metrics)
print(results$cv_metrics)
print(results$feature_importance)