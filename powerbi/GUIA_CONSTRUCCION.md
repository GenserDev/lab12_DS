# Guía para construir el informe en Power BI Desktop

Power BI Desktop solo funciona en Windows. Esta guía deja el informe igual al diseño del documento, con los mismos datos y resultados del Lab 10. Al terminar se guarda como `powerbi/Observatorio_Turismo_Sostenible.pbix`.

## Datos y modelo

**1. Aplicar el tema**

Vista > Temas > Buscar temas, y elegir `powerbi/tema_observatorio.json`.

**2. Crear el parámetro y las consultas**

Inicio > Transformar datos > Nueva fuente > Consulta en blanco. Por cada bloque de `consultas_power_query.m`, crear una consulta con el nombre que aparece en su comentario y pegar el código en el Editor avanzado. El orden es RutaDatos, LeerCsv, Viajeros, Calendario, Metricas, Predicciones, Modelos y Similitud. RutaDatos debe apuntar a la carpeta `datos` del repositorio. LeerCsv se deshabilita para carga (clic derecho > Habilitar carga).

**3. Relaciones**

En la vista de modelo, desactivar la detección automática y crear estas relaciones.

| Desde | Hacia | Cardinalidad | Dirección |
|---|---|---|---|
| Calendario[Fecha] | Viajeros[Fecha] | 1 a 1 | Ambas |
| Calendario[Fecha] | Predicciones[Fecha] | 1 a varios | Única |
| Modelos[Modelo] | Metricas[Modelo] | 1 a varios | Única |
| Modelos[Modelo] | Predicciones[Modelo] | 1 a varios | Única |

SerieSeleccion, MetricaSeleccion y Similitud quedan sin relaciones.

**4. Calendario**

Marcar Calendario como tabla de fechas con la columna Fecha. Ordenar Mes por MesNum. Crear la jerarquía **Periodo** con Año, Trimestre y Mes.

**5. Tablas calculadas y medidas**

Crear SerieSeleccion y MetricaSeleccion, y luego una tabla vacía llamada Medidas para guardar todas las medidas de `medidas.dax`. Formato sin decimales para viajeros, un decimal para porcentajes.

## Estructura de páginas

