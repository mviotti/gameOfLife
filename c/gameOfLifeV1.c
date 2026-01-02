#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

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

int get_cell(uint8_t *board, int row, int col) {
    if (row < 0 || row >= 8 || col < 0 || col >= 8) {
        return 0;
    }
    int bit_position = col;
    return (board[row] >> bit_position) & 1;
}

int count_neighbors(uint8_t *board, int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue; 
            count += get_cell(board, row + dr, col + dc);
        }
    }
    return count;
}

void evolve(uint8_t *board, uint8_t *next_board) {
    for (int row = 1; row < 7; row++) {
        next_board[row] = 0; 

        for (int col = 1; col < 7; col++) {
            int alive = get_cell(board, row, col);
            int neighbors = count_neighbors(board, row, col);

            int next_alive = 0;
            if (alive && (neighbors == 2 || neighbors == 3)) {
                next_alive = 1;
            } else if (!alive && neighbors == 3) {
                next_alive = 1;
            }
            
            if (next_alive) {
                next_board[row] |= (1 << col);
            }
        }
    }
}

// Imprime el tablero como hexadecimal
void print_board_hex(uint8_t *board) {
    for (int i = 0; i < 8; i++) {
        printf("%02X", board[i]);
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

    uint8_t board[8];
    if (parse_hex_to_bytes(argv[2], board) != 0) {
        return 1;
    }

    // Ejecutar el Game of Life por el número de generaciones especificado
    uint8_t next_board[8];
    for (int gen = 0; gen < generations; gen++) {
        evolve(board, next_board);
        // Copiar next_board a board para la siguiente iteración
        memcpy(board, next_board, 8);
    }

    // Imprimir el estado final
    print_board_hex(board);

    return 0;
}
