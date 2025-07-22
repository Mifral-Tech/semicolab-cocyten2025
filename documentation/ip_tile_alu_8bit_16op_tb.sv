`timescale 1ns / 1ps

module ip_tile_alu_8bit_16op_tb;

	parameter CSR_IN_WIDTH = 16;
	parameter CSR_OUT_WIDTH = 16;
	parameter REG_WIDTH = 32;

	bit clk;
	bit arst_n;
	interface_ip_tile intf(clk, arst_n);

	always #5ns clk = !clk;
	assign #20ns arst_n = 1'b1;

	ip_tile_alu_8bit_16op DUT(
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
    // Reset inicial
    arst_n = 0;
    clk = 0;
    #10;
    arst_n = 1;
    #10;
    
    // ---------- ADD ----------
    intf.write_data_reg_a({4'b0000, 20'd0, 8'd10}); // opcode ADD, A = 10
    intf.write_data_reg_b({24'd0, 8'd5});           // B = 5
    #10;

    // ---------- SUB ----------
    intf.write_data_reg_a({4'b0001, 20'd0, 8'd20}); // opcode SUB, A = 20
    intf.write_data_reg_b({24'd0, 8'd8});           // B = 8
    #10;

    // ---------- MUL ----------
    intf.write_data_reg_a({4'b0010, 20'd0, 8'd7});  // opcode MUL, A = 7
    intf.write_data_reg_b({24'd0, 8'd6});           // B = 6
    #10;

    // ---------- DIV ----------
    intf.write_data_reg_a({4'b0011, 20'd0, 8'd40}); // opcode DIV, A = 40
    intf.write_data_reg_b({24'd0, 8'd5});           // B = 5
    #10;

    // ---------- DIV /0 ----------
    intf.write_data_reg_a({4'b0011, 20'd0, 8'd15}); // opcode DIV, A = 15
    intf.write_data_reg_b({24'd0, 8'd0});           // B = 0
    #10;

    // ---------- AND ----------
    intf.write_data_reg_a({4'b0100, 20'd0, 8'b10101010});
    intf.write_data_reg_b({24'd0, 8'b11001100});
    #10;

    // ---------- OR ----------
    intf.write_data_reg_a({4'b0101, 20'd0, 8'b10100010});
    intf.write_data_reg_b({24'd0, 8'b00001111});
    #10;

    // ---------- NOT ----------
    intf.write_data_reg_a({4'b0110, 20'd0, 8'b11110000}); // Solo usa A
    intf.write_data_reg_b(32'd0);
    #10;

    // ---------- XOR ----------
    intf.write_data_reg_a({4'b0111, 20'd0, 8'b11110000});
    intf.write_data_reg_b({24'd0, 8'b00001111});
    #10;

    // ---------- XNOR ----------
    intf.write_data_reg_a({4'b1000, 20'd0, 8'b10101010});
    intf.write_data_reg_b({24'd0, 8'b10101010});
    #10;

    // ---------- SHIFT LEFT ----------
    intf.write_data_reg_a({4'b1001, 20'd0, 8'b00011111});
    intf.write_data_reg_b(32'd0);
    #10;

    // ---------- SHIFT RIGHT ----------
    intf.write_data_reg_a({4'b1010, 20'd0, 8'b11100000});
    intf.write_data_reg_b(32'd0);
    #10;

    // ---------- INC ----------
    intf.write_data_reg_a({4'b1011, 20'd0, 8'd99});
    intf.write_data_reg_b(32'd0);
    #10;

    // ---------- DEC ----------
    intf.write_data_reg_a({4'b1100, 20'd0, 8'd100});
    intf.write_data_reg_b(32'd0);
    #10;

    // ---------- INVERSE SUB ----------
    intf.write_data_reg_a({4'b1101, 20'd0, 8'd30});
    intf.write_data_reg_b({24'd0, 8'd50});
    #10;

    // ---------- ARITH SHIFT RIGHT A ----------
    intf.write_data_reg_a({4'b1110, 20'd0, 8'b11110000});
    intf.write_data_reg_b(32'd0);
    #10;

    // ---------- ARITH SHIFT RIGHT B ----------
    intf.write_data_reg_a({4'b1111, 20'd0, 8'b00000000});
    intf.write_data_reg_b({24'd0, 8'b11110000});
    #10;

    $finish;
end



endmodule
