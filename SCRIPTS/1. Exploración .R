# Cargar las librerías 
library(tidyverse) # Incluye dplyr, ggplot2 y readxl
library(readxl)    # Específico para leer archivos .xlsx
library(tseries)   # Para la prueba Augmented Dickey-Fuller (adfuller)
library(vars)      # Para estimación y análisis de modelos VAR
library(urca)      # Para cointegración de Johansen y VECM

#  Cargar los datos desde Excel
df <- read_excel("C:/Users/Usuario/Downloads/Mensuales-20260727-142811.xlsx")

# Inspeccionar las primeras filas (equivalente a df.head())
head(df)

#--------------------

# Renombrar columnas
colnames(df) <- c("fecha", "ipc")

# Eliminar la primera fila (contiene la descripción)
df <- df[-1, ]

# Convertir IPC a numérico
df$ipc <- as.numeric(df$ipc)

# Crear la serie temporal (inicia en enero de 1992)
ipc_ts <- ts(df$ipc, start = c(1992, 1), frequency = 12)

# Gráfico de la serie temporal
plot(
  ipc_ts,
  type = "l",
  col = "blue",
  lwd = 2,
  main = "Serie Temporal de IPC_Subyacente",
  xlab = "Fecha",
  ylab = "Valor"
)

grid()

legend(
  "topleft",   # Leyenda arriba a la izquierda
  legend = "IPC_Subyacente",
  col = "blue",
  lty = 1,
  lwd = 2,
  bty = "n"
)

#------------------------
# Estadísticas descriptivas
summary(ipc_ts)

mean(ipc_ts)
sd(ipc_ts)
min(ipc_ts)
max(ipc_ts)

#-------------------------
# Histograma del IPC

ggplot(df, aes(x = ipc)) +
  geom_histogram(
    bins = 30,
    fill = "steelblue",
    color = "white"
  ) +
  labs(
    title = "Distribución del IPC Subyacente",
    subtitle = "Frecuencia de valores observados",
    x = "Índice IPC",
    y = "Frecuencia"
  ) +
  theme_minimal()


