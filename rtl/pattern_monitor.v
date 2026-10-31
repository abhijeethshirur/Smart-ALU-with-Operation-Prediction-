`timescale 1ns / 1ps

module pattern_monitor (
    input  wire       clk,         
    input  wire       rst,          
    input  wire [2:0] opcode_in,    
    output reg  [2:0] op_current, 
    output reg  [2:0] op_prev_1,    
    output reg  [2:0] op_prev_2   
);

    always @(posedge clk) begin
        if (rst) begin  
            op_current <= 3'b000;
            op_prev_1  <= 3'b000;
            op_prev_2  <= 3'b000;
        end else begin
            op_prev_2  <= op_prev_1;
            op_prev_1  <= op_current;
            op_current <= opcode_in;
        end
    end

endmodule
