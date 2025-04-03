module tb();

    reg clk;
    reg write_enable;

    reg [4:0] addr_1;
    reg [4:0] addr_2;
    reg [4:0] addr_3;

    reg [31:0] write_data;

    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    regfile dut(
        .clk(clk),
        .write_enable(write_enable),
        .addr_1(addr_1),
        .addr_2(addr_2),
        .addr_3(addr_3),
        .write_data(write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    always #1 clk = ~clk;

    integer k;
    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, tb);
        clk = 0;
        write_enable = 1;
        addr_1 = 0;
        addr_2 = 1;
        addr_3 = 0;
        write_data = 0;

        // write reg[i] = i to all registers
        for (k = 0; k < 32; k += 1) begin
            write_data = addr_3;
            addr_3 += 1;
            #2;
        end

        # 10

        // check if reg[i] is in fact = i
        for (k = 0; k < 32; k += 1) begin
            addr_1 += 1; 
            addr_2 += 1;
            $assert(read_data_1 == addr_1);
            #2;
        end

        #400 $finish;
    end
endmodule;
