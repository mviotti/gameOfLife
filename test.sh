#!/bin/bash
./compile.sh

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ejecutables a probar
EXECUTABLES=(
    "python ./python/gameOfLifeV1.py"
    "c\gameOfLifeV1.exe"
)

# Casos de test: generaciones, input, expected_output
TEST_CASES=(
    "1 0000700000000000 0020202000000000"
    "10 0000700000000000 0000700000000000"
    "1 000030300C0C0000 00003020040C0000"
    "2 000030300C0C0000 000030300C0C0000"
    "10 000030300C0C0000 000030300C0C0000"
    "1 0010503000000000 0020183000000000"
    "2 0010503000000000 0010083800000000"
    "3 0010503000000000 0000281810000000"
    "4 0010503000000000 0000082818000000"
    "5 0010503000000000 0000100C18000000"
    "6 0010503000000000 000008041C000000"
    "7 0010503000000000 000000140C080000"
    "8 0010503000000000 00000004140C0000"
    "9 0010503000000000 00000008060C0000"
    "10 0010503000000000 00000004020E0000"
    "11 0010503000000000 000000000A060400"
    "12 0010503000000000 00000000020A0600"
    "13 0010503000000000 0000000004020600"
)

total_tests=0
passed_tests=0
failed_tests=0

echo "========================================"
echo "  Game of Life - Integration Tests"
echo "========================================"
echo ""

# Iterar sobre cada ejecutable
for executable in "${EXECUTABLES[@]}"; do
    echo -e "${BLUE}Testing: ${executable}${NC}"
    echo "----------------------------------------"

    exe_passed=0
    exe_failed=0

    # Iterar sobre cada caso de test
    for test_case in "${TEST_CASES[@]}"; do
        # Separar los parámetros del caso de test
        read -r generations input expected <<< "$test_case"

        total_tests=$((total_tests + 1))

        # Ejecutar el test
        output=$($executable $generations $input 2>&1)

        # Validar la salida
        if echo "$output" | grep -qx "$expected"; then
            echo -e "${GREEN}✓${NC} Passed: gen=$generations, input=$input"
            passed_tests=$((passed_tests + 1))
            exe_passed=$((exe_passed + 1))
        else
            echo -e "${RED}✗${NC} Failed: gen=$generations, input=$input"
            echo "   Expected: $expected"
            echo "   Got:      $output"
            failed_tests=$((failed_tests + 1))
            exe_failed=$((exe_failed + 1))
        fi
    done

    echo ""
    echo "Results for ${executable}:"
    echo "  Passed: $exe_passed"
    echo "  Failed: $exe_failed"
    echo ""
    echo "========================================"
    echo ""
done

# Resumen final
echo "========================================"
echo "  FINAL RESULTS"
echo "========================================"
echo "Total tests:  $total_tests"
echo -e "${GREEN}Passed:       $passed_tests${NC}"
echo -e "${RED}Failed:       $failed_tests${NC}"
echo "========================================"

# Exit code basado en si todos los tests pasaron
if [ $failed_tests -eq 0 ]; then
    exit 0
else
    exit 1
fi
