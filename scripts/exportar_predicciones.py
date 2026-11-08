import logging
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
from prophet import Prophet
from statsmodels.tsa.holtwinters import SimpleExpSmoothing

warnings.filterwarnings("ignore")
logging.getLogger("cmdstanpy").disabled = True

DATOS = Path(__file__).resolve().parent.parent / "datos"
INICIO_PRUEBA = "2021-04-01"

serie = pd.read_csv(DATOS / "serie_total_mensual.csv", parse_dates=["Fecha"]).set_index("Fecha")["Viajero"].asfreq("MS")
entrenamiento = serie[serie.index < INICIO_PRUEBA]
prueba = serie[serie.index >= INICIO_PRUEBA]
pasos = len(prueba)

prophet = Prophet().fit(pd.DataFrame({"ds": entrenamiento.index, "y": entrenamiento.values}))
predicciones = {
    "SeasonalNaive": np.tile(entrenamiento[-12:].values, int(np.ceil(pasos / 12)))[:pasos],
    "SES": SimpleExpSmoothing(entrenamiento).fit().forecast(pasos).values,
    "Prophet": prophet.predict(pd.DataFrame({"ds": prueba.index}))["yhat"].values,
}

metricas = pd.read_csv(DATOS / "metricas_modelos.csv")
metricas_total = metricas[(metricas.Serie == "Total") & (metricas.Laboratorio == "Lab1")].set_index("Modelo")

filas = []
for modelo, predicho in predicciones.items():
    error = prueba.values - predicho
    mae = round(np.abs(error).mean())
    rmse = round(np.sqrt((error ** 2).mean()))
    esperado = metricas_total.loc[modelo]
    if (mae, rmse) != (esperado.MAE, esperado.RMSE):
        raise ValueError(f"{modelo} no reproduce las métricas del Lab 10: {mae}, {rmse}")
    print(f"{modelo}: MAE {mae:,} RMSE {rmse:,} coincide con metricas_modelos.csv")
    filas.append(pd.DataFrame({
        "Fecha": prueba.index,
        "Serie": "Total",
        "Laboratorio": "Lab1",
        "Modelo": modelo,
        "Conjunto": "Prueba abr 2021 a jun 2026",
        "Observado": prueba.values,
        "Predicho": predicho,
        "Error": error,
    }))

pd.concat(filas).to_csv(DATOS / "predicciones_modelos.csv", index=False, date_format="%Y-%m-%d")

similitud = pd.DataFrame({
    "Serie": ["Via_Marítima", "Reg_América Del Norte", "Reg_Europa", "Via_Terrestre", "Via_Aérea", "Reg_América Del Centro", "Total"],
    "DistanciaMedia": [8.66, 7.42, 6.96, 6.57, 6.52, 6.49, 6.21],
    "Grupo": [2, 3, 3, 1, 1, 1, 1],
})
similitud.to_csv(DATOS / "similitud_series.csv", index=False)
