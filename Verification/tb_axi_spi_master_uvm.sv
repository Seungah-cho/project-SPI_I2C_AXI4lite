import uvm_pkg::*;
`include "uvm_macros.svh"

interface axi_spi_if (
    input logic clk,
    input logic reset_n
);
    // AXI4-Lite signal
    logic [ 4:0] awaddr;
    logic [ 2:0] awprot;
    logic        awvalid;
    logic        awready;
    logic [31:0] wdata;
    logic [ 3:0] wstrb;
    logic        wvalid;
    logic        wready;
    logic [ 1:0] bresp;
    logic        bvalid;
    logic        bready;
    logic [ 4:0] araddr;
    logic [ 2:0] arprot;
    logic        arvalid;
    logic        arready;
    logic [31:0] rdata;
    logic [ 1:0] rresp;
    logic        rvalid;
    logic        rready;

    // SPI signal (모니터링, Slave용)
    logic        spi_sclk;
    logic        spi_mosi;
    logic        spi_miso;

    // tb용 내부 변수
    logic [ 7:0] tb_s_tx_data;  // 가짜 Slave가 전송할 데이터

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output awaddr, awprot, awvalid, wdata, wstrb, wvalid, bready;
        output araddr, arprot, arvalid, rready;
        output tb_s_tx_data;
        input awready, wready, bresp, bvalid;
        input arready, rdata, rresp, rvalid;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input awaddr, awvalid, awready, wdata, wvalid, wready;
        input araddr, arvalid, arready, rdata, rvalid, rready;
        input spi_sclk, spi_mosi, spi_miso, tb_s_tx_data;
    endclocking
endinterface  //axi_spi_if


class axi_spi_seq_item extends uvm_sequence_item;
    rand logic [7:0] m_tx_data;
    rand logic [7:0] s_tx_data;
    logic            cpol       = 0;  // mode0만 사용하기 때문.
    logic            cpha       = 0;

    logic      [7:0] m_rx_data;

    constraint c_data {
        m_tx_data inside {[8'h00 : 8'hff]};
        s_tx_data inside {[8'h00 : 8'hff]};
    }

    `uvm_object_utils_begin(axi_spi_seq_item)
        `uvm_field_int(m_tx_data, UVM_ALL_ON)
        `uvm_field_int(s_tx_data, UVM_ALL_ON)
        `uvm_field_int(m_rx_data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_spi_seq_item");
        super.new(name);
    endfunction  //new()

    virtual function string convert2string();
        return $sformatf(
            "[AXI Write] m_tx=0x%02h, s_tx=0x%02h | [AXI Read] m_rx=0x%02h",
            m_tx_data,
            s_tx_data,
            m_rx_data
        );
    endfunction
endclass  //axi_spi_seq_item


class axi_spi_seq extends uvm_sequence #(axi_spi_seq_item);
    `uvm_object_utils(axi_spi_seq)

    int num_trans = 10;

    function new(string name = "axi_spi_seq");
        super.new(name);
    endfunction  //new()

    task body();
        axi_spi_seq_item item;
        repeat (num_trans) begin
            item = axi_spi_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(), "axi_spi_seq_item Randomize fail!")
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM)
            finish_item(item);
        end
    endtask  //body()
endclass  //axi_spi_seq


