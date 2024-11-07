library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_pwm_breath is
end tb_pwm_breath;

architecture behavior of tb_pwm_breath is
    signal i_clk      : STD_LOGIC := '0';
    signal i_rst      : STD_LOGIC := '1';
    signal i_sw_up    : STD_LOGIC := '0';
    signal i_sw_dn    : STD_LOGIC := '0';
    signal pwm        : STD_LOGIC;

    constant clk_period : time := 10 ns;

    -- Instantiate the Unit Under Test (UUT)
    component pwm_breath
        Port ( i_clk : in STD_LOGIC;
               i_rst : in STD_LOGIC;
               i_sw_up : in STD_LOGIC;
               i_sw_dn : in STD_LOGIC;           
               pwm : out STD_LOGIC);
    end component;

begin
    -- Instantiate the UUT
    uut: pwm_breath
        Port Map (
            i_clk => i_clk,
            i_rst => i_rst,
            i_sw_up => i_sw_up,
            i_sw_dn => i_sw_dn,
            pwm => pwm
        );

    -- Clock process
    clk_process :process
    begin
        i_clk <= '0';
        wait for clk_period/2;
        i_clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
 
   stim_proc: process
   begin 
      -- hold reset state for 100 ns.
      i_rst <= '0';
      i_sw_up <= '0';
      i_sw_dn <= '0';
      wait for 100 ns; 
      i_rst <= '1';
      wait for clk_period*1024*256;
      -- insert stimulus here 
      wait;
   end process;
end behavior;

