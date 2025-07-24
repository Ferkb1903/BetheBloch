#!/bin/bash

# Script avanzado para extraer pérdidas de energía por proceso físico
# Energías hasta TeV para capturar pérdidas radiativas en muones

# Energías cinéticas en MeV (optimizadas para electrones)
# Los electrones muestran efectos radiativos a energías mucho menores que muones
ENERGIES=(
  # Región baja energía (comportamiento clásico)
  0.1 0.2 0.5 1 2 5 10 20 50
  # Región crítica (transición ionización→radiación)
  100 200 500 1000 2000 5000 
  # Región radiativa (bremsstrahlung dominante)
  10000 20000 50000 100000 200000 500000
  # Región extrema (1-1000 TeV)
  1000000 2000000 5000000 10000000 20000000 50000000 100000000 200000000 500000000 1000000000
)

TEMPLATE="template_detailed.mac"
TMPMAC="tmp_detailed.mac"
EXEC="./TestEm1"
CSV="electron_detailed_results.csv"

echo "Energy_MeV,Total_Deposit_MeV,Ionization_Loss,Radiative_Loss,Process_Info" > "$CSV"

# Contador para progreso
TOTAL=${#ENERGIES[@]}
CURRENT=0

echo "Iniciando análisis detallado de pérdidas de energía para ELECTRONES hasta PeV..."
echo "Rango: ${ENERGIES[0]} MeV - ${ENERGIES[-1]} MeV ($(echo "scale=1; ${ENERGIES[-1]}/1000000000" | bc -l) PeV)"
echo "¡Esperamos ver efectos radiativos dramáticos!"
echo "========================================="

for E in "${ENERGIES[@]}"; do
    CURRENT=$((CURRENT + 1))
    PERCENT=$((CURRENT * 100 / TOTAL))
    
    echo "[$CURRENT/$TOTAL - $PERCENT%] Procesando E = $E MeV ($(echo "scale=3; $E/1000000" | bc -l) TeV)..."
    
    # Generar macro temporal
    sed "s/__ENERGY__/$E/g" "$TEMPLATE" > "$TMPMAC"
    
    # Ejecutar simulación y capturar salida completa
    OUTPUT=$($EXEC "$TMPMAC" 2>&1)
    
    # Extraer energía total depositada
    TOTAL_DEPOSIT=$(echo "$OUTPUT" | grep "Total energy deposit:" | awk '{print $4}')
    DEPOSIT_UNIT=$(echo "$OUTPUT" | grep "Total energy deposit:" | awk '{print $5}')
    
    # Convertir a MeV si es necesario
    if [ "$DEPOSIT_UNIT" = "keV" ]; then
        TOTAL_DEPOSIT=$(echo "$TOTAL_DEPOSIT / 1000" | bc -l)
    fi
    
    # Buscar información específica sobre procesos físicos
    IONIZATION_INFO=$(echo "$OUTPUT" | grep -i "ionisation\|ioni\|eIoni" | head -1)
    BREMS_INFO=$(echo "$OUTPUT" | grep -i "brem\|eBrem" | head -1)
    PAIR_INFO=$(echo "$OUTPUT" | grep -i "pair\|ePair" | head -1)
    
    # Extraer valores numéricos de procesos específicos si están disponibles
    IONIZATION_LOSS="N/A"
    RADIATIVE_LOSS="N/A"
    
    # Buscar líneas que contengan información de pérdidas específicas
    ION_LINE=$(echo "$OUTPUT" | grep -i "ionisation.*loss\|ioni.*loss" | head -1)
    if [ ! -z "$ION_LINE" ]; then
        IONIZATION_LOSS=$(echo "$ION_LINE" | grep -o '[0-9.]\+\s*[kM]eV' | head -1)
    fi
    
    RAD_LINE=$(echo "$OUTPUT" | grep -i "brem.*loss\|radiative.*loss" | head -1)
    if [ ! -z "$RAD_LINE" ]; then
        RADIATIVE_LOSS=$(echo "$RAD_LINE" | grep -o '[0-9.]\+\s*[kM]eV' | head -1)
    fi
    
    # Información de procesos activos
    PROCESS_INFO=$(echo "$OUTPUT" | grep -i "process\|physics" | grep -v "verbose" | head -3 | tr '\n' ';')
    
    # Guardar en CSV
    echo "$E,$TOTAL_DEPOSIT,$IONIZATION_LOSS,$RADIATIVE_LOSS,\"$PROCESS_INFO\"" >> "$CSV"
    
    echo "     → Total depositado: $TOTAL_DEPOSIT MeV/mm"
    if [ "$IONIZATION_LOSS" != "N/A" ]; then
        echo "     → Pérdidas ionización: $IONIZATION_LOSS"
    fi
    if [ "$RADIATIVE_LOSS" != "N/A" ]; then
        echo "     → Pérdidas radiativas: $RADIATIVE_LOSS"
    fi
    
    # Para energías muy altas, mostrar información adicional
    if [ $E -gt 100000 ]; then
        echo "     → Información de procesos a alta energía:"
        echo "$OUTPUT" | grep -i "brem\|pair\|radiative" | head -2 | sed 's/^/       /'
    fi
done

echo "========================================="
echo "Análisis detallado completado!"
echo "Datos guardados en $CSV"
echo "Total de puntos procesados: $TOTAL"
echo "Rango final: ${ENERGIES[0]} MeV - ${ENERGIES[-1]} MeV"

# Verificar si se detectaron pérdidas radiativas
RAD_DETECTED=$(grep -v "N/A" "$CSV" | grep -v "Radiative_Loss" | wc -l)
if [ $RAD_DETECTED -gt 0 ]; then
    echo "¡Pérdidas radiativas detectadas en $RAD_DETECTED puntos!"
else
    echo "Nota: Puede ser necesario analizar la salida de Geant4 manualmente"
    echo "para extraer información específica sobre procesos radiativas."
fi

# Limpieza
rm -f "$TMPMAC"
