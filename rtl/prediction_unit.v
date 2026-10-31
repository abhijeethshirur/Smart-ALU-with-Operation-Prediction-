`timescale 1ns / 1ps

module prediction_unit (
    input  wire       clk,             
    input  wire       rst,              
    input  wire [2:0] opcode_in,        
    input  wire [2:0] op_current,     
    input  wire [2:0] op_prev_1,        
    input  wire [2:0] op_prev_2,       
    output reg  [2:0] predicted_op,    
    output wire       predict_arm,     
    output wire       predict_hit,      
    output reg  [1:0] counter_state   
);

    localparam STRONGLY_MISPREDICT = 2'b00; 
    localparam WEAKLY_MISPREDICT   = 2'b01; 
    localparam WEAKLY_PREDICT      = 2'b10; 
    localparam STRONGLY_PREDICT    = 2'b11; 

    wire history_repeating;
    assign history_repeating = (op_current == op_prev_1);

    always @(*) begin
        if (history_repeating) begin
 
            predicted_op = op_current;
        end else if (op_current == op_prev_2) begin
           
            predicted_op = op_prev_1;
        end else begin
         
            predicted_op = op_current;
        end
    end

    
    assign predict_arm = (counter_state >= WEAKLY_PREDICT);

    wire guess_correct;
    assign guess_correct = (opcode_in == predicted_op);

  
    assign predict_hit = predict_arm && guess_correct;

    always @(posedge clk) begin
        if (rst) begin
            counter_state <= STRONGLY_MISPREDICT;
        end else begin
            if (guess_correct) begin
               
                case (counter_state)
                    STRONGLY_MISPREDICT: counter_state <= WEAKLY_MISPREDICT;
                    WEAKLY_MISPREDICT:   counter_state <= WEAKLY_PREDICT;
                    WEAKLY_PREDICT:      counter_state <= STRONGLY_PREDICT;
                    STRONGLY_PREDICT:    counter_state <= STRONGLY_PREDICT;
                    default:             counter_state <= STRONGLY_MISPREDICT;
                endcase
            end else begin
                
                case (counter_state)
                    STRONGLY_PREDICT:    counter_state <= WEAKLY_PREDICT;
                    WEAKLY_PREDICT:      counter_state <= WEAKLY_MISPREDICT;
                    WEAKLY_MISPREDICT:   counter_state <= STRONGLY_MISPREDICT;
                    STRONGLY_MISPREDICT: counter_state <= STRONGLY_MISPREDICT;
                    default:             counter_state <= STRONGLY_MISPREDICT;
                endcase
            end
        end
    end

endmodule
