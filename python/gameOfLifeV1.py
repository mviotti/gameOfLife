from utils import *

class GameOfLifeV1:
    board = None
    rows = None
    cols = None

    def __init__(self, rows, cols, values):
        # Initialize a matrix with all values set to False
        self.rows = int(rows)
        self.cols = int(cols)
        self.board = [[False for _ in range(self.cols + 2)] for _ in range(self.rows + 2)]
        
        # Fill the inner part of the matrix with the given values
        boolean_values = [char == '1' for char in values]
        index = 0
        for i in range(1, self.rows + 1):
            for j in range(1, self.cols + 1):
                self.board[i][j] = boolean_values[index]
                index += 1


    def print(self):
        # Method to print the matrix
        for row in self.board:
            for value in row:
                print('X' if value else '-', end=' ')
            print()  # New line after each row

    def iterate(self):
        newboard = [[False for _ in range(self.cols + 2)] for _ in range(self.rows + 2)]

        for i in range(0, len(self.board)-1):
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