import sys
import time

from gameOfLifeV1 import GameOfLifeV1
PRINT = False
def main():
    # Check if the correct number of arguments are provided
    if len(sys.argv) != 5:
        print("Usage: python main.py <param1> <param2> <param3>")
        sys.exit(1)
    
    # Retrieve command line arguments
    executions = int(sys.argv[1])
    x = int(sys.argv[2])
    y = int(sys.argv[3])
    initialvalue = sys.argv[4]
    
    # Print the parameters
    print(f"Executions: {executions}")
    print(f"X: {x}")
    print(f"Y: {y}")
    print(f"Initial Value: {initialvalue}")

    # Initialize game of life
    game = GameOfLifeV1(x, y, initialvalue)
    game.print()

    # Run
    
    start_time = time.time()
    for i in range(executions):
        game.iterate()
        if(PRINT):
            print("iteration " + str(i))
            game.print()

    end_time = time.time()
    elapsed_time = end_time - start_time
    print("Last status:")
    game.print()
    print(f"Time: {elapsed_time}")





if __name__ == "__main__":
    main()