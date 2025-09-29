`timescale 1ns / 1ps

module tb();
  reg clk, reset;
  reg Nickel, Dime, Quarter;
  wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;

  machimeDispense dut(
    .clk(clk), .reset(reset),
    .Nickel(Nickel), .Dime(Dime), .Quarter(Quarter),
    .Dispense(Dispense), .ReturnNickel(ReturnNickel),
    .ReturnDime(ReturnDime), .ReturnTwoDimes(ReturnTwoDimes)
  );

  // Reloj
  initial clk = 1'b0;
  always #5 clk = ~clk;  

  initial begin
    reset = 1'b0; Nickel = 0; Dime = 0; Quarter = 0;
    #20;                
    reset = 1'b1;   
    #20;

    Quarter = 1; #10; Quarter = 0; #20;

    Nickel = 1;  #10; Nickel = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #20;

    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #20;

    Dime   = 1;  #10; Dime   = 0;  #10;
    Quarter= 1;  #10; Quarter= 0;  #20;

    Nickel = 1;  #10; Nickel = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Quarter= 1;  #10; Quarter= 0;  #20;

    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Quarter= 1;  #10; Quarter= 0;  #20;

    Nickel = 1;  #10; Nickel = 0;  #10;
    reset  = 0;  #20;          
    reset  = 1;  #20;          
    Quarter= 1;  #10; Quarter= 0;  #20;

    $finish;
  end
endmodule

module tb_soda_mealy_simple;


  reg clk;
  reg reset;       
  reg Nickel, Dime, Quarter;

  wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;

  soda_mealy_fsm dut (
    .clk(clk),
    .rst_n(reset),         
    .Nickel(Nickel),
    .Dime(Dime),
    .Quarter(Quarter),
    .Dispense(Dispense),
    .ReturnNickel(ReturnNickel),
    .ReturnDime(ReturnDime),
    .ReturnTwoDimes(ReturnTwoDimes)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("soda_mealy.vcd");
    $dumpvars(0, tb_soda_mealy_simple);
  end

  initial begin

    Nickel = 0; Dime = 0; Quarter = 0;
    reset  = 1'b0;
    #20;               
    reset = 1'b1;        
    #20;

    Quarter = 1; #10; show("TC1 Quarter=1"); Quarter = 0; #20;

    Nickel = 1;  #10; show("TC2 N=1"); Nickel = 0;  #10;
    Dime   = 1;  #10; show("TC2 D=1"); Dime   = 0;  #10;
    Dime   = 1;  #10; show("TC2 D=1"); Dime   = 0;  #20;

    Dime   = 1;  #10; show("TC3 D=1"); Dime   = 0;  #10;
    Dime   = 1;  #10; show("TC3 D=1"); Dime   = 0;  #10;
    Dime   = 1;  #10; show("TC3 D=1"); Dime   = 0;  #20;

    Dime   = 1;  #10; show("TC4 D=1"); Dime   = 0;  #10;
    Quarter= 1;  #10; show("TC4 Q=1"); Quarter= 0;  #20;

    Nickel = 1;  #10; show("TC5 N=1"); Nickel = 0;  #10;
    Dime   = 1;  #10; show("TC5 D=1"); Dime   = 0;  #10;
    Quarter= 1;  #10; show("TC5 Q=1"); Quarter= 0;  #20;

    Dime   = 1;  #10; show("TC6 D=1"); Dime   = 0;  #10;
    Dime   = 1;  #10; show("TC6 D=1"); Dime   = 0;  #10;
    Quarter= 1;  #10; show("TC6 Q=1"); Quarter= 0;  #20;

    Nickel = 1;  #10; show("TC7 N=1 (antes de reset)"); Nickel = 0;  #10;
    reset  = 0;  #20;           
    reset  = 1;  #20;            
    Quarter= 1;  #10; show("TC7 Q=1 (después de reset)"); Quarter= 0;  #20;
    $display("Fin de pruebas.");
    $finish;
  end

endmodule
