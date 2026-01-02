gcc c/gameOfLifeV1.c -o c/gameOfLifeV1
gcc -Ofast -march=native -mtune=native -funroll-loops -funroll-all-loops -flto \
    -fomit-frame-pointer -finline-functions \
    c/gameOfLifeV1.c -o c/gameOfLifeV1_optimized