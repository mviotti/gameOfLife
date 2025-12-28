# gameOfLife
Implementation of the Game of Life in different languages to measure performance and try diffrent types of optimization

Each implementation should receive as a fist parameter the number of steps to execute, and the "board" in hexadecimal format as a second parameter, having 0 for death cell and 1 for live cell. The output of the execution will be the last tatus of the board.

All implementations will be handle an 8x8 board. This size was decided in order to perform Byte level optimizations. Also a 64x64 could be implemented in the future.
To simplify the code even more, the usable board will be de 6x6 region of the center, leaving the outsides column and rows to reduce the calculations complexity.

There is a (google sheet)[https://docs.google.com/spreadsheets/d/1k93SeQk64VlknOom7dyuidwX8lJlkqXFFCe7LqXURn4/edit?gid=0#gid=0] to convert visually a board to hex string

Example ef execution
`python ./python/gameOfLifeV1.py 2 0000700000000000` the output should be `0020202000000000`

# Performance results

1 Millon Executions
Language | 4x4 | 10x10 | 62x62 | 100x100 | 1000x1000 
Python   |  8  |  50   |       |   4323  |  


# Scripts
- `./board.sh 00FFAABACA00` will display a board in human readable format 
- `./compile.sh` to compile the source code
- `./test.sh` to run tests across all compiled sources
- `./performance.sh` to measure the performance in every implementation

## test
There will be a `test.sh` file to run a specific board an specific number of steps and compare the result board with the expected one. The same tests will be compared across all implementations.