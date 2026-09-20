module par_gen(
  input        clock,
  input        reset,
  input  [7:0] io_snd_data_0,
  input  [7:0] io_snd_data_1,
  input  [7:0] io_snd_data_2,
  input  [7:0] io_snd_data_3,
  input  [7:0] io_snd_data_4,
  input  [7:0] io_snd_data_5,
  input  [7:0] io_snd_data_6,
  input  [7:0] io_snd_data_7,
  input        io_snd_data_vld,
  input        io_rcv_data_vld,
  output [7:0] io_parity_data_0,
  output [7:0] io_parity_data_1,
  output [7:0] io_parity_data_2,
  output [7:0] io_parity_data_3,
  output [7:0] io_parity_data_4,
  output [7:0] io_parity_data_5,
  output [7:0] io_parity_data_6,
  output [7:0] io_parity_data_7,
  output       io_parity_insert,
  output       io_parity_check,
  input        io_parity_rdy,
  input  [3:0] io_rdi_state,
  input        io_parity_rx_enable,
  input        io_parity_tx_enable
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
  reg [31:0] _RAND_32;
  reg [31:0] _RAND_33;
  reg [31:0] _RAND_34;
  reg [31:0] _RAND_35;
  reg [31:0] _RAND_36;
  reg [31:0] _RAND_37;
  reg [31:0] _RAND_38;
  reg [31:0] _RAND_39;
  reg [31:0] _RAND_40;
  reg [31:0] _RAND_41;
  reg [31:0] _RAND_42;
  reg [31:0] _RAND_43;
  reg [31:0] _RAND_44;
  reg [31:0] _RAND_45;
  reg [31:0] _RAND_46;
  reg [31:0] _RAND_47;
  reg [31:0] _RAND_48;
  reg [31:0] _RAND_49;
  reg [31:0] _RAND_50;
  reg [31:0] _RAND_51;
  reg [31:0] _RAND_52;
  reg [31:0] _RAND_53;
  reg [31:0] _RAND_54;
  reg [31:0] _RAND_55;
  reg [31:0] _RAND_56;
  reg [31:0] _RAND_57;
  reg [31:0] _RAND_58;
  reg [31:0] _RAND_59;
  reg [31:0] _RAND_60;
  reg [31:0] _RAND_61;
  reg [31:0] _RAND_62;
  reg [31:0] _RAND_63;
  reg [31:0] _RAND_64;
  reg [31:0] _RAND_65;
  reg [31:0] _RAND_66;
  reg [31:0] _RAND_67;
`endif // RANDOMIZE_REG_INIT
  reg  parity_data_snd_reg_0;
  reg  parity_data_snd_reg_1;
  reg  parity_data_snd_reg_2;
  reg  parity_data_snd_reg_3;
  reg  parity_data_snd_reg_4;
  reg  parity_data_snd_reg_5;
  reg  parity_data_snd_reg_6;
  reg  parity_data_snd_reg_7;
  reg  parity_data_snd_reg_8;
  reg  parity_data_snd_reg_9;
  reg  parity_data_snd_reg_10;
  reg  parity_data_snd_reg_11;
  reg  parity_data_snd_reg_12;
  reg  parity_data_snd_reg_13;
  reg  parity_data_snd_reg_14;
  reg  parity_data_snd_reg_15;
  reg  parity_data_snd_reg_16;
  reg  parity_data_snd_reg_17;
  reg  parity_data_snd_reg_18;
  reg  parity_data_snd_reg_19;
  reg  parity_data_snd_reg_20;
  reg  parity_data_snd_reg_21;
  reg  parity_data_snd_reg_22;
  reg  parity_data_snd_reg_23;
  reg  parity_data_snd_reg_24;
  reg  parity_data_snd_reg_25;
  reg  parity_data_snd_reg_26;
  reg  parity_data_snd_reg_27;
  reg  parity_data_snd_reg_28;
  reg  parity_data_snd_reg_29;
  reg  parity_data_snd_reg_30;
  reg  parity_data_snd_reg_31;
  reg  parity_data_snd_reg_32;
  reg  parity_data_snd_reg_33;
  reg  parity_data_snd_reg_34;
  reg  parity_data_snd_reg_35;
  reg  parity_data_snd_reg_36;
  reg  parity_data_snd_reg_37;
  reg  parity_data_snd_reg_38;
  reg  parity_data_snd_reg_39;
  reg  parity_data_snd_reg_40;
  reg  parity_data_snd_reg_41;
  reg  parity_data_snd_reg_42;
  reg  parity_data_snd_reg_43;
  reg  parity_data_snd_reg_44;
  reg  parity_data_snd_reg_45;
  reg  parity_data_snd_reg_46;
  reg  parity_data_snd_reg_47;
  reg  parity_data_snd_reg_48;
  reg  parity_data_snd_reg_49;
  reg  parity_data_snd_reg_50;
  reg  parity_data_snd_reg_51;
  reg  parity_data_snd_reg_52;
  reg  parity_data_snd_reg_53;
  reg  parity_data_snd_reg_54;
  reg  parity_data_snd_reg_55;
  reg  parity_data_snd_reg_56;
  reg  parity_data_snd_reg_57;
  reg  parity_data_snd_reg_58;
  reg  parity_data_snd_reg_59;
  reg  parity_data_snd_reg_60;
  reg  parity_data_snd_reg_61;
  reg  parity_data_snd_reg_62;
  reg  parity_data_snd_reg_63;
  reg [18:0] parity_dcount_snd_reg;
  reg [8:0] parity_pcount_snd_reg;
  reg [18:0] parity_dcount_rcv_reg;
  reg [8:0] parity_pcount_rcv_reg;
  wire  _T_3 = io_rdi_state != 4'h1;
  wire [8:0] _T_5 = parity_pcount_snd_reg + 9'h8;
  wire  _parity_data_snd_reg_56_T_1 = parity_data_snd_reg_0 ^ ^io_snd_data_0;
  wire  _parity_data_snd_reg_57_T_1 = parity_data_snd_reg_1 ^ ^io_snd_data_1;
  wire  _parity_data_snd_reg_58_T_1 = parity_data_snd_reg_2 ^ ^io_snd_data_2;
  wire  _parity_data_snd_reg_59_T_1 = parity_data_snd_reg_3 ^ ^io_snd_data_3;
  wire  _parity_data_snd_reg_60_T_1 = parity_data_snd_reg_4 ^ ^io_snd_data_4;
  wire  _parity_data_snd_reg_61_T_1 = parity_data_snd_reg_5 ^ ^io_snd_data_5;
  wire  _parity_data_snd_reg_62_T_1 = parity_data_snd_reg_6 ^ ^io_snd_data_6;
  wire  _parity_data_snd_reg_63_T_1 = parity_data_snd_reg_7 ^ ^io_snd_data_7;
  wire [18:0] _parity_dcount_snd_reg_T_1 = parity_dcount_snd_reg + 19'h8;
  wire  _GEN_1542 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_8 : parity_data_snd_reg_0;
  wire  _GEN_1543 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_9 : parity_data_snd_reg_1;
  wire  _GEN_1544 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_10 : parity_data_snd_reg_2;
  wire  _GEN_1545 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_11 : parity_data_snd_reg_3;
  wire  _GEN_1546 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_12 : parity_data_snd_reg_4;
  wire  _GEN_1547 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_13 : parity_data_snd_reg_5;
  wire  _GEN_1548 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_14 : parity_data_snd_reg_6;
  wire  _GEN_1549 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_15 : parity_data_snd_reg_7;
  wire  _GEN_1550 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_16 : parity_data_snd_reg_8;
  wire  _GEN_1551 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_17 : parity_data_snd_reg_9;
  wire  _GEN_1552 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_18 : parity_data_snd_reg_10
    ;
  wire  _GEN_1553 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_19 : parity_data_snd_reg_11
    ;
  wire  _GEN_1554 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_20 : parity_data_snd_reg_12
    ;
  wire  _GEN_1555 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_21 : parity_data_snd_reg_13
    ;
  wire  _GEN_1556 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_22 : parity_data_snd_reg_14
    ;
  wire  _GEN_1557 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_23 : parity_data_snd_reg_15
    ;
  wire  _GEN_1558 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_24 : parity_data_snd_reg_16
    ;
  wire  _GEN_1559 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_25 : parity_data_snd_reg_17
    ;
  wire  _GEN_1560 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_26 : parity_data_snd_reg_18
    ;
  wire  _GEN_1561 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_27 : parity_data_snd_reg_19
    ;
  wire  _GEN_1562 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_28 : parity_data_snd_reg_20
    ;
  wire  _GEN_1563 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_29 : parity_data_snd_reg_21
    ;
  wire  _GEN_1564 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_30 : parity_data_snd_reg_22
    ;
  wire  _GEN_1565 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_31 : parity_data_snd_reg_23
    ;
  wire  _GEN_1566 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_32 : parity_data_snd_reg_24
    ;
  wire  _GEN_1567 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_33 : parity_data_snd_reg_25
    ;
  wire  _GEN_1568 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_34 : parity_data_snd_reg_26
    ;
  wire  _GEN_1569 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_35 : parity_data_snd_reg_27
    ;
  wire  _GEN_1570 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_36 : parity_data_snd_reg_28
    ;
  wire  _GEN_1571 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_37 : parity_data_snd_reg_29
    ;
  wire  _GEN_1572 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_38 : parity_data_snd_reg_30
    ;
  wire  _GEN_1573 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_39 : parity_data_snd_reg_31
    ;
  wire  _GEN_1574 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_40 : parity_data_snd_reg_32
    ;
  wire  _GEN_1575 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_41 : parity_data_snd_reg_33
    ;
  wire  _GEN_1576 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_42 : parity_data_snd_reg_34
    ;
  wire  _GEN_1577 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_43 : parity_data_snd_reg_35
    ;
  wire  _GEN_1578 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_44 : parity_data_snd_reg_36
    ;
  wire  _GEN_1579 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_45 : parity_data_snd_reg_37
    ;
  wire  _GEN_1580 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_46 : parity_data_snd_reg_38
    ;
  wire  _GEN_1581 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_47 : parity_data_snd_reg_39
    ;
  wire  _GEN_1582 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_48 : parity_data_snd_reg_40
    ;
  wire  _GEN_1583 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_49 : parity_data_snd_reg_41
    ;
  wire  _GEN_1584 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_50 : parity_data_snd_reg_42
    ;
  wire  _GEN_1585 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_51 : parity_data_snd_reg_43
    ;
  wire  _GEN_1586 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_52 : parity_data_snd_reg_44
    ;
  wire  _GEN_1587 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_53 : parity_data_snd_reg_45
    ;
  wire  _GEN_1588 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_54 : parity_data_snd_reg_46
    ;
  wire  _GEN_1589 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_55 : parity_data_snd_reg_47
    ;
  wire  _GEN_1590 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_56 : parity_data_snd_reg_48
    ;
  wire  _GEN_1591 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_57 : parity_data_snd_reg_49
    ;
  wire  _GEN_1592 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_58 : parity_data_snd_reg_50
    ;
  wire  _GEN_1593 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_59 : parity_data_snd_reg_51
    ;
  wire  _GEN_1594 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_60 : parity_data_snd_reg_52
    ;
  wire  _GEN_1595 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_61 : parity_data_snd_reg_53
    ;
  wire  _GEN_1596 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_62 : parity_data_snd_reg_54
    ;
  wire  _GEN_1597 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_63 : parity_data_snd_reg_55
    ;
  wire  _GEN_1598 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_0 : parity_data_snd_reg_56;
  wire  _GEN_1599 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_1 : parity_data_snd_reg_57;
  wire  _GEN_1600 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_2 : parity_data_snd_reg_58;
  wire  _GEN_1601 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_3 : parity_data_snd_reg_59;
  wire  _GEN_1602 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_4 : parity_data_snd_reg_60;
  wire  _GEN_1603 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_5 : parity_data_snd_reg_61;
  wire  _GEN_1604 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_6 : parity_data_snd_reg_62;
  wire  _GEN_1605 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? parity_data_snd_reg_7 : parity_data_snd_reg_63;
  wire [18:0] _GEN_1798 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? 19'h10000 : parity_dcount_snd_reg;
  wire [8:0] _GEN_1799 = parity_dcount_snd_reg == 19'h10000 & io_parity_rdy ? _T_5 : parity_pcount_snd_reg;
  wire [8:0] _T_21 = parity_pcount_rcv_reg + 9'h8;
  wire  _T_24 = parity_dcount_rcv_reg == 19'h10000;
  wire [18:0] _parity_dcount_rcv_reg_T_1 = parity_dcount_rcv_reg + 19'h8;
  wire [18:0] _GEN_4366 = _T_24 & io_rcv_data_vld ? 19'h10000 : parity_dcount_rcv_reg;
  wire [8:0] _GEN_4367 = _T_24 & io_rcv_data_vld ? _T_21 : parity_pcount_rcv_reg;
  assign io_parity_data_0 = {{7'd0}, parity_data_snd_reg_0};
  assign io_parity_data_1 = {{7'd0}, parity_data_snd_reg_1};
  assign io_parity_data_2 = {{7'd0}, parity_data_snd_reg_2};
  assign io_parity_data_3 = {{7'd0}, parity_data_snd_reg_3};
  assign io_parity_data_4 = {{7'd0}, parity_data_snd_reg_4};
  assign io_parity_data_5 = {{7'd0}, parity_data_snd_reg_5};
  assign io_parity_data_6 = {{7'd0}, parity_data_snd_reg_6};
  assign io_parity_data_7 = {{7'd0}, parity_data_snd_reg_7};
  assign io_parity_insert = parity_dcount_snd_reg == 19'h10000;
  assign io_parity_check = parity_dcount_rcv_reg == 19'h10000;
  always @(posedge clock) begin
    if (reset) begin
      parity_data_snd_reg_0 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_0 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_0 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_0 <= parity_data_snd_reg_8;
    end else begin
      parity_data_snd_reg_0 <= _GEN_1542;
    end
    if (reset) begin
      parity_data_snd_reg_1 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_1 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_1 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_1 <= parity_data_snd_reg_9;
    end else begin
      parity_data_snd_reg_1 <= _GEN_1543;
    end
    if (reset) begin
      parity_data_snd_reg_2 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_2 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_2 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_2 <= parity_data_snd_reg_10;
    end else begin
      parity_data_snd_reg_2 <= _GEN_1544;
    end
    if (reset) begin
      parity_data_snd_reg_3 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_3 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_3 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_3 <= parity_data_snd_reg_11;
    end else begin
      parity_data_snd_reg_3 <= _GEN_1545;
    end
    if (reset) begin
      parity_data_snd_reg_4 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_4 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_4 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_4 <= parity_data_snd_reg_12;
    end else begin
      parity_data_snd_reg_4 <= _GEN_1546;
    end
    if (reset) begin
      parity_data_snd_reg_5 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_5 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_5 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_5 <= parity_data_snd_reg_13;
    end else begin
      parity_data_snd_reg_5 <= _GEN_1547;
    end
    if (reset) begin
      parity_data_snd_reg_6 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_6 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_6 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_6 <= parity_data_snd_reg_14;
    end else begin
      parity_data_snd_reg_6 <= _GEN_1548;
    end
    if (reset) begin
      parity_data_snd_reg_7 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_7 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_7 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_7 <= parity_data_snd_reg_15;
    end else begin
      parity_data_snd_reg_7 <= _GEN_1549;
    end
    if (reset) begin
      parity_data_snd_reg_8 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_8 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_8 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_8 <= parity_data_snd_reg_16;
    end else begin
      parity_data_snd_reg_8 <= _GEN_1550;
    end
    if (reset) begin
      parity_data_snd_reg_9 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_9 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_9 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_9 <= parity_data_snd_reg_17;
    end else begin
      parity_data_snd_reg_9 <= _GEN_1551;
    end
    if (reset) begin
      parity_data_snd_reg_10 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_10 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_10 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_10 <= parity_data_snd_reg_18;
    end else begin
      parity_data_snd_reg_10 <= _GEN_1552;
    end
    if (reset) begin
      parity_data_snd_reg_11 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_11 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_11 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_11 <= parity_data_snd_reg_19;
    end else begin
      parity_data_snd_reg_11 <= _GEN_1553;
    end
    if (reset) begin
      parity_data_snd_reg_12 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_12 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_12 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_12 <= parity_data_snd_reg_20;
    end else begin
      parity_data_snd_reg_12 <= _GEN_1554;
    end
    if (reset) begin
      parity_data_snd_reg_13 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_13 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_13 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_13 <= parity_data_snd_reg_21;
    end else begin
      parity_data_snd_reg_13 <= _GEN_1555;
    end
    if (reset) begin
      parity_data_snd_reg_14 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_14 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_14 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_14 <= parity_data_snd_reg_22;
    end else begin
      parity_data_snd_reg_14 <= _GEN_1556;
    end
    if (reset) begin
      parity_data_snd_reg_15 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_15 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_15 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_15 <= parity_data_snd_reg_23;
    end else begin
      parity_data_snd_reg_15 <= _GEN_1557;
    end
    if (reset) begin
      parity_data_snd_reg_16 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_16 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_16 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_16 <= parity_data_snd_reg_24;
    end else begin
      parity_data_snd_reg_16 <= _GEN_1558;
    end
    if (reset) begin
      parity_data_snd_reg_17 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_17 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_17 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_17 <= parity_data_snd_reg_25;
    end else begin
      parity_data_snd_reg_17 <= _GEN_1559;
    end
    if (reset) begin
      parity_data_snd_reg_18 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_18 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_18 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_18 <= parity_data_snd_reg_26;
    end else begin
      parity_data_snd_reg_18 <= _GEN_1560;
    end
    if (reset) begin
      parity_data_snd_reg_19 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_19 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_19 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_19 <= parity_data_snd_reg_27;
    end else begin
      parity_data_snd_reg_19 <= _GEN_1561;
    end
    if (reset) begin
      parity_data_snd_reg_20 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_20 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_20 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_20 <= parity_data_snd_reg_28;
    end else begin
      parity_data_snd_reg_20 <= _GEN_1562;
    end
    if (reset) begin
      parity_data_snd_reg_21 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_21 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_21 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_21 <= parity_data_snd_reg_29;
    end else begin
      parity_data_snd_reg_21 <= _GEN_1563;
    end
    if (reset) begin
      parity_data_snd_reg_22 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_22 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_22 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_22 <= parity_data_snd_reg_30;
    end else begin
      parity_data_snd_reg_22 <= _GEN_1564;
    end
    if (reset) begin
      parity_data_snd_reg_23 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_23 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_23 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_23 <= parity_data_snd_reg_31;
    end else begin
      parity_data_snd_reg_23 <= _GEN_1565;
    end
    if (reset) begin
      parity_data_snd_reg_24 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_24 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_24 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_24 <= parity_data_snd_reg_32;
    end else begin
      parity_data_snd_reg_24 <= _GEN_1566;
    end
    if (reset) begin
      parity_data_snd_reg_25 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_25 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_25 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_25 <= parity_data_snd_reg_33;
    end else begin
      parity_data_snd_reg_25 <= _GEN_1567;
    end
    if (reset) begin
      parity_data_snd_reg_26 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_26 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_26 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_26 <= parity_data_snd_reg_34;
    end else begin
      parity_data_snd_reg_26 <= _GEN_1568;
    end
    if (reset) begin
      parity_data_snd_reg_27 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_27 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_27 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_27 <= parity_data_snd_reg_35;
    end else begin
      parity_data_snd_reg_27 <= _GEN_1569;
    end
    if (reset) begin
      parity_data_snd_reg_28 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_28 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_28 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_28 <= parity_data_snd_reg_36;
    end else begin
      parity_data_snd_reg_28 <= _GEN_1570;
    end
    if (reset) begin
      parity_data_snd_reg_29 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_29 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_29 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_29 <= parity_data_snd_reg_37;
    end else begin
      parity_data_snd_reg_29 <= _GEN_1571;
    end
    if (reset) begin
      parity_data_snd_reg_30 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_30 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_30 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_30 <= parity_data_snd_reg_38;
    end else begin
      parity_data_snd_reg_30 <= _GEN_1572;
    end
    if (reset) begin
      parity_data_snd_reg_31 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_31 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_31 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_31 <= parity_data_snd_reg_39;
    end else begin
      parity_data_snd_reg_31 <= _GEN_1573;
    end
    if (reset) begin
      parity_data_snd_reg_32 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_32 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_32 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_32 <= parity_data_snd_reg_40;
    end else begin
      parity_data_snd_reg_32 <= _GEN_1574;
    end
    if (reset) begin
      parity_data_snd_reg_33 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_33 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_33 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_33 <= parity_data_snd_reg_41;
    end else begin
      parity_data_snd_reg_33 <= _GEN_1575;
    end
    if (reset) begin
      parity_data_snd_reg_34 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_34 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_34 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_34 <= parity_data_snd_reg_42;
    end else begin
      parity_data_snd_reg_34 <= _GEN_1576;
    end
    if (reset) begin
      parity_data_snd_reg_35 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_35 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_35 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_35 <= parity_data_snd_reg_43;
    end else begin
      parity_data_snd_reg_35 <= _GEN_1577;
    end
    if (reset) begin
      parity_data_snd_reg_36 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_36 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_36 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_36 <= parity_data_snd_reg_44;
    end else begin
      parity_data_snd_reg_36 <= _GEN_1578;
    end
    if (reset) begin
      parity_data_snd_reg_37 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_37 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_37 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_37 <= parity_data_snd_reg_45;
    end else begin
      parity_data_snd_reg_37 <= _GEN_1579;
    end
    if (reset) begin
      parity_data_snd_reg_38 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_38 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_38 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_38 <= parity_data_snd_reg_46;
    end else begin
      parity_data_snd_reg_38 <= _GEN_1580;
    end
    if (reset) begin
      parity_data_snd_reg_39 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_39 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_39 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_39 <= parity_data_snd_reg_47;
    end else begin
      parity_data_snd_reg_39 <= _GEN_1581;
    end
    if (reset) begin
      parity_data_snd_reg_40 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_40 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_40 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_40 <= parity_data_snd_reg_48;
    end else begin
      parity_data_snd_reg_40 <= _GEN_1582;
    end
    if (reset) begin
      parity_data_snd_reg_41 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_41 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_41 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_41 <= parity_data_snd_reg_49;
    end else begin
      parity_data_snd_reg_41 <= _GEN_1583;
    end
    if (reset) begin
      parity_data_snd_reg_42 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_42 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_42 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_42 <= parity_data_snd_reg_50;
    end else begin
      parity_data_snd_reg_42 <= _GEN_1584;
    end
    if (reset) begin
      parity_data_snd_reg_43 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_43 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_43 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_43 <= parity_data_snd_reg_51;
    end else begin
      parity_data_snd_reg_43 <= _GEN_1585;
    end
    if (reset) begin
      parity_data_snd_reg_44 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_44 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_44 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_44 <= parity_data_snd_reg_52;
    end else begin
      parity_data_snd_reg_44 <= _GEN_1586;
    end
    if (reset) begin
      parity_data_snd_reg_45 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_45 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_45 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_45 <= parity_data_snd_reg_53;
    end else begin
      parity_data_snd_reg_45 <= _GEN_1587;
    end
    if (reset) begin
      parity_data_snd_reg_46 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_46 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_46 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_46 <= parity_data_snd_reg_54;
    end else begin
      parity_data_snd_reg_46 <= _GEN_1588;
    end
    if (reset) begin
      parity_data_snd_reg_47 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_47 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_47 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_47 <= parity_data_snd_reg_55;
    end else begin
      parity_data_snd_reg_47 <= _GEN_1589;
    end
    if (reset) begin
      parity_data_snd_reg_48 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_48 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_48 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_48 <= parity_data_snd_reg_56;
    end else begin
      parity_data_snd_reg_48 <= _GEN_1590;
    end
    if (reset) begin
      parity_data_snd_reg_49 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_49 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_49 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_49 <= parity_data_snd_reg_57;
    end else begin
      parity_data_snd_reg_49 <= _GEN_1591;
    end
    if (reset) begin
      parity_data_snd_reg_50 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_50 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_50 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_50 <= parity_data_snd_reg_58;
    end else begin
      parity_data_snd_reg_50 <= _GEN_1592;
    end
    if (reset) begin
      parity_data_snd_reg_51 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_51 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_51 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_51 <= parity_data_snd_reg_59;
    end else begin
      parity_data_snd_reg_51 <= _GEN_1593;
    end
    if (reset) begin
      parity_data_snd_reg_52 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_52 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_52 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_52 <= parity_data_snd_reg_60;
    end else begin
      parity_data_snd_reg_52 <= _GEN_1594;
    end
    if (reset) begin
      parity_data_snd_reg_53 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_53 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_53 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_53 <= parity_data_snd_reg_61;
    end else begin
      parity_data_snd_reg_53 <= _GEN_1595;
    end
    if (reset) begin
      parity_data_snd_reg_54 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_54 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_54 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_54 <= parity_data_snd_reg_62;
    end else begin
      parity_data_snd_reg_54 <= _GEN_1596;
    end
    if (reset) begin
      parity_data_snd_reg_55 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_55 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_55 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_55 <= parity_data_snd_reg_63;
    end else begin
      parity_data_snd_reg_55 <= _GEN_1597;
    end
    if (reset) begin
      parity_data_snd_reg_56 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_56 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_56 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_56 <= _parity_data_snd_reg_56_T_1;
    end else begin
      parity_data_snd_reg_56 <= _GEN_1598;
    end
    if (reset) begin
      parity_data_snd_reg_57 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_57 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_57 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_57 <= _parity_data_snd_reg_57_T_1;
    end else begin
      parity_data_snd_reg_57 <= _GEN_1599;
    end
    if (reset) begin
      parity_data_snd_reg_58 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_58 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_58 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_58 <= _parity_data_snd_reg_58_T_1;
    end else begin
      parity_data_snd_reg_58 <= _GEN_1600;
    end
    if (reset) begin
      parity_data_snd_reg_59 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_59 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_59 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_59 <= _parity_data_snd_reg_59_T_1;
    end else begin
      parity_data_snd_reg_59 <= _GEN_1601;
    end
    if (reset) begin
      parity_data_snd_reg_60 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_60 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_60 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_60 <= _parity_data_snd_reg_60_T_1;
    end else begin
      parity_data_snd_reg_60 <= _GEN_1602;
    end
    if (reset) begin
      parity_data_snd_reg_61 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_61 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_61 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_61 <= _parity_data_snd_reg_61_T_1;
    end else begin
      parity_data_snd_reg_61 <= _GEN_1603;
    end
    if (reset) begin
      parity_data_snd_reg_62 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_62 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_62 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_62 <= _parity_data_snd_reg_62_T_1;
    end else begin
      parity_data_snd_reg_62 <= _GEN_1604;
    end
    if (reset) begin
      parity_data_snd_reg_63 <= 1'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_data_snd_reg_63 <= 1'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_data_snd_reg_63 <= 1'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_data_snd_reg_63 <= _parity_data_snd_reg_63_T_1;
    end else begin
      parity_data_snd_reg_63 <= _GEN_1605;
    end
    if (reset) begin
      parity_dcount_snd_reg <= 19'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_dcount_snd_reg <= 19'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_dcount_snd_reg <= 19'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_dcount_snd_reg <= _parity_dcount_snd_reg_T_1;
    end else begin
      parity_dcount_snd_reg <= _GEN_1798;
    end
    if (reset) begin
      parity_pcount_snd_reg <= 9'h0;
    end else if (io_rdi_state != 4'h1) begin
      parity_pcount_snd_reg <= 9'h0;
    end else if (_T_5 == 9'h40 & io_parity_rdy) begin
      parity_pcount_snd_reg <= 9'h0;
    end else if (io_snd_data_vld & io_parity_tx_enable & parity_dcount_snd_reg != 19'h10000) begin
      parity_pcount_snd_reg <= 9'h0;
    end else begin
      parity_pcount_snd_reg <= _GEN_1799;
    end
    if (reset) begin
      parity_dcount_rcv_reg <= 19'h0;
    end else if (_T_3) begin
      parity_dcount_rcv_reg <= 19'h0;
    end else if (_T_21 == 9'h40 & io_rcv_data_vld & parity_dcount_rcv_reg == 19'h10000) begin
      parity_dcount_rcv_reg <= 19'h0;
    end else if (io_rcv_data_vld & io_parity_rx_enable & parity_dcount_rcv_reg != 19'h10000) begin
      parity_dcount_rcv_reg <= _parity_dcount_rcv_reg_T_1;
    end else begin
      parity_dcount_rcv_reg <= _GEN_4366;
    end
    if (reset) begin
      parity_pcount_rcv_reg <= 9'h0;
    end else if (_T_3) begin
      parity_pcount_rcv_reg <= 9'h0;
    end else if (_T_21 == 9'h40 & io_rcv_data_vld & parity_dcount_rcv_reg == 19'h10000) begin
      parity_pcount_rcv_reg <= 9'h0;
    end else if (io_rcv_data_vld & io_parity_rx_enable & parity_dcount_rcv_reg != 19'h10000) begin
      parity_pcount_rcv_reg <= 9'h0;
    end else begin
      parity_pcount_rcv_reg <= _GEN_4367;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  parity_data_snd_reg_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  parity_data_snd_reg_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  parity_data_snd_reg_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  parity_data_snd_reg_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  parity_data_snd_reg_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  parity_data_snd_reg_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  parity_data_snd_reg_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  parity_data_snd_reg_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  parity_data_snd_reg_8 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  parity_data_snd_reg_9 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  parity_data_snd_reg_10 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  parity_data_snd_reg_11 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  parity_data_snd_reg_12 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  parity_data_snd_reg_13 = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  parity_data_snd_reg_14 = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  parity_data_snd_reg_15 = _RAND_15[0:0];
  _RAND_16 = {1{`RANDOM}};
  parity_data_snd_reg_16 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  parity_data_snd_reg_17 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  parity_data_snd_reg_18 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  parity_data_snd_reg_19 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  parity_data_snd_reg_20 = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  parity_data_snd_reg_21 = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  parity_data_snd_reg_22 = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  parity_data_snd_reg_23 = _RAND_23[0:0];
  _RAND_24 = {1{`RANDOM}};
  parity_data_snd_reg_24 = _RAND_24[0:0];
  _RAND_25 = {1{`RANDOM}};
  parity_data_snd_reg_25 = _RAND_25[0:0];
  _RAND_26 = {1{`RANDOM}};
  parity_data_snd_reg_26 = _RAND_26[0:0];
  _RAND_27 = {1{`RANDOM}};
  parity_data_snd_reg_27 = _RAND_27[0:0];
  _RAND_28 = {1{`RANDOM}};
  parity_data_snd_reg_28 = _RAND_28[0:0];
  _RAND_29 = {1{`RANDOM}};
  parity_data_snd_reg_29 = _RAND_29[0:0];
  _RAND_30 = {1{`RANDOM}};
  parity_data_snd_reg_30 = _RAND_30[0:0];
  _RAND_31 = {1{`RANDOM}};
  parity_data_snd_reg_31 = _RAND_31[0:0];
  _RAND_32 = {1{`RANDOM}};
  parity_data_snd_reg_32 = _RAND_32[0:0];
  _RAND_33 = {1{`RANDOM}};
  parity_data_snd_reg_33 = _RAND_33[0:0];
  _RAND_34 = {1{`RANDOM}};
  parity_data_snd_reg_34 = _RAND_34[0:0];
  _RAND_35 = {1{`RANDOM}};
  parity_data_snd_reg_35 = _RAND_35[0:0];
  _RAND_36 = {1{`RANDOM}};
  parity_data_snd_reg_36 = _RAND_36[0:0];
  _RAND_37 = {1{`RANDOM}};
  parity_data_snd_reg_37 = _RAND_37[0:0];
  _RAND_38 = {1{`RANDOM}};
  parity_data_snd_reg_38 = _RAND_38[0:0];
  _RAND_39 = {1{`RANDOM}};
  parity_data_snd_reg_39 = _RAND_39[0:0];
  _RAND_40 = {1{`RANDOM}};
  parity_data_snd_reg_40 = _RAND_40[0:0];
  _RAND_41 = {1{`RANDOM}};
  parity_data_snd_reg_41 = _RAND_41[0:0];
  _RAND_42 = {1{`RANDOM}};
  parity_data_snd_reg_42 = _RAND_42[0:0];
  _RAND_43 = {1{`RANDOM}};
  parity_data_snd_reg_43 = _RAND_43[0:0];
  _RAND_44 = {1{`RANDOM}};
  parity_data_snd_reg_44 = _RAND_44[0:0];
  _RAND_45 = {1{`RANDOM}};
  parity_data_snd_reg_45 = _RAND_45[0:0];
  _RAND_46 = {1{`RANDOM}};
  parity_data_snd_reg_46 = _RAND_46[0:0];
  _RAND_47 = {1{`RANDOM}};
  parity_data_snd_reg_47 = _RAND_47[0:0];
  _RAND_48 = {1{`RANDOM}};
  parity_data_snd_reg_48 = _RAND_48[0:0];
  _RAND_49 = {1{`RANDOM}};
  parity_data_snd_reg_49 = _RAND_49[0:0];
  _RAND_50 = {1{`RANDOM}};
  parity_data_snd_reg_50 = _RAND_50[0:0];
  _RAND_51 = {1{`RANDOM}};
  parity_data_snd_reg_51 = _RAND_51[0:0];
  _RAND_52 = {1{`RANDOM}};
  parity_data_snd_reg_52 = _RAND_52[0:0];
  _RAND_53 = {1{`RANDOM}};
  parity_data_snd_reg_53 = _RAND_53[0:0];
  _RAND_54 = {1{`RANDOM}};
  parity_data_snd_reg_54 = _RAND_54[0:0];
  _RAND_55 = {1{`RANDOM}};
  parity_data_snd_reg_55 = _RAND_55[0:0];
  _RAND_56 = {1{`RANDOM}};
  parity_data_snd_reg_56 = _RAND_56[0:0];
  _RAND_57 = {1{`RANDOM}};
  parity_data_snd_reg_57 = _RAND_57[0:0];
  _RAND_58 = {1{`RANDOM}};
  parity_data_snd_reg_58 = _RAND_58[0:0];
  _RAND_59 = {1{`RANDOM}};
  parity_data_snd_reg_59 = _RAND_59[0:0];
  _RAND_60 = {1{`RANDOM}};
  parity_data_snd_reg_60 = _RAND_60[0:0];
  _RAND_61 = {1{`RANDOM}};
  parity_data_snd_reg_61 = _RAND_61[0:0];
  _RAND_62 = {1{`RANDOM}};
  parity_data_snd_reg_62 = _RAND_62[0:0];
  _RAND_63 = {1{`RANDOM}};
  parity_data_snd_reg_63 = _RAND_63[0:0];
  _RAND_64 = {1{`RANDOM}};
  parity_dcount_snd_reg = _RAND_64[18:0];
  _RAND_65 = {1{`RANDOM}};
  parity_pcount_snd_reg = _RAND_65[8:0];
  _RAND_66 = {1{`RANDOM}};
  parity_dcount_rcv_reg = _RAND_66[18:0];
  _RAND_67 = {1{`RANDOM}};
  parity_pcount_rcv_reg = _RAND_67[8:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
