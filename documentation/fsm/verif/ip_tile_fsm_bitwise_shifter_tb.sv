`timescale 1ns / 1ps
module ip_tile_fsm_bitwise_shifter_tb;

	parameter CSR_IN_WIDTH = 16;
	parameter CSR_OUT_WIDTH = 16;
	parameter REG_WIDTH = 32;

	bit clk;
	bit arst_n;
	interface_ip_tile intf(clk, arst_n);

	always #5ns clk = !clk;
	assign #20ns arst_n = 1'b1;

	ip_tile_user_name DUT(
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

// USER LOGIC //
initial begin
    wait(arst_n);
    repeat(3) @(posedge clk);
      write_data_reg_a(32'hA5A5A5A5);  // 
      write_data_reg_b(32'h12A2A3A5);
      write_csr_in(16'b1000_0001_1111_0101);
    end

endmodule
