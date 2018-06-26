`timescale 1 ns/1 ns
`define DEL 2
module ARM_tb;

reg clk = 1'b0;
always clk = #5 ~clk;

reg rst = 1'b1;
initial #10 rst = 1'b0;

reg [7:0] rom[1023:0];

integer i;
initial begin
      mcr_data = 32'b0;
      for(i=0;i<8192;i=i+1)
         rom[i]=0;
  $readmemh("hex.txt", rom);
end
wire [31:0] r0;
wire        rom_en;
wire [31:0] rom_addr;
reg  [31:0] rom_data;
reg  [31:0] mcr_data;
always @ (posedge clk)
if (rom_en)
    rom_data <= #`DEL {rom[rom_addr+3],rom[rom_addr+2],rom[rom_addr+1],rom[rom_addr]};
else;


wire        inst_mcr;
wire        ram_cen;
wire        ram_wen;
wire [3:0]  ram_flag;
wire [31:0] ram_addr;
wire [31:0] ram_wdata;

reg [31:0] ram [511:0];
initial begin
for(i=0;i<512;i=i+1)
         ram[i]=0;
end

reg [31:0] ram_rdata;

always @ (posedge clk )
if ( ram_cen & ~ram_wen )
    if (ram_addr==32'he0000000)
	    ram_rdata <= #`DEL 32'h0;
	else if (ram_addr[31:28]==4'h0)
	    ram_rdata <= #`DEL  {rom[ram_addr+3],rom[ram_addr+2],rom[ram_addr+1],rom[ram_addr]};
    else if (ram_addr[31:28]==4'h4)
	    ram_rdata <= #`DEL ram[ram_addr[27:2]];
	else;
else;


always @ (posedge clk )
if (ram_cen & ram_wen & (ram_addr[31:28]==4'h4))
    ram[ram_addr[27:2]] <= #`DEL { (ram_flag[3] ? ram_wdata[31:24]:ram[ram_addr[27:2]][31:24]),(ram_flag[2] ? ram_wdata[23:16]:ram[ram_addr[27:2]][23:16]),(ram_flag[1] ? ram_wdata[15:8]:ram[ram_addr[27:2]][15:8]),(ram_flag[0] ? ram_wdata[7:0]:ram[ram_addr[27:2]][7:0])};
else;


always @ (posedge clk)
if (ram_cen & ram_wen & (ram_addr==32'he0000004) )
    $write("%s",ram_wdata[7:0]);
else;

ARM uut(
          .clk                 (    clk                   ),
          .cpu_en              (    1'b1                  ),
          .cpu_restart         (    1'b0                  ),
          .fiq                 (    1'b0                  ),
          .irq                 (    1'b0                  ),
			 .mcr_data            (    mcr_data              ),
          .ram_abort           (    1'b0                  ),
          .ram_rdata           (    ram_rdata             ),
          .rom_abort           (    1'b0                  ),
          .rom_data            (    rom_data              ),
          .rst                 (    rst                   ),

          .inst_mcr            (    inst_mcr              ),
			 .ram_addr            (    ram_addr              ),
          .ram_cen             (    ram_cen               ),
          .ram_flag            (    ram_flag              ),
          .ram_wdata           (    ram_wdata             ),
          .ram_wen             (    ram_wen               ),
          .rom_addr            (    rom_addr              ),
          .rom_en              (    rom_en                ),
			 .r0                  (    r0                    )
        ); 

endmodule



