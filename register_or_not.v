module register_or_not (clk, in, out, rst, enable);
    parameter SEL = 1; 
    parameter RSTTYPE = "SYNC";
    parameter WIDTH = 18; 
    
    input clk, rst, enable; 
    input [WIDTH-1:0] in;
    output reg [WIDTH-1:0] out;
    
    generate
        if (SEL == 0) begin
            always @(*) begin
                out = in; 
            end
        end else if (SEL == 1) begin
            if (RSTTYPE == "SYNC") begin
                always @(posedge clk) begin
                    if (rst) begin
                        out <= 0;
                    end else if (enable) begin
                        out <= in;
                    end
                end
            end else if (RSTTYPE == "ASYNC") begin
                always @(posedge clk or posedge rst) begin
                    if (rst) begin
                        out <= 0;
                    end else if (enable) begin
                        out <= in;
                    end
                end
            end
        end
    endgenerate
    
endmodule
