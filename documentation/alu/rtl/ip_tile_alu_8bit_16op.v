`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Mifral
// Engineer:
//
// Design Name: semicolab
// Module Name: ip_tile_alu_8bit_16op
//
//////////////////////////////////////////////////////////////////////////////////

module ip_tile_alu_8bit_16op #(
parameter REG_WIDTH = 32,
parameter CSR_IN_WIDTH = 16,
parameter CSR_OUT_WIDTH = 16)

(
input wire clk,
input wire arst_n,
input wire [CSR_IN_WIDTH-1:0] csr_in,
input wire  [REG_WIDTH - 1:0] data_reg_a,
input wire  [REG_WIDTH - 1:0] data_reg_b,
output wire [REG_WIDTH - 1:0] data_reg_c,
output wire [CSR_OUT_WIDTH-1:0] csr_out,
output wire csr_in_re,
output wire csr_out_we
    );    

// localparam for operation selector
localparam ADD  = 4'b0000,
           SUB  = 4'b0001,
           MUL  = 4'b0010,
           DIV  = 4'b0011,
           AND  = 4'b0100,
           OR   = 4'b0101,
           NOT  = 4'b0110,
           XOR  = 4'b0111,
           XNOR = 4'b1000,
           LEFT_SHIFT  = 4'b1001,
           RIGHT_SHIFT = 4'b1010,
           INCREMENT  = 4'b1011,
           DECREMENT  = 4'b1100,
           INVERSE_SUB = 4'b1101,
           AR_RIGHT_SHIFT_A = 4'b1110,
           AR_RIGHT_SHIFT_B = 4'b1111;

// alu operation selector from a 4 MSBs
wire [3:0] alu_op = data_reg_a[31:28];
wire [7:0] operand_a = data_reg_a[7:0];
wire [7:0] operand_b = data_reg_b[7:0];
wire [3:0] flags;
           
// wires for internal flags and operations
wire [15:0] full_mult;
wire [15:0] full_sum;
wire zero_division;
wire mult_overflow;
wire sum_overflow;
wire result_zero;

// registers for internal output values
reg [7:0] data_reg_c_r;
reg csr_out_we_reg;
reg csr_in_re_reg;

// ALU //
always @(*) begin
    csr_in_re_reg   = 1'b0;
    csr_out_we_reg  = 1'b0;
    data_reg_c_r    = 8'd0;        
    case(alu_op)
        ADD: data_reg_c_r  = operand_a + operand_b;
        SUB: data_reg_c_r  = operand_a - operand_b;
        MUL: data_reg_c_r  = operand_a * operand_b;
        DIV: begin
            if(operand_b == 0)
                data_reg_c_r = 8'b11111111;
            else 
                data_reg_c_r = operand_a / operand_b;
        end         
        AND: data_reg_c_r  = operand_a & operand_b;
        OR:  data_reg_c_r  = operand_a | operand_b;
        NOT: data_reg_c_r  = ~operand_a;
        XOR: data_reg_c_r  = operand_a ^ operand_b;
        XNOR: data_reg_c_r = ~(operand_a ^ operand_b) ;
        LEFT_SHIFT: data_reg_c_r = operand_a << 1;
        RIGHT_SHIFT: data_reg_c_r = operand_a >> 1;
        INCREMENT: data_reg_c_r = operand_a + 1;
        DECREMENT: data_reg_c_r = operand_a - 1;
        INVERSE_SUB: data_reg_c_r = (operand_b - operand_a);
        AR_RIGHT_SHIFT_A: data_reg_c_r = operand_a >>> 1 ;
        AR_RIGHT_SHIFT_B: data_reg_c_r = operand_b >>> 1 ;
        default: data_reg_c_r = 8'd0;
    endcase
end

// assign for internal signals used for flags
assign full_sum = operand_a + operand_b; // internal sum operation with 16 bits to detect overflow
assign full_mult = operand_a * operand_b; // internal multiplication operation with 16 bits to detect overflow
assign sum_overflow = |(full_sum[15:8]) && (alu_op == ADD); // flag to indicate that the SUM has overflow
assign mult_overflow = |(full_mult[15:8]) && (alu_op == MUL); // flag to indicate that the MULTIPLICATION has overflow
assign zero_division = (operand_b == 0) && (alu_op == DIV); // flag to indicate that the DIVISION is invalid (division by 0)
assign result_zero = (data_reg_c_r == 0); // flag to indicate that the operation result is 0

// assign to the module outputs
assign csr_out_we = csr_out_we_reg;
assign csr_in_re = csr_in_re_reg;    

// assign flag values and concatenate operation result with flags in data_reg_c output
assign flags = {mult_overflow, sum_overflow, zero_division, result_zero};
assign data_reg_c = {flags, 20'd0, data_reg_c_r}; 
            
endmodule
