A synthesizable, hardware-efficient Context-Aware Smart ALU designed in Verilog HDL. The architecture introduces deterministic gate-level prediction using a sequential pattern monitor and a 2-bit saturating counter to mitigate execution latency and suppress dynamic power via operand isolation.

# Architecture
- Parameterized Execution Core: Scalable $N$-bit ALU supporting standard arithmetic (`ADD`, `SUB`) and bitwise logical (`AND`, `OR`, `XOR`, `NOT`) operations.
- Pattern Monitor: 3-cycle rolling history window tracking instruction streams in real time.
- Advance Look-Ahead Prediction: Speculative `PREDICT_HIT` generation to pre-arm datapath multiplexers ahead of decode completion.
- Operand Isolation: Clamps arithmetic carry chains (`arith_en = 0`) during bitwise logical execution to suppress dynamic switching power.

# Key Hardware Results
- FPGA used: AMD Xilinx Artix-7 FPGA (`xc7a35tcpg236-1`)
- Software Loop Prediction Accuracy: >90%
- Hardware Area Overhead: <2% relative to conventional ALU (requires only 11 Flip-Flops)

# Verification
Designed, simulated, and synthesized using AMD Xilinx Vivado ML Standard Edition.

# Simulation Waveforms & Verification 

![Smart ALU](C:\Users\abhij\OneDrive\Desktop\Smart_ALU\comparision)
