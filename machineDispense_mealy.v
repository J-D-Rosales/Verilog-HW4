`timescale 1ns/1ps

module soda_mealy_fsm (
    input  wire clk,
    input  wire rst_n,           // active-low async reset
    input  wire Nickel,          // 5¢
    input  wire Dime,            // 10¢
    input  wire Quarter,         // 25¢
    output reg  Dispense,
    output reg  ReturnNickel,    // return 5¢
    output reg  ReturnDime,      // return 10¢
    output reg  ReturnTwoDimes   // return 20¢ (two dimes)
);

  // State encode credit: 0,5,10,15,20
  localparam [2:0] S0  = 3'd0,
                   S5  = 3'd1,
                   S10 = 3'd2,
                   S15 = 3'd3,
                   S20 = 3'd4;

  reg [2:0] state, next_state;

  // Sequential state update
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= S0;
    else
      state <= next_state;
  end

  // Mealy next-state and outputs
  always @* begin
    // defaults
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
          // 0 + 25 = 25 -> vend, no change
          Dispense    = 1'b1;
          next_state  = S0;
        end
      end

      S5: begin
        if (Nickel)        next_state = S10;
        else if (Dime)     next_state = S15;
        else if (Quarter) begin
          // 5 + 25 = 30 -> change 5
          Dispense      = 1'b1;
          ReturnNickel  = 1'b1;
          next_state    = S0;
        end
      end

      S10: begin
        if (Nickel)        next_state = S15;
        else if (Dime)     next_state = S20;
        else if (Quarter) begin
          // 10 + 25 = 35 -> change 10
          Dispense    = 1'b1;
          ReturnDime  = 1'b1;
          next_state  = S0;
        end
      end

      S15: begin
        if (Nickel)        next_state = S20;
        else if (Dime) begin
          // 15 + 10 = 25 -> exact
          Dispense    = 1'b1;
          next_state  = S0;
        end else if (Quarter) begin
          // 15 + 25 = 40 -> change 15 (10 + 5)
          Dispense      = 1'b1;
          ReturnDime    = 1'b1;
          ReturnNickel  = 1'b1;
          next_state    = S0;
        end
      end

      S20: begin
        if (Nickel) begin
          // 20 + 5 = 25 -> exact
          Dispense    = 1'b1;
          next_state  = S0;
        end else if (Dime) begin
          // 20 + 10 = 30 -> change 5
          Dispense      = 1'b1;
          ReturnNickel  = 1'b1;
          next_state    = S0;
        end else if (Quarter) begin
          // 20 + 25 = 45 -> change 20 (two dimes)
          Dispense        = 1'b1;
          ReturnTwoDimes  = 1'b1;
          next_state      = S0;
        end
      end

      default: next_state = S0;
    endcase
  end

  // Optional: enforce "exactly one coin per cycle" in sim
  //`define SIM_STRICT_ONECOIN
`ifdef SIM_STRICT_ONECOIN
  always @(posedge clk) begin
    if (rst_n) begin
      integer sum;
      sum = (Nickel?1:0) + (Dime?1:0) + (Quarter?1:0);
      if (sum != 1) $error("Exactly one coin must be asserted each cycle.");
    end
  end
`endif

endmodule
