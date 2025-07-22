`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Mifral
// Engineer:
//
// Design Name: semicolab
// Module Name: ip_tile_alu_8bit_16op_tb
//
//////////////////////////////////////////////////////////////////////////////////

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
    wait(arst_n);
    
    // ---------- ADD ----------
    intf.write_data_reg_a({4'b0000, 20'd0, 8'd10}); // opcode ADD, A = 10
    intf.write_data_reg_b({24'd0, 8'd5});           // B = 5
    @(posedge clk);

    // ---------- SUB ----------
    intf.write_data_reg_a({4'b0001, 20'd0, 8'd20}); // opcode SUB, A = 20
    intf.write_data_reg_b({24'd0, 8'd8});           // B = 8
    @(posedge clk);

    // ---------- MUL ----------
    intf.write_data_reg_a({4'b0010, 20'd0, 8'd7});  // opcode MUL, A = 7
    intf.write_data_reg_b({24'd0, 8'd6});           // B = 6
    @(posedge clk);

    // ---------- DIV ----------
    intf.write_data_reg_a({4'b0011, 20'd0, 8'd40}); // opcode DIV, A = 40
    intf.write_data_reg_b({24'd0, 8'd5});           // B = 5
    @(posedge clk);

    // ---------- DIV /0 ----------
    intf.write_data_reg_a({4'b0011, 20'd0, 8'd15}); // opcode DIV, A = 15
    intf.write_data_reg_b({24'd0, 8'd0});           // B = 0
    @(posedge clk);

    // ---------- AND ----------
    intf.write_data_reg_a({4'b0100, 20'd0, 8'b10101010});
    intf.write_data_reg_b({24'd0, 8'b11001100});
    @(posedge clk);

    // ---------- OR ----------
    intf.write_data_reg_a({4'b0101, 20'd0, 8'b10100010});
    intf.write_data_reg_b({24'd0, 8'b00001111});
    @(posedge clk);

    // ---------- NOT ----------
    intf.write_data_reg_a({4'b0110, 20'd0, 8'b11110000}); // Solo usa A
    intf.write_data_reg_b(32'd0);
    @(posedge clk);

    // ---------- XOR ----------
    intf.write_data_reg_a({4'b0111, 20'd0, 8'b11110000});
    intf.write_data_reg_b({24'd0, 8'b00001111});
    @(posedge clk);

    // ---------- XNOR ----------
    intf.write_data_reg_a({4'b1000, 20'd0, 8'b10101010});
    intf.write_data_reg_b({24'd0, 8'b10101010});
    @(posedge clk);

    // ---------- SHIFT LEFT ----------
    intf.write_data_reg_a({4'b1001, 20'd0, 8'b00011111});
    intf.write_data_reg_b(32'd0);
    @(posedge clk);

    // ---------- SHIFT RIGHT ----------
    intf.write_data_reg_a({4'b1010, 20'd0, 8'b11100000});
    intf.write_data_reg_b(32'd0);
    @(posedge clk);

    // ---------- INC ----------
    intf.write_data_reg_a({4'b1011, 20'd0, 8'd99});
    intf.write_data_reg_b(32'd0);
    @(posedge clk);

    // ---------- DEC ----------
    intf.write_data_reg_a({4'b1100, 20'd0, 8'd100});
    intf.write_data_reg_b(32'd0);
    @(posedge clk);

    // ---------- INVERSE SUB ----------
    intf.write_data_reg_a({4'b1101, 20'd0, 8'd30});
    intf.write_data_reg_b({24'd0, 8'd50});
    @(posedge clk);

    // ---------- ARITH SHIFT RIGHT A ----------
    intf.write_data_reg_a({4'b1110, 20'd0, 8'b11110000});
    intf.write_data_reg_b(32'd0);
    @(posedge clk);

    // ---------- ARITH SHIFT RIGHT B ----------
    intf.write_data_reg_a({4'b1111, 20'd0, 8'b00000000});
    intf.write_data_reg_b({24'd0, 8'b11110000});
    @(posedge clk);

    $finish;
end



endmodule
