`timescale 1ns/1ps

module soda_mealy_fsm (
    input  wire clk,
    input  wire rst_n,  
    input  wire Nickel,          // 5
    input  wire Dime,            // 10
    input  wire Quarter,         // 25
    output reg  Dispense,
    output reg  ReturnNickel,    // return 5
    output reg  ReturnDime,      // return 10
    output reg  ReturnTwoDimes   // return 20
);


  parameter S0  = 3'd000,
  parameter S5  = 3'd001,
  parameter S10 = 3'd010,
  parameter S15 = 3'd011,
  parameter S20 = 3'd100;

  reg [2:0] state, next_state;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= S0;
    else
      state <= next_state;
  end

  always @* begin
    next_state      = state;
    Dispense        = 1'b0;
    ReturnNickel    = 1'b0;
    ReturnDime      = 1'b0;
    ReturnTwoDimes  = 1'b0;

    case (state)
      S0: begin
        if (Nickel)        next_state = S5;
        else if (Dime)     next_state = S10;
        else if (Quarter) begin
          Dispense    = 1'b1;
          next_state  = S0;
        end
      end

      S5: begin
        if (Nickel)        next_state = S10;
        else if (Dime)     next_state = S15;
        else if (Quarter) begin
          Dispense      = 1'b1;
          ReturnNickel  = 1'b1;
          next_state    = S0;
        end
      end

      S10: begin
        if (Nickel)        next_state = S15;
        else if (Dime)     next_state = S20;
        else if (Quarter) begin
          Dispense    = 1'b1;
          ReturnDime  = 1'b1;
          next_state  = S0;
        end
      end

      S15: begin
        if (Nickel)        next_state = S20;
        else if (Dime) begin
          Dispense    = 1'b1;
          next_state  = S0;
        end else if (Quarter) begin
          Dispense      = 1'b1;
          ReturnDime    = 1'b1;
          ReturnNickel  = 1'b1;
          next_state    = S0;
        end
      end

      S20: begin
        if (Nickel) begin
          Dispense    = 1'b1;
          next_state  = S0;
        end else if (Dime) begin
          Dispense      = 1'b1;
          ReturnNickel  = 1'b1;
          next_state    = S0;
        end else if (Quarter) begin
          Dispense        = 1'b1;
          ReturnTwoDimes  = 1'b1;
          next_state      = S0;
        end
      end

      default: next_state = S0;
    endcase
  end

endmodule
