module PLL(
    input fref,
    input ndiv,
    input ibit_buffer,
    input ibit_vco,
    output reg pll_clk
    );
    initial begin
        pll_clk = 1;
        forever begin
            #1ns;
            pll_clk = ~ pll_clk;
        end
    end
endmodule

