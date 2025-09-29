`timescale 1ns / 1ps

module tb();
  reg clk, reset;
  reg Nickel, Dime, Quarter;
  wire Dispense, ReturnNickel, ReturnDime, ReturnTwoDimes;

  // DUT (usa tu módulo tal cual)
  machimeDispense dut(
    .clk(clk), .reset(reset),
    .Nickel(Nickel), .Dime(Dime), .Quarter(Quarter),
    .Dispense(Dispense), .ReturnNickel(ReturnNickel),
    .ReturnDime(ReturnDime), .ReturnTwoDimes(ReturnTwoDimes)
  );

  // Reloj
  initial clk = 1'b0;
  always #5 clk = ~clk;   // periodo 10ns

  // Estímulos (un pulso de 1 ciclo por moneda)
  initial begin
    // init
    reset = 1'b0; Nickel = 0; Dime = 0; Quarter = 0;
    #20;                 // en reset un par de ciclos
    reset = 1'b1;        // salir de reset
    #20;

    // TC1: Exacto 25 con Quarter -> Dispense
    Quarter = 1; #10; Quarter = 0; #20;

    // TC2: 5 + 10 + 10 = 25 (N, D, D) -> Dispense
    Nickel = 1;  #10; Nickel = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #20;

    // TC3: 10 + 10 + 10 = 30 (D, D, D) -> Dispense + ReturnNickel
    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #20;

    // TC4: 10 + 25 = 35 (D, Q) -> Dispense + ReturnDime
    Dime   = 1;  #10; Dime   = 0;  #10;
    Quarter= 1;  #10; Quarter= 0;  #20;

    // TC5: 15 + 25 = 40 (N, D, Q) -> Dispense + ReturnDime + ReturnNickel
    Nickel = 1;  #10; Nickel = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Quarter= 1;  #10; Quarter= 0;  #20;

    // TC6: 20 + 25 = 45 (D, D, Q) -> Dispense + ReturnTwoDimes
    Dime   = 1;  #10; Dime   = 0;  #10;
    Dime   = 1;  #10; Dime   = 0;  #10;
    Quarter= 1;  #10; Quarter= 0;  #20;

    // TC7: Reset a mitad de compra (tras 5c), luego quarter
    Nickel = 1;  #10; Nickel = 0;  #10;
    reset  = 0;  #20;              // aplicar reset (activo en bajo)
    reset  = 1;  #20;              // salir de reset
    Quarter= 1;  #10; Quarter= 0;  #20;

    $finish;
  end
endmodule
