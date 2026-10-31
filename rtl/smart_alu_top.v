`timescale 1ns / 1ps

module smart_alu_top #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       opcode_in,
    output wire [WIDTH-1:0] result,
    output wire             zero,
    output wire             carry,
    output wire             overflow,
    output wire             predict_hit,
    output wire [2:0]       predicted_op,
    output wire [1:0]       counter_state
);

    wire [2:0] op_curr;
    wire [2:0] op_p1;
    wire [2:0] op_p2;
    wire       predict_arm;

    wire [2:0] active_opcode;
    assign active_opcode = (predict_arm) ? predicted_op : opcode_in;

    wire is_arithmetic;
    assign is_arithmetic = (active_opcode == 3'b000) || (active_opcode == 3'b001);

    wire arith_en;
    assign arith_en = is_arithmetic;

    pattern_monitor u_monitor (
        .clk        (clk),
        .rst        (rst),
        .opcode_in  (opcode_in),
        .op_current (op_curr),
        .op_prev_1  (op_p1),
        .op_prev_2  (op_p2)
    );

    prediction_unit u_predictor (
        .clk           (clk),
        .rst           (rst),
        .opcode_in     (opcode_in),
        .op_current    (op_curr),
        .op_prev_1     (op_p1),
        .op_prev_2     (op_p2),
        .predicted_op  (predicted_op),
        .predict_arm   (predict_arm),
        .predict_hit   (predict_hit),
        .counter_state (counter_state)
    );

    alu_core #(
        .WIDTH(WIDTH)
    ) u_core (
        .clk      (clk),
        .arith_en (arith_en),
        .a        (a),
        .b        (b),
        .opcode   (active_opcode),
        .result   (result),
        .zero     (zero),
        .carry    (carry),
        .overflow (overflow)
    );

endmodule
