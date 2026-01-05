gcc c/gameOfLifeV1.c -o c/gameOfLifeV1
gcc -Ofast -march=native -mtune=native -funroll-loops -funroll-all-loops -flto \
    -fomit-frame-pointer -finline-functions \
    c/gameOfLifeV1.c -o c/gameOfLifeV1_optimized
gcc -Ofast -march=native -mtune=native -funroll-loops -funroll-all-loops -flto \
    -fomit-frame-pointer -finline-functions \
    c/gameOfLifeBit_optimized.c -o c/gameOfLifeBit_optimized
gcc -Ofast -march=native -mtune=native -funroll-loops -funroll-all-loops -flto \
    -fomit-frame-pointer -finline-functions -mbmi -mbmi2 \
    c/gameOfLifeRyzen_optimized.c -o c/gameOfLifeRyzen_optimized
#java -cp java GameOfLifeV1 10 0000700000000000