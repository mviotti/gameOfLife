#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <immintrin.h>  // Para AVX/AVX2
#include <x86intrin.h>  // Para BMI1/BMI2, POPCNT, LZCNT


int hex_char_to_int(char c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

int parse_hex_to_bytes(const char *hex_string, uint8_t *bytes) {
    if (strlen(hex_string) != 16) {
        return -1;
    }

    for (int i = 0; i < 8; i++) {
        int high = hex_char_to_int(hex_string[i * 2]);
        int low = hex_char_to_int(hex_string[i * 2 + 1]);

        if (high == -1 || low == -1) {
            return -1;
        }

        bytes[i] = (high << 4) | low;
    }

    return 0;
}

int get_cell(uint64_t board, int row, int col) {
    int position = row * 8 + col;
    if (position < 8 || position > 54) {
        return 0;
    }
    return (board >> (63-position)) & 1;
}

int count_neighbors(uint64_t board, int row, int col) {
    int position = row * 8 + col;
    if (position < 8 || position > 54) {
        return 0;
    }

    uint64_t mask = 0xE0A0E00000000000 >> (position - 9);
    int count = _popcnt64(board & mask); 
    return count;
}

void evolve(uint64_t board, uint64_t *next_board) {
    *next_board = 0;
    for (int row = 1; row < 7; row++) {
        for (int col = 1; col < 7; col++) {
            int alive = get_cell(board, row, col);
            int neighbors = count_neighbors(board, row, col);

            if (neighbors == 3 || alive && neighbors == 2) {
                int position = row * 8 + col;
                *next_board |= (1ULL << (63 - position));
            }
        }
    }
}

// Imprime el tablero como hexadecimal
void print_board_hex(uint64_t board) {
    for (int i = 0; i < 8; i++) {
        printf("%02X", (board >> (i * 8)) & 0xFF);
    }
    printf("\n");
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <generaciones> <estado_hex>\n", argv[0]);
        fprintf(stderr, "Example: %s 10 0000700000000000\n", argv[0]);
        return 1;
    }

    char *endptr;
    int generations = strtol(argv[1], &endptr, 10);

    if (*endptr != '\0' || generations < 0) {
        return 1;
    }

    uint8_t old_board[8];
    if (parse_hex_to_bytes(argv[2], old_board) != 0) {
        return 1;
    }

    uint64_t next_board = 0;
    uint64_t board = *(uint64_t*)old_board; 

    for (int gen = 0; gen < generations; gen++) {
        evolve(board, &next_board);
        board = next_board;
    }

    print_board_hex(board);

    return 0;
}