Todas las páginas llevan una barra lateral verde (#264D3C) de 180 px con el título del observatorio y un navegador de páginas (Insertar > Botones > Navegador > Navegador de páginas) en vertical. El estado seleccionado del navegador usa relleno dorado (#D5AD55) para que se vea en qué página se está. Arriba de cada página va un cuadro de texto con la medida **Selección activa** y un botón **Restablecer vista** enlazado al marcador de la página.

**Inicio**

Segmentadores de Año (tipo Entre), SerieSeleccion (botones) y AñoMes (lista desplegable con búsqueda). Tres tarjetas: Total viajeros, Promedio mensual y Viajeros vía aérea.

V1. Gráfico de líneas con la jerarquía Periodo en el eje y las medidas Total viajeros y Viajeros vía aérea. Activar exploración en profundidad (drill down y drill up).

V2. Gráfico de columnas agrupadas con Periodo, Total viajeros y Viajeros vía aérea. En Formato > Editar interacciones, V1 filtra a V2 y V2 resalta a V1.

**Evolución**

Los mismos segmentadores de Año y SerieSeleccion, sincronizados con Inicio (Vista > Sincronizar segmentaciones).

V3. Matriz Calendario de viajeros con Año en filas, Mes en columnas y Viajeros serie en valores. Formato condicional de fondo con escala de blanco a #91A88E y a #264D3C. Al hacer clic en una celda filtra V4 y V5.

V4. Gráfico de columnas Estacionalidad por mes con Mes en el eje y Mediana del mes en valores. Barras de error con Primer cuartil del mes como límite inferior y Tercer cuartil del mes como superior. Información sobre herramientas con Mínimo y Máximo del mes.

V5. Gráfico de columnas Variación interanual con la jerarquía Periodo (Año y Mes) y Variación interanual (%). Color de columnas por valor de campo con la medida Color variación.

**Vías de ingreso**

V6. Gráfico de áreas Participación de la vía aérea con la jerarquía Periodo y Participación aérea (%), en dorado.

V7. Gráfico de dispersión Total frente a vía aérea con Total viajeros en X, Viajeros vía aérea en Y y AñoMes en valores. Seleccionar un punto resalta el período en V6 y viceversa.

**Predicciones**

Segmentadores de Metricas[SerieNombre] (selección única, valor inicial Total) y MetricaSeleccion (botones). Tarjeta de texto con Mensaje mejor modelo. Texto fijo con el conjunto de evaluación: prueba de abril 2021 a junio 2026, 63 meses, MAE y RMSE en viajeros, menor es mejor.

V8. Gráfico de barras Error por modelo con Modelos[Modelo] en el eje, Error seleccionado en valores y Metricas[Grupo] en leyenda (verde Lab 1, dorado LSTM).

V9. Gráfico de líneas Observado frente a predicho con Calendario[Fecha] en el eje y las medidas Observado (prueba), Predicción SeasonalNaive, Predicción SES y Predicción Prophet. Observado en verde y línea gruesa, los modelos en dorado, salvia y marrón con línea discontinua. Clic en una barra de V8 deja en V9 solo ese modelo.

V10. Gráfico de columnas agrupadas Error mensual por modelo con Calendario[Fecha], Error de predicción y Predicciones[Modelo] en leyenda. Una línea de referencia en cero.

V11. Gráfico de columnas agrupadas Mejor modelo del Lab 1 frente al mejor LSTM con Metricas[SerieNombre] filtrado a Total y Vía aérea, Metricas[Grupo] en leyenda, Mejor error del grupo en valores y Modelo del mejor error en información sobre herramientas. Este visual ignora el segmentador de serie (Editar interacciones > Ninguno).

V12. Gráfico de barras Series más y menos parecidas con Similitud[SerieNombre], Distancia media y Similitud[GrupoKMeans] en leyenda.

Tabla comparativa de todos los modelos con SerieNombre, Laboratorio, Modelo, MAE y RMSE, dentro de un marcador que se muestra con el botón **Ver tabla de modelos**. Cuadro de texto con las limitaciones copiadas del Lab 10.

**Detalle del año**

Página de obtención de detalles (drillthrough) con Calendario[Año] como campo. Botón Atrás arriba a la izquierda. Tarjetas de Total viajeros, Viajeros vía aérea y Participación aérea (%).

V13. Gráfico de columnas agrupadas con Mes, Total viajeros y Viajeros vía aérea.

Desde V2, V5 o V6 se llega con clic derecho > Obtener detalles > Detalle del año.

**Metodología**

Cuadros de texto con fuentes, glosario (MAE, RMSE, conjunto de prueba, vía aérea, catch22, KMeans) y limitaciones. Es la misma página de Metodología del Lab 10.

## Marcadores

Por cada página, con todos los filtros limpios, crear un marcador **Vista inicial [página]** con Datos y Visualización activados. El botón Restablecer vista de esa página apunta a su marcador. Además, un marcador **Tabla de modelos visible** y otro **Tabla de modelos oculta** en Predicciones.

## Comprobación antes de guardar

**1.** En Predicciones, poner MAE recalculado y RMSE recalculado en una tabla con Modelo. Deben dar 207,322 y 219,664 para SeasonalNaive, 165,370 y 180,596 para SES, y 132,305 y 139,549 para Prophet. Después se quita la tabla.

**2.** En Inicio, filtrar el año 2024. Total viajeros debe dar 3,274,436 y Viajeros vía aérea 1,143,353.

**3.** Guardar como `powerbi/Observatorio_Turismo_Sostenible.pbix` y anotar la versión de Power BI Desktop (Ayuda > Acerca de) en el README.
