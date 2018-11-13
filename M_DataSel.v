//------------------------------------------------------------------------------
// 版    权  :  
// 文件名称  :  M_ChSel.v
// 设    计  :  Pejoicen
// 邮    件  :  pejoicen@live.com
// 校    对  :
// 设计日期  :  22018-11-13
// 功能简述  :  Data select
// 版本序号  :  0.1
// 修改历史  :  1. Initial, pejoicen, 2018-11-13
//------------------------------------------------------------------------------
`timescale 1 ns / 1 ps

module M_DataSel (
    //----------------------------------
    // Reset, clock
    //----------------------------------
    input                               CpSl_Rst_iN                             , // Reset, active low
    input                               CpSl_Clk_i                              , // Clock

    //----------------------------------
    // ADC data & control
    //----------------------------------
    input                               CpSl_Trig_i                             , // Capture go
    input      [ 8: 0]                  CpSv_DeInd_i                            , // Decimation indicator

    input      [63: 0]                  CpSv_Ad0Data_i                          , // AD 0 data in
    input      [63: 0]                  CpSv_Ad1Data_i                          , // AD 1 data in
    input      [63: 0]                  CpSv_Ad2Data_i                          , // AD 2 data in
    input      [63: 0]                  CpSv_Ad3Data_i                          , // AD 3 data in

    //----------------------------------
    // User data
    //----------------------------------
    output                              CpSl_UsrClk_o                           , // User clock
    output reg                          CpSl_UsrDvld_o                          , // User data valid
    output reg [511:0]                  CpSv_UsrData_o                            // User data
);

//------------------------------------------------------------------------------
// Declaration
//------------------------------------------------------------------------------
// Delay
reg                                     PrSl_TrigDly1_s                         ; // Delay Capture go
reg  [63: 0]                            PrSv_Ad0DataD1_s                        ; // Delay input data 1 clk
reg  [63: 0]                            PrSv_Ad1DataD1_s                        ; // Delay input data 1 clk
reg  [63: 0]                            PrSv_Ad2DataD1_s                        ; // Delay input data 1 clk
reg  [63: 0]                            PrSv_Ad3DataD1_s                        ; // Delay input data 1 clk
reg  [63: 0]                            PrSv_Ad0DataD2_s                        ; // Delay input data 2 clk
reg  [63: 0]                            PrSv_Ad1DataD2_s                        ; // Delay input data 2 clk
reg  [63: 0]                            PrSv_Ad2DataD2_s                        ; // Delay input data 2 clk
reg  [63: 0]                            PrSv_Ad3DataD2_s                        ; // Delay input data 2 clk
// 1_4
reg  [ 1: 0]                            PrSv_QuarterCnt_s                       ; // 1/4 
reg  [63: 0]                            PrSv_1_4Data0_s                         ; // 1/4 
reg  [63: 0]                            PrSv_1_4Data1_s                         ; // 1/4 
reg  [63: 0]                            PrSv_1_4Data2_s                         ; // 1/4 
reg  [63: 0]                            PrSv_1_4Data3_s                         ; // 1/4 
reg                                     PrSl_1_4Dvld_s                          ; // 1/4 
// Select Data
reg  [63: 0]                            PrSv_SelData0_s                         ; // 
reg  [63: 0]                            PrSv_SelData1_s                         ; // 
reg  [63: 0]                            PrSv_SelData2_s                         ; // 
reg  [63: 0]                            PrSv_SelData3_s                         ; // 
reg                                     PrSl_SelDvld_s                          ; // 
// Other
reg  [511:0]                            PrSv_UsrData_s                          ; // 
reg                                     PrSl_UsrDvld_s                          ; // 
reg                                     PrSl_UsrDvldDly1_s                      ; // 
reg  [511:0]                            PrSv_UsrDataDly1_s                      ; // 
reg                                     PrSl_UsrDvldDly2_s                      ; // 
reg  [511:0]                            PrSv_UsrDataDly2_s                      ; // 

//------------------------------------------------------------------------------
// Main Body of Code
//------------------------------------------------------------------------------
//--------------------------------------
// Delay
//--------------------------------------
// Delay Capture go & Frame & PRF
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0) begin
        PrSl_TrigDly1_s  <=   1'b0;
    end
    else begin
        PrSl_TrigDly1_s  <= CpSl_Trig_i  ;
    end
end


// AD data
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0) begin
        PrSv_Ad0DataD1_s <= 64'b0;
        PrSv_Ad1DataD1_s <= 64'b0;
        PrSv_Ad2DataD1_s <= 64'b0;
        PrSv_Ad3DataD1_s <= 64'b0;

        PrSv_Ad0DataD2_s <= 64'b0;
        PrSv_Ad1DataD2_s <= 64'b0;
        PrSv_Ad2DataD2_s <= 64'b0;
        PrSv_Ad3DataD2_s <= 64'b0;
    end
    else begin
        PrSv_Ad0DataD1_s <= CpSv_Ad0Data_i;
        PrSv_Ad1DataD1_s <= CpSv_Ad1Data_i;
        PrSv_Ad2DataD1_s <= CpSv_Ad2Data_i;
        PrSv_Ad3DataD1_s <= CpSv_Ad3Data_i;

        PrSv_Ad0DataD2_s <= PrSv_Ad0DataD1_s;
        PrSv_Ad1DataD2_s <= PrSv_Ad1DataD1_s;
        PrSv_Ad2DataD2_s <= PrSv_Ad2DataD1_s;
        PrSv_Ad3DataD2_s <= PrSv_Ad3DataD1_s;
    end
end


//--------------------------------------
// 1/4 600->150
//--------------------------------------
// 1_4 DeInd counter
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0)
        PrSv_QuarterCnt_s <= 2'b0;
    else begin
        if (PrSl_TrigDly1_s == 1'b1)
            PrSv_QuarterCnt_s <= PrSv_QuarterCnt_s +1'b1;
        else
            PrSv_QuarterCnt_s <= 2'b0;
    end
end


// 1_4 data
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0) begin
        PrSv_1_4Data0_s <= 64'b0;
        PrSv_1_4Data1_s <= 64'b0;
        PrSv_1_4Data2_s <= 64'b0;
        PrSv_1_4Data3_s <= 64'b0;
    end
    else if (PrSl_TrigDly1_s == 1'b1) begin
            case (PrSv_QuarterCnt_s)
                2'b00: begin
                    PrSv_1_4Data0_s[15:0] <= PrSv_Ad0DataD1_s[15:0];
                    PrSv_1_4Data1_s[15:0] <= PrSv_Ad1DataD1_s[15:0];
                    PrSv_1_4Data2_s[15:0] <= PrSv_Ad2DataD1_s[15:0];
                    PrSv_1_4Data3_s[15:0] <= PrSv_Ad3DataD1_s[15:0];
                end
                2'b01: begin
                    PrSv_1_4Data0_s[31:16] <= PrSv_Ad0DataD1_s[15:0];
                    PrSv_1_4Data1_s[31:16] <= PrSv_Ad1DataD1_s[15:0];
                    PrSv_1_4Data2_s[31:16] <= PrSv_Ad2DataD1_s[15:0];
                    PrSv_1_4Data3_s[31:16] <= PrSv_Ad3DataD1_s[15:0];
                end
                2'b10: begin
                    PrSv_1_4Data0_s[47:32] <= PrSv_Ad0DataD1_s[15:0];
                    PrSv_1_4Data1_s[47:32] <= PrSv_Ad1DataD1_s[15:0];
                    PrSv_1_4Data2_s[47:32] <= PrSv_Ad2DataD1_s[15:0];
                    PrSv_1_4Data3_s[47:32] <= PrSv_Ad3DataD1_s[15:0];
                end
                2'b11: begin
                    PrSv_1_4Data0_s[63:48] <= PrSv_Ad0DataD1_s[15:0];
                    PrSv_1_4Data1_s[63:48] <= PrSv_Ad1DataD1_s[15:0];
                    PrSv_1_4Data2_s[63:48] <= PrSv_Ad2DataD1_s[15:0];
                    PrSv_1_4Data3_s[63:48] <= PrSv_Ad3DataD1_s[15:0];
                end
                default:
                    PrSv_1_4Data0_s <= 64'b0;
            endcase
        end
        else begin
            PrSv_1_4Data0_s <= 64'b0;
            PrSv_1_4Data1_s <= 64'b0;
            PrSv_1_4Data2_s <= 64'b0;
            PrSv_1_4Data3_s <= 64'b0;
        end

end


// 1_4 data valid
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0)
        PrSl_1_4Dvld_s <= 1'b0;
    else begin
        PrSl_1_4Dvld_s <= PrSv_QuarterCnt_s[1]&PrSv_QuarterCnt_s[0];
    end
end

/*************************************/
// div more than 4
/*************************************/

// the counter for calculating which data be output
reg [8:0] PrSv_DivCnt_s;
reg [8:0] PrSv_AddCnt_s;


always@(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0) begin
        PrSv_AddCnt_s <= 'b0;
    end
    else begin
        PrSv_AddCnt_s <= CpSv_DeInd_i - 9'd4; 
    end
end

always@(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0) begin
        PrSv_DivCnt_s <= 'b0;
    end
    else begin
        if (PrSl_TrigDly1_s == 1'b1) begin
            if (PrSv_DivCnt_s < 9'd4)
                PrSv_DivCnt_s <= PrSv_DivCnt_s + PrSv_AddCnt_s;
            else
                PrSv_DivCnt_s <= PrSv_DivCnt_s - 9'd4;
        end
        else
            PrSv_DivCnt_s <= 'b0;
    end
end
            


// data valid
reg [1:0] PrSv_DataVldCnt_s;
reg [1:0] PrSv_DataVldCntDly_s;


// select data
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0) begin
        PrSv_DataVldCnt_s <= 2'b0;
    end
    else if (PrSl_TrigDly1_s == 1'b1) begin
            case (PrSv_DivCnt_s)
            9'b00:
                PrSv_DataVldCnt_s   <= PrSv_DataVldCnt_s +1'b1;
            9'b01:
                PrSv_DataVldCnt_s   <= PrSv_DataVldCnt_s +1'b1;
            9'b10:  
                PrSv_DataVldCnt_s   <= PrSv_DataVldCnt_s +1'b1;
            9'b11:  
                PrSv_DataVldCnt_s   <= PrSv_DataVldCnt_s +1'b1;
            default:
                PrSv_DataVldCnt_s   <= PrSv_DataVldCnt_s; 
            endcase
    end
    else begin
        PrSv_DataVldCnt_s   <= PrSv_DataVldCnt_s; 
    end
end


always @(posedge CpSl_Clk_i) begin
    PrSv_DataVldCntDly_s <= PrSv_DataVldCnt_s;
end


// PrSl_SelDvld_s
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0)
        PrSl_SelDvld_s <= 1'b0;
    else begin
        //if (PrSv_DataVldCnt_s == 2'b11 && PrSv_DataVldCntDly_s== 2'b10 )
        if (PrSv_DataVldCnt_s == 2'b11 && PrSv_DivCnt_s[8:2]== 7'b0 )           // when has 3 valid data,then receive one more data output
            PrSl_SelDvld_s <= 1'b1;
        else
            PrSl_SelDvld_s <= 1'b0;   
    end
end

wire [3:0] CpSv_DataMap_s;
assign CpSv_DataMap_s = {PrSv_DataVldCnt_s,PrSv_DivCnt_s[1:0]};

// select data
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0) begin
        PrSv_SelData0_s <= 64'b0;
        PrSv_SelData1_s <= 64'b0;
        PrSv_SelData2_s <= 64'b0;
        PrSv_SelData3_s <= 64'b0;
    end
    else begin
        if (PrSl_TrigDly1_s == 1'b1 ) begin
            case (CpSv_DataMap_s)
            4'b0000: begin
                PrSv_SelData0_s[15:0] <= PrSv_Ad0DataD1_s[15:0];
                PrSv_SelData1_s[15:0] <= PrSv_Ad1DataD1_s[15:0];
                PrSv_SelData2_s[15:0] <= PrSv_Ad2DataD1_s[15:0];
                PrSv_SelData3_s[15:0] <= PrSv_Ad3DataD1_s[15:0];
            end
            4'b0001: begin
                PrSv_SelData0_s[15:0] <= PrSv_Ad0DataD1_s[31:16];
                PrSv_SelData1_s[15:0] <= PrSv_Ad1DataD1_s[31:16];
                PrSv_SelData2_s[15:0] <= PrSv_Ad2DataD1_s[31:16];
                PrSv_SelData3_s[15:0] <= PrSv_Ad3DataD1_s[31:16];
            end
            4'b0010: begin                                
                PrSv_SelData0_s[15:0] <= PrSv_Ad0DataD1_s[47:32];
                PrSv_SelData1_s[15:0] <= PrSv_Ad1DataD1_s[47:32];
                PrSv_SelData2_s[15:0] <= PrSv_Ad2DataD1_s[47:32];
                PrSv_SelData3_s[15:0] <= PrSv_Ad3DataD1_s[47:32];
            end
            4'b0011: begin
                PrSv_SelData0_s[15:0] <= PrSv_Ad0DataD1_s[63:48];
                PrSv_SelData1_s[15:0] <= PrSv_Ad1DataD1_s[63:48];
                PrSv_SelData2_s[15:0] <= PrSv_Ad2DataD1_s[63:48];
                PrSv_SelData3_s[15:0] <= PrSv_Ad3DataD1_s[63:48];
            end
            4'b0100: begin
                PrSv_SelData0_s[31:16] <= PrSv_Ad0DataD1_s[15:0];
                PrSv_SelData1_s[31:16] <= PrSv_Ad1DataD1_s[15:0];
                PrSv_SelData2_s[31:16] <= PrSv_Ad2DataD1_s[15:0];
                PrSv_SelData3_s[31:16] <= PrSv_Ad3DataD1_s[15:0];
            end
            4'b0101: begin
                PrSv_SelData0_s[31:16] <= PrSv_Ad0DataD1_s[31:16];
                PrSv_SelData1_s[31:16] <= PrSv_Ad1DataD1_s[31:16];
                PrSv_SelData2_s[31:16] <= PrSv_Ad2DataD1_s[31:16];
                PrSv_SelData3_s[31:16] <= PrSv_Ad3DataD1_s[31:16];
            end
            4'b0110: begin
                PrSv_SelData0_s[31:16] <= PrSv_Ad0DataD1_s[47:32];
                PrSv_SelData1_s[31:16] <= PrSv_Ad1DataD1_s[47:32];
                PrSv_SelData2_s[31:16] <= PrSv_Ad2DataD1_s[47:32];
                PrSv_SelData3_s[31:16] <= PrSv_Ad3DataD1_s[47:32];
            end
            4'b0111: begin
                PrSv_SelData0_s[31:16] <= PrSv_Ad0DataD1_s[63:48];
                PrSv_SelData1_s[31:16] <= PrSv_Ad1DataD1_s[63:48];
                PrSv_SelData2_s[31:16] <= PrSv_Ad2DataD1_s[63:48];
                PrSv_SelData3_s[31:16] <= PrSv_Ad3DataD1_s[63:48];
            end
            4'b1000: begin
                PrSv_SelData0_s[47:32] <= PrSv_Ad0DataD1_s[15:0];
                PrSv_SelData1_s[47:32] <= PrSv_Ad1DataD1_s[15:0];
                PrSv_SelData2_s[47:32] <= PrSv_Ad2DataD1_s[15:0];
                PrSv_SelData3_s[47:32] <= PrSv_Ad3DataD1_s[15:0];
            end
            4'b1001: begin
                PrSv_SelData0_s[47:32] <= PrSv_Ad0DataD1_s[31:16];
                PrSv_SelData1_s[47:32] <= PrSv_Ad1DataD1_s[31:16];
                PrSv_SelData2_s[47:32] <= PrSv_Ad2DataD1_s[31:16];
                PrSv_SelData3_s[47:32] <= PrSv_Ad3DataD1_s[31:16];
            end
            4'b1010: begin
                PrSv_SelData0_s[47:32] <= PrSv_Ad0DataD1_s[47:32];
                PrSv_SelData1_s[47:32] <= PrSv_Ad1DataD1_s[47:32];
                PrSv_SelData2_s[47:32] <= PrSv_Ad2DataD1_s[47:32];
                PrSv_SelData3_s[47:32] <= PrSv_Ad3DataD1_s[47:32];
            end
            4'b1011: begin
                PrSv_SelData0_s[47:32] <= PrSv_Ad0DataD1_s[63:48];
                PrSv_SelData1_s[47:32] <= PrSv_Ad1DataD1_s[63:48];
                PrSv_SelData2_s[47:32] <= PrSv_Ad2DataD1_s[63:48];
                PrSv_SelData3_s[47:32] <= PrSv_Ad3DataD1_s[63:48];
            end
            4'b1100: begin
                PrSv_SelData0_s[63:48] <= PrSv_Ad0DataD1_s[15:0];
                PrSv_SelData1_s[63:48] <= PrSv_Ad1DataD1_s[15:0];
                PrSv_SelData2_s[63:48] <= PrSv_Ad2DataD1_s[15:0];
                PrSv_SelData3_s[63:48] <= PrSv_Ad3DataD1_s[15:0];
            end
            4'b1101: begin
                PrSv_SelData0_s[63:48] <= PrSv_Ad0DataD1_s[31:16];
                PrSv_SelData1_s[63:48] <= PrSv_Ad1DataD1_s[31:16];
                PrSv_SelData2_s[63:48] <= PrSv_Ad2DataD1_s[31:16];
                PrSv_SelData3_s[63:48] <= PrSv_Ad3DataD1_s[31:16];
            end
            4'b1110: begin
                PrSv_SelData0_s[63:48] <= PrSv_Ad0DataD1_s[47:32];
                PrSv_SelData1_s[63:48] <= PrSv_Ad1DataD1_s[47:32];
                PrSv_SelData2_s[63:48] <= PrSv_Ad2DataD1_s[47:32];
                PrSv_SelData3_s[63:48] <= PrSv_Ad3DataD1_s[47:32];
            end
            4'b1111: begin
                PrSv_SelData0_s[63:48] <= PrSv_Ad0DataD1_s[63:48];
                PrSv_SelData1_s[63:48] <= PrSv_Ad1DataD1_s[63:48];
                PrSv_SelData2_s[63:48] <= PrSv_Ad2DataD1_s[63:48];
                PrSv_SelData3_s[63:48] <= PrSv_Ad3DataD1_s[63:48];
            end
            default: ;
            endcase
        end
        else begin
            PrSv_SelData0_s     <= 64'b0;
            PrSv_SelData1_s     <= 64'b0;
            PrSv_SelData2_s     <= 64'b0;
            PrSv_SelData3_s     <= 64'b0;
        end
    end
end



// user data output
reg [1:0] PrSv_VldCnt_s;

always@(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN ==1'b0)
        PrSv_VldCnt_s <= 'b0;
    else begin
        if (PrSl_1_4Dvld_s == 1'b1) begin
            PrSv_VldCnt_s <= PrSv_VldCnt_s + 1'b1;
        end
        else;
    end
end    

// dual channel
//PrSv_UsrData_s
always@(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN ==1'b0)
        PrSv_UsrData_s <= 'b0;
    else begin
        if (PrSl_TrigDly1_s == 1'b1 && PrSl_1_4Dvld_s == 1'b1) begin
            case (PrSv_VldCnt_s)
            2'b00:
                PrSv_UsrData_s[127:  0] <= {PrSv_1_4Data3_s[63:0],PrSv_1_4Data0_s[63:0]};
            2'b01:
                PrSv_UsrData_s[255:128] <= {PrSv_1_4Data3_s[63:0],PrSv_1_4Data0_s[63:0]};
            2'b10:
                PrSv_UsrData_s[383:256] <= {PrSv_1_4Data3_s[63:0],PrSv_1_4Data0_s[63:0]};
            2'b11:
                PrSv_UsrData_s[511:384] <= {PrSv_1_4Data3_s[63:0],PrSv_1_4Data0_s[63:0]};
            default:;
            endcase
        end
        else;
    end
end

// PrSl_UsrDvld_s
always @(posedge CpSl_Clk_i) begin
    if (CpSl_Rst_iN == 1'b0)
        PrSl_UsrDvld_s <= 1'b0;
    else begin
        PrSl_UsrDvld_s <= PrSv_VldCnt_s[1]&PrSv_VldCnt_s[0]&PrSl_1_4Dvld_s;
    end
end

endmodule
