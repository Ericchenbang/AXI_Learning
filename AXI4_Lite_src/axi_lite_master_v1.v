module axi_lite_master(
    input  wire        ACLK,
    input  wire        ARESETn,

    // Write Address
    output reg  [31:0] M_AXI_AWADDR,
    output reg         M_AXI_AWVALID,
    input  wire        M_AXI_AWREADY,

    // Write Data
    output reg  [31:0] M_AXI_WDATA,
    output reg  [3:0]  M_AXI_WSTRB,
    output reg         M_AXI_WVALID,
    input  wire        M_AXI_WREADY,

    // Write Response
    input  wire [1:0]  M_AXI_BRESP,
    input  wire        M_AXI_BVALID,
    output reg         M_AXI_BREADY,

    // Read Address
    output reg  [31:0] M_AXI_ARADDR,
    output reg         M_AXI_ARVALID,
    input  wire        M_AXI_ARREADY,

    // Read Data
    input  wire [31:0] M_AXI_RDATA,
    input  wire [1:0]  M_AXI_RRESP,
    input  wire        M_AXI_RVALID,
    output reg         M_AXI_RREADY
);

parameter IDLE = 0, WRITE = 1, WAIT_B = 2, READ = 3, WAIT_R = 4, DONE = 5;
reg [2:0] state;

always @(posedge ACLK) begin
    if (!ARESETn) begin
        state <= IDLE;

        M_AXI_AWVALID <= 0;
        M_AXI_WVALID  <= 0;
        M_AXI_BREADY  <= 0;
        M_AXI_ARVALID <= 0;
        M_AXI_RREADY  <= 0;
    end else begin
        case (state)

        IDLE: begin
            // prepare write
            M_AXI_AWADDR  <= 32'h0000_0004;
            M_AXI_WDATA   <= 32'h1234_5678;
            M_AXI_WSTRB  <= 4'b1111;

            M_AXI_AWVALID <= 1;
            M_AXI_WVALID  <= 1;

            state <= WRITE;
        end

        WRITE: begin
            if (M_AXI_AWREADY) M_AXI_AWVALID <= 0;
            if (M_AXI_WREADY)  M_AXI_WVALID  <= 0;

            if (!M_AXI_AWVALID && !M_AXI_WVALID) begin
                M_AXI_BREADY <= 1;
                state <= WAIT_B;
            end
        end

        WAIT_B: begin
            if (M_AXI_BVALID) begin
                M_AXI_BREADY <= 0;
                state <= READ;
            end
        end

        READ: begin
            M_AXI_ARADDR  <= 32'h0000_0004;
            M_AXI_ARVALID <= 1;

            if (M_AXI_ARREADY) begin
                M_AXI_ARVALID <= 0;
                M_AXI_RREADY  <= 1;
                state <= WAIT_R;
            end
        end

        WAIT_R: begin
            if (M_AXI_RVALID) begin
                // we can check M_AXI_RDATA here
                M_AXI_RREADY <= 0;
                state <= DONE;
            end
        end

        DONE: begin
            // stop here
            state <= DONE;
        end
        endcase
    end
end
endmodule