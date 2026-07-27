# Análisis del IPC Subyacente mediante R

## 1. Descripción del proyecto

Este proyecto desarrolla un análisis exploratorio de datos (EDA) y un análisis de series temporales del **Índice de Precios al Consumidor Subyacente (IPC_Subyacente)** utilizando el lenguaje de programación R.

El objetivo principal es comprender el comportamiento histórico del IPC_Subyacente, identificar sus principales características estadísticas, evaluar su estacionariedad y construir un modelo ARIMA que permita realizar pronósticos para los próximos 24 meses.

El análisis utiliza información oficial proveniente del **Banco Central de Reserva del Perú (BCRP)**.

---

# 2. Fuente de datos

**Institución:** Banco Central de Reserva del Perú (BCRP).

**Base de datos utilizada:** Serie mensual del IPC_Subyacente.

**Periodo analizado:** Enero de 1992 hasta el último periodo disponible en la base descargada.

**Variable analizada:**

- `IPC_Subyacente`: indicador de evolución de precios que excluye componentes altamente volátiles de la inflación, permitiendo analizar una tendencia más estable del comportamiento inflacionario.

---

# 3. Estructura del proyecto

An-lisis-de-IPC_Subyacente---R/

├── DATOS/
│ └── Mensuales-20260727-142811.xlsx

├── FIGURAS/
│ ├── 1. EXPLORACIÓN/
│ │ ├── 1. Serie temporal de IPC_Subyacente.png
│ │ └── 2. Histograma del IPC.png
│ │
│ └── 2. ANALISIS FINAL/
│ ├── 1. IPC_Subyacente diferenciada.png
│ ├── 2. ACF, PACF.png
│ ├── 3. Diagnóstico del modelo.png
│ └── 4. Pronóstico ARIMA (5,2,5)-24 meses.png

├── GUIONES/
│ ├── 1. Exploración.R
│ └── 2. Análisis final.R

└── LÉAME.md


---

# 4. Metodología del análisis

El proyecto se desarrolló en dos etapas:

## Parte 1: Análisis exploratorio de datos (EDA)

En esta etapa se realizó:

- Importación de la base de datos en formato Excel.
- Limpieza y transformación de la información.
- Conversión de la variable IPC a formato numérico.
- Construcción de la serie temporal mensual.
- Obtención de estadísticas descriptivas.
- Visualización gráfica del comportamiento histórico del IPC_Subyacente.

Los principales gráficos generados fueron:

1. **Serie temporal del IPC_Subyacente**

   Permite observar la evolución del índice a través del tiempo e identificar tendencias, cambios estructurales y periodos de mayor variabilidad.

2. **Histograma del IPC_Subyacente**

   Permite analizar la distribución de los valores observados y conocer la concentración de los datos.

---

# 5. Análisis final de series temporales

A partir de los resultados encontrados en el análisis exploratorio, se realizó un modelo econométrico de series temporales.

## 5.1 Prueba de estacionariedad

Se aplicó la prueba de raíz unitaria de Dickey-Fuller Aumentada (ADF) para determinar si la serie era estacionaria.

Debido a que la serie original presentó problemas de estacionariedad, se aplicaron diferencias sucesivas hasta obtener una serie adecuada para la modelación.

---

## 5.2 Transformación de la serie

Se aplicó una segunda diferencia al IPC_Subyacente:

\[
ARIMA(p,2,q)
\]

La serie diferenciada permitió analizar los patrones temporales mediante las funciones de autocorrelación.

---

## 5.3 Identificación del modelo

Se utilizaron los gráficos:

- ACF (Autocorrelation Function).
- PACF (Partial Autocorrelation Function).

Estos permitieron identificar los posibles valores de los parámetros autorregresivos (AR) y de media móvil (MA).

Además, se realizó una búsqueda automática de modelos comparando criterios de información:

- AIC (Akaike Information Criterion).
- BIC (Bayesian Information Criterion).

El modelo seleccionado fue:

\[
\textbf{ARIMA(5,2,5)}
\]

debido a que presentó el mejor ajuste según los criterios evaluados.

---

# 6. Diagnóstico del modelo

Para evaluar la adecuación del modelo ARIMA(5,2,5), se analizaron los residuos mediante:

- Histograma de residuos.
- Curva de densidad.
- Prueba de normalidad Jarque-Bera.

El diagnóstico permitió verificar si los errores del modelo presentan un comportamiento compatible con los supuestos estadísticos requeridos.

---

# 7. Pronóstico

Finalmente, utilizando el modelo ARIMA(5,2,5), se realizó un pronóstico del IPC_Subyacente para los próximos:

**24 meses**

El pronóstico incluye:

- Valores estimados futuros.
- Intervalos de confianza al 95%.
- Comparación entre valores históricos y valores proyectados.

El gráfico final permite visualizar la posible trayectoria futura del IPC_Subyacente según el comportamiento observado en la serie histórica.

---

# 8. Principales conclusiones

- El IPC_Subyacente presenta una tendencia creciente durante el periodo analizado, reflejando cambios acumulados en el nivel de precios de la economía peruana.

- La serie original no presentó características estacionarias, por lo que fue necesario aplicar diferenciación para lograr una estructura adecuada para el modelamiento.

- El modelo ARIMA(5,2,5) mostró un mejor ajuste entre las alternativas evaluadas mediante los criterios AIC y BIC.

- El modelo permite generar pronósticos de corto plazo que pueden servir como referencia para analizar la evolución esperada del componente subyacente de la inflación.

---

# 9. Requisitos para ejecutar el proyecto

Para reproducir el análisis se requiere:

## Software

- RStudio.

## Librerías utilizadas

```r
library(tidyverse)
library(readxl)
library(tseries)
library(vars)
library(urca)
