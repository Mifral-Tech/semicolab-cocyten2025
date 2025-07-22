`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Mifral
// Engineer:
//
// Design Name: semicolab
// Module Name: ip_tile_fsm_bitwise_shifter
//
//////////////////////////////////////////////////////////////////////////////////

// ===================== INPUT REGISTERS ======================

// DATA_REG_A - 32-bit data input port.
// This register provides the primary input data to be shifted by the FSM
// when selected through CSR_IN.

// DATA_REG_B - 32-bit alternative data input port.
// This serves as a second data source. The FSM will use this register if selected
// through CSR_IN.

// DATA_REG_C - 32-bit output port.
// This is the final output of the FSM once the shifting operation has completed.
// The value is valid when the DONE flag is HIGH (csr_out[0] = 1).

// ===================== CSR_IN BREAKDOWN (16 bits) ======================

// CSR_IN CLEAR-ON-READ[1:0] - Data input selection.
// [0] = 1 to select DATA_REG_A as the input to be shifted.
// [1] = 1 to select DATA_REG_B as the input to be shifted.
// If both are zero, the module will use zero as the input (null data).
// These bits are "clear-on-read", meaning they are automatically cleared
// by the FSM once read.

// CSR_IN PULSE[15] - Operation start pulse.
// Writing '1' to this bit signals the FSM to begin a shifting operation.
// This is a pulse bit, and must only be high for one cycle.

// CSR_IN CLEAR-ON-READ[3:2] - Shift direction control.
// [2] = 1 selects a right shift operation.
// [3] = 1 selects a left shift operation.
// These are clear-on-read bits and must be re-written for each new operation.
// If both bits are zero, no shifting occurs. If both are one, left has priority.

// CSR_IN STABLES[8:4] - Shift amount.
// Using 5 stable bits from csr_in indicating how many bits to shift.
// Range: 0 to 31 (for 32-bit registers).
// This value remains valid until overwritten.

// ===================== CSR_OUT BREAKDOWN (16 bits) ======================

// CSR_OUT[15] - BUSY flag (stable).
// Set to '1' while the FSM is performing the shifting operation.
// Cleared automatically when the FSM reaches the DONE state.

// CSR_OUT[0] - DONE flag (clear-on-read).
// Set to '1' for one clock cycle when the operation has completed.
// This is a "clear-on-read" flag: it is automatically cleared by reading
// from csr_out.



module ip_tile_fsm_bitwise_shifter #(
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
    
    
`define CSR_OUT_BUSY csr_out[15] // DEFINE BUSY SIGNAL ON CSR_IN STABLE BIT TO INDICATE THAT THE FSM IS SHIFTING THE DATA
`define CSR_OUT_DONE csr_out[0] // DEFINE DONE SIGNAL ON CSR_IN CLEAR ON READ BIT TO INDICATE THAT THE FSM HAS FINISHED THE SHIFTING OPERATION
`define CSR_IN_START csr_in[15] // START PULSE SIGNAL TO LOAD DATA AND START SHIFTING OPERATION
`define CSR_IN_SHIFT_AMOUNT csr_in[8:4] // DEFINE SHIFT AMOUNT IN CSR_IN STABLE BITS (MAX SHIFT AMOUNT = 32 BITS)
`define CSR_IN_RIGHT_SHIFT_DIRECTION csr_in[2] // DEFINE RIGHT SHIFT DIRECTION IN CSR_IN CLEAR ON READ BIT
`define CSR_IN_LEFT_SHIFT_DIRECTION csr_in[3] // DEFINE LEFT SHIFT DIRECTION IN CSR_IN CLEAR ON READ BIT
`define CSR_IN_INPUT_DATA_REG_A_SELECTION csr_in[0] // DEFINE DATA_REG_A SELECTION IN CSR_IN CLEAR ON READ BIT
`define CSR_IN_INPUT_DATA_REG_B_SELECTION csr_in[1] // DEFINE DATA_REG_B SELECTION IN CSR_IN CLEAR ON READ BIT
  
reg [1:0] state_reg, state_nxt; // STATES
reg [4:0] shift_counter; // COUNTER TO SHIFT THE DATA THE AMOUNT DEFINED BY THE CSR_INPUT
reg [REG_WIDTH - 1:0] data_input_r; // REGISTER FOR INPUT DATA_REG_A/B SELECTED
reg [REG_WIDTH - 1:0] shifting_result_r; // REGISTER FOR SHIFTING OPERATION OUTPUT
reg csr_in_re_r; // REGISTER FOR CSR_IN_RE
reg csr_out_we_r; // REGISTER FOR CSR_OUT_WE
wire busy; // INDICATES THAT THE FSM IS PERFORMING THE SHIFTING OPERATION
wire done; // INDICATES THAT THE FSM HAS FINISHED THE SHIFTING OPERATION

reg [4:0] shift_amount_r; // REGISTER TO STORE THE SHIFT AMOUNT SET IN CSR_IN
reg use_reg_a, use_reg_b; // REGISTER TO STORE THE DATA INPUT SELECTED IN CSR_IN
reg shift_left_r, shift_right_r; // REGISTER TO STORE THE SHIFTING DIRECTION SELECTED IN CSR_IN

localparam IDLE  = 2'b00,
           LOAD  = 2'b01,
           SHIFT = 2'b10,
           DONE  = 2'b11;              
    
always @(*) begin
    case (state_reg)
        IDLE:  state_nxt = `CSR_IN_START ? LOAD : IDLE; // IF THERE IS A START PULSE IN CSR_IN PULSE BIT, WE TRANSITION TO LOAD STATE
        LOAD:  state_nxt = SHIFT; // ONCE THE DATA IS LOADED WE TRANSITION TO SHIFT STATE
        SHIFT: state_nxt = (shift_counter == shift_amount_r) ? DONE : SHIFT; // WE SHIFT THE DATA UNTIL THE SHIFT AMOUNT HAS BEEN REACHED
        DONE:  state_nxt = IDLE; // DONE STATE INDICATED BY CSR_OUT PULSE BIT - DONE SIGNAL
        default: state_nxt = IDLE;
    endcase
