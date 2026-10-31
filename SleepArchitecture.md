# SleepPulse — Arquitectura de Software y Especificación Técnica

## 1. Visión General del Sistema

**SleepPulse** es una solución nativa para iOS (iOS 17+) diseñada con los estándares más rigurosos de ingeniería de software biomédico. Su propósito es capturar, depurar, segmentar y analizar cronobiológicamente los datos de sueño registrados por el sensor photoplethysmography (PPG) y acelerómetros de **Apple Watch** sincronizados mediante **Apple HealthKit**.

```
┌────────────────────────────────────────────────────────┐
│                   Capa de Presentación                 │
│         SwiftUI + Swift Charts + Modern Concurrency    │
│  [DashboardView] [HypnogramView] [DetailViews 1..4]   │
└───────────────────────────▲────────────────────────────┘
                            │ (@MainActor, ViewModels)
┌───────────────────────────┴────────────────────────────┐
│                    Capa de Dominio                     │
│    SleepSession, SleepSample, SleepStage, SleepMetrics │
└───────────────────────────▲────────────────────────────┘
                            │ (Inyección de Dependencias)
┌───────────────────────────┴────────────────────────────┐
│               Capa de Analítica y Negocio              │
│  [SleepCalculator] [DynamicSleepNeed] [Aggregator]     │
└───────────────────────────▲────────────────────────────┘
                            │ (Protocolos Sendable)
┌───────────────────────────┴────────────────────────────┐
│                 Capa de Datos / Hardware               │
│   [HealthKitManager (HKHealthStore)] / [MockService]   │
└────────────────────────────────────────────────────────┘
```

---

## 2. Modelado Matemático y Algorítmico de Métricas

### 2.1. Rendimiento del Sueño (Sleep Performance)
El **Rendimiento del Sueño** no se evalúa respecto a una cifra genérica e inmutable de 8 horas, sino frente a la **Necesidad Dinámica** ($N_d$) que el cuerpo demanda en esa noche específica:

$$\text{Rendimiento} = \frac{\text{Duración Real Dormido}}{\text{Necesidad Dinámica de Sueño}} \times 100\%$$

Donde la **Necesidad Dinámica** ($N_d$) se computa como:
$$N_d = N_{\text{basal}} + (\text{Deuda Acumulada}_{14d} \times \alpha) + \Delta_{\text{esfuerzo}}$$

- $N_{\text{basal}}$: Necesidad genética/fisiológica de referencia (por defecto 8.0 horas).
- $\alpha$: Factor de amortización fisiológica nocturna ($\alpha \approx 0.22$). Un ser humano no puede recuperar 8 horas de deuda en una sola sesión sin generar fragmentación del sueño; por ello, la deuda se distribuye recuperando un 20–25% por noche.
- $\Delta_{\text{esfuerzo}}$: Demanda metabólica añadida por gasto físico o estrés diurno ($\approx 0.25\text{--}0.50\text{ h}$).

---

### 2.2. Eficiencia del Sueño (Sleep Efficiency)
Mide la capacidad de consolidación del descanso dentro del lecho. Permite diferenciar entre el tiempo de reposo pasivo y el sueño bioactivo real:

$$\text{Eficiencia} = \frac{\text{Tiempo Total Asleep (Profundo + Core + REM)}}{\text{Tiempo Total en Cama (InBed)}} \times 100\%$$

* **Criterio Clínico:**
  - $\ge 90\%$: **Óptimo**. Excelente latencia de sueño (adormecimiento en $<15\text{ min}$) y ausencia de vigilias prolongadas.
  - $85\% - 89\%$: **Bueno**. Leves despertares fisiológicos.
  - $<85\%$: **Atención requerida**. Sugiere hiperactivación nocturna, insomnio de mantenimiento o latencia elevada.

---

### 2.3. Consistencia Circadiana (Sleep Consistency)
Evalúa la regularidad cronobiológica de los horarios de inicio (hora de acostarse) y finalización (hora de despertar) a lo largo de una ventana móvil de los últimos 7 días.

Para evitar la discontinuidad horaria de la medianoche ($23:59 \to 00:01$), se realiza una proyección continua de minutos nocturnos:

$$T_{\text{continuo}} = \begin{cases} (h + 24) \times 60 + m & \text{si } h < 12 \\ h \times 60 + m & \text{si } h \ge 12 \end{cases}$$

Se calculan las desviaciones estándar muestrales:
- $\sigma_{\text{bed}}$: Desviación típica de hora de acostarse (en minutos).
- $\sigma_{\text{wake}}$: Desviación típica de hora de despertar (en minutos).

La puntuación normalizada de consistencia (0.0 a 1.0) se obtiene mediante:
$$\text{Consistencia} = \max\left(0, 1.0 - \frac{\sigma_{\text{bed}} + \sigma_{\text{wake}}}{2 \times 180}\right)$$

