`timescale 1ns / 1ps

module mips_pipeline(
    input wire clk,
    input wire rst
);

    // =========================================================
    // Memories
    // =========================================================
    reg [31:0] IMEM [0:255];
    reg [31:0] DMEM [0:255];

integer i;



initial begin
    for (i = 0; i < 256; i = i + 1) begin
        IMEM[i] = 32'd0;
        DMEM[i] = 32'd0;
    end

    for (i = 0; i < 32; i = i + 1)
        REG[i] = 32'd0;

    $readmemb("instr.txt", IMEM);
    $readmemb("data.txt",  DMEM);
end

    // =========================================================
    // Register File
    // =========================================================
    reg [31:0] REG [0:31];

    // =========================================================
    // IF stage
    // =========================================================
    reg  [31:0] pc_reg;
    wire [31:0] pc_plus4;
    reg  [31:0] next_pc;
    wire [31:0] instr_f;

    assign pc_plus4 = pc_reg + 32'd4;
    assign instr_f  = IMEM[pc_reg[31:2]];

    // IF/ID pipeline register
    reg [31:0] if_id_npc;
    reg [31:0] if_id_instr;

    // =========================================================
    // ID stage
    // =========================================================
    wire [5:0] id_opcode;
    wire [4:0] id_rs;
    wire [4:0] id_rt;
    wire [4:0] id_rd;
    wire [5:0] id_funct;
    wire [15:0] id_imm16;

    reg  [1:0] id_wb;
    reg  [2:0] id_mem;
    reg  [3:0] id_ex_ctrl;

    reg [31:0] reg_read_data1;
    reg [31:0] reg_read_data2;
    wire [31:0] sign_ext_imm;

    assign id_opcode = if_id_instr[31:26];
    assign id_rs     = if_id_instr[25:21];
    assign id_rt     = if_id_instr[20:16];
    assign id_rd     = if_id_instr[15:11];
    assign id_imm16  = if_id_instr[15:0];
    assign id_funct  = if_id_instr[5:0];

    assign sign_ext_imm = {{16{id_imm16[15]}}, id_imm16};

    // Combinational register reads
    always @(*) begin
        reg_read_data1 = REG[id_rs];
        reg_read_data2 = REG[id_rt];
    end

    // Combinational control
    // wb[1] = RegWrite
    // wb[0] = MemToReg
    // mem[2] = Branch
    // mem[1] = MemRead
    // mem[0] = MemWrite
    // ex[3] = RegDst
    // ex[2:1] = ALUOp
    // ex[0] = ALUSrc
    always @(*) begin
        id_wb      = 2'b00;
        id_mem     = 3'b000;
        id_ex_ctrl = 4'b0000;

        case (id_opcode)
            6'b000000: begin
                // R-type
                id_wb      = 2'b10;
                id_mem     = 3'b000;
                id_ex_ctrl = 4'b1100;
            end

            6'b100011: begin
                // LW
                id_wb      = 2'b11;
                id_mem     = 3'b010;
                id_ex_ctrl = 4'b0001;
            end

            6'b101011: begin
                // SW
                id_wb      = 2'b00;
                id_mem     = 3'b001;
                id_ex_ctrl = 4'b0001;
            end

            6'b000100: begin
                // BEQ
                id_wb      = 2'b00;
                id_mem     = 3'b100;
                id_ex_ctrl = 4'b0010;
            end

            default: begin
                // Treat anything else as NOP / bubble
                id_wb      = 2'b00;
                id_mem     = 3'b000;
                id_ex_ctrl = 4'b0000;
            end
        endcase
    end

    // =========================================================
    // ID/EX pipeline register
    // =========================================================
    reg [1:0]  id_ex_wb;
    reg [2:0]  id_ex_mem;
    reg [3:0]  id_ex_exec;
    reg [31:0] id_ex_npc;
    reg [31:0] id_ex_readdat1;
    reg [31:0] id_ex_readdat2;
    reg [31:0] id_ex_sign_ext;
    reg [4:0]  id_ex_rt;
    reg [4:0]  id_ex_rd;
    reg [5:0]  id_ex_funct;

    // =========================================================
    // EX stage
    // =========================================================
    wire       ex_regdst;
    wire [1:0] ex_aluop;
    wire       ex_alusrc;

    reg  [31:0] ex_branch_addr;
    reg  [31:0] ex_alu_src_b;
    reg  [2:0]  ex_alu_control;
    reg  [31:0] ex_alu_result;
    reg         ex_zero;
    reg  [4:0]  ex_write_reg;

    assign ex_regdst = id_ex_exec[3];
    assign ex_aluop  = id_ex_exec[2:1];
    assign ex_alusrc = id_ex_exec[0];

    always @(*) begin
        ex_branch_addr = id_ex_npc + (id_ex_sign_ext << 2);
        ex_alu_src_b   = ex_alusrc ? id_ex_sign_ext : id_ex_readdat2;
        ex_write_reg   = ex_regdst ? id_ex_rd : id_ex_rt;

        case (ex_aluop)
            2'b00: ex_alu_control = 3'b010; // add
            2'b01: ex_alu_control = 3'b110; // sub
            2'b10: begin
                case (id_ex_funct)
                    6'b100000: ex_alu_control = 3'b010; // add
                    6'b100010: ex_alu_control = 3'b110; // sub
                    6'b100100: ex_alu_control = 3'b000; // and
                    6'b100101: ex_alu_control = 3'b001; // or
                    6'b101010: ex_alu_control = 3'b111; // slt
                    default:   ex_alu_control = 3'b010;
                endcase
            end
            default: ex_alu_control = 3'b010;
        endcase

        case (ex_alu_control)
            3'b000: ex_alu_result = id_ex_readdat1 & ex_alu_src_b;
            3'b001: ex_alu_result = id_ex_readdat1 | ex_alu_src_b;
            3'b010: ex_alu_result = id_ex_readdat1 + ex_alu_src_b;
            3'b110: ex_alu_result = id_ex_readdat1 - ex_alu_src_b;
            3'b111: ex_alu_result = ($signed(id_ex_readdat1) < $signed(ex_alu_src_b)) ? 32'd1 : 32'd0;
            default: ex_alu_result = 32'd0;
        endcase

        ex_zero = (ex_alu_result == 32'd0);
    end

    // =========================================================
    // EX/MEM pipeline register
    // =========================================================
    reg [1:0]  ex_mem_wb;
    reg [2:0]  ex_mem_mem;
    reg [31:0] ex_mem_br_addr;
    reg        ex_mem_zero;
    reg [31:0] ex_mem_alu_out;
    reg [31:0] ex_mem_rdata2;
    reg [4:0]  ex_mem_write_reg;

    // =========================================================
    // MEM stage
    // =========================================================
    wire ex_mem_branch;
    wire pc_src;
    reg  [31:0] mem_read_data;

    assign ex_mem_branch = ex_mem_mem[2];
    assign pc_src        = ex_mem_branch & ex_mem_zero;

    always @(*) begin
        if (ex_mem_mem[1])
            mem_read_data = DMEM[ex_mem_alu_out[7:0]];
        else
            mem_read_data = 32'd0;
    end

    // =========================================================
    // MEM/WB pipeline register
    // =========================================================
    reg        wb_regwrite;
    reg        wb_memtoreg;
    reg [31:0] wb_read_data;
    reg [31:0] wb_alu_result;
    reg [4:0]  wb_write_reg;
    wire [31:0] wb_write_data;

    assign wb_write_data = wb_memtoreg ? wb_read_data : wb_alu_result;

    // =========================================================
    // Next PC selection
    // =========================================================
    always @(*) begin
        if (pc_src)
            next_pc = ex_mem_br_addr;
        else
            next_pc = pc_plus4;
    end

    // =========================================================
    // Sequential logic: reset, writeback, memory write, pipeline regs
    // =========================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg          <= 32'd0;
            if_id_npc       <= 32'd0;
            if_id_instr     <= 32'd0;

            id_ex_wb        <= 2'd0;
            id_ex_mem       <= 3'd0;
            id_ex_exec      <= 4'd0;
            id_ex_npc       <= 32'd0;
            id_ex_readdat1  <= 32'd0;
            id_ex_readdat2  <= 32'd0;
            id_ex_sign_ext  <= 32'd0;
            id_ex_rt        <= 5'd0;
            id_ex_rd        <= 5'd0;
            id_ex_funct     <= 6'd0;

            ex_mem_wb       <= 2'd0;
            ex_mem_mem      <= 3'd0;
            ex_mem_br_addr  <= 32'd0;
            ex_mem_zero     <= 1'b0;
            ex_mem_alu_out  <= 32'd0;
            ex_mem_rdata2   <= 32'd0;
            ex_mem_write_reg <= 5'd0;

            wb_regwrite     <= 1'b0;
            wb_memtoreg     <= 1'b0;
            wb_read_data    <= 32'd0;
            wb_alu_result   <= 32'd0;
            wb_write_reg    <= 5'd0;

            for (i = 0; i < 32; i = i + 1)
                REG[i] <= 32'd0;
        end
        else begin
            // -------------------------
            // WB stage write to regfile
            // -------------------------
            if (wb_regwrite && (wb_write_reg != 5'd0))
                REG[wb_write_reg] <= wb_write_data;

            REG[0] <= 32'd0;

            // -------------------------
            // MEM stage write to DMEM
            // -------------------------
            if (ex_mem_mem[0])
                DMEM[ex_mem_alu_out] <= ex_mem_rdata2;

            // -------------------------
            // Update PC
            // -------------------------
            pc_reg <= next_pc;

            // -------------------------
            // IF/ID
            // -------------------------
            if_id_npc   <= pc_plus4;
            if_id_instr <= instr_f;

            // -------------------------
            // ID/EX
            // -------------------------
            id_ex_wb        <= id_wb;
            id_ex_mem       <= id_mem;
            id_ex_exec      <= id_ex_ctrl;
            id_ex_npc       <= if_id_npc;
            id_ex_readdat1  <= reg_read_data1;
            id_ex_readdat2  <= reg_read_data2;
            id_ex_sign_ext  <= sign_ext_imm;
            id_ex_rt        <= id_rt;
            id_ex_rd        <= id_rd;
            id_ex_funct     <= id_funct;

            // -------------------------
            // EX/MEM
            // -------------------------
            ex_mem_wb        <= id_ex_wb;
            ex_mem_mem       <= id_ex_mem;
            ex_mem_br_addr   <= ex_branch_addr;
            ex_mem_zero      <= ex_zero;
            ex_mem_alu_out   <= ex_alu_result;
            ex_mem_rdata2    <= id_ex_readdat2;
            ex_mem_write_reg <= ex_write_reg;

            // -------------------------
            // MEM/WB
            // -------------------------
            wb_regwrite   <= ex_mem_wb[1];
            wb_memtoreg   <= ex_mem_wb[0];
            wb_read_data  <= mem_read_data;
            wb_alu_result <= ex_mem_alu_out;
            wb_write_reg  <= ex_mem_write_reg;
        end
    end

endmodule


// Optional wrapper for compatibility with older projects
module top(
    input wire clk,
    input wire rst
);
    mips_pipeline uut (
        .clk(clk),
        .rst(rst)
    );
endmodule