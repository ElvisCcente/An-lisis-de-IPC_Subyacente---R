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




#------------------------

# Prueba de raíz unitaria (para saber si es estacionaria)
# p-valor < 0.05 ==> estacionaria

library(urca)

# Aplicar prueba ADF
resultado_adf <- ur.df(ipc_ts, type = "drift", selectlags = "AIC")

# Imprimir resultados
cat("ADF Statistic:", resultado_adf@teststat[1], "\n")
cat("Número de lags usados:", resultado_adf@lags, "\n")
cat("Número de observaciones usadas:", length(ipc_ts), "\n")

cat("Valores críticos:\n")
cat("   1%:", resultado_adf@cval[1,1], "\n")
cat("   5%:", resultado_adf@cval[1,2], "\n")
cat("   10%:", resultado_adf@cval[1,3], "\n")

# p-value (aproximado con tseries)
resultado_adf_p <- adf.test(ipc_ts)

cat("p-value:", resultado_adf_p$p.value, "\n")

# Interpretación simple
if (resultado_adf_p$p.value < 0.05) {
  cat("\n✅ La serie es estacionaria (rechazamos H0)\n")
} else {
  cat("\n❌ La serie NO es estacionaria (no rechazamos H0)\n")
}

#------------------------------

# Esto te dice cuántas veces necesita ser diferenciada la variable.

library(tseries)

# Seleccionar la serie
series <- ipc_ts
diff_count <- 0

# Diferenciar hasta que sea estacionaria o máximo 3 veces
while (adf.test(series)$p.value > 0.05 && diff_count < 3) {
  series <- diff(series)
  diff_count <- diff_count + 1
}

cat("IPC_Subyacente: estacionaria tras", diff_count, "diferencia(s)\n")


#---------------------------

# . Seleccionar la variable IPC_Subyacente

ipc_sub <- ipc_ts

# Verificar
head(ipc_sub)

# . Aplicar la segunda diferencia

ipc_sub_diff2 <- diff(ipc_sub, differences = 2)

cat("\n✅ Serie diferenciada (primeras observaciones):\n")
head(ipc_sub_diff2)

# Graficar la serie diferenciada

plot(
  ipc_sub_diff2,
  type = "l",
  col = "blue",
  lwd = 2,
  main = "IPC_Subyacente diferenciada (2da diferencia)",
  xlab = "Fecha",
  ylab = "Cambio"
)

grid()

legend(
  "topleft",
  legend = "IPC_Subyacente",
  col = "blue",
  lty = 1,
  lwd = 2,
  bty = "n"
)

#-----------------------------


# ACF y PACF

# Graficar ACF y PACF
par(mfrow = c(1, 2))  # Dos gráficos en una fila

acf(
  ipc_sub_diff2,
  lag.max = 40,
  main = "ACF - IPC_Subyacente diferenciada"
)

pacf(
  ipc_sub_diff2,
  lag.max = 40,
  main = "PACF - IPC_Subyacente diferenciada"
)

# Restaurar la ventana gráfica
par(mfrow = c(1, 1))


#------------------

# Determinar los rezagos de ARIMA p, q
# (objetivo es mejor ajuste a los datos históricos, usa AIC)


# Selección automática de ARIMA usando AIC/BIC

mejor_aic <- Inf
mejor_bic <- Inf
mejor_param_aic <- NULL
mejor_param_bic <- NULL

# Selección de parámetros posibles
p <- 0:5   # rezagos AR
d <- 2     # número de diferencias (ya calculaste)
q <- 0:5   # rezagos MA

# Iterar sobre todas las combinaciones
for (i in p) {
  for (k in q) {
    
    modelo <- try(arima(ipc_sub, order = c(i, d, k)), silent = TRUE)
    
    if (!inherits(modelo, "try-error")) {
      
      # Comparar AIC
      if (AIC(modelo) < mejor_aic) {
        mejor_aic <- AIC(modelo)
        mejor_param_aic <- c(i, d, k)
      }
      
      # Comparar BIC
      if (BIC(modelo) < mejor_bic) {
        mejor_bic <- BIC(modelo)
        mejor_param_bic <- c(i, d, k)
      }
    }
  }
}

