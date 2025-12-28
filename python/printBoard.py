import sys

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python printBoard.py <hex_value>")
        sys.exit(1)

    hexBoard = sys.argv[1]
    x = 8
    y = 8

    # Pad hex string to 16 characters (64 bits) by adding zeros to the RIGHT
    hex_padded = hexBoard.ljust(16, '0')
    _values = int(hex_padded, 16)
    binary_str = format(_values, '064b')

    # Create board from binary string (reverse bits within each byte)
    board = []
    for i in range(8):
        byte_bits = binary_str[i*8:(i+1)*8]
        row = [bit == '1' for bit in byte_bits]
        board.append(row)

    # Print the board with X for True/1 and - for False/0
    for row in board:
        print(' '.join('X' if cell else '-' for cell in row))
