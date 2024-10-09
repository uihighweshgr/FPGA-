
-- Company:
-- Engineer:
--
-- Create Date: 2024/09/25 15:03:09
-- Design Name:
-- Module Name: counter - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           o_count1 : out STD_LOGIC_VECTOR(3 downto 0);
           o_count2 : out STD_LOGIC_VECTOR(3 downto 0)
           );
end counter;

architecture Behavioral of counter is
signal count1:STD_LOGIC_VECTOR(3 downto 0);
signal count2:STD_LOGIC_VECTOR(3 downto 0);
signal state:STD_LOGIC;
signal divclk:STD_LOGIC_VECTOR(26 downto 0);
signal fclk:STD_LOGIC;
begin

o_count1 <= count1;
o_count2 <= count2;

fd:process(i_clk ,i_rst)
begin
if (i_rst = '0') then 
    divclk <= (others => '0');
elsif (rising_edge(i_clk)) then
    divclk <= divclk +1 ;
end if;
end process fd;
fclk <= divclk(25);      
            




FSM:process(i_clk, i_rst)
begin
    if i_rst = '0' then
        state <= '0';
    elsif i_clk'event and i_clk ='1' then
        case state is
            when '0' =>
                if count1="1111" then
                     state <= '1';
                end if;
             when '1' =>
                if count2="0000" then
                     state <= '0';
                end if;
             when others =>
                 null;
          end case;
      end if;
end process;
   
counter1p:process(fclk, i_rst, state)
begin
    if i_rst = '0' then
        count1 <= "0000";
    elsif fclk'event and fclk ='1' then
        case state is
            when '0' =>
                count1 <= count1 + '1';
             when '1' =>
                null;
             when others =>
                 null;
          end case;
      end if;
end process;

counter2p:process(fclk, i_rst, state)
begin
    if i_rst = '0' then
        count2 <= "1111";
    elsif fclk'event and fclk ='1' then
        case state is
            when '0' =>
                null;
             when '1' =>
                count2 <= count2 - '1';
             when others =>
                 null;
          end case;
      end if;
end process;
   
end Behavioral;