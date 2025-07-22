`timescale 1ns / 1ps


module ip_tile_fsm_bitwise_shifter_tb;

	parameter CSR_IN_WIDTH = 16;
	parameter CSR_OUT_WIDTH = 16;
	parameter REG_WIDTH = 32;

	bit clk;
	bit arst_n;
  bit [CSR_IN_WIDTH - 1 : 0] csr_in;
  bit [REG_WIDTH - 1 : 0] data_reg_a;
  bit [REG_WIDTH - 1 : 0] data_reg_b;
  bit csr_in_we;
	bit [CSR_IN_WIDTH - 1 : 0] csr_in_wdata;
  logic csr_in_re;
  logic [CSR_OUT_WIDTH - 1 : 0] csr_out, csr_out_r;
  bit csr_out_re;
  logic csr_out_we;
  logic [REG_WIDTH - 1 : 0] data_reg_c;

	always #5ns clk = !clk;
	assign #20ns arst_n = 1'b1;

	task write_data_reg_a(logic [REG_WIDTH - 1 : 0] data);
		@(posedge clk);
		data_reg_a <= data;
	endtask

	task write_data_reg_b(logic [REG_WIDTH - 1 : 0] data);
		@(posedge clk);
		data_reg_b <= data;
	endtask

	function logic [REG_WIDTH - 1 : 0] read_data_reg_c();
		return data_reg_c;
	endfunction

	task read_csr_out(output logic [CSR_OUT_WIDTH - 1 : 0] csr_out_data);
		csr_out_data <= csr_out_r;
		csr_out_re <= 1'b1;
		@(posedge clk);
		csr_out_re <= 1'b0;
	endtask

	task write_csr_in(logic [CSR_IN_WIDTH - 1 : 0] csr_in_data);
		csr_in_wdata <= csr_in_data;
		csr_in_we <= 1'b1;
		@(posedge clk);
		csr_in_we <= 1'b0;
	endtask

	always_ff@(posedge clk, negedge arst_n) begin
		if(!arst_n) begin
			csr_out_r <= {CSR_OUT_WIDTH{1'b0}};
		end else begin
      if(csr_out_we) // Writing is taking priority over clear on read
        csr_out_r <= csr_out;
      else if(csr_out_re)
        csr_out_r[3 : 0] <= 8'd0; // 4 Least Significant Bits are clear on read, so we have to clear when reading
		end
	end

  always@(posedge clk, negedge arst_n) begin
    if(~arst_n) begin
      csr_in <= {CSR_IN_WIDTH{1'b0}};
    end else begin
      csr_in[CSR_IN_WIDTH - 1 : CSR_IN_WIDTH - 4] <= 4'd0; // 4 Most Significant Bits are single pulse, so we have to clear every clock cycle except when we write
      if(csr_in_we) // Writing is taking priority over clear on read
        csr_in <= csr_in_wdata;
      else if(csr_in_re)
        csr_in[3 : 0] <= 8'd0; // 8 Least Significant Bits are clear on read, so we have to clear when reading
    end
  end

	ip_tile_fsm_bitwise_shifter DUT(
	  .clk(clk),
	  .arst_n(arst_n),
	  .csr_in(csr_in),
	  .csr_in_re(csr_in_re),
	  .data_reg_a(data_reg_a),
	  .data_reg_b(data_reg_b),
	  .csr_out(csr_out),
	  .csr_out_we(csr_out_we),
	  .data_reg_c(data_reg_c)
	);

// USER LOGIC //
initial begin
    wait(arst_n);
    repeat(3) @(posedge clk);
     // 1. Carga un valor en data_reg_a
      write_data_reg_a(32'hA5A5A5A5);  // Ejemplo: patrón alternado
      write_data_reg_b(32'h12A2A3A5);
      write_csr_in(16'b1000_0001_1111_0101);
      repeat(20) @(posedge clk);
    end

endmodule
