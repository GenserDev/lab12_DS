# Observatorio de Turismo Sostenible en Power BI

CC3066 Data Science, Universidad del Valle de Guatemala, Semestre II 2026. Laboratorio 12.
Integrantes: Javier Chávez, Genser Catalán y Juan Cruz.

Segunda versión del cuadro de mando del Laboratorio 10, ahora como informe interactivo de Power BI para directivos del sector turístico. Usa la misma base de migración de enero 2009 a junio 2026, las mismas siete preguntas de gestión y los resultados de los modelos de los Laboratorios 1 y 2, sin entrenar modelos nuevos. El documento de diseño compara el informe con la versión en Streamlit.

## Estructura

```
datos/                    CSV del Lab 10 y resultados de modelos
scripts/                  exportación reproducible de predicciones
powerbi/                  informe .pbix, consultas M, medidas DAX, tema y guía
docs/                     documento de diseño y comparación (PDF y Word), bosquejo, avance y capturas
```

**Tablas de predicciones y métricas.** `datos/metricas_modelos.csv` es el archivo original del Lab 10 con MAE y RMSE de 7 series. `datos/predicciones_modelos.csv` trae observado, predicho y error mensual de SeasonalNaive, SES y Prophet en el conjunto de prueba (abril 2021 a junio 2026). En Power BI se cargan como Metricas y Predicciones.

## Cómo abrir el informe

Power BI Desktop solo funciona en Windows 10 o posterior. Versión usada: [PENDIENTE].

**1. Clonar el repositorio**

```bash
git clone https://github.com/GenserDev/lab12_DS.git && cd lab12_DS
```

**2. Abrir el informe**

Abrir `powerbi/Observatorio_Turismo_Sostenible.pbix` con Power BI Desktop.

**3. Cambiar la ruta de los datos**

Inicio > Transformar datos > Editar parámetros. Poner en RutaDatos la ruta completa de la carpeta `datos` de este repositorio, terminando en `\`.

**4. Actualizar**

Inicio > Actualizar. Las tarjetas de Inicio deben mostrar 46,711,913 viajeros en total sin filtros.

## Regenerar las predicciones (opcional)

El script vuelve a ejecutar los tres modelos del Lab 1 con la misma partición y se detiene si el MAE o el RMSE no coinciden con `metricas_modelos.csv`.

```bash
python3 -m venv .venv && source .venv/bin/activate
```

```bash
pip install -r scripts/requirements.txt
```

```bash
python scripts/exportar_predicciones.py
```

## Reproducir las tres pruebas

Los pasos y resultados esperados están en la sección 7.3 del documento de diseño. En resumen, la prueba 1 filtra el año 2024 en Inicio, la prueba 2 baja de año a mes en 2023 y regresa, y la prueba 3 compara los modelos de la serie total en Predicciones. Se hace lo mismo en el Streamlit del Lab 10.

## Versión del Laboratorio 10

El código está en https://github.com/JAVIERCLO/lab10_DS.

```bash
git clone https://github.com/JAVIERCLO/lab10_DS.git && cd lab10_DS
```

```bash
pip install -r requirements.txt && streamlit run app.py
```

Si el .pbix pesa demasiado para GitHub, se entrega aparte y aquí se indica su ubicación y versión. La guía para reconstruirlo desde cero está en `powerbi/GUIA_CONSTRUCCION.md`.
