module DSP_project_tb ();
reg [17:0] A , B , D , BCIN , BCOUT_expected  ;
reg [47:0] C , PCIN , P_expected , PCOUT_expected   ;
reg [7:0] OPMODE ;
reg clk , CARRYIN  , RSTA , RSTB , RSTM , RSTP ,RSTC , RSTD , RSTCARRYIN , RSTOPMODE , CARRYOUT_expected , CARRYOUTF_expected  ;
reg  CEA , CEB , CEM , CEP , CEC , CED , CECARRYIN , CEOPMODE  ;
reg [35:0] M_expected ; 
wire CARRYOUT_dut  ;
wire  CARRYOUTF_dut ; 
wire [17:0]BCOUT_dut ;
wire [47:0] P_dut , PCOUT_dut ;
wire [35:0] M_dut ;
integer i ;
reg [17:0] pre_adder_sub , b1 ;
reg [47:0] d_a_b_connected , x , z ;
// PARAMETERS
parameter A0REG = 0 ; parameter A1REG= 1 ; parameter B0REG = 0 ; parameter B1REG = 1 ;
parameter CREG = 1 ; parameter DREG = 1 ; parameter MREG =1 ;  parameter PREG = 1 ; 
parameter CARRYINREG = 1 ; parameter CARRYOUTREG =1 ; parameter OPMODEREG = 1 ;
parameter CARRYINSEL = "OPMODE5" ; parameter B_INPUT = "DIRECT" ;  parameter RSTTYPE = "SYNC";

 DSP_project #(A0REG , A1REG , B0REG , B1REG , CREG , DREG , MREG , PREG , CARRYINREG , CARRYOUTREG , OPMODEREG , CARRYINSEL , B_INPUT , RSTTYPE ) dut (
 	.A(A) , .B(B) , .D(D) , .C(C) , .clk(clk) , .CARRYIN(CARRYIN) , .OPMODE(OPMODE) , .BCIN(BCIN) , .RSTA(RSTA) , .RSTB(RSTB) , .RSTM(RSTM) , .RSTP(RSTP) ,
	 .RSTC(RSTC) , .RSTD(RSTD) , .RSTCARRYIN(RSTCARRYIN) , .RSTOPMODE(RSTOPMODE) , .CEA(CEA) , .CEB(CEB) , .CEM(CEM) , .CEP(CEP) , .CEC(CEC) , .CED(CED) ,
	  .CECARRYIN(CECARRYIN) , .CEOPMODE(CEOPMODE) , .PCIN(PCIN) ,.BCOUT(BCOUT_dut) , .PCOUT(PCOUT_dut) , .P(P_dut) , .M(M_dut) , .CARRYOUT(CARRYOUT_dut) , .CARRYOUTF(CARRYOUTF_dut) );
 initial begin
 	clk = 0 ;
 	forever 
 	#10 clk = ~clk ;
 end
 
 initial begin
 	RSTA=1 ; RSTB=1 ; RSTM=1 ; RSTP=1 ; RSTC=1 ; RSTD=1 ; RSTCARRYIN=1 ; RSTOPMODE=1 ;
 	CEA=$random ; CEB=$random ; CEM=$random ; CEP=$random ; CEC=$random ; CED=$random ; CECARRYIN=$random ; CEOPMODE=$random ;
 	A=$random ; B=$random ; D=$random ; C=$random ;BCIN=$random ; PCIN=$random ; OPMODE=$random ; CECARRYIN=$random; 
 	P_expected=0 ; PCOUT_expected=0; BCOUT_expected=0 ; CARRYOUT_expected=0 ; CARRYOUTF_expected=0;	M_expected=0;
 	@(negedge clk);
 	if (P_expected!=P_dut || PCOUT_dut!=PCOUT_expected || BCOUT_expected!= BCOUT_dut || CARRYOUT_expected!=CARRYOUT_dut || CARRYOUTF_dut!=CARRYOUTF_expected || M_dut!=M_expected )
 	$display(" ERROR P_expected = %d , P_dut = %d , PCOUT_dut = %d , PCOUT_expected = %d , 
    BCOUT_dut = %d , BCOUT_expected = %d , CARRYOUT_dut = %d , CARRYOUT_expected = %d , 
    CARRYOUTF_dut = %d , CARRYOUTF_expected = %d , M_dut = %d , M_expected = %d  " ,
    P_expected , P_dut , PCOUT_dut , PCOUT_expected , BCOUT_dut , BCOUT_expected , CARRYOUT_dut , CARRYOUT_expected , CARRYOUTF_dut , CARRYOUTF_expected , M_dut , M_expected ) ;

 	RSTA=0 ; RSTB=0 ; RSTM=0 ; RSTP=0 ; RSTC=0 ; RSTD=0 ; RSTCARRYIN=0 ; RSTOPMODE=0 ;
 	for (i=0 ; i<=50; i=i+1) begin
 	CEA=1 ; CEB=1; CEM=1 ; CEP=0 ; CEC=1 ; CED=1 ; CECARRYIN=1 ; CEOPMODE=1 ;
 	A=$random ; B=$random ; D=$random ; C=$random ;BCIN=$random ; PCIN=$random ; OPMODE=$random ; CARRYIN=$random;
 		if(OPMODE[6])
 		pre_adder_sub=D-B ;
 		else 
 		pre_adder_sub = D+B ;

 		if(OPMODE[4])
		b1= pre_adder_sub ;
		else 
		b1= B ; 

		BCOUT_expected= b1 ;
		M_expected=b1 * A ;
		d_a_b_connected = {D[11:0] , A , b1 } ;

		case (OPMODE[3:2])
		2'b00 : z= 48'b0;
		2'b01 : z= PCIN ;
		2'b10 : z= P_expected ;
		2'b11 : z= C;
		endcase
		case (OPMODE[1:0]) 
		2'b00 : x= 48'b0;
		2'b01 : x= M_expected ;
		2'b10 : x= P_expected ;
		2'b11 : x= d_a_b_connected;
		endcase
		if (OPMODE[7])
		{CARRYOUT_expected, PCOUT_expected} = z-x-OPMODE[5];
		else 
		 {CARRYOUT_expected, PCOUT_expected} = z+x+OPMODE[5];
		 
		 P_expected = PCOUT_expected ;
		 CARRYOUTF_expected= CARRYOUT_expected ;

		 @(negedge clk); CEOPMODE=0  ; repeat(2) @(negedge clk); CEP=1;  @(negedge clk);
 	if (P_expected!=P_dut || PCOUT_dut!=PCOUT_expected || BCOUT_expected!= BCOUT_dut || CARRYOUT_expected!=CARRYOUT_dut || CARRYOUTF_dut!=CARRYOUTF_expected || M_dut!=M_expected )
 	$display(" ERROR P_expected = %d , P_dut = %d , PCOUT_dut = %d , PCOUT_expected = %d , 
    BCOUT_dut = %d , BCOUT_expected = %d , CARRYOUT_dut = %d , CARRYOUT_expected = %d , 
    CARRYOUTF_dut = %d , CARRYOUTF_expected = %d , M_dut = %d , M_expected = %d  " ,
    P_expected , P_dut , PCOUT_dut , PCOUT_expected , BCOUT_dut , BCOUT_expected , CARRYOUT_dut ,
     CARRYOUT_expected , CARRYOUTF_dut , CARRYOUTF_expected , M_dut , M_expected ) ;
 	end 
 	$stop ;
 end

 	initial begin
 		$monitor (" P = %d  ,PCOUT = %d ,  BCOUT = %d , CARRYOUT = %d ,  CARRYOUTF = %d , M = %d  " 
 	 ,P_expected  , PCOUT_dut  , BCOUT_dut, CARRYOUT_dut ,  CARRYOUTF_dut , M_dut  ) ;
 	end
endmodule 