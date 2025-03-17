Descripción General

Este proyecto realiza un análisis completo del programa de puntos de una aerolínea, desde la carga y limpieza de datos hasta el modelado predictivo. El objetivo es entender cómo se generan y utilizan los puntos, identificar perfiles de clientes que usan más el programa, y construir un modelo para predecir categorías de puntos.

Estructura del Proyecto

El código se divide en cinco bloques principales:

Carga y exploración inicial de datos: Carga los datos de los archivos CSV y realiza una exploración inicial.
Limpieza y transformación de datos: Limpia y transforma los datos para prepararlos para el análisis.
Análisis exploratorio de datos (EDA): Realiza un análisis exploratorio para entender mejor los datos.
Creación del dataframe para modelado: Crea un dataframe consolidado para el modelado predictivo.
Modelado predictivo usando Python y reticulate: Entrena y evalúa un modelo de clasificación usando Python y reticulate.
Bloque 1: Carga y Exploración Inicial de Datos

Se cargan las librerías necesarias (tidyverse, ggplot2, corrplot, reticulate).
Se cargan los datos desde los archivos CSV clh.csv y cfa.csv.
Se realiza una exploración inicial de los datos usando str() y summary().
Bloque 2: Limpieza y Transformación de Datos

Se eliminan valores atípicos en la columna Salary de df_clh.
Se formatean las fechas y se eliminan columnas innecesarias en ambos dataframes.
Se corrige el nombre de la columna ï..Loyalty.Number en df_cfa.
Bloque 3: Análisis Exploratorio de Datos (EDA)

Se visualiza la matriz de correlación para df_cfa.
Se calcula y visualiza el descuento promedio por punto.
Se visualiza la media de puntos acumulados y el descuento por punto a lo largo del tiempo.
Se visualiza el numero de altas de clientes a lo largo del tiempo.
Se visualiza el numero de vuelos reservados a lo largo del tiempo.
Bloque 4: Creación del DataFrame para Modelado

Se realiza un left_join() entre df_clh y df_cfa para combinar los datos.
Se calculan los puntos totales canjeados por cliente.
Se guarda el dataframe resultante en data/model.csv.
Bloque 5: Modelado Predictivo Usando Python y reticulate

Se carga el script de Python model.py usando source_python().
Se llama a la función train_and_evaluate_model() para entrenar y evaluar un modelo RandomForestClassifier.
Se imprimen las métricas del modelo (log loss, F1-score, accuracy), los resultados de validación cruzada y la importancia de las características.
Análisis de Resultados

El análisis exploratorio revela patrones en la acumulación y canje de puntos a lo largo del tiempo.
El modelo predictivo proporciona métricas de rendimiento que indican su capacidad para predecir categorías de puntos.
La importancia de las características ayuda a identificar qué variables tienen mayor influencia en la predicción.
Conclusiones

Este análisis proporciona información valiosa sobre el programa de puntos de la aerolínea. Los resultados pueden utilizarse para mejorar el programa, personalizar ofertas para los clientes y optimizar las estrategias de marketing.