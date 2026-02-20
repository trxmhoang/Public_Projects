module reg_file #(
    parameter ADDR_WIDTH = 4
)(
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,

    input wire [ADDR_WIDTH-1:0] awaddr,
    input wire [31:0] wdata,
    input wire [3:0] wstrb,

    input wire [ADDR_WIDTH-1:0] araddr,
    output reg [31:0] rdata,

    output reg start,
    output reg irq,
    input wire [1:0] status,
    input wire [1:0] err_code
);

    localparam ADDR_CTRL = 0;
    localparam ADDR_STATUS = 4;
    localparam ADDR_ERR = 8;

    // Write Strobe
    wire [31:0] mask, wdata_mask;
    assign mask = {{8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}}};
    assign wdata_mask = wdata & mask;

    // Control Register
    reg ier;
    wire ctrl_sel = (awaddr == ADDR_CTRL) & wr_en & wstrb[0];
    wire start_next = ctrl_sel ? wdata[0] : start;
    wire ier_next = ctrl_sel ? wdata[1] : ier;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start <= 0;
            ier <= 0;
        end else begin
            start <= start_next;
            ier <= ier_next;
        end
    end

    always @(*) begin
        if (ier && (status == 2 || status == 3)) begin
            irq = 1;
        end else begin
            irq = 0;
        end
    end

    // Read Logic
    reg [31:0] rdata_next;
    always @(*) begin
        case (araddr)
            ADDR_CTRL: rdata_next = {30'b0, ier, start};
            ADDR_STATUS: rdata_next = {30'b0, status};
            ADDR_ERR: rdata_next = {30'b0, err_code};
            default: rdata_next = 32'b0;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rdata <= 32'b0;
        else if (rd_en) begin
            rdata <= rdata_next;
        end else begin
            rdata <= 32'b0;
        end
    end
endmodule