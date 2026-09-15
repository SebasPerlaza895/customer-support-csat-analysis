# Dashboard Power BI — CSAT

Plan y guía para construir el dashboard en Power BI Desktop a partir de
`powerbi/data/clean_customer_support.csv` (generado con
`python/export_for_powerbi.py`).

## 1. Conectar los datos

1. Abre Power BI Desktop → **Obtener datos → Texto/CSV**
2. Selecciona `powerbi/data/clean_customer_support.csv`
3. En el editor de Power Query, revisa los tipos de columna:
   - `order_date_time`, `issue_reported_at`, `issue_responded`,
     `survey_response_date` → cambia el tipo a **Fecha/Hora**
   - `csat_score`, `item_price`, `connected_handling_time` → **Número entero/decimal**
   - El resto → **Texto**
4. **Cerrar y aplicar**

## 2. Medidas DAX

Crea estas medidas sobre la tabla `clean_customer_support`:

```dax
Total Interacciones = COUNTROWS(clean_customer_support)

CSAT Promedio = AVERAGE(clean_customer_support[csat_score])

% Satisfechos (CSAT >= 4) =
DIVIDE(
    CALCULATE(COUNTROWS(clean_customer_support), clean_customer_support[csat_score] >= 4),
    [Total Interacciones]
)

% Insatisfechos (CSAT <= 2) =
DIVIDE(
    CALCULATE(COUNTROWS(clean_customer_support), clean_customer_support[csat_score] <= 2),
    [Total Interacciones]
)
```

> **Nota sobre `connected_handling_time`**: esta columna viene vacía en el
> 99.7% de las filas (solo 242 de 85,907 tienen valor, sin concentrarse en
> ningún canal o categoría en particular). No hay suficiente cobertura para
> usarla como KPI — un promedio ahí sería engañoso. Por eso no se incluye
> en el dashboard; si Power Query te la muestra en blanco al convertirla a
> Número, es el comportamiento correcto, no un error de conversión.

## 3. Página 1 — Overview

**Tarjetas KPI** (arriba, en fila):
- `Total Interacciones` → 85,907
- `CSAT Promedio` → 4.24
- `% Satisfechos (CSAT >= 4)` → 82.5%
- `% Insatisfechos (CSAT <= 2)` → 14.6%

**Visuales:**
- Barras horizontales: `CSAT Promedio` por `channel_name` (Email queda visiblemente por debajo)
- Barras horizontales: `CSAT Promedio` por `category` (ordenado descendente)
- Línea/área: `CSAT Promedio` por día (`survey_response_date`) — para ver si hay caídas puntuales
- Segmentadores (slicers) arriba o a la izquierda: `channel_name`, `category`, `agent_shift`, `tenure_bucket`

## 4. Página 2 — Desempeño de agentes

- **Tabla**: `agent_name`, `supervisor`, `manager`, `Total Interacciones`,
  `CSAT Promedio` — ordenada ascendente por CSAT (para ver primero a quién
  hay que apoyar). Filtra a agentes con al menos 30 casos para que el
  promedio sea confiable.
- Barras: `CSAT Promedio` por `tenure_bucket` (agentes en training rinden
  peor: 4.15 vs. 4.35 en 61-90 días)
- Barras: `CSAT Promedio` por `agent_shift` (turno mañana es el más débil:
  4.19, y concentra ~48% del volumen)
- Matriz (heatmap): `agent_shift` (filas) x `tenure_bucket` (columnas),
  valor = `CSAT Promedio`

## 5. Hallazgo a destacar en el dashboard

Al filtrar la tabla de agentes por CSAT ascendente, varios de los peores
agentes reportan al **mismo supervisor** (ej. "Zoe Yamamoto" aparece en 3
de los 5 agentes con peor CSAT, con 30+ casos cada uno). Vale la pena
agregar una tarjeta o texto destacando esto: sugiere un problema de
**coaching a nivel de supervisor**, no solo de agentes individuales — es
justo el tipo de insight que un dashboard de BI debe sacar a la luz.

## 6. Guardar y subir al repo

Guarda el archivo como `powerbi/csat_dashboard.pbix` y avísame — te ayudo
a hacer el commit y push a GitHub (los `.pbix` son binarios, así que no
puedo generarlos ni editarlos yo directamente, pero sí los subo por ti).
