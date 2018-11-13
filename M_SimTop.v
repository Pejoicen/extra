//------------------------------------------------------------------------------
// Company     :  BT Tech
// File name   :  M_SimTop.v
// Author      :  TanQingze
// Email       :  tanqingze@bita-tech.com
// Data        :  2018/11/13
// Function    :  Data simulate 
// Version     :  0.1
// Description :  1. Initial, 2018-11-13 10:49:35
//------------------------------------------------------------------------------
`timescale 1 ns / 1 ps
module M_SimTop();


//------------------------------------------------------------------------------
// Declaration
//------------------------------------------------------------------------------
reg CpSl_Rst_iN;
reg CpSl_CfgClk_i;
reg CpSl_AdcClk_i;
reg CpSl_Start_i;


reg [63:0] PrSv_Ch0Cnt_s;
reg [63:0] PrSv_Ch1Cnt_s;
reg [63:0] PrSv_Ch2Cnt_s;
reg [63:0] PrSv_Ch3Cnt_s;
/**************************************/
// Reset
initial begin
    CpSl_Rst_iN = 1'b0; #10 CpSl_Rst_iN = 1'b1;
end

/**************************************/
// Clocks
initial begin
    CpSl_CfgClk_i = 1'b0; forever #5 CpSl_CfgClk_i <= ~ CpSl_CfgClk_i;
end

initial begin
    CpSl_AdcClk_i = 1'b1; forever #2 CpSl_AdcClk_i <= ~ CpSl_AdcClk_i;
end

/**************************************/
// others control signals
initial begin
    CpSl_Start_i = 1'b0; #21 CpSl_Start_i = 1'b1;
end

// sample 
wire [8:0] PrSv_DeInd_s;
assign PrSv_DeInd_s = 9'd5;

// Data
always@(posedge CpSl_AdcClk_i) begin
    if (CpSl_Start_i == 1'b0) begin
        PrSv_Ch0Cnt_s   <= 64'h1003100210011000;
        PrSv_Ch1Cnt_s   <= 64'h2003200220012000;
        PrSv_Ch2Cnt_s   <= 64'h3003300230013000;
        PrSv_Ch3Cnt_s   <= 64'h4003400240014000;
    end
    else begin
        PrSv_Ch0Cnt_s   <= PrSv_Ch0Cnt_s + 64'h0004000400040004;
        PrSv_Ch1Cnt_s   <= PrSv_Ch1Cnt_s + 64'h0004000400040004;
        PrSv_Ch2Cnt_s   <= PrSv_Ch2Cnt_s + 64'h0004000400040004;
        PrSv_Ch3Cnt_s   <= PrSv_Ch3Cnt_s + 64'h0004000400040004;
    end
end    
        
        
        
        
//implement
M_DataSel  U_M_ChSel (
    //----------------------------------
    // Reset, clock
    //----------------------------------
    .CpSl_Rst_iN                        (CpSl_Rst_iN                            ), // input                              Clock, 100MHz
    .CpSl_Clk_i                         (CpSl_AdcClk_i                          ), // input                               Clock, 250MHz

    //----------------------------------
    // Data
    //----------------------------------                               PRF
    .CpSl_Trig_i                        (CpSl_Start_i                           ), // input                                Capture go
    .CpSv_DeInd_i                       (PrSv_DeInd_s                           ), // input      [ 8: 0]                   Decimation indicator
    
    .CpSv_Ad0Data_i                     (PrSv_Ch0Cnt_s                          ), // input      [63: 0]                   AD 0 data in
    .CpSv_Ad1Data_i                     (PrSv_Ch1Cnt_s                          ), // input      [63: 0]                   AD 1 data in
    .CpSv_Ad2Data_i                     (PrSv_Ch2Cnt_s                          ), // input      [63: 0]                   AD 2 data in
    .CpSv_Ad3Data_i                     (PrSv_Ch3Cnt_s                          ), // input      [63: 0]                   AD 3 data in
    .CpSl_UsrClk_o                      (                                       ), // output                               User clock
    .CpSl_UsrDvld_o                     (                                       ), // output                               User data valid
    .CpSv_UsrData_o                     (                                       )  // output     [511:0]                   User data
);


endmodule