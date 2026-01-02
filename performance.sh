#!/bin/bash
. ./compile.sh
# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parámetros del test
GENERATIONS=1000000
INITIAL_STATE="0006066060181800"

echo "========================================"
echo "  Game of Life - Performance Test 1M Generations"
echo "========================================"
echo ""

# Array de implementaciones: "nombre;comando"
IMPLEMENTATIONS=(
#    "Python V1;python ./python/gameOfLifeV1.py"
    "C V1;c/gameOfLifeV1.exe"
    "C Optimized;c/gameOfLifeV1_optimized.exe"
    "C Ryzen Optimized;c/gameOfLifeRyzen_optimized.exe"
    "Java V1;java -cp java GameOfLifeV1"
)

# Función para ejecutar y medir tiempo
run_benchmark() {
    local name=$1
    local command=$2

    echo -e "${BLUE}Testing: ${name}${NC}"
    echo "Command: $command $GENERATIONS $INITIAL_STATE"
    echo ""

    # Ejecutar con time y capturar el tiempo
    START=$(date +%s.%N)
    output=$($command $GENERATIONS $INITIAL_STATE 2>&1)
    END=$(date +%s.%N)

    # Calcular tiempo transcurrido (usando awk en lugar de bc)
    ELAPSED=$(awk "BEGIN {print $END - $START}")
    echo -e "${GREEN}Time: ${ELAPSED} seconds${NC}"
    echo "----------------------------------------"
    echo ""

    # Guardar resultado para el resumen
    RESULTS+=("$name:$ELAPSED")
}

# Array para guardar resultados
RESULTS=()

# Ejecutar cada implementación
for impl in "${IMPLEMENTATIONS[@]}"; do
    IFS=';' read -r name command <<< "$impl"
    run_benchmark "$name" "$command"
done

# Mostrar resumen final
echo "========================================"
echo "  PERFORMANCE SUMMARY"
echo "========================================"
echo ""
printf "%-20s | %s\n" "Implementation" "Time (seconds)"
echo "----------------------------------------"

for result in "${RESULTS[@]}"; do
    IFS=':' read -r name time <<< "$result"
    printf "%-20s | %s\n" "$name" "$time"
done

echo "========================================"
