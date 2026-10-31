`timescale 1ns / 1ps

module alu_core #(
    parameter WIDTH = 8
)(
    input  wire             clk,          
    input  wire             arith_en,      
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       opcode,
    output reg  [WIDTH-1:0] result,
    output wire             zero,
    output reg              carry,
    output reg              overflow
);

    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam AND = 3'b010;
    localparam OR  = 3'b011;
    localparam XOR = 3'b100;
    localparam NOT = 3'b101;

    wire [WIDTH-1:0] a_arith;
    wire [WIDTH-1:0] b_arith;

    assign a_arith = a & {WIDTH{arith_en}};
    assign b_arith = b & {WIDTH{arith_en}};

    reg [WIDTH:0] math_result;

    always @(*) begin
        carry       = 1'b0;
        overflow    = 1'b0;
        math_result = {(WIDTH+1){1'b0}};

        case (opcode)
            ADD: begin
                math_result = {1'b0, a_arith} + {1'b0, b_arith};
                result      = math_result[WIDTH-1:0];
                carry       = math_result[WIDTH];
                overflow    = (~(a_arith[WIDTH-1] ^ b_arith[WIDTH-1])) & 
                              (a_arith[WIDTH-1] ^ result[WIDTH-1]);
            end

            SUB: begin
                math_result = {1'b0, a_arith} - {1'b0, b_arith};
                result      = math_result[WIDTH-1:0];
                carry       = math_result[WIDTH]; 
                overflow    = (a_arith[WIDTH-1] ^ b_arith[WIDTH-1]) & 
                              (a_arith[WIDTH-1] ^ result[WIDTH-1]);
            end

            AND: begin
                result      = a & b;
            end

            OR: begin
                result      = a | b;
            end

            XOR: begin
                result      = a ^ b;
            end

            NOT: begin
                result      = ~a;
            end

            default: begin
                result      = {WIDTH{1'b0}};
            end
        endcase
    end

    assign zero = (result == {WIDTH{1'b0}});

endmodule
