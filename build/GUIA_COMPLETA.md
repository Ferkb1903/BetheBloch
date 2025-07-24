# GUÍA COMPLETA: Simulación de Bethe-Bloch con Geant4
## Proyecto: Pérdidas de energía de muones en cobre (1 MeV - 1 PeV)

### 📁 ARCHIVOS CLAVE

#### 1. SIMULACIÓN PRINCIPAL
- `TestEm1` - Ejecutable de Geant4 compilado
- `template_detailed.mac` - Plantilla de configuración para Geant4
- `run_detailed_analysis.sh` - Script principal de simulación
- `detailed_results.csv` - Datos de la simulación (24 puntos)

#### 2. ANÁLISIS Y VISUALIZACIÓN
- `final_muon_analysis.py` - **SCRIPT PRINCIPAL DE ANÁLISIS** 📊
- `muon_bethe_bloch_final_analysis.png/pdf` - Gráficos principales (4 paneles)
- `muon_minimum_high_resolution.png/pdf` - Zoom del mínimo

### 🚀 CÓMO USAR EL PROYECTO

#### EJECUTAR NUEVA SIMULACIÓN:
```bash
cd /home/ferna/fer/TestEm1/build
./run_detailed_analysis.sh
```

#### ANALIZAR DATOS EXISTENTES:
```bash
cd /home/ferna/fer/TestEm1/build
python3 final_muon_analysis.py
```

#### MODIFICAR ENERGÍAS DE SIMULACIÓN:
Editar el array ENERGIES en `run_detailed_analysis.sh` (líneas 8-17)

### 📊 RESULTADOS PRINCIPALES

#### CARACTERÍSTICAS DEL MÍNIMO:
- **Energía**: 500 MeV (0.5 GeV)
- **Pérdida mínima**: 1.167 MeV/mm
- **Velocidad**: β = 0.985c
- **Factor relativístico**: γ = 5.73

#### REGIONES ANALIZADAS:
1. **No-relativística** (1-100 MeV): Comportamiento 1/β²
2. **Relativística** (100-10000 MeV): Región del mínimo
3. **Ultra-relativística** (10 GeV - 1 PeV): Aumento logarítmico

### 🔧 PERSONALIZACIÓN

#### CAMBIAR MATERIAL:
En `template_detailed.mac`, línea 10:
```
/testem/det/setMat G4_Cu    # Cambiar por G4_Al, G4_Fe, etc.
```

#### CAMBIAR PARTÍCULA:
En `template_detailed.mac`, línea 21:
```
/gun/particle mu+    # Cambiar por e-, pi+, etc.
```

#### CAMBIAR GEOMETRÍA:
En `template_detailed.mac`, línea 11:
```
/testem/det/setSize 1 mm    # Cambiar espesor
```

#### MODIFICAR ESTADÍSTICA:
En `template_detailed.mac`, línea 32:
```
/run/beamOn 50000    # Cambiar número de eventos
```

### 📈 INTERPRETACIÓN DE GRÁFICOS

#### Panel Superior Izquierdo:
- **Curva completa** (1 MeV - 1 PeV)
- **Puntos azules**: Datos simulados
- **Línea azul**: Interpolación suave
- **Línea roja**: Teoría de Bethe-Bloch

#### Panel Superior Derecho:
- **Región del mínimo** (100-5000 MeV)
- **Punto rojo**: Mínimo exacto
- **Líneas discontinuas**: Referencias

#### Panel Inferior Izquierdo:
- **Región ultra-relativística** (>1 GeV)
- **Sub-regiones coloreadas**: Diferentes tendencias
- **Líneas discontinuas**: Ajustes energéticos

#### Panel Inferior Derecho:
- **Ratio vs mínimo** (normalizado)
- **Regiones sombreadas**: Diferentes regímenes físicos
- **Puntos marcados**: Energías características

### 🛠️ RESOLUCIÓN DE PROBLEMAS

#### Error "template not found":
```bash
# Verificar que existe:
ls -la template_detailed.mac

# Si no existe, copiar desde el original:
cp ../template.mac template_detailed.mac
```

#### Error "TestEm1 not found":
```bash
# Recompilar:
make clean
make

# O usar ruta completa:
./TestEm1 template_detailed.mac
```

#### Datos NaN en resultados:
- Verificar que la simulación terminó correctamente
- Revisar el log de Geant4 para errores
- Aumentar estadística (más eventos)

### 📂 ESTRUCTURA DE DATOS

#### Formato de detailed_results.csv:
```
Energy_MeV,Total_Deposit_MeV,Ionization_Loss,Radiative_Loss,Process_Info
1,1.4847,N/A,N/A,"Physics info..."
2,2.5513,N/A,N/A,"Physics info..."
...
```

#### Significado de columnas:
- **Energy_MeV**: Energía cinética del muón
- **Total_Deposit_MeV**: Pérdida de energía total por mm
- **Ionization_Loss**: Pérdidas por ionización (si disponible)
- **Radiative_Loss**: Pérdidas radiativas (si disponible)
- **Process_Info**: Información de procesos físicos

### 🔬 FÍSICA IMPLEMENTADA

#### Procesos incluidos:
- **Ionización** (muIoni): Proceso dominante
- **Bremsstrahlung** (muBrems): Despreciable para muones
- **Producción de pares** (muPairProd): Threshold ~211 MeV
- **Scattering múltiple**: Efectos angulares

#### Lista de física:
- **emstandard_opt4**: Física electromagnética de alta precisión
- **Cortes de producción**: 0.1 mm
- **Modelos**: Bethe-Bloch con correcciones relativísticas

### 📋 COMANDOS ÚTILES

#### Verificar compilación:
```bash
ldd TestEm1  # Ver dependencias
./TestEm1 --help  # Ver opciones
```

#### Monitorear simulación:
```bash
tail -f detailed_output.txt  # Ver progreso en tiempo real
```

#### Análisis rápido:
```bash
# Contar puntos válidos:
grep -v "NaN" detailed_results.csv | wc -l

# Ver energías procesadas:
cut -d',' -f1 detailed_results.csv | tail -n +2
```

### 🎯 PRÓXIMOS PASOS SUGERIDOS

#### Extensiones posibles:
1. **Otros materiales**: Al, Fe, Pb, aire
2. **Otras partículas**: e-, π±, p, K±
3. **Diferentes geometrías**: Cilindros, esferas
4. **Campos magnéticos**: Efectos de curvatura
5. **Materiales compuestos**: Mezclas, aleaciones

#### Análisis avanzados:
1. **Funciones de respuesta**: Resolución energética
2. **Efectos angulares**: Scattering múltiple
3. **Comparación experimental**: Datos de laboratorio
4. **Optimización detectores**: Resolución vs espesor

### 📞 REFERENCIA RÁPIDA

#### Archivos más importantes:
1. `final_muon_analysis.py` - **ANÁLISIS COMPLETO**
2. `detailed_results.csv` - **DATOS PRINCIPALES**
3. `template_detailed.mac` - **CONFIGURACIÓN GEANT4**
4. `run_detailed_analysis.sh` - **AUTOMATIZACIÓN**

#### Comandos esenciales:
```bash
# Ejecutar análisis:
python3 final_muon_analysis.py

# Nueva simulación:
./run_detailed_analysis.sh

# Verificar datos:
head detailed_results.csv
```

---
**¡Ya tienes todo lo necesario para trabajar independientemente!** 🎉

Los gráficos que más te gustaron fueron generados por `final_muon_analysis.py` usando los datos de `detailed_results.csv`. Puedes modificar ese script Python para personalizar los análisis según tus necesidades.
