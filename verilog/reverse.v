module reverse (
    input wire clk,           // Clock 27 MHz (Tang Primer 20k)
    input wire rst_n,         // Reset activo bajo
    input wire uart_rx,       // Pin RX UART
    output wire uart_tx       // Pin TX UART
);

    // Parámetros UART (115200 baudios @ 27 MHz)
    localparam CLK_FREQ = 27000000;
    localparam BAUD_RATE = 115200;
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;  // 234

    // Estados de la máquina
    localparam IDLE = 0;
    localparam RECEIVING = 1;
    localparam TRANSMITTING = 2;

    // Señales internas
    reg [1:0] state;
    reg [7:0] buffer [0:31];  // Buffer para 32 caracteres
    reg [4:0] rx_count;       // Contador de recepción (0-31)
    reg [4:0] tx_count;       // Contador de transmisión (0-31)

    // Señales UART RX
    wire rx_ready;
    wire [7:0] rx_data;
    reg rx_clear;

    // Señales UART TX
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_busy;

    // Instancia del receptor UART
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_rx),
        .rx_ready(rx_ready),
        .rx_data(rx_data),
        .rx_clear(rx_clear)
    );

    // Instancia del transmisor UART
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx(uart_tx),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy)
    );

    // Máquina de estados principal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            rx_count <= 0;
            tx_count <= 0;
            rx_clear <= 0;
            tx_start <= 0;
        end else begin
            rx_clear <= 0;
            tx_start <= 0;

            case (state)
                IDLE: begin
                    rx_count <= 0;
                    tx_count <= 0;
                    if (rx_ready) begin
                        buffer[0] <= rx_data;
                        rx_count <= 1;
                        rx_clear <= 1;
                        state <= RECEIVING;
                    end
                end

                RECEIVING: begin
                    if (rx_ready) begin
                        buffer[rx_count] <= rx_data;
                        rx_clear <= 1;

                        if (rx_count == 31) begin
                            // Todos los 32 caracteres recibidos
                            state <= TRANSMITTING;
                            tx_count <= 0;
                        end else begin
                            rx_count <= rx_count + 1;
                        end
                    end
                end

                TRANSMITTING: begin
                    if (!tx_busy && tx_count < 32) begin
                        // Enviar en orden inverso: último primero
                        tx_data <= buffer[31 - tx_count];
                        tx_start <= 1;
                        tx_count <= tx_count + 1;
                    end else if (tx_count == 32 && !tx_busy) begin
                        // Transmisión completa
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

// Módulo receptor UART
module uart_rx #(
    parameter CLK_FREQ = 27000000,
    parameter BAUD_RATE = 115200
)(
    input wire clk,
    input wire rst_n,
    input wire rx,
    output reg rx_ready,
    output reg [7:0] rx_data,
    input wire rx_clear
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam HALF_BAUD = BAUD_DIV / 2;

    reg [1:0] rx_sync;
    reg [15:0] baud_counter;
    reg [3:0] bit_counter;
    reg [7:0] shift_reg;
    reg receiving;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync <= 2'b11;
            baud_counter <= 0;
            bit_counter <= 0;
            shift_reg <= 0;
            receiving <= 0;
            rx_ready <= 0;
            rx_data <= 0;
        end else begin
            // Sincronización de entrada
            rx_sync <= {rx_sync[0], rx};

            if (rx_clear) begin
                rx_ready <= 0;
            end

            if (!receiving) begin
                if (rx_sync[1] == 0) begin  // Detectar bit de inicio
                    receiving <= 1;
                    baud_counter <= HALF_BAUD;
                    bit_counter <= 0;
                end
            end else begin
                if (baud_counter == 0) begin
                    baud_counter <= BAUD_DIV - 1;

                    if (bit_counter < 8) begin
                        shift_reg <= {rx_sync[1], shift_reg[7:1]};
                        bit_counter <= bit_counter + 1;
                    end else begin
                        // Bit de stop recibido
                        receiving <= 0;
                        rx_data <= shift_reg;
                        rx_ready <= 1;
                    end
                end else begin
                    baud_counter <= baud_counter - 1;
                end
            end
        end
    end

endmodule

// Módulo transmisor UART
module uart_tx #(
    parameter CLK_FREQ = 27000000,
    parameter BAUD_RATE = 115200
)(
    input wire clk,
    input wire rst_n,
    output reg tx,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx_busy
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_counter;
    reg [3:0] bit_counter;
    reg [7:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1;
            tx_busy <= 0;
            baud_counter <= 0;
            bit_counter <= 0;
            shift_reg <= 0;
        end else begin
            if (!tx_busy) begin
                tx <= 1;  // Estado idle
                if (tx_start) begin
                    shift_reg <= tx_data;
                    tx_busy <= 1;
                    baud_counter <= BAUD_DIV - 1;
                    bit_counter <= 0;
                    tx <= 0;  // Bit de inicio
                end
            end else begin
                if (baud_counter == 0) begin
                    baud_counter <= BAUD_DIV - 1;

                    if (bit_counter < 8) begin
                        tx <= shift_reg[0];
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        bit_counter <= bit_counter + 1;
                    end else if (bit_counter == 8) begin
                        tx <= 1;  // Bit de stop
                        bit_counter <= bit_counter + 1;
                    end else begin
                        tx_busy <= 0;
                    end
                end else begin
                    baud_counter <= baud_counter - 1;
                end
            end
        end
    end

endmodule
