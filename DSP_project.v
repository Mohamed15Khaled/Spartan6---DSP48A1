module DSP_project (A , B , D , C , clk , CARRYIN , OPMODE , BCIN , RSTA , RSTB , RSTM , RSTP ,
	 RSTC , RSTD , RSTCARRYIN , RSTOPMODE , CEA , CEB , CEM , CEP , CEC , CED , CECARRYIN , CEOPMODE , PCIN ,
	 BCOUT , PCOUT , P , M , CARRYOUT , CARRYOUTF );

// PARMETERS 
parameter A0REG = 0 ; parameter A1REG= 1 ; parameter B0REG = 0 ; parameter B1REG = 1 ;
parameter CREG = 1 ; parameter DREG = 1 ; parameter MREG =1 ;  parameter PREG = 1 ; 
parameter CARRYINREG = 1 ; parameter CARRYOUTREG =1 ; parameter OPMODEREG = 1 ;
parameter CARRYINSEL = "OPMODE5" ; parameter B_INPUT = "DIRECT" ;  parameter RSTTYPE = "SYNC";

// inputs and outputs 
input [17:0] A , B , D , BCIN ;
input [47:0] C , PCIN ;
input [7:0] OPMODE ;
input clk , CARRYIN  , RSTA , RSTB , RSTM , RSTP ,RSTC , RSTD , RSTCARRYIN , RSTOPMODE ;
input  CEA , CEB , CEM , CEP , CEC , CED , CECARRYIN , CEOPMODE  ;
output CARRYOUT  ;
output reg CARRYOUTF ; 
output reg [17:0]BCOUT ;
output [47:0] P ;
output reg [47:0] PCOUT ;
output reg [35:0] M ;

// wiring 
wire [17:0] b , b0 , d , a0  , a1 , b1 ;
reg [17:0]  pre_adder_subtracter , b1_before  ;
wire [47:0] c  ;
reg [47:0] d_a_b_connected , x , z , post_adder_subtracter  ;
reg [35:0] multiplication  ;
wire [35:0] m ;
wire [7:0] opmode ; 
wire carry_cascade , cyi  ; 
reg  cyo ;

// instantiating 

register_or_not #(.SEL(A0REG), .RSTTYPE(RSTTYPE) , .WIDTH(18)) a00 (.clk(clk), .in(A), .out(a0), .rst(RSTA), .enable(CEA));
register_or_not #(.SEL(B0REG), .RSTTYPE(RSTTYPE) , .WIDTH(18)) b00 (.clk(clk), .in(b), .out(b0), .rst(RSTB), .enable(CEB));
register_or_not #(.SEL(CREG), .RSTTYPE(RSTTYPE) , .WIDTH(48)) cc (.clk(clk), .in(C), .out(c), .rst(RSTC), .enable(CEC));
register_or_not #(.SEL(DREG), .RSTTYPE(RSTTYPE) , .WIDTH(18)) dd (.clk(clk), .in(D), .out(d), .rst(RSTD), .enable(CED));
register_or_not #(.SEL(OPMODEREG), .RSTTYPE(RSTTYPE) , .WIDTH(8)) opmodee (.clk(clk), .in(OPMODE), .out(opmode), .rst(RSTOPMODE), .enable(CEOPMODE));
register_or_not #(.SEL(A1REG), .RSTTYPE(RSTTYPE) , .WIDTH(18)) a11 (.clk(clk), .in(a0), .out(a1), .rst(RSTA), .enable(CEA));
register_or_not #(.SEL(B1REG), .RSTTYPE(RSTTYPE) , .WIDTH(18)) b11 (.clk(clk), .in(b1_before), .out(b1), .rst(RSTB), .enable(CEB));
register_or_not #(.SEL(CARRYINREG), .RSTTYPE(RSTTYPE) , .WIDTH(1)) carry_cas (.clk(clk), .in(carry_cascade), .out(cyi), .rst(RSTCARRYIN), .enable(CECARRYIN));
register_or_not #(.SEL(MREG), .RSTTYPE(RSTTYPE) , .WIDTH(36)) mm (.clk(clk), .in(multiplication), .out(m), .rst(RSTM), .enable(CEM));
register_or_not #(.SEL(CARRYOUTREG), .RSTTYPE(RSTTYPE) , .WIDTH(1)) carry_out (.clk(clk), .in(cyo), .out(CARRYOUT), .rst(RSTCARRYIN), .enable(CECARRYIN));
register_or_not #(.SEL(PREG), .RSTTYPE(RSTTYPE) , .WIDTH(48)) pp (.clk(clk), .in(post_adder_subtracter), .out(P), .rst(RSTP), .enable(CEP));

generate 
	if(B_INPUT=="DIRECT")
	assign b = B ;	
	else if (B_INPUT=="CASCADE")
	assign b= BCIN ;
endgenerate

generate
	if(CARRYINSEL == "OPMODE5")
  assign carry_cascade = opmode[5];
else if (CARRYINSEL == "CARRYIN")
  assign carry_cascade = CARRYIN ;
endgenerate


	always @(*) begin
		if(opmode[6]==0)
		pre_adder_subtracter=b0+d ;
		else 
		pre_adder_subtracter=d-b0 ;

		if(opmode[4])
		b1_before= pre_adder_subtracter ;
		else 
		b1_before= b0 ; 

		BCOUT= b1 ;
		multiplication=b1*a1 ;
		M=m ;
		d_a_b_connected = {d[11:0] , a1 , b1 } ;

		case (opmode[3:2])
		2'b00 : z= 48'b0;
		2'b01 : z= PCIN ;
		2'b10 : z= P ;
		2'b11 : z= c;
		endcase
		case (opmode[1:0]) 
		2'b00 : x= 48'b0;
		2'b01 : x= m ;
		2'b10 : x= P ;
		2'b11 : x= d_a_b_connected;
		endcase
		if (opmode[7])
		{cyo,post_adder_subtracter}= z-x-cyi ;
		else 
		{cyo,post_adder_subtracter}= z+x+cyi ;
		CARRYOUTF=CARRYOUT ;
		PCOUT=P;
	end
endmodule