cat("✅ Mejor ARIMA según AIC:", mejor_param_aic,
    "con AIC =", mejor_aic, "\n")

cat("✅ Mejor ARIMA según BIC:", mejor_param_bic,
    "con BIC =", mejor_bic, "\n")


# ✅ Ajuste del modelo final con AIC


modelo_final <- arima(ipc_sub, order = mejor_param_aic)

summary(modelo_final)


#---------------------


# Modelo ARIMA(5,2,5)

# ======================================
# ✅ Ajuste del modelo ARIMA(5,2,5)
# ======================================

# Entrenar el modelo con los parámetros seleccionados
modelo_arima <- arima(ipc_sub, order = c(5, 2, 5))

# Mostrar resumen del modelo
summary(modelo_arima)

# Información del modelo
cat("Coeficientes:\n")
print(modelo_arima$coef)

cat("\nErrores estándar:\n")
print(sqrt(diag(modelo_arima$var.coef)))

cat("\nAIC:", AIC(modelo_arima), "\n")
cat("BIC:", BIC(modelo_arima), "\n")
cat("Log-Likelihood:", modelo_arima$loglik, "\n")
cat("Sigma²:", modelo_arima$sigma2, "\n")


#---------------------------------------

# Diagnóstico del modelo
# Verificar normalidad de los residuos

# Residuos del modelo
residuos <- residuals(modelo_arima)

# 1️⃣ Histograma y curva de densidad
hist(residuos,
     probability = TRUE,
     breaks = 30,
     col = "lightgray",
     main = "Distribución de residuos",
     xlab = "Residual")

lines(density(residuos), col = "red", lwd = 2)

# 2️⃣ Prueba de normalidad (Jarque-Bera)
library(tseries)

jb_test <- jarque.bera.test(residuos)

cat("Jarque-Bera:", round(jb_test$statistic, 3),
    ", p-value:", round(jb_test$p.value, 3), "\n")

if (jb_test$p.value > 0.05) {
  cat("✅ Residuos aproximadamente normales\n")
} else {
  cat("❌ Residuos no normales\n")
}


#--------------------------------------


# Pronóstico para 24 meses

# Número de periodos a pronosticar
h <- 24

# Generar pronóstico
pronostico <- predict(modelo_arima, n.ahead = h)

# Valores pronosticados
pred_mean <- pronostico$pred

# Intervalos de confianza (95%)
lim_inf <- pred_mean - 1.96 * pronostico$se
lim_sup <- pred_mean + 1.96 * pronostico$se

# Crear serie temporal del pronóstico
pred_ts <- ts(pred_mean,
              start = end(ipc_sub) + c(0,1),
              frequency = 12)

lim_inf_ts <- ts(lim_inf,
                 start = end(ipc_sub) + c(0,1),
                 frequency = 12)

lim_sup_ts <- ts(lim_sup,
                 start = end(ipc_sub) + c(0,1),
                 frequency = 12)

# Graficar valores reales y pronóstico
ts.plot(ipc_sub, pred_ts,
        col = c("blue", "red"),
        lty = c(1, 2),
        lwd = 2,
        xlab = "Fecha",
        ylab = "IPC_Subyacente",
        main = "Valores reales vs Pronóstico ARIMA(5,2,5) - 24 meses")

# Bandas de confianza
lines(lim_inf_ts, col = "pink", lty = 3)
lines(lim_sup_ts, col = "pink", lty = 3)

legend("topleft",
       legend = c("Valores reales", "Pronóstico 24 meses", "Intervalo de confianza"),
       col = c("blue", "red", "pink"),
       lty = c(1, 2, 3),
       lwd = 2,
       bty = "n")

grid()

# Mostrar valores pronosticados
cat("Pronóstico 24 meses:\n")
print(pred_mean)