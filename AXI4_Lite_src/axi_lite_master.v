module axi_lite_master(
    input  wire        ACLK,
    input  wire        ARESETn,

    // Write Address
    output reg  [31:0] M_AXI_AWADDR,
    output reg         M_AXI_AWVALID,
    input  wire        M_AXI_AWREADY,
    output reg  [2:0]  M_AXI_AWPROT,

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
    output reg  [2:0]  M_AXI_ARPROT,

    // Read Data
    input  wire [31:0] M_AXI_RDATA,
    input  wire [1:0]  M_AXI_RRESP,
    input  wire        M_AXI_RVALID,
    output reg         M_AXI_RREADY
);

parameter 
    RESET_WAIT = 0,
    IDLE = 1,
    WRITE = 2,
    WAIT_B = 3,
    READ = 4,
    WAIT_R = 5,
    DONE = 6;

reg [2:0] state;

always @(posedge ACLK) begin
    if (!ARESETn) begin
        state <= RESET_WAIT;

        M_AXI_AWVALID <= 0;
        M_AXI_WVALID  <= 0;
        M_AXI_BREADY  <= 0;
        M_AXI_ARVALID <= 0;
        M_AXI_RREADY  <= 0;
        M_AXI_AWPROT <= 3'b000;
        M_AXI_ARPROT <= 3'b000;
    end else begin
        case (state)
            RESET_WAIT: begin
                state <= IDLE;
            end
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

                if (M_AXI_ARVALID && M_AXI_ARREADY) begin
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
