module sb_ldes(
  input          clock,
  input          reset,
  input          io_in_bits,
  input          io_in_remote_clock,
  input          io_out_ready,
  output         io_out_valid,
  output [127:0] io_out_bits
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
  reg [31:0] _RAND_68;
  reg [31:0] _RAND_69;
  reg [31:0] _RAND_70;
  reg [31:0] _RAND_71;
  reg [31:0] _RAND_72;
  reg [31:0] _RAND_73;
  reg [31:0] _RAND_74;
  reg [31:0] _RAND_75;
  reg [31:0] _RAND_76;
  reg [31:0] _RAND_77;
  reg [31:0] _RAND_78;
  reg [31:0] _RAND_79;
  reg [31:0] _RAND_80;
  reg [31:0] _RAND_81;
  reg [31:0] _RAND_82;
  reg [31:0] _RAND_83;
  reg [31:0] _RAND_84;
  reg [31:0] _RAND_85;
  reg [31:0] _RAND_86;
  reg [31:0] _RAND_87;
  reg [31:0] _RAND_88;
  reg [31:0] _RAND_89;
  reg [31:0] _RAND_90;
  reg [31:0] _RAND_91;
  reg [31:0] _RAND_92;
  reg [31:0] _RAND_93;
  reg [31:0] _RAND_94;
  reg [31:0] _RAND_95;
  reg [31:0] _RAND_96;
  reg [31:0] _RAND_97;
  reg [31:0] _RAND_98;
  reg [31:0] _RAND_99;
  reg [31:0] _RAND_100;
  reg [31:0] _RAND_101;
  reg [31:0] _RAND_102;
  reg [31:0] _RAND_103;
  reg [31:0] _RAND_104;
  reg [31:0] _RAND_105;
  reg [31:0] _RAND_106;
  reg [31:0] _RAND_107;
  reg [31:0] _RAND_108;
  reg [31:0] _RAND_109;
  reg [31:0] _RAND_110;
  reg [31:0] _RAND_111;
  reg [31:0] _RAND_112;
  reg [31:0] _RAND_113;
  reg [31:0] _RAND_114;
  reg [31:0] _RAND_115;
  reg [31:0] _RAND_116;
  reg [31:0] _RAND_117;
  reg [31:0] _RAND_118;
  reg [31:0] _RAND_119;
  reg [31:0] _RAND_120;
  reg [31:0] _RAND_121;
  reg [31:0] _RAND_122;
  reg [31:0] _RAND_123;
  reg [31:0] _RAND_124;
  reg [31:0] _RAND_125;
  reg [31:0] _RAND_126;
  reg [31:0] _RAND_127;
  reg [31:0] _RAND_128;
  reg [31:0] _RAND_129;
  reg [31:0] _RAND_130;
`endif // RANDOMIZE_REG_INIT
  reg  data_0;
  reg  data_1;
  reg  data_2;
  reg  data_3;
  reg  data_4;
  reg  data_5;
  reg  data_6;
  reg  data_7;
  reg  data_8;
  reg  data_9;
  reg  data_10;
  reg  data_11;
  reg  data_12;
  reg  data_13;
  reg  data_14;
  reg  data_15;
  reg  data_16;
  reg  data_17;
  reg  data_18;
  reg  data_19;
  reg  data_20;
  reg  data_21;
  reg  data_22;
  reg  data_23;
  reg  data_24;
  reg  data_25;
  reg  data_26;
  reg  data_27;
  reg  data_28;
  reg  data_29;
  reg  data_30;
  reg  data_31;
  reg  data_32;
  reg  data_33;
  reg  data_34;
  reg  data_35;
  reg  data_36;
  reg  data_37;
  reg  data_38;
  reg  data_39;
  reg  data_40;
  reg  data_41;
  reg  data_42;
  reg  data_43;
  reg  data_44;
  reg  data_45;
  reg  data_46;
  reg  data_47;
  reg  data_48;
  reg  data_49;
  reg  data_50;
  reg  data_51;
  reg  data_52;
  reg  data_53;
  reg  data_54;
  reg  data_55;
  reg  data_56;
  reg  data_57;
  reg  data_58;
  reg  data_59;
  reg  data_60;
  reg  data_61;
  reg  data_62;
  reg  data_63;
  reg  data_64;
  reg  data_65;
  reg  data_66;
  reg  data_67;
  reg  data_68;
  reg  data_69;
  reg  data_70;
  reg  data_71;
  reg  data_72;
  reg  data_73;
  reg  data_74;
  reg  data_75;
  reg  data_76;
  reg  data_77;
  reg  data_78;
  reg  data_79;
  reg  data_80;
  reg  data_81;
  reg  data_82;
  reg  data_83;
  reg  data_84;
  reg  data_85;
  reg  data_86;
  reg  data_87;
  reg  data_88;
  reg  data_89;
  reg  data_90;
  reg  data_91;
  reg  data_92;
  reg  data_93;
  reg  data_94;
  reg  data_95;
  reg  data_96;
  reg  data_97;
  reg  data_98;
  reg  data_99;
  reg  data_100;
  reg  data_101;
  reg  data_102;
  reg  data_103;
  reg  data_104;
  reg  data_105;
  reg  data_106;
  reg  data_107;
  reg  data_108;
  reg  data_109;
  reg  data_110;
  reg  data_111;
  reg  data_112;
  reg  data_113;
  reg  data_114;
  reg  data_115;
  reg  data_116;
  reg  data_117;
  reg  data_118;
  reg  data_119;
  reg  data_120;
  reg  data_121;
  reg  data_122;
  reg  data_123;
  reg  data_124;
  reg  data_125;
  reg  data_126;
  reg  data_127;
  reg  receiving;
  reg [6:0] recvCount;
  wire  wrap_wrap = recvCount == 7'h7f;
  wire [6:0] _wrap_value_T_1 = recvCount + 7'h1;
  reg [6:0] recvCount_delay;
  wire  _GEN_130 = wrap_wrap ? 1'h0 : receiving;
  wire  _T = io_out_ready & io_out_valid;
  wire  _GEN_131 = _T | _GEN_130;
  wire [7:0] io_out_bits_lo_lo_lo_lo = {data_7,data_6,data_5,data_4,data_3,data_2,data_1,data_0};
  wire [15:0] io_out_bits_lo_lo_lo = {data_15,data_14,data_13,data_12,data_11,data_10,data_9,data_8,
    io_out_bits_lo_lo_lo_lo};
  wire [7:0] io_out_bits_lo_lo_hi_lo = {data_23,data_22,data_21,data_20,data_19,data_18,data_17,data_16};
  wire [31:0] io_out_bits_lo_lo = {data_31,data_30,data_29,data_28,data_27,data_26,data_25,data_24,
    io_out_bits_lo_lo_hi_lo,io_out_bits_lo_lo_lo};
  wire [7:0] io_out_bits_lo_hi_lo_lo = {data_39,data_38,data_37,data_36,data_35,data_34,data_33,data_32};
  wire [15:0] io_out_bits_lo_hi_lo = {data_47,data_46,data_45,data_44,data_43,data_42,data_41,data_40,
    io_out_bits_lo_hi_lo_lo};
  wire [7:0] io_out_bits_lo_hi_hi_lo = {data_55,data_54,data_53,data_52,data_51,data_50,data_49,data_48};
  wire [31:0] io_out_bits_lo_hi = {data_63,data_62,data_61,data_60,data_59,data_58,data_57,data_56,
    io_out_bits_lo_hi_hi_lo,io_out_bits_lo_hi_lo};
  wire [63:0] io_out_bits_lo = {io_out_bits_lo_hi,io_out_bits_lo_lo};
  wire [7:0] io_out_bits_hi_lo_lo_lo = {data_71,data_70,data_69,data_68,data_67,data_66,data_65,data_64};
  wire [15:0] io_out_bits_hi_lo_lo = {data_79,data_78,data_77,data_76,data_75,data_74,data_73,data_72,
    io_out_bits_hi_lo_lo_lo};
  wire [7:0] io_out_bits_hi_lo_hi_lo = {data_87,data_86,data_85,data_84,data_83,data_82,data_81,data_80};
  wire [31:0] io_out_bits_hi_lo = {data_95,data_94,data_93,data_92,data_91,data_90,data_89,data_88,
    io_out_bits_hi_lo_hi_lo,io_out_bits_hi_lo_lo};
  wire [7:0] io_out_bits_hi_hi_lo_lo = {data_103,data_102,data_101,data_100,data_99,data_98,data_97,data_96};
  wire [15:0] io_out_bits_hi_hi_lo = {data_111,data_110,data_109,data_108,data_107,data_106,data_105,data_104,
    io_out_bits_hi_hi_lo_lo};
  wire [7:0] io_out_bits_hi_hi_hi_lo = {data_119,data_118,data_117,data_116,data_115,data_114,data_113,data_112};
  wire [31:0] io_out_bits_hi_hi = {data_127,data_126,data_125,data_124,data_123,data_122,data_121,data_120,
    io_out_bits_hi_hi_hi_lo,io_out_bits_hi_hi_lo};
  wire [63:0] io_out_bits_hi = {io_out_bits_hi_hi,io_out_bits_hi_lo};
  assign io_out_valid = ~receiving;
  assign io_out_bits = {io_out_bits_hi,io_out_bits_lo};
  always @(posedge clock) begin
    if (7'h0 == recvCount_delay) begin
      data_0 <= io_in_bits;
    end
    if (7'h1 == recvCount_delay) begin
      data_1 <= io_in_bits;
    end
    if (7'h2 == recvCount_delay) begin
      data_2 <= io_in_bits;
    end
    if (7'h3 == recvCount_delay) begin
      data_3 <= io_in_bits;
    end
    if (7'h4 == recvCount_delay) begin
      data_4 <= io_in_bits;
    end
    if (7'h5 == recvCount_delay) begin
      data_5 <= io_in_bits;
    end
    if (7'h6 == recvCount_delay) begin
      data_6 <= io_in_bits;
    end
    if (7'h7 == recvCount_delay) begin
      data_7 <= io_in_bits;
    end
    if (7'h8 == recvCount_delay) begin
      data_8 <= io_in_bits;
    end
    if (7'h9 == recvCount_delay) begin
      data_9 <= io_in_bits;
    end
    if (7'ha == recvCount_delay) begin
      data_10 <= io_in_bits;
    end
    if (7'hb == recvCount_delay) begin
      data_11 <= io_in_bits;
    end
    if (7'hc == recvCount_delay) begin
      data_12 <= io_in_bits;
    end
    if (7'hd == recvCount_delay) begin
      data_13 <= io_in_bits;
    end
    if (7'he == recvCount_delay) begin
      data_14 <= io_in_bits;
    end
    if (7'hf == recvCount_delay) begin
      data_15 <= io_in_bits;
    end
    if (7'h10 == recvCount_delay) begin
      data_16 <= io_in_bits;
    end
    if (7'h11 == recvCount_delay) begin
      data_17 <= io_in_bits;
    end
    if (7'h12 == recvCount_delay) begin
      data_18 <= io_in_bits;
    end
    if (7'h13 == recvCount_delay) begin
      data_19 <= io_in_bits;
    end
    if (7'h14 == recvCount_delay) begin
      data_20 <= io_in_bits;
    end
    if (7'h15 == recvCount_delay) begin
      data_21 <= io_in_bits;
    end
    if (7'h16 == recvCount_delay) begin
      data_22 <= io_in_bits;
    end
    if (7'h17 == recvCount_delay) begin
      data_23 <= io_in_bits;
    end
    if (7'h18 == recvCount_delay) begin
      data_24 <= io_in_bits;
    end
    if (7'h19 == recvCount_delay) begin
      data_25 <= io_in_bits;
    end
    if (7'h1a == recvCount_delay) begin
      data_26 <= io_in_bits;
    end
    if (7'h1b == recvCount_delay) begin
      data_27 <= io_in_bits;
    end
    if (7'h1c == recvCount_delay) begin
      data_28 <= io_in_bits;
    end
    if (7'h1d == recvCount_delay) begin
      data_29 <= io_in_bits;
    end
    if (7'h1e == recvCount_delay) begin
      data_30 <= io_in_bits;
    end
    if (7'h1f == recvCount_delay) begin
      data_31 <= io_in_bits;
    end
    if (7'h20 == recvCount_delay) begin
      data_32 <= io_in_bits;
    end
    if (7'h21 == recvCount_delay) begin
      data_33 <= io_in_bits;
    end
    if (7'h22 == recvCount_delay) begin
      data_34 <= io_in_bits;
    end
    if (7'h23 == recvCount_delay) begin
      data_35 <= io_in_bits;
    end
    if (7'h24 == recvCount_delay) begin
      data_36 <= io_in_bits;
    end
    if (7'h25 == recvCount_delay) begin
      data_37 <= io_in_bits;
    end
    if (7'h26 == recvCount_delay) begin
      data_38 <= io_in_bits;
    end
    if (7'h27 == recvCount_delay) begin
      data_39 <= io_in_bits;
    end
    if (7'h28 == recvCount_delay) begin
      data_40 <= io_in_bits;
    end
    if (7'h29 == recvCount_delay) begin
      data_41 <= io_in_bits;
    end
    if (7'h2a == recvCount_delay) begin
      data_42 <= io_in_bits;
    end
    if (7'h2b == recvCount_delay) begin
      data_43 <= io_in_bits;
    end
    if (7'h2c == recvCount_delay) begin
      data_44 <= io_in_bits;
    end
    if (7'h2d == recvCount_delay) begin
      data_45 <= io_in_bits;
    end
    if (7'h2e == recvCount_delay) begin
      data_46 <= io_in_bits;
    end
    if (7'h2f == recvCount_delay) begin
      data_47 <= io_in_bits;
    end
    if (7'h30 == recvCount_delay) begin
      data_48 <= io_in_bits;
    end
    if (7'h31 == recvCount_delay) begin
      data_49 <= io_in_bits;
    end
    if (7'h32 == recvCount_delay) begin
      data_50 <= io_in_bits;
    end
    if (7'h33 == recvCount_delay) begin
      data_51 <= io_in_bits;
    end
    if (7'h34 == recvCount_delay) begin
      data_52 <= io_in_bits;
    end
    if (7'h35 == recvCount_delay) begin
      data_53 <= io_in_bits;
    end
    if (7'h36 == recvCount_delay) begin
      data_54 <= io_in_bits;
    end
    if (7'h37 == recvCount_delay) begin
      data_55 <= io_in_bits;
    end
    if (7'h38 == recvCount_delay) begin
      data_56 <= io_in_bits;
    end
    if (7'h39 == recvCount_delay) begin
      data_57 <= io_in_bits;
    end
    if (7'h3a == recvCount_delay) begin
      data_58 <= io_in_bits;
    end
    if (7'h3b == recvCount_delay) begin
      data_59 <= io_in_bits;
    end
    if (7'h3c == recvCount_delay) begin
      data_60 <= io_in_bits;
    end
    if (7'h3d == recvCount_delay) begin
      data_61 <= io_in_bits;
    end
    if (7'h3e == recvCount_delay) begin
      data_62 <= io_in_bits;
    end
    if (7'h3f == recvCount_delay) begin
      data_63 <= io_in_bits;
    end
    if (7'h40 == recvCount_delay) begin
      data_64 <= io_in_bits;
    end
    if (7'h41 == recvCount_delay) begin
      data_65 <= io_in_bits;
    end
    if (7'h42 == recvCount_delay) begin
      data_66 <= io_in_bits;
    end
    if (7'h43 == recvCount_delay) begin
      data_67 <= io_in_bits;
    end
    if (7'h44 == recvCount_delay) begin
      data_68 <= io_in_bits;
    end
    if (7'h45 == recvCount_delay) begin
      data_69 <= io_in_bits;
    end
    if (7'h46 == recvCount_delay) begin
      data_70 <= io_in_bits;
    end
    if (7'h47 == recvCount_delay) begin
      data_71 <= io_in_bits;
    end
    if (7'h48 == recvCount_delay) begin
      data_72 <= io_in_bits;
    end
    if (7'h49 == recvCount_delay) begin
      data_73 <= io_in_bits;
    end
    if (7'h4a == recvCount_delay) begin
      data_74 <= io_in_bits;
    end
    if (7'h4b == recvCount_delay) begin
      data_75 <= io_in_bits;
    end
    if (7'h4c == recvCount_delay) begin
      data_76 <= io_in_bits;
    end
    if (7'h4d == recvCount_delay) begin
      data_77 <= io_in_bits;
    end
    if (7'h4e == recvCount_delay) begin
      data_78 <= io_in_bits;
    end
    if (7'h4f == recvCount_delay) begin
      data_79 <= io_in_bits;
    end
    if (7'h50 == recvCount_delay) begin
      data_80 <= io_in_bits;
    end
    if (7'h51 == recvCount_delay) begin
      data_81 <= io_in_bits;
    end
    if (7'h52 == recvCount_delay) begin
      data_82 <= io_in_bits;
    end
    if (7'h53 == recvCount_delay) begin
      data_83 <= io_in_bits;
    end
    if (7'h54 == recvCount_delay) begin
      data_84 <= io_in_bits;
    end
    if (7'h55 == recvCount_delay) begin
      data_85 <= io_in_bits;
    end
    if (7'h56 == recvCount_delay) begin
      data_86 <= io_in_bits;
    end
    if (7'h57 == recvCount_delay) begin
      data_87 <= io_in_bits;
    end
    if (7'h58 == recvCount_delay) begin
      data_88 <= io_in_bits;
    end
    if (7'h59 == recvCount_delay) begin
      data_89 <= io_in_bits;
    end
    if (7'h5a == recvCount_delay) begin
      data_90 <= io_in_bits;
    end
    if (7'h5b == recvCount_delay) begin
      data_91 <= io_in_bits;
    end
    if (7'h5c == recvCount_delay) begin
      data_92 <= io_in_bits;
    end
    if (7'h5d == recvCount_delay) begin
      data_93 <= io_in_bits;
    end
    if (7'h5e == recvCount_delay) begin
      data_94 <= io_in_bits;
    end
    if (7'h5f == recvCount_delay) begin
      data_95 <= io_in_bits;
    end
    if (7'h60 == recvCount_delay) begin
      data_96 <= io_in_bits;
    end
    if (7'h61 == recvCount_delay) begin
      data_97 <= io_in_bits;
    end
    if (7'h62 == recvCount_delay) begin
      data_98 <= io_in_bits;
    end
    if (7'h63 == recvCount_delay) begin
      data_99 <= io_in_bits;
    end
    if (7'h64 == recvCount_delay) begin
      data_100 <= io_in_bits;
    end
    if (7'h65 == recvCount_delay) begin
      data_101 <= io_in_bits;
    end
    if (7'h66 == recvCount_delay) begin
      data_102 <= io_in_bits;
    end
    if (7'h67 == recvCount_delay) begin
      data_103 <= io_in_bits;
    end
    if (7'h68 == recvCount_delay) begin
      data_104 <= io_in_bits;
    end
    if (7'h69 == recvCount_delay) begin
      data_105 <= io_in_bits;
    end
    if (7'h6a == recvCount_delay) begin
      data_106 <= io_in_bits;
    end
    if (7'h6b == recvCount_delay) begin
      data_107 <= io_in_bits;
    end
    if (7'h6c == recvCount_delay) begin
      data_108 <= io_in_bits;
    end
    if (7'h6d == recvCount_delay) begin
      data_109 <= io_in_bits;
    end
    if (7'h6e == recvCount_delay) begin
      data_110 <= io_in_bits;
    end
    if (7'h6f == recvCount_delay) begin
      data_111 <= io_in_bits;
    end
    if (7'h70 == recvCount_delay) begin
      data_112 <= io_in_bits;
    end
    if (7'h71 == recvCount_delay) begin
      data_113 <= io_in_bits;
    end
    if (7'h72 == recvCount_delay) begin
      data_114 <= io_in_bits;
    end
    if (7'h73 == recvCount_delay) begin
      data_115 <= io_in_bits;
    end
    if (7'h74 == recvCount_delay) begin
      data_116 <= io_in_bits;
    end
    if (7'h75 == recvCount_delay) begin
      data_117 <= io_in_bits;
    end
    if (7'h76 == recvCount_delay) begin
      data_118 <= io_in_bits;
    end
    if (7'h77 == recvCount_delay) begin
      data_119 <= io_in_bits;
    end
    if (7'h78 == recvCount_delay) begin
      data_120 <= io_in_bits;
    end
    if (7'h79 == recvCount_delay) begin
      data_121 <= io_in_bits;
    end
    if (7'h7a == recvCount_delay) begin
      data_122 <= io_in_bits;
    end
    if (7'h7b == recvCount_delay) begin
      data_123 <= io_in_bits;
    end
    if (7'h7c == recvCount_delay) begin
      data_124 <= io_in_bits;
    end
    if (7'h7d == recvCount_delay) begin
      data_125 <= io_in_bits;
    end
    if (7'h7e == recvCount_delay) begin
      data_126 <= io_in_bits;
    end
    if (7'h7f == recvCount_delay) begin
      data_127 <= io_in_bits;
    end
    receiving <= reset | _GEN_131;
  end
  always @(posedge io_in_remote_clock) begin
    if (reset) begin
      recvCount <= 7'h0;
    end else begin
      recvCount <= _wrap_value_T_1;
    end
    if (reset) begin
      recvCount_delay <= 7'h0;
    end else begin
      recvCount_delay <= recvCount;
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
  data_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  data_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  data_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  data_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  data_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  data_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  data_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  data_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  data_8 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  data_9 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  data_10 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  data_11 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  data_12 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  data_13 = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  data_14 = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  data_15 = _RAND_15[0:0];
  _RAND_16 = {1{`RANDOM}};
  data_16 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  data_17 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  data_18 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  data_19 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  data_20 = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  data_21 = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  data_22 = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  data_23 = _RAND_23[0:0];
  _RAND_24 = {1{`RANDOM}};
  data_24 = _RAND_24[0:0];
  _RAND_25 = {1{`RANDOM}};
  data_25 = _RAND_25[0:0];
  _RAND_26 = {1{`RANDOM}};
  data_26 = _RAND_26[0:0];
  _RAND_27 = {1{`RANDOM}};
  data_27 = _RAND_27[0:0];
  _RAND_28 = {1{`RANDOM}};
  data_28 = _RAND_28[0:0];
  _RAND_29 = {1{`RANDOM}};
  data_29 = _RAND_29[0:0];
  _RAND_30 = {1{`RANDOM}};
  data_30 = _RAND_30[0:0];
  _RAND_31 = {1{`RANDOM}};
  data_31 = _RAND_31[0:0];
  _RAND_32 = {1{`RANDOM}};
  data_32 = _RAND_32[0:0];
  _RAND_33 = {1{`RANDOM}};
  data_33 = _RAND_33[0:0];
  _RAND_34 = {1{`RANDOM}};
  data_34 = _RAND_34[0:0];
  _RAND_35 = {1{`RANDOM}};
  data_35 = _RAND_35[0:0];
  _RAND_36 = {1{`RANDOM}};
  data_36 = _RAND_36[0:0];
  _RAND_37 = {1{`RANDOM}};
  data_37 = _RAND_37[0:0];
  _RAND_38 = {1{`RANDOM}};
  data_38 = _RAND_38[0:0];
  _RAND_39 = {1{`RANDOM}};
  data_39 = _RAND_39[0:0];
  _RAND_40 = {1{`RANDOM}};
  data_40 = _RAND_40[0:0];
  _RAND_41 = {1{`RANDOM}};
  data_41 = _RAND_41[0:0];
  _RAND_42 = {1{`RANDOM}};
  data_42 = _RAND_42[0:0];
  _RAND_43 = {1{`RANDOM}};
  data_43 = _RAND_43[0:0];
  _RAND_44 = {1{`RANDOM}};
  data_44 = _RAND_44[0:0];
  _RAND_45 = {1{`RANDOM}};
  data_45 = _RAND_45[0:0];
  _RAND_46 = {1{`RANDOM}};
  data_46 = _RAND_46[0:0];
  _RAND_47 = {1{`RANDOM}};
  data_47 = _RAND_47[0:0];
  _RAND_48 = {1{`RANDOM}};
  data_48 = _RAND_48[0:0];
  _RAND_49 = {1{`RANDOM}};
  data_49 = _RAND_49[0:0];
  _RAND_50 = {1{`RANDOM}};
  data_50 = _RAND_50[0:0];
  _RAND_51 = {1{`RANDOM}};
  data_51 = _RAND_51[0:0];
  _RAND_52 = {1{`RANDOM}};
  data_52 = _RAND_52[0:0];
  _RAND_53 = {1{`RANDOM}};
  data_53 = _RAND_53[0:0];
  _RAND_54 = {1{`RANDOM}};
  data_54 = _RAND_54[0:0];
  _RAND_55 = {1{`RANDOM}};
  data_55 = _RAND_55[0:0];
  _RAND_56 = {1{`RANDOM}};
  data_56 = _RAND_56[0:0];
  _RAND_57 = {1{`RANDOM}};
  data_57 = _RAND_57[0:0];
  _RAND_58 = {1{`RANDOM}};
  data_58 = _RAND_58[0:0];
  _RAND_59 = {1{`RANDOM}};
  data_59 = _RAND_59[0:0];
  _RAND_60 = {1{`RANDOM}};
  data_60 = _RAND_60[0:0];
  _RAND_61 = {1{`RANDOM}};
  data_61 = _RAND_61[0:0];
  _RAND_62 = {1{`RANDOM}};
  data_62 = _RAND_62[0:0];
  _RAND_63 = {1{`RANDOM}};
  data_63 = _RAND_63[0:0];
  _RAND_64 = {1{`RANDOM}};
  data_64 = _RAND_64[0:0];
  _RAND_65 = {1{`RANDOM}};
  data_65 = _RAND_65[0:0];
  _RAND_66 = {1{`RANDOM}};
  data_66 = _RAND_66[0:0];
  _RAND_67 = {1{`RANDOM}};
  data_67 = _RAND_67[0:0];
  _RAND_68 = {1{`RANDOM}};
  data_68 = _RAND_68[0:0];
  _RAND_69 = {1{`RANDOM}};
  data_69 = _RAND_69[0:0];
  _RAND_70 = {1{`RANDOM}};
  data_70 = _RAND_70[0:0];
  _RAND_71 = {1{`RANDOM}};
  data_71 = _RAND_71[0:0];
  _RAND_72 = {1{`RANDOM}};
  data_72 = _RAND_72[0:0];
  _RAND_73 = {1{`RANDOM}};
  data_73 = _RAND_73[0:0];
  _RAND_74 = {1{`RANDOM}};
  data_74 = _RAND_74[0:0];
  _RAND_75 = {1{`RANDOM}};
  data_75 = _RAND_75[0:0];
  _RAND_76 = {1{`RANDOM}};
  data_76 = _RAND_76[0:0];
  _RAND_77 = {1{`RANDOM}};
  data_77 = _RAND_77[0:0];
  _RAND_78 = {1{`RANDOM}};
  data_78 = _RAND_78[0:0];
  _RAND_79 = {1{`RANDOM}};
  data_79 = _RAND_79[0:0];
  _RAND_80 = {1{`RANDOM}};
  data_80 = _RAND_80[0:0];
  _RAND_81 = {1{`RANDOM}};
  data_81 = _RAND_81[0:0];
  _RAND_82 = {1{`RANDOM}};
  data_82 = _RAND_82[0:0];
  _RAND_83 = {1{`RANDOM}};
  data_83 = _RAND_83[0:0];
  _RAND_84 = {1{`RANDOM}};
  data_84 = _RAND_84[0:0];
  _RAND_85 = {1{`RANDOM}};
  data_85 = _RAND_85[0:0];
  _RAND_86 = {1{`RANDOM}};
  data_86 = _RAND_86[0:0];
  _RAND_87 = {1{`RANDOM}};
  data_87 = _RAND_87[0:0];
  _RAND_88 = {1{`RANDOM}};
  data_88 = _RAND_88[0:0];
  _RAND_89 = {1{`RANDOM}};
  data_89 = _RAND_89[0:0];
  _RAND_90 = {1{`RANDOM}};
  data_90 = _RAND_90[0:0];
  _RAND_91 = {1{`RANDOM}};
  data_91 = _RAND_91[0:0];
  _RAND_92 = {1{`RANDOM}};
  data_92 = _RAND_92[0:0];
  _RAND_93 = {1{`RANDOM}};
  data_93 = _RAND_93[0:0];
  _RAND_94 = {1{`RANDOM}};
  data_94 = _RAND_94[0:0];
  _RAND_95 = {1{`RANDOM}};
  data_95 = _RAND_95[0:0];
  _RAND_96 = {1{`RANDOM}};
  data_96 = _RAND_96[0:0];
  _RAND_97 = {1{`RANDOM}};
  data_97 = _RAND_97[0:0];
  _RAND_98 = {1{`RANDOM}};
  data_98 = _RAND_98[0:0];
  _RAND_99 = {1{`RANDOM}};
  data_99 = _RAND_99[0:0];
  _RAND_100 = {1{`RANDOM}};
  data_100 = _RAND_100[0:0];
  _RAND_101 = {1{`RANDOM}};
  data_101 = _RAND_101[0:0];
  _RAND_102 = {1{`RANDOM}};
  data_102 = _RAND_102[0:0];
  _RAND_103 = {1{`RANDOM}};
  data_103 = _RAND_103[0:0];
  _RAND_104 = {1{`RANDOM}};
  data_104 = _RAND_104[0:0];
  _RAND_105 = {1{`RANDOM}};
  data_105 = _RAND_105[0:0];
  _RAND_106 = {1{`RANDOM}};
  data_106 = _RAND_106[0:0];
  _RAND_107 = {1{`RANDOM}};
  data_107 = _RAND_107[0:0];
  _RAND_108 = {1{`RANDOM}};
  data_108 = _RAND_108[0:0];
  _RAND_109 = {1{`RANDOM}};
  data_109 = _RAND_109[0:0];
  _RAND_110 = {1{`RANDOM}};
  data_110 = _RAND_110[0:0];
  _RAND_111 = {1{`RANDOM}};
  data_111 = _RAND_111[0:0];
  _RAND_112 = {1{`RANDOM}};
  data_112 = _RAND_112[0:0];
  _RAND_113 = {1{`RANDOM}};
  data_113 = _RAND_113[0:0];
  _RAND_114 = {1{`RANDOM}};
  data_114 = _RAND_114[0:0];
  _RAND_115 = {1{`RANDOM}};
  data_115 = _RAND_115[0:0];
  _RAND_116 = {1{`RANDOM}};
  data_116 = _RAND_116[0:0];
  _RAND_117 = {1{`RANDOM}};
  data_117 = _RAND_117[0:0];
  _RAND_118 = {1{`RANDOM}};
  data_118 = _RAND_118[0:0];
  _RAND_119 = {1{`RANDOM}};
  data_119 = _RAND_119[0:0];
  _RAND_120 = {1{`RANDOM}};
  data_120 = _RAND_120[0:0];
  _RAND_121 = {1{`RANDOM}};
  data_121 = _RAND_121[0:0];
  _RAND_122 = {1{`RANDOM}};
  data_122 = _RAND_122[0:0];
  _RAND_123 = {1{`RANDOM}};
  data_123 = _RAND_123[0:0];
  _RAND_124 = {1{`RANDOM}};
  data_124 = _RAND_124[0:0];
  _RAND_125 = {1{`RANDOM}};
  data_125 = _RAND_125[0:0];
  _RAND_126 = {1{`RANDOM}};
  data_126 = _RAND_126[0:0];
  _RAND_127 = {1{`RANDOM}};
  data_127 = _RAND_127[0:0];
  _RAND_128 = {1{`RANDOM}};
  receiving = _RAND_128[0:0];
  _RAND_129 = {1{`RANDOM}};
  recvCount = _RAND_129[6:0];
  _RAND_130 = {1{`RANDOM}};
  recvCount_delay = _RAND_130[6:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