end


always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        state_reg       <= IDLE;
        shift_counter   <= 5'd0;
        data_input_r        <= {REG_WIDTH{1'b0}};
        shifting_result_r <= {REG_WIDTH{1'b0}};
        csr_in_re_r <= 1'b0;
        csr_out_we_r <= 1'b0;
        shift_amount_r <= 5'd0;
        use_reg_a <= 1'b0;
        use_reg_b <= 1'b0;
        shift_left_r <= 1'b0;
        shift_right_r <= 1'b0;
    end else begin
        state_reg <= state_nxt;
        csr_out_we_r <= 1'b0;
        csr_in_re_r <= 1'b0;

        case (state_reg)
            IDLE: begin
                if(`CSR_IN_START) begin // TRIGGER THE OPERATION IF A START PULSE IS DETECTED IN CSR_IN PULSE BIT
                    // SAVE ALL THE CSR_IN SIGNALS IN REGISTERS TO PERFORM THE OPERATION //
                    shift_amount_r <= (`CSR_IN_SHIFT_AMOUNT > REG_WIDTH) ? REG_WIDTH[4:0] : `CSR_IN_SHIFT_AMOUNT;
                    use_reg_a <= `CSR_IN_INPUT_DATA_REG_A_SELECTION;
                    use_reg_b <= `CSR_IN_INPUT_DATA_REG_B_SELECTION;
                    shift_left_r <= `CSR_IN_LEFT_SHIFT_DIRECTION;
                    shift_right_r <= `CSR_IN_RIGHT_SHIFT_DIRECTION;
                    csr_in_re_r <= 1'b1; // SET CSR_IN_RE TO 1 IN ORDER TO CONFIRM THAT WE HAVE RECEIVED THE CSR_IN COMMAND
                    shift_counter <= 5'd0; // RESET THE COUNTER
                    shifting_result_r <= {REG_WIDTH{1'b0}};  // WE CLEAN THE OUTPUT
                end
            end
            LOAD: begin
                if (use_reg_a) begin
                    data_input_r <= data_reg_a; // USE DATA_REG_A AS OUR DATA INPUT
                end else if (use_reg_b) begin
                    data_input_r <= data_reg_b; // USE DATA_REG_B AS OUR DATA INPUT
                end else
                    data_input_r <= {REG_WIDTH{1'b0}};  // ALL 0'S IF INPUT DATA IS NOT SELECTED
            end
            SHIFT: begin
                csr_out_we_r <= 1'b1; // ACTIVATING THE CSR_OUT_WE TO WRITE THE BUSY SIGNAL IN CSR_OUT STABLE BIT
                shift_counter <= shift_counter + 1; // ADDING 1 TO THE SHIFT COUNTER

                if (shift_left_r) begin
                    shifting_result_r <= {shifting_result_r[REG_WIDTH-2:0], data_input_r[REG_WIDTH-1]};  // ← MSB FROM INPUT TO LSB OF OUTPUT
                    data_input_r        <= {data_input_r[REG_WIDTH-2:0], 1'b0};  // ← SHIFT INPUT LEFT
                end else if (shift_right_r) begin
                    shifting_result_r <= {data_input_r[0], shifting_result_r[REG_WIDTH-1:1]};  // ← LSB FROM INPUT TO MSB OF OUTPUT
                    data_input_r        <= {1'b0, data_input_r[REG_WIDTH-1:1]};  // ← SHIFT INPUT RIGHT
                end
            end
            DONE: begin
                csr_out_we_r <= 1'b1; // ENABLE WRITING TO CSR_OUT TO INDICATE THE DONE FLAG STATUS
            end
            default: begin                         
            end
        endcase
    end
end




assign busy = (state_reg == SHIFT); // ASSIGN BUSY SIGNAL TO HIGH IF THE FSM IS SHIFTING, CURRENT STATE = BUSY
assign done = (state_reg == DONE);  // ASSIGN DONE SIGNAL TO HIGH IF THE FSM HAS FINISHED THE OPERATION, CURRENT STATE = DONE
assign csr_out_we = csr_out_we_r; // ASSIGN THE CSR_OUT_WE_INTERNAL SIGNAL USED IN THE LOGIC TO CSR_OUT_WE OUTPUT
assign csr_out = {busy, 14'd0, done}; // CONCATENATE BUSY SIGNAL IN THE STABLE BIT AND DONE SIGNAL IN THE PULSE BIT OF CSR_OUT
assign data_reg_c = shifting_result_r; // ASSIGN THE RESULT FROM THE SHIFTING OPERATION TO DATA_REG_C OUTPUT
assign csr_in_re = csr_in_re_r; // ASSIGN THE CSR_IN_RE_INTERNAL SIGNAL USED IN THE LOGIC TO CSR_IN_RE OUTPUT
    
endmodule
