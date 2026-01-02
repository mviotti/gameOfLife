public class GameOfLifeV1 {
    private boolean[][] board;
    private int rows;
    private int cols;

    public GameOfLifeV1(int rows, int cols, String values) {
        this.rows = rows;
        this.cols = cols;

        // Pad hex string to 16 characters (64 bits) by adding zeros to the RIGHT
        String hexPadded = String.format("%-16s", values).replace(' ', '0');

        // Convert hex to binary string (64 bits)
        long longValue = Long.parseUnsignedLong(hexPadded, 16);
        String binaryStr = String.format("%64s", Long.toBinaryString(longValue)).replace(' ', '0');

        // Create board from binary string
        this.board = new boolean[8][8];
        for (int i = 0; i < 8; i++) {
            for (int j = 0; j < 8; j++) {
                int index = i * 8 + j;
                this.board[i][j] = binaryStr.charAt(index) == '1';
            }
        }
    }

    public void print() {
        StringBuilder bits = new StringBuilder();
        for (int i = 0; i < this.rows; i++) {
            for (int j = 0; j < this.cols; j++) {
                bits.append(this.board[i][j] ? '1' : '0');
            }
        }

        long longValue = Long.parseUnsignedLong(bits.toString(), 2);
        String hexValue = String.format("%016X", longValue);
        System.out.println(hexValue);
    }

    public void iterate(boolean[][] nextBoard) {
        // Limpiar next_board
        for (int i = 0; i < this.rows; i++) {
            for (int j = 0; j < this.cols; j++) {
                nextBoard[i][j] = false;
            }
        }

        for (int i = 1; i < this.board.length - 1; i++) {
            for (int j = 1; j < this.board[i].length - 1; j++) {
                int num = calculateNeighbors(i, j);
                if (num == 3 || (num == 2 && this.board[i][j])) {
                    nextBoard[i][j] = true;
                } else {
                    nextBoard[i][j] = false;
                }
            }
        }
    }

    private int calculateNeighbors(int i, int j) {
        int count = 0;
        count += this.board[i-1][j-1] ? 1 : 0;
        count += this.board[i-1][j]   ? 1 : 0;
        count += this.board[i-1][j+1] ? 1 : 0;
        count += this.board[i][j-1]   ? 1 : 0;
        count += this.board[i][j+1]   ? 1 : 0;
        count += this.board[i+1][j-1] ? 1 : 0;
        count += this.board[i+1][j]   ? 1 : 0;
        count += this.board[i+1][j+1] ? 1 : 0;
        return count;
    }

    public void setBoard(boolean[][] newBoard) {
        this.board = newBoard;
    }

    public boolean[][] getBoard() {
        return this.board;
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Usage: java GameOfLifeV1 <param1> <param2>");
            System.exit(1);
        }

        int executions = Integer.parseInt(args[0]);
        String initialValue = args[1];
        int x = 8;
        int y = 8;

        GameOfLifeV1 game = new GameOfLifeV1(x, y, initialValue);
        boolean[][] nextBoard = new boolean[x][y];

        for (int i = 0; i < executions; i++) {
            game.iterate(nextBoard);
            // Swap
            boolean[][] temp = game.getBoard();
            game.setBoard(nextBoard);
            nextBoard = temp;
        }

        game.print();
    }
}