*Una desviación combinada de 0 minutos equivale al 100% de consistencia; una desviación de 30 minutos retiene $>90\%$.*

---

### 2.4. Deuda de Sueño (Sleep Debt - Ventana 14 Días)
La deuda de sueño no se mide en 24 horas, ya que la fatiga cognitiva y el deterioro inmune se acumulan a nivel sistémico en un horizonte temporal de dos semanas.

Para cada día $i \in \{1, 2, \dots, 14\}$:
$$\Delta_i = N_{\text{basal}} - \text{Dormido}_i$$

El modelo acumulativo con factor de decay metabólico ($\lambda \approx 0.97$) y tasa de compensación amortizada ($\beta = 0.50$ para noches con superávit de sueño) opera como:
$$\text{Deuda}_t = \left(\text{Deuda}_{t-1} + \Delta_t \cdot \mathbb{I}_{(\Delta_t > 0)} - |\Delta_t| \cdot \beta \cdot \mathbb{I}_{(\Delta_t \le 0)}\right) \times \lambda$$

---

## 3. Integración con Apple Watch y HealthKit

### 3.1. Tipos de Muestras e Identificadores
Se consultan muestras `HKCategorySample` con el identificador `HKCategoryTypeIdentifier.sleepAnalysis`:

| Identificador HealthKit (`HKCategoryValueSleepAnalysis`) | Fase en SleepPulse | Profundidad (Eje Y) | Color de Visualización |
| :--- | :--- | :---: | :--- |
| `asleepDeep` (Valor 4) | **Profundo** | Nivel 1 | Azul Marino (`#2640A6`) |
| `asleepCore` (Valor 3) | **Esencial / Core** | Nivel 2 | Azul Celeste (`#408CF2`) |
| `asleepREM` (Valor 5) | **REM** | Nivel 3 | Violeta Eléctrico (`#8C59F2`) |
| `awake` (Valor 2) | **Despierto** | Nivel 4 | Naranja Coral (`#F27359`) |
| `inBed` (Valor 0) | **En Cama** | Base Envolvente | Gris Neutro |

### 3.2. Agrupación y Detección de Límites de Sesión
Dado que el Apple Watch divide la noche en decenas de microintervalos de fases de sueño (cada uno de 5 a 45 minutos), `HealthKitManager` aplica un algoritmo de agregación con umbral de separación de 3 horas ($\Delta t_{\text{gap}} = 10\,800\text{ s}$). Si entre dos muestras consecutivas transcurren más de 3 horas, se segmentan como sesiones de descanso independientes.

---

## 4. Visualización del Hipnograma (Depth of Sleep Chart)

La pantalla de profundidad implementa `Swift Charts` de iOS 17 con las siguientes características:
1. **Representación Escalonada de Profundidad:** El eje Y mapea de 1 a 4, situando el sueño profundo en la base física y los despertares en la cumbre.
2. **Capas Duales (BarMark + AreaMark):** Combinan tramos rectangulares exactos con un área bajo la curva coloreada por fase.
3. **Scrubbing Táctil Interactivo:** Mediante `chartOverlay` y un `DragGesture(minimumDistance: 0)`, el usuario puede deslizar su dedo a lo largo de cualquier punto de la noche para inspeccionar la fase exacta, hora y duración sin latencia.
4. **Composición Apilada:** Barra geométrica continua que muestra la proporción relativa respecto a las metas saludables (15–25% Profundo, 20–25% REM, 45–60% Core).

---

## 5. Agregación Multitemporal (Día, Semana, Mes, Año)

`SleepPeriodAggregator` computa de forma eficiente estadísticas para los 4 horizontes requeridos:
- **Diario:** Análisis micro del hipnograma, duración por fase, pulso cardíaco y métricas de la última noche.
- **Semanal:** Barras apiladas de fases por día (L, M, X, J, V, S, D), medias móviles de consistencia y línea umbral de 8 horas.
- **Mensual:** Análisis de 30 días con visualización de tendencias de rendimiento y variabilidad de eficiencia.
- **Anual:** Agrupación en 12 cubos mensuales (Ene - Dic) para detectar patrones estacionales, deuda crónica y distribución media anual.

---

## 6. Privacidad y Directrices de Apple (App Store Review)

De acuerdo con las **Apple HealthKit Human Interface Guidelines** y la sección 5.1.3 del App Store Review:
1. **Entitlements:** Se declaran explícitamente `NSHealthShareUsageDescription` y `NSHealthUpdateUsageDescription` en el `Info.plist`.
2. **No Publicidad:** Los datos biométricos de HealthKit se procesan 100% en el dispositivo (`on-device analytics`) y nunca se comercializan ni transmiten a redes de terceros.
3. **Resiliencia en Simulador:** Incorpora `MockHealthKitService` con generador sintético de ciclos ultradianos (90 min) para permitir revisiones de Apple y pruebas sin necesidad de vincular un Apple Watch físico.
