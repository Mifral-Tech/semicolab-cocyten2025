`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Mifral
// Engineer:
//
// Design Name: semicolab
// Module Name: ip_tile_fsm_bitwise_shifter_tb
//
//////////////////////////////////////////////////////////////////////////////////

module ip_tile_fsm_bitwise_shifter_tb;

  parameter CSR_IN_WIDTH = 16;
  parameter CSR_OUT_WIDTH = 16;
  parameter REG_WIDTH = 32;

  bit clk;
  bit arst_n;
  interface_ip_tile intf(clk, arst_n);

  always #5ns clk = !clk;
  assign #20ns arst_n = 1'b1;

ip_tile_fsm_bitwise_shifter DUT(	  
	  .clk(clk),
	  .arst_n(arst_n),
	  .csr_in(intf.csr_in),
	  .csr_in_re(intf.csr_in_re),
	  .data_reg_a(intf.data_reg_a),
	  .data_reg_b(intf.data_reg_b),
	  .csr_out(intf.csr_out),
	  .csr_out_we(intf.csr_out_we),
	  .data_reg_c(intf.data_reg_c)
	);

  initial begin
    clk = 0;
    @(posedge arst_n);  // wait for reset release

////////////////////////////////////////////////////////////
// TESTS CAN BE COMMENTED TO EVALUATE INDIVIDUALLY OR ALL //
////////////////////////////////////////////////////////////	  
    // Test 1: Shift data_reg_a (0xA5A5A5A5) right 32 bits
    intf.write_data_reg_a(32'hA5A5A5A5);
    intf.write_csr_in(16'b1000_0001_1111_0101);
    intf.wait_done();
    #30;

    // Test 2: Shift data_reg_b (0xF0000000) left 4 bits
    intf.write_data_reg_b(32'hF000_0000);
    intf.write_csr_in(16'b1000_0000_0011_1010); 
    intf.wait_done();
    repeat (2) @(posedge clk);

    // Test 3: Shift data_reg_a (0xF0F0F0F0) left 16 bits
    intf.write_data_reg_a(32'hF0F0F0F0);
    intf.write_csr_in(16'b1000_0000_1111_1001);
    intf.wait_done();

    // Test 4: Shift data_reg_b (0xFFFFFFFF) right 32 bits
    intf.write_data_reg_b(32'hFFFF_FFFF);
    intf.write_csr_in(16'b1000_0001_1111_0110);
    intf.wait_done();

    // Test 5: Shift data_reg_b (0xBBBB_BBBB) right 1 bit
    intf.write_data_reg_b(32'hBBBB_BBBB);
    intf.write_csr_in(16'b1000_0000_0000_0110);
    intf.wait_done();
    @(posedge clk);
    // Test 6: Shift data_reg_a (0xAAAA_AAAA) 0 bits
    intf.write_data_reg_a(32'hAAAA_AAAA);
    intf.write_data_reg_b(32'h0000_0000);
    intf.write_csr_in(16'b1000_0000_0000_0001);
    intf.wait_done();
    repeat (3) @(posedge clk);

    // Test 7: Try to write csr_in while FSM is busy shifting
    intf.write_data_reg_a(32'h12345678);
    intf.write_csr_in(16'b1000_0001_1111_1001); 
    repeat (8) @(posedge clk);
    intf.write_csr_in(16'b1000_0000_0010_0101); 
    intf.wait_done();
    @(posedge clk);

    // Test 8: Issue reset while FSM is busy shifting
    intf.write_data_reg_a(32'hCAFEBABE);
    intf.write_csr_in(16'b1000_0001_1111_1001); 
    repeat (4) @(posedge clk);
    #2 arst_n <= 1'b0;
    @(posedge clk);
    arst_n <= 1'b1; // Release reset
    repeat (10) @(posedge clk);

    $finish;
  end

endmodule

