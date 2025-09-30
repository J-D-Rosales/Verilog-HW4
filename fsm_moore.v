`timescale 1ns/1ps

module fsm_moore(input clk, input rst_n, input [3:0] x, output reg z);
  localparam S0=2'b00,S1=2'b01,S2=2'b10,SACC=2'b11;
  reg [1:0] state,next;
  reg [3:0] A,B;
  wire [3:0] sum4 = A + B;
  wire [3:0] diff4 = A - B;
  wire m = (x==sum4) | (x==diff4);

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=S0; A<=4'd0; B<=4'd0;
    end else begin
      state<=next;
      if(state==S0 || state==SACC) A<=x;
      if(state==S1) B<=x;
    end
  end

  always @* begin
    next=state;
    case(state)
      S0:   next=S1;
      S1:   next=S2;
      S2:   next = m ? SACC : S0;
      SACC: next=S1;
      default: next=S0;
    endcase
  end

  always @* z = (state==SACC);
endmodule

module fsm_mealy(input clk, input rst_n, input [3:0] x, output z);
  localparam S0=2'b00,S1=2'b01,S2=2'b10;
  reg [1:0] state,next;
  reg [3:0] A,B;
  wire [3:0] sum4 = A + B;
  wire [3:0] diff4 = A - B;
  assign z = (state==S2) & ((x==sum4) | (x==diff4));

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=S0; A<=4'd0; B<=4'd0;
    end else begin
      state<=next;
      if(state==S0) A<=x;
      if(state==S1) B<=x;
    end
  end

  always @* begin
    next=state;
    case(state)
      S0: next=S1;
      S1: next=S2;
      S2: next=S0;
      default: next=S0;
    endcase
  end
endmodule
