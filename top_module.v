module top_module (
    input clk,
    input rst,
    input enable,
    input [17:0] in,
    output [17:0] out
);

    register_or_not #(
        .SEL(1),
        .RSTTYPE("SYNC"),
        .WIDTH(18)
    ) uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .in(in),
        .out(out)
    );

endmodule
