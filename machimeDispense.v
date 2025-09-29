`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2025 08:17:40 AM
// Design Name: 
// Module Name: machimeDispense
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


  //DESIGN

`timescale 1ns/1ns

module machineDispense (
  input  wire clk,
  input  wire reset_n,          // activo en bajo
  input  wire Nickel,           // 1= se insertó níquel este ciclo
  input  wire Dime,             // 1= se insertó dime este ciclo
  input  wire Quarter,          // 1= se insertó quarter este ciclo
  output reg  Dispense,
  output reg  ReturnNickel,
  output reg  ReturnDime,
  output reg  ReturnTwoDimes
);

  // Estados: 0,5,10,15,20 y pagos 25/30/35/40/45 (un ciclo y vuelta a S0)
  
  parameter S0   = 4'd0;  // 0
  parameter S5   = 4'd1;  // 5
  parameter S10  = 4'd2;  // 10
  parameter S15  = 4'd3;  // 15
  parameter S20  = 4'd4;  // 20

  parameter P25  = 4'd5;  // Dispense
  parameter P30  = 4'd6;  // Dispense + 5
  parameter P35  = 4'd7;  // Dispense + 10
  parameter P40  = 4'd8;  // Dispense + 15 (10+5)
  parameter P45  = 4'd9;  // Dispense + 20 (dos dimes)

  reg [3:0] state, nextstate;

  // Registro de estado (reset asíncrono activo en bajo)
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) state <= S0;
    else          state <= nextstate;
  end

  // Lógica combinacional (Moore): nextstate + salidas
  always @* begin
    // defaults (evitan latches)
    nextstate = state;
    Dispense = 1'b0;
    ReturnNickel = 1'b0;
    ReturnDime   = 1'b0;
    ReturnTwoDimes = 1'b0;

    case (state)
      // Acumulación
      S0:  begin
              if      (Nickel)  nextstate = S5;
              else if (Dime)    nextstate = S10;
              else if (Quarter) nextstate = P25;
            end
      S5:  begin
              if      (Nickel)  nextstate = S10;
              else if (Dime)    nextstate = S15;
              else if (Quarter) nextstate = P30;
            end
      S10: begin
              if      (Nickel)  nextstate = S15;
              else if (Dime)    nextstate = S20;
              else if (Quarter) nextstate = P35;
            end
      S15: begin
              if      (Nickel)  nextstate = S20;
              else if (Dime)    nextstate = P25;   // 15+10=25
              else if (Quarter) nextstate = P40;   // 15+25=40
            end
      S20: begin
              if      (Nickel)  nextstate = P25;   // 20+5=25
              else if (Dime)    nextstate = P30;   // 20+10=30
              else if (Quarter) nextstate = P45;   // 20+25=45
            end

      // Pago (un ciclo y regreso a S0)
      P25: begin
              Dispense = 1'b1;
              nextstate = S0;
            end
      P30: begin
              Dispense = 1'b1; ReturnNickel = 1'b1; // 5¢
              nextstate = S0;
            end
      P35: begin
              Dispense = 1'b1; ReturnDime = 1'b1;   // 10¢
              nextstate = S0;
            end
      P40: begin
              Dispense = 1'b1; ReturnDime = 1'b1; ReturnNickel = 1'b1; // 15¢
              nextstate = S0;
            end
      P45: begin
              Dispense = 1'b1; ReturnTwoDimes = 1'b1; // 20¢
              nextstate = S0;
            end

      default: nextstate = S0;
    endcase
  end

endmodule
    
module clockdivider(
  input  wire in_clk,
  input  wire reset_n,   // activo en bajo
  output reg  out_clk
);
  reg [24:0] counter;

  always @(posedge in_clk or negedge reset_n) begin
    if (!reset_n) begin
      counter <= 25'd0;
      out_clk <= 1'b0;
    end else begin
      counter <= counter + 25'd1;
      if (counter == 25'd0)   // overflow
        out_clk <= ~out_clk;
    end
  end
endmodule
