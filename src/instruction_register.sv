module instruction_register (
    `include "defines.sv"

    input                          tck_ir,
    input                          tdi,
    input                          tl_reset, 
    input                          captureIR,
    input                          updateIR,
    output logic                   tdo,
    output logic [`INST_COUNT-1:0] instructions
);

logic [`INST_REG_WIDTH:0]  shift_reg;
logic [`INST_COUNT-1:0]    decoded;


// assign shift_reg[`INST_REG_WIDTH] = tdi;
// assign tdo = shift_reg[0];

// Shift register
/*always @(posedge tck_ir) begin
     shift_reg[`INST_REG_WIDTH] = tdi;
    shift_reg[0] <= shift_reg[1] || captureIR;  // 7.1.1 (d)
end
genvar i;
for (i = `INST_REG_WIDTH; i > 1; i = i - 1) begin
    always @(posedge tck_ir) begin
        tdo = shift_reg[0];
        shift_reg[i-1] <= shift_reg[i] && ~captureIR;  // 7.1.1 (e)
    end
end
*/


// Shift register
always @(posedge tck_ir or posedge tl_reset) begin
    if (tl_reset) begin
        shift_reg <= '0;
        tdo <= 0; // Ensure tdo is also reset
    end else begin
        shift_reg <= {tdi, shift_reg[`INST_REG_WIDTH:1]};
        shift_reg[0] <= shift_reg[1] || captureIR;  // 7.1.1 (d)
        tdo <= shift_reg[0]; // Nonblocking assignment to tdo
    end
end

// Shift register logic for intermediate bits
genvar i;
generate
    for (i = `INST_REG_WIDTH; i > 1; i = i - 1) begin : shift_reg_update
        always @(posedge tck_ir or posedge tl_reset) begin
            if (tl_reset) begin
                shift_reg[i-1] <= 0;
            end else begin
                shift_reg[i-1] <= shift_reg[i] && ~captureIR;  // 7.1.1 (e)
            end
        end
    end
endgenerate

    
// Instruction decoder
//8.1.1 (e)
always_comb begin
    unique0 case (shift_reg[`INST_REG_WIDTH-1:0]) // TODO: check spec for default case behavior
        `E_BYPASS         : decoded <= `D_BYPASS;
        `E_SAMPLE_PRELOAD : decoded <= `D_SAMPLE_PRELOAD;
        `E_EXTEST         : decoded <= `D_EXTEST;
        `E_INTEST         : decoded <= `D_INTEST;
        `E_IDCODE         : decoded <= `D_IDCODE;
        `E_CLAMP          : decoded <= `D_CLAMP;
        `E_HALT           : decoded <= `D_HALT;
        `E_STEP           : decoded <= `D_STEP;
        `E_RESUME         : decoded <= `D_RESUME;
        `E_RESET          : decoded <= `D_RESET;
        default           : decoded <= 'bx;
    endcase
end

// Instruction latch
always @(posedge updateIR or negedge tl_reset) begin
    if (~tl_reset)
        instructions <= `D_IDCODE;  // 7.2.1 (e,f)
    else if (updateIR)
        instructions <= decoded;
end

endmodule // instruction_register
