// RutaDatos (parámetro de texto). Cambiarlo a la carpeta datos del repositorio, terminando en barra invertida.
"C:\lab12_DS\datos\" meta [IsParameterQuery = true, Type = "Text", IsParameterQueryRequired = true]


// LeerCsv
(archivo as text) as table =>
let
    Origen = Csv.Document(File.Contents(RutaDatos & archivo), [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Encabezados = Table.PromoteHeaders(Origen, [PromoteAllScalars = true])
in
    Encabezados


// Viajeros
let
    Total = Table.TransformColumnTypes(LeerCsv("serie_total_mensual.csv"), {{"Fecha", type date}, {"Viajero", type number}}, "en-US"),
    Aerea = Table.Distinct(
        Table.TransformColumnTypes(
            Table.Combine({LeerCsv("train_via_aerea_mensual.csv"), LeerCsv("test_via_aerea_mensual.csv")}),
            {{"Fecha", type date}, {"Viajero", type number}}, "en-US"),
        {"Fecha"}),
    Union = Table.NestedJoin(Total, {"Fecha"}, Aerea, {"Fecha"}, "Aerea", JoinKind.Inner),
    Expandida = Table.ExpandTableColumn(Union, "Aerea", {"Viajero"}, {"ViajerosAerea"}),
    Renombrada = Table.RenameColumns(Expandida, {{"Viajero", "ViajerosTotal"}}),
    Tipos = Table.TransformColumnTypes(Renombrada, {{"ViajerosAerea", type number}}),
    SinVacios = Table.SelectRows(Tipos, each [Fecha] <> null and [ViajerosTotal] <> null and [ViajerosAerea] <> null),
    Ordenada = Table.Sort(SinVacios, {{"Fecha", Order.Ascending}})
in
    Ordenada


// Calendario
let
    Meses = {"Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"},
    Fechas = Table.SelectColumns(Viajeros, {"Fecha"}),
    Anio = Table.AddColumn(Fechas, "Año", each Date.Year([Fecha]), Int64.Type),
    MesNum = Table.AddColumn(Anio, "MesNum", each Date.Month([Fecha]), Int64.Type),
    Mes = Table.AddColumn(MesNum, "Mes", each Meses{[MesNum] - 1}, type text),
    Trimestre = Table.AddColumn(Mes, "Trimestre", each "T" & Text.From(Date.QuarterOfYear([Fecha])), type text),
    AnioMes = Table.AddColumn(Trimestre, "AñoMes", each Date.ToText([Fecha], "yyyy-MM"), type text),
    Indice = Table.AddColumn(AnioMes, "IndiceMes", each [Año] * 12 + [MesNum], Int64.Type)
in
    Indice


// Metricas
let
    Origen = LeerCsv("metricas_modelos.csv"),
    Tipos = Table.TransformColumnTypes(Origen, {{"MAE", type number}, {"RMSE", type number}}, "en-US"),
    Validas = Table.SelectRows(Tipos, each [RMSE] <> null and not Number.IsNaN([RMSE])),
    Nombres = Table.AddColumn(Validas, "SerieNombre", each Record.FieldOrDefault([
        #"Total" = "Total", #"Via_Aérea" = "Vía aérea", #"Via_Terrestre" = "Vía terrestre", #"Via_Marítima" = "Vía marítima",
        #"Reg_América Del Centro" = "Región Centroamérica", #"Reg_América Del Norte" = "Región Norteamérica", #"Reg_Europa" = "Región Europa"
    ], [Serie], [Serie]), type text),
    Grupo = Table.AddColumn(Nombres, "Grupo", each if [Laboratorio] = "Lab2" then "LSTM (Lab 2)" else "Series de tiempo (Lab 1)", type text)
in
    Grupo


// Predicciones
let
    Origen = LeerCsv("predicciones_modelos.csv"),
    Tipos = Table.TransformColumnTypes(Origen, {{"Fecha", type date}, {"Observado", type number}, {"Predicho", type number}, {"Error", type number}}, "en-US")
in
    Tipos


// Modelos
let
    Nombres = Table.Distinct(Table.SelectColumns(Metricas, {"Modelo", "Laboratorio"}), {"Modelo"}),
    ConPrediccion = Table.AddColumn(Nombres, "TienePredicciones", each List.Contains(List.Distinct(Predicciones[Modelo]), [Modelo]), type logical)
in
    ConPrediccion


// Similitud
let
    Origen = LeerCsv("similitud_series.csv"),
    Tipos = Table.TransformColumnTypes(Origen, {{"DistanciaMedia", type number}, {"Grupo", Int64.Type}}, "en-US"),
    Nombres = Table.AddColumn(Tipos, "SerieNombre", each Record.FieldOrDefault([
        #"Total" = "Total", #"Via_Aérea" = "Vía aérea", #"Via_Terrestre" = "Vía terrestre", #"Via_Marítima" = "Vía marítima",
        #"Reg_América Del Centro" = "Región Centroamérica", #"Reg_América Del Norte" = "Región Norteamérica", #"Reg_Europa" = "Región Europa"
    ], [Serie], [Serie]), type text),
    Etiqueta = Table.AddColumn(Nombres, "GrupoKMeans", each "Grupo " & Text.From([Grupo]), type text)
in
    Etiqueta
