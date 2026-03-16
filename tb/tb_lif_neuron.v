`timescale 1ns/1ps

module tb_lif_neuron;

    parameter WIDTH = 18;

    reg clk;
    reg rst_n;
    reg signed [WIDTH-1:0] i_in;

    wire signed [WIDTH-1:0] v_mem;
    wire spike;


    lif_neuron #(
        .WIDTH(WIDTH),
        .VTH(18'sd30),
        .VRESET(18'sd0),
        .REF_PERIOD(10),
        .LEAK_SHIFT(4),
        .TAU_SHIFT(3)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .i_in(i_in),
        .v_mem(v_mem),
        .spike(spike)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        rst_n = 0;
        i_in = 0;

        #20 rst_n = 1;

        // No current
        #100;

        // very Small current
        i_in = 1;
        #500;

        // Larger current
        i_in = 20;
        #500;

        // High current
        i_in = 100;
        #500;

        // Remove input
        i_in = 0;
        #500;

        $finish;
    end

endmodule
