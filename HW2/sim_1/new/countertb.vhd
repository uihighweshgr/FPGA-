library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity countertb is
end countertb;

architecture Behavioral of countertb is
    component pwm
    port ( i_clk           :in std_logic;    
           i_rst           :in std_logic;
	       i_target        :in std_logic_vector(7 downto 0);
	       i_th_speed      :in std_logic_vector(7 downto 0);
	       i_speed_now     :in std_logic_vector(7 downto 0); 
--           o_state_counter :out std_logic; 
	       o_pwm           :out std_logic; 
--           o_state_speed   :out std_logic_vector;
           o_speed         :out std_logic_vector(7 downto 0)
    );
    end component;
   
    signal i_clk : STD_LOGIC := '0';
    signal i_rst : STD_LOGIC := '0';
    signal i_target: std_logic_vector(7 downto 0); --定義 4-bit 訊號
    signal i_th_speed: std_logic_vector(7 downto 0); --定義 4-bit 訊號
    signal i_speed_now: std_logic_vector(7 downto 0); --定義 4-bit 訊號
    signal o_speed:std_logic_vector(7 downto 0);
    signal o_pwm : STD_LOGIC;
   
begin
    --主
    TB: pwm port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_target =>i_target,
        i_th_speed=>i_th_speed,
        i_speed_now=>i_speed_now,
        o_pwm => o_pwm,
        o_speed => o_speed  
       );

    -- 時鐘生成
    process
    begin
       i_clk <= '0';
        wait for 5 ps;
       i_clk <= '1';
        wait for 5 ps;
    end process;
   
    -- 測試過程
    process
    begin
        i_rst <= '0';
        wait for 10 ns;
        i_rst <= '1';
        
        i_target <=   "01100100";   -- 100
        i_th_speed <= "01010000"; -- 80
        i_speed_now <="00000000"; -- 0
        wait for 12600ps;
        i_speed_now <="01011010"; -- 90
        wait for 15200ps;
        i_speed_now <="01111000"; -- 120
        wait for 17800ps;
        i_speed_now <="01100100";   -- 100
        wait for 20400ps;

    end process;

end Behavioral;
