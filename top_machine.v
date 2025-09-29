`timescale 1ns/1ns

module top_machine (
  input  wire clk,     // 100 MHz (W5)
  input  wire btnC,    // reset activo alto en la placa
  input  wire btnL,    // Nickel
  input  wire btnU,    // Dime
  input  wire btnR,    // Quarter
  output wire [3:0] led
);
  wire slow_clk;
  wire reset_n = ~btnC;

  clockdivider u_div (
    .in_clk (clk),
    .reset_n(reset_n),
    .out_clk(slow_clk)
  );
  reg [1:0] syncN, syncD, syncQ;
  reg prevN, prevD, prevQ;

  always @(posedge slow_clk or negedge reset_n) begin
    if (!reset_n) begin
      syncN <= 2'b00; syncD <= 2'b00; syncQ <= 2'b00;
      prevN <= 1'b0;  prevD <= 1'b0;  prevQ <= 1'b0;
    end else begin

      syncN <= {syncN[0], btnL};
      syncD <= {syncD[0], btnU};
      syncQ <= {syncQ[0], btnR};
      prevN <= syncN[1];
      prevD <= syncD[1];
      prevQ <= syncQ[1];
    end
  end

  wire Nickel_pulse  =  syncN[1] & ~prevN;
  wire Dime_pulse    =  syncD[1] & ~prevD;
  wire Quarter_pulse =  syncQ[1] & ~prevQ;


  wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;

  // DUT 
  machineDispense u_fsm (
    .clk           (slow_clk),
    .reset_n       (reset_n),
    .Nickel        (Nickel_pulse),
    .Dime          (Dime_pulse),
    .Quarter       (Quarter_pulse),
    .Dispense      (Dispense),
    .ReturnNickel  (ReturnNickel),
    .ReturnDime    (ReturnDime),
    .ReturnTwoDimes(ReturnTwoDimes)
  );

  assign led[0] = Dispense;
  assign led[1] = ReturnNickel;
  assign led[2] = ReturnDime;
  assign led[3] = ReturnTwoDimes;

endmodule