class axi_spi_continuous_seq extends uvm_sequence #(axi_spi_seq_item);
    `uvm_object_utils(axi_spi_continuous_seq)

    int num_trans = 15000;

    function new(string name = "axi_spi_continuous_seq");
        super.new(name);
    endfunction

    task body();
        axi_spi_seq_item item;
        repeat (num_trans) begin
            item = axi_spi_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(), "Randomize fail!")
            finish_item(item);
        end
    endtask
endclass  //axi_spi_continuous_seq


class axi_spi_corner_seq extends uvm_sequence #(axi_spi_seq_item);
    `uvm_object_utils(axi_spi_corner_seq)

    logic [7:0] patterns[] = '{
        8'h00,  // All 0
        8'hFF,  // All 1
        8'h55,  // 01010101
        8'hAA,  // 10101010
        8'h01,  // 00000001
        8'h02,  // 00000010
        8'h04,  // 00000100
        8'h08,  // 00001000
        8'h10,  // 00010000
        8'h20,  // 00100000
        8'h40,  // 01000000
        8'h80,  // 10000000
        8'hFE,  // 11111110
        8'h7F   // 01111111
    };

    function new(string name="axi_spi_corner_seq");
        super.new(name);
    endfunction

    task body();
        axi_spi_seq_item item;
        
        foreach(patterns[i]) begin
            foreach(patterns[j]) begin
                item = axi_spi_seq_item::type_id::create("item");
                start_item(item);
                
                if (!item.randomize() with {
                    m_tx_data == patterns[i];
                    s_tx_data == patterns[j]; 
                }) `uvm_fatal(get_type_name(), "Randomize fail!")
                
                finish_item(item);
            end
        end
    endtask
endclass


class axi_spi_driver extends uvm_driver #(axi_spi_seq_item);
    `uvm_component_utils(axi_spi_driver)

    virtual axi_spi_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_spi_if)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal(
                get_type_name(),
                "AXI SPI interface를 config db에서 찾을 수 없음.")
        end
    endfunction

    task run_phase(uvm_phase phase);
        axi_spi_seq_item item;

        // AXI 신호 초기화
        vif.drv_cb.awvalid <= 0;
        vif.drv_cb.wvalid  <= 0;
        vif.drv_cb.bready  <= 0;
        vif.drv_cb.arvalid <= 0;
        vif.drv_cb.rready  <= 0;
        wait (vif.reset_n == 1'b1);

        // CLKDIV 레지스터(0x10) 초기화
        axi_write(5'h10, 32'd4);

        forever begin
            seq_item_port.get_next_item(item);

            vif.drv_cb.tb_s_tx_data <= item.s_tx_data;

            `uvm_info(get_type_name(), $sformatf(
                      "[DRV] (AXI Write) TX_DATA: 0x%02h", item.m_tx_data),
                      UVM_HIGH)
            // TXDATA 레지스터 쓰기
            axi_write(5'h08, {24'd0, item.m_tx_data});

            // CTRL 레지스터 쓰기
            axi_write(5'h00, {29'd0, item.cpha, item.cpol, 1'b1});

            // Start 비트 Clear
            axi_write(5'h00, {29'd0, item.cpha, item.cpol, 1'b0});

            // STATUS 레지스터 폴링
            poll_done();

            // RXDATA 레지스터 읽기
            axi_read(5'h0C, item.m_rx_data);
            `uvm_info(get_type_name(), $sformatf(
                      "[DRV] (AXI Read) RX_DATA: 0x%02h", item.m_rx_data),
                      UVM_HIGH)
            seq_item_port.item_done();
        end
    endtask


    task axi_write(input [4:0] addr, input [31:0] data);
        @(vif.drv_cb);
        vif.drv_cb.awaddr  <= addr;
        vif.drv_cb.awvalid <= 1'b1;
        vif.drv_cb.wdata   <= data;
        vif.drv_cb.wstrb   <= 4'hF;
        vif.drv_cb.wvalid  <= 1'b1;
        vif.drv_cb.bready  <= 1'b1;

        fork
            begin
                // awready가 1이 될 때까지 클럭 엣지마다 대기
                do @(vif.drv_cb); while (vif.drv_cb.awready !== 1'b1);
                vif.drv_cb.awvalid <= 1'b0;
            end
            begin
                // wready가 1이 될 때까지 클럭 엣지마다 대기
                do @(vif.drv_cb); while (vif.drv_cb.wready !== 1'b1);
                vif.drv_cb.wvalid <= 1'b0;
            end
        join

        // bvalid 대기
        do @(vif.drv_cb); while (vif.drv_cb.bvalid !== 1'b1);
        vif.drv_cb.bready <= 1'b0;
    endtask


    task axi_read(input [4:0] addr, output logic [31:0] data);
        @(vif.drv_cb);
        vif.drv_cb.araddr  <= addr;
        vif.drv_cb.arvalid <= 1'b1;
        vif.drv_cb.rready  <= 1'b1;

        // arready 대기
        do @(vif.drv_cb); while (vif.drv_cb.arready !== 1'b1);
        vif.drv_cb.arvalid <= 1'b0;

        // rvalid 대기
        do @(vif.drv_cb); while (vif.drv_cb.rvalid !== 1'b1);
        data = vif.drv_cb.rdata;
        vif.drv_cb.rready <= 1'b0;
    endtask

    task poll_done();
        logic [31:0] rdata;

        axi_read(5'h04, rdata);  // Status Read

        // while ((rdata & 32'h2) == 0) begin  // done is bit 1
        // (AXI BUS를 통해 register를 한 번 read하는데 최소 3~5 사이클 이상이 소요.
        // done이 1 clk 동안만 1이 되기 때문에 Driver가 done=1을 캡처하지 못하고 무한 루프에 빠졌음.
        // 그래서 done=1이 되는 것을 기다리는 대신 busy=0이 되는 것을 기다리는 방식 사용.)
        while ((rdata & 32'h1) == 1) begin // bit 0 (busy)가 1인 동안 계속 폴링 -> 0이 되면 완료된 것
            axi_read(5'h04, rdata);
        end
    endtask
endclass  //axi_spi_driver


class axi_spi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_spi_monitor)
    uvm_analysis_port #(axi_spi_seq_item) ap;
    virtual axi_spi_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual axi_spi_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),
                       "axi_spi_if를 config_db에서 찾을 수 없음.");
    endfunction

    task run_phase(uvm_phase phase);
        axi_spi_seq_item item;
        logic [7:0] captured_tx_data;

        forever begin
            item = axi_spi_seq_item::type_id::create("item");

            // TXDATA 쓰기 감지
            wait_axi_write(5'h08, captured_tx_data);
            item.m_tx_data = captured_tx_data;
            item.s_tx_data = vif.mon_cb.tb_s_tx_data;

            // RXDATA 읽기 감지
            wait_axi_read(5'h0C, item.m_rx_data);

            `uvm_info(get_type_name(), $sformatf(
                      "[MON] Captured m_tx=0x%02h, s_tx=0x%02h, m_rx=0x%02h",
                      item.m_tx_data,
                      item.s_tx_data,
                      item.m_rx_data
                      ), UVM_HIGH)
            ap.write(item);
        end
    endtask

    task wait_axi_write(input [4:0] target_addr, output logic [7:0] data);
        logic addr_ok = 0;
        logic data_ok = 0;

        while (!(addr_ok && data_ok)) begin
            @(vif.mon_cb);
            if (vif.mon_cb.awvalid && vif.mon_cb.awready && (vif.mon_cb.awaddr == target_addr))
                addr_ok = 1;
            if (vif.mon_cb.wvalid && vif.mon_cb.wready) begin
                if (addr_ok) begin
                    data = vif.mon_cb.wdata[7:0];
                    data_ok = 1;
                end
            end
        end
    endtask

    task wait_axi_read(input [4:0] target_addr, output logic [7:0] data);
        logic addr_ok = 0;

        while (1) begin
            @(vif.mon_cb);
            if (vif.mon_cb.arvalid && vif.mon_cb.arready && (vif.mon_cb.araddr == target_addr))
                addr_ok = 1;
            if (addr_ok && vif.mon_cb.rvalid && vif.mon_cb.rready) begin
                data = vif.mon_cb.rdata[7:0];
                break;
            end
        end
    endtask
endclass  //axi_spi_monitor


class axi_spi_agent extends uvm_agent;
    `uvm_component_utils(axi_spi_agent)

    axi_spi_driver drv;
    axi_spi_monitor mon;
    uvm_sequencer #(axi_spi_seq_item) sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = axi_spi_driver::type_id::create("drv", this);
        mon = axi_spi_monitor::type_id::create("mon", this);
        sqr = uvm_sequencer#(axi_spi_seq_item)::type_id::create("sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass  //axi_spi_agent


class axi_spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_spi_scoreboard)
    uvm_analysis_imp #(axi_spi_seq_item, axi_spi_scoreboard) ap_imp;

    int pass_cnt = 0;
    int fail_cnt = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(axi_spi_seq_item item);
        bit loopback_match = (item.m_tx_data === item.m_rx_data);

        if (!loopback_match) begin
            fail_cnt++;
            `uvm_error(
                get_type_name(),
                $sformatf(
                    "Mismatch!! [Loopback Test] Expected(tx):0x%02h, Actual(rx):0x%02h",
                    item.m_tx_data, item.m_rx_data))
        end else begin
            pass_cnt++;
            `uvm_info(get_type_name(), $sformatf(
                      "Match!! [Loopback Test] Expected(tx):0x%02h, Actual(rx):0x%02h",
                      item.m_tx_data,
                      item.m_rx_data
                      ), UVM_MEDIUM)
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "\n\n", UVM_LOW)
        `uvm_info(get_type_name(), "  ===== Scoreboard Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf(
                  "  Total transactions : %0d", pass_cnt + fail_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Pass : %0d", pass_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("  Fail : %0d", fail_cnt), UVM_LOW)
        if (fail_cnt > 0) begin
            `uvm_error(get_type_name(),
                       $sformatf("  TEST FAILED: %0d mismatches detected!",
                                 fail_cnt))
        end else begin
            `uvm_info(get_type_name(), $sformatf(
                      "  TEST PASSED: %0d all matches detected!", pass_cnt),
                      UVM_LOW)
        end
        `uvm_info(get_type_name(), "  ===== Scoreboard Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), "\n\n", UVM_LOW)
    endfunction
endclass  //axi_spi_scoreboard


class axi_spi_coverage extends uvm_subscriber #(axi_spi_seq_item);
    `uvm_component_utils(axi_spi_coverage)

    logic [7:0] cov_m_tx_data;
    logic [7:0] cov_s_tx_data;

    covergroup cg_data;
        cp_m_tx: coverpoint cov_m_tx_data {
            bins zero = {8'h00};
            bins max = {8'hff};
            bins alt_01 = {8'h55};
            bins alt_10 = {8'haa};
            bins low = {[8'h00 : 8'h3f]};
            bins mid = {[8'h40 : 8'hbf]};
            bins high = {[8'hc0 : 8'hff]};
        }
        cp_s_tx: coverpoint cov_s_tx_data {
            bins zero = {8'h00};
            bins max = {8'hff};
            bins alt_01 = {8'h55};
            bins alt_10 = {8'haa};
            bins low = {[8'h00 : 8'h3f]};
            bins mid = {[8'h40 : 8'hbf]};
            bins high = {[8'hc0 : 8'hff]};
        }
        cx_mtx_stx: cross cp_m_tx, cp_s_tx;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_data = new();
    endfunction

    function void write(axi_spi_seq_item item);
        cov_m_tx_data = item.m_tx_data;
        cov_s_tx_data = item.s_tx_data;
        cg_data.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "\n\n", UVM_LOW);
        `uvm_info(get_type_name(), "  ===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "   Overall: %.1f%%", cg_data.get_coverage()), UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "   m_tx  : %.1f%%", cg_data.cp_m_tx.get_coverage()),
                  UVM_LOW);
        `uvm_info(get_type_name(), $sformatf(
                  "   s_tx  : %.1f%%", cg_data.cp_s_tx.get_coverage()),
                  UVM_LOW);
        `uvm_info(
            get_type_name(), $sformatf(
            "   cross(m_tx, s_tx)  : %.1f%%", cg_data.cx_mtx_stx.get_coverage()
            ), UVM_LOW);
        `uvm_info(get_type_name(), "  ===== Coverage Summary =====", UVM_LOW);
        `uvm_info(get_type_name(), "\n\n", UVM_LOW);
    endfunction
endclass  //axi_spi_coverage


class axi_spi_env extends uvm_env;
    `uvm_component_utils(axi_spi_env)

    axi_spi_agent agt;
    axi_spi_scoreboard scb;
    axi_spi_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = axi_spi_agent::type_id::create("agt", this);
        scb = axi_spi_scoreboard::type_id::create("scb", this);
        cov = axi_spi_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cov.analysis_export);
    endfunction
endclass  //axi_spi_env


class axi_spi_base_test extends uvm_test;
    `uvm_component_utils(axi_spi_base_test)

    axi_spi_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_spi_env::type_id::create("env", this);
    endfunction
endclass  //axi_spi_base_test


class axi_spi_rand_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_rand_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  //new()

    task run_phase(uvm_phase phase);
        axi_spi_seq seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "\n\n\n=== Starting AXI-SPI Random Test ===\n\n", UVM_LOW)
        seq = axi_spi_seq::type_id::create("seq");
        seq.num_trans = 20;
        seq.start(env.agt.sqr);

        #1000;
        phase.drop_objection(this);
    endtask  //run_phase
endclass  //axi_spi_rand_test


class axi_spi_continuous_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_continuous_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi_spi_continuous_seq seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "\n\n\n=== Starting AXI-SPI Continuous Test ===\n\n",
                  UVM_LOW)
        seq = axi_spi_continuous_seq::type_id::create("seq");
        seq.start(env.agt.sqr);

        #1000;
        phase.drop_objection(this);
    endtask
endclass  //axi_spi_continuous_test


class axi_spi_corner_test extends axi_spi_base_test;
    `uvm_component_utils(axi_spi_corner_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi_spi_corner_seq seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(),
                  "\n\n\n=== Starting AXI-SPI Corner Case Test ===\n\n",
                  UVM_LOW)
        seq = axi_spi_corner_seq::type_id::create("seq");
        seq.start(env.agt.sqr);

        #1000;
        phase.drop_objection(this);
    endtask
endclass //axi_spi_corner_test




module tb_axi_spi_master_uvm;
    logic clk, reset_n;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset_n = 0;
        #20 reset_n = 1;
    end

    axi_spi_if vif (
        clk,
        reset_n
    );

    // DUT Instantiation
    SPI_Master_v1_0 dut (
        .miso(vif.spi_miso),
        .mosi(vif.spi_mosi),
        .sclk(vif.spi_sclk),

        .s00_axi_aclk   (clk),
        .s00_axi_aresetn(reset_n),
        .s00_axi_awaddr (vif.awaddr),
        .s00_axi_awprot (vif.awprot),
        .s00_axi_awvalid(vif.awvalid),
        .s00_axi_awready(vif.awready),
        .s00_axi_wdata  (vif.wdata),
        .s00_axi_wstrb  (vif.wstrb),
        .s00_axi_wvalid (vif.wvalid),
        .s00_axi_wready (vif.wready),
        .s00_axi_bresp  (vif.bresp),
        .s00_axi_bvalid (vif.bvalid),
        .s00_axi_bready (vif.bready),
        .s00_axi_araddr (vif.araddr),
        .s00_axi_arprot (vif.arprot),
        .s00_axi_arvalid(vif.arvalid),
        .s00_axi_arready(vif.arready),
        .s00_axi_rdata  (vif.rdata),
        .s00_axi_rresp  (vif.rresp),
        .s00_axi_rvalid (vif.rvalid),
        .s00_axi_rready (vif.rready)
    );

    // 간단한 Dummy SPI Slave (MISO에 데이터 Loopback 또는 tb_s_tx_data 전송)
    // 실제 검증 시에는 SPI Slave VIP를 사용하는 것이 좋습니다.
    assign vif.spi_miso = vif.spi_mosi;  // Loopback test용 단순화

    initial begin
        uvm_config_db#(virtual axi_spi_if)::set(null, "*", "vif", vif);
        run_test("spi_axi_test");  // env 및 test 등록 후 실행
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_axi_spi_master_uvm, "+all");
    end
endmodule
