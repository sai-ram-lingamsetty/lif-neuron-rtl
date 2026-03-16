`timescale 1ns/1ps
// -------------------------------------------------------------
// Standard Leaky Integrate-and-Fire (LIF) Neuron
//
// Continuous model:
// Cm * dVm/dt = I - Vm/Rm
//
// Discrete approximation:
// Vm_next = Vm + (dt/Cm) * (I - Vm/Rm)
//
// Hardware implementation:
// Vm_next = Vm + (I - Vm/2^LEAK_SHIFT) / 2^TAU_SHIFT
//
// Features:
// - Parameterized precision
// - Refractory period
// - Threshold spike generation
// - Reset behavior
// - Shift-based leak approximation
// -------------------------------------------------------------

module lif_neuron #(
    parameter WIDTH = 18,
    parameter signed [WIDTH-1:0] VTH = 18'sd30,
    parameter signed [WIDTH-1:0] VRESET = 18'sd0,
    parameter integer REF_PERIOD = 10,
    parameter LEAK_SHIFT = 3,
    parameter TAU_SHIFT  = 2
)(
    input  wire clk,
    input  wire rst_n,
    input  wire signed [WIDTH-1:0] i_in,
    output reg  signed [WIDTH-1:0] v_mem,
    output reg spike
);

    wire signed [WIDTH-1:0] v_leak;
    wire signed [WIDTH-1:0] dv;
    wire signed [WIDTH-1:0] v_next;

    reg [$clog2(REF_PERIOD+1)-1:0] ref_count;

    assign v_leak = v_mem >>> LEAK_SHIFT;
    assign dv     = (i_in - v_leak) >>> TAU_SHIFT;
    assign v_next = v_mem + dv;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            v_mem <= VRESET;
            spike <= 1'b0;
            ref_count <= 0;
        end
        else begin
            if(ref_count > 0) begin
                ref_count <= ref_count - 1;
                v_mem <= VRESET;
                spike <= 1'b0;
            end
            else if(v_next >= VTH) begin
                v_mem <= VRESET;
                spike <= 1'b1;
                ref_count <= REF_PERIOD;
            end
            else begin
                v_mem <= (v_next < VRESET) ? VRESET : v_next;
                spike <= 1'b0;
            end
        end
    end
endmodule
