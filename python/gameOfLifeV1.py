from utils import *
import sys

class GameOfLifeV1:
    board = None
    rows = None
    cols = None

    def __init__(self, rows, cols, values):
        # Initialize a matrix with all values set to False
        self.rows = int(rows)
        self.cols = int(cols)

        # Pad hex string to 16 characters (64 bits) by adding zeros to the RIGHT
        hex_padded = values.ljust(16, '0')
        _values = int(hex_padded, 16)
        binary_str = format(_values, '064b')

        # Create board from binary string (reverse bits within each byte)
        self.board = []
        for i in range(8):
            byte_bits = binary_str[i*8:(i+1)*8]
            reversed_bits = byte_bits[::-1]  # Reverse bits within this byte
            row = [bit == '1' for bit in reversed_bits]
            self.board.append(row)


    def print(self):
        # Reverse bits within each byte when converting back to hex
        bits_by_row = []
        for row in self.board:
            row_bits = "".join(str(int(b)) for b in row)
            reversed_row_bits = row_bits[::-1]  # Reverse bits within this byte
            bits_by_row.append(reversed_row_bits)
        bits = "".join(bits_by_row)
        hex_value = f"{int(bits, 2):016X}"
        print(hex_value)

    def iterate(self):
        newboard = [[False for _ in range(self.cols)] for _ in range(self.rows)]

        for i in range(1, len(self.board)-1):
            for j in range(1, len(self.board[i])-1):
                num = self.calculateNeighbors(i, j)
                if num == 3 or (num == 2 and self.board[i][j]):
                    newboard[i][j] = True
                else:
                    newboard[i][j] = False

        self.board = newboard

    def calculateNeighbors(self, i, j):
        return (self.board[i-1][j-1] + self.board[i-1][j] + self.board[i-1][j+1] 
              + self.board[i][j-1]                        + self.board[i][j+1] 
              + self.board[i+1][j-1] + self.board[i+1][j] + self.board[i+1][j+1])
    

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python main.py <param1> <param2>")
        sys.exit(1)
    
    executions = int(sys.argv[1])
    initialvalue = sys.argv[2]
    x = 8
    y = 8

    game = GameOfLifeV1(x, y, initialvalue)
    for i in range(executions):
        game.iterate()
    game.print()