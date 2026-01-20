`timescale 1ns/1ps

module tb_axi_lite_master;

  // --------------------------------------------------
  // clock & reset
  // --------------------------------------------------
  logic ACLK;
  logic ARESETn;

  initial begin
    ACLK = 0;
    forever #5 ACLK = ~ACLK;   // 100 MHz
  end

  initial begin
    ARESETn = 0;
    #100;
    ARESETn = 1;
  end

  // --------------------------------------------------
  // AXI signals
  // --------------------------------------------------
  logic [31:0] AWADDR;
  logic        AWVALID;
  logic        AWREADY;

  logic [31:0] WDATA;
  logic [3:0]  WSTRB;
  logic        WVALID;
  logic        WREADY;

  logic [1:0]  BRESP;
  logic        BVALID;
  logic        BREADY;

  logic [31:0] ARADDR;
  logic        ARVALID;
  logic        ARREADY;

  logic [31:0] RDATA;
  logic [1:0]  RRESP;
  logic        RVALID;
  logic        RREADY;

  // --------------------------------------------------
  // DUT: your AXI master
  // --------------------------------------------------
  axi_lite_master dut (
    .ACLK        (ACLK),
    .ARESETn     (ARESETn),

    .M_AXI_AWADDR (AWADDR),
    .M_AXI_AWVALID(AWVALID),
    .M_AXI_AWREADY(AWREADY),

    .M_AXI_WDATA  (WDATA),
    .M_AXI_WSTRB  (WSTRB),
    .M_AXI_WVALID (WVALID),
    .M_AXI_WREADY (WREADY),

    .M_AXI_BRESP  (BRESP),
    .M_AXI_BVALID (BVALID),
    .M_AXI_BREADY (BREADY),

    .M_AXI_ARADDR (ARADDR),
    .M_AXI_ARVALID(ARVALID),
    .M_AXI_ARREADY(ARREADY),

    .M_AXI_RDATA  (RDATA),
    .M_AXI_RRESP  (RRESP),
    .M_AXI_RVALID (RVALID),
    .M_AXI_RREADY (RREADY)
  );

  // --------------------------------------------------
  // AXI VIP (Slave)
  // --------------------------------------------------
  axi_vip_0 u_axi_vip (
    .aclk    (ACLK),
    .aresetn (ARESETn),

    .s_axi_awaddr  (AWADDR),
    .s_axi_awvalid (AWVALID),
    .s_axi_awready (AWREADY),

    .s_axi_wdata   (WDATA),
    .s_axi_wstrb   (WSTRB),
    .s_axi_wvalid  (WVALID),
    .s_axi_wready  (WREADY),

    .s_axi_bresp   (BRESP),
    .s_axi_bvalid  (BVALID),
    .s_axi_bready  (BREADY),

    .s_axi_araddr  (ARADDR),
    .s_axi_arvalid (ARVALID),
    .s_axi_arready (ARREADY),

    .s_axi_rdata   (RDATA),
    .s_axi_rresp   (RRESP),
    .s_axi_rvalid  (RVALID),
    .s_axi_rready  (RREADY)
  );

endmodule
