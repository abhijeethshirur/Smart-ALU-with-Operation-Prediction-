`timescale 1ns / 1ps

module tb_smart_alu;

    localparam WIDTH = 8;
    localparam CLK_PERIOD = 10;

    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam AND = 3'b010;
    localparam OR  = 3'b011;
    localparam XOR = 3'b100;
    localparam NOT = 3'b101;

    reg             clk;
    reg             rst;
    reg [WIDTH-1:0] a;
    reg [WIDTH-1:0] b;
    reg [2:0]       opcode_in;

    wire [WIDTH-1:0] result;
    wire             zero;
    wire             carry;
    wire             overflow;
    wire             predict_hit;
    wire [2:0]       predicted_op;
    wire [1:0]       counter_state;

    integer total_instructions = 0;
    integer hit_count = 0;
    integer i;

    smart_alu_top #(
        .WIDTH(WIDTH)
    ) uut (
        .clk           (clk),
        .rst           (rst),
        .a             (a),
        .b             (b),
        .opcode_in     (opcode_in),
        .result        (result),
        .zero          (zero),
        .carry         (carry),
        .overflow      (overflow),
        .predict_hit   (predict_hit),
        .predicted_op  (predicted_op),
        .counter_state (counter_state)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;

    task execute_op(input [2:0] op, input [WIDTH-1:0] val_a, input [WIDTH-1:0] val_b);
        begin
            @(posedge clk);
            #1; 
            total_instructions = total_instructions + 1;
            if (predict_hit) begin
                hit_count = hit_count + 1;
            end

            opcode_in = op;
            a         = val_a;
            b         = val_b;
        end
    endtask

    initial begin
        clk       = 0;
        rst       = 1;
        a         = 8'd0;
        b         = 8'd0;
        opcode_in = ADD;

        #(CLK_PERIOD * 2);
        rst = 0;
        #(CLK_PERIOD);

        $display("-------------------------------------------------------");
        $display("      STARTING SMART ALU COMPREHENSIVE SIMULATION      ");
        $display("-------------------------------------------------------");

        $display("\n[TEST 1] Running Functional Verification...");
        execute_op(ADD, 8'd25, 8'd15);  
        execute_op(SUB, 8'd50, 8'd20); 
        execute_op(AND, 8'hFF, 8'h0F);  
        execute_op(OR,  8'hF0, 8'h0F);  
        execute_op(XOR, 8'hAA, 8'h55);  
        execute_op(NOT, 8'hAA, 8'd0);  

        execute_op(ADD, 8'd120, 8'd20);
        execute_op(SUB, 8'd50, 8'd50);

        $display("[TEST 2] Streaming 30 Consecutive ADD Operations (Loop 1)...");
        for (i = 0; i < 30; i = i + 1) begin
            execute_op(ADD, 8'd10, i[WIDTH-1:0]);
        end

        $display("[TEST 2] Streaming 30 Consecutive AND Operations (Loop 2)...");
        for (i = 0; i < 30; i = i + 1) begin
            execute_op(AND, 8'hF0, i[WIDTH-1:0]);
        end

        $display("[TEST 3] Streaming Alternating Sequence (ADD -> SUB)...");
        for (i = 0; i < 20; i = i + 1) begin
            execute_op(ADD, 8'd15, 8'd5);
            execute_op(SUB, 8'd20, 8'd4);
        end

        $display("[TEST 4] Streaming 40 Pseudo-Random Operations...");
        for (i = 0; i < 40; i = i + 1) begin
            execute_op($urandom_range(0, 5), $urandom_range(1, 100), $urandom_range(1, 100));
        end

        @(posedge clk);
        #(CLK_PERIOD * 2);

        $display("\n-------------------------------------------------------");
        $display("               PERFORMANCE METRICS REPORT              ");
        $display("-------------------------------------------------------");
        $display(" Total Instructions Executed : %0d", total_instructions);
        $display(" Total Prediction Hits       : %0d", hit_count);
        $display(" Total Misses: %0d", (total_instructions - hit_count));
        $display(" Measured Overall Hit Rate   : %0.2f%%", (hit_count * 100.0) / total_instructions);
        $display("-------------------------------------------------------\n");

        $finish; 
    end

endmodule
