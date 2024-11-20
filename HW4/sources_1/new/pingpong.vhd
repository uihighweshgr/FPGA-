library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity pingpong is
    port(
           i_clk            : in STD_LOGIC;
           i_rst            : in STD_LOGIC;
           i_left_button    : in STD_LOGIC; --s5
           i_right_button   : in STD_LOGIC; --s9
           o_count          : out STD_LOGIC_VECTOR(7 downto 0)     
        );   
end pingpong;

architecture Behavioral of pingpong is
signal count            : STD_LOGIC_VECTOR(7 downto 0);
signal right_score      : STD_LOGIC_VECTOR(3 downto 0);
signal left_score       : STD_LOGIC_VECTOR(3 downto 0);
signal divclk           :STD_LOGIC_VECTOR(26 downto 0);
signal led_clk          :STD_LOGIC;
type counter_state is (reserve,counter_is_counting_left, counter_is_counting_right,left_win,right_win,left_ready_serve,right_ready_serve);
signal counter_move_state: counter_state;
signal prestate: counter_state;
begin

o_count <= count;

led_move_state :process (i_clk , i_rst , i_left_button , i_right_button)
begin
    if  i_rst = '0'  then --初始右發球
            counter_move_state <= reserve;
    elsif i_clk' event and i_clk = '1' then
        prestate <= counter_move_state;
        case counter_move_state is 
            when counter_is_counting_left =>
                if (count = "10000000") and (i_left_button = '1') then --左打到
                    counter_move_state <= counter_is_counting_right;             
                elsif (i_left_button = '0' and count = "00000000") or (count<"10000000" and i_left_button='1') then --左沒打到
                    counter_move_state <= right_win;   
                end if;                   
            when counter_is_counting_right =>
                if (count = "00000001") and (i_right_button = '1') then --右打到
                    counter_move_state <= counter_is_counting_left;
                elsif (i_right_button = '0' and count = "00000000") or (i_right_button = '1' and count > "00000001") then --右沒打到
                    counter_move_state <= left_win;
                end if;    
            when right_win =>
                if count = (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score then
                    counter_move_state <= reserve;
                end if;
                --if i_left_button = '1' then --左預備發球
                --    counter_move_state <= left_ready_serve;
                --end if;                           
            when left_win =>
                if count = (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score then
                    counter_move_state <= reserve;
                end if;
            when left_ready_serve =>
                if count = "10000000" then --左發球
                    counter_move_state <= counter_is_counting_right;
                end if;                           
            when right_ready_serve =>
                if count = "00000001" then --右發球
                    counter_move_state <= counter_is_counting_left;
                end if;
            when reserve =>
                if i_left_button = '1' then
                    counter_move_state <= left_ready_serve;
                elsif i_right_button = '1' then 
                    counter_move_state <= right_ready_serve;
                else
                    counter_move_state <= reserve;
                end if;
            when others =>
                null;
        end case;
    end if;
end process;

counter :process (i_clk , i_rst)
begin
    if i_rst = '0' then
        count <= "00000000";--count初始直 
    elsif led_clk' event and led_clk = '1' then
        case counter_move_state is 
            when counter_is_counting_left =>
                count <= count(6 downto 0) & '0'; --左移
            when counter_is_counting_right =>
                count <= '0' & count(7 downto 1); --右移
            when right_win =>
                count <= (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score; --看分數                         
            when left_win =>    
                count <= (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score;  --看分數
            when left_ready_serve =>
                count <= "10000000"; --左初始直                          
            when right_ready_serve =>
                count <= "00000001"; --右初始直
            when others =>
                null;
        end case;
    end if;                
end process;

count_score : process (i_clk, i_rst)
begin
    if i_rst = '0' then
        right_score <= "0000"; -- 初始化 score
        left_score  <= "0000"; 
    elsif i_clk' event and i_clk = '1' then
        case counter_move_state is  
            when counter_is_counting_left =>
                null; 
            when counter_is_counting_right =>
                null; 
            when right_win =>
                if prestate = counter_is_counting_left then
                
                    right_score <= right_score + '1'; --right_win  
                else
                    right_score <= right_score;
                end if;
            when left_win =>    
                if prestate = counter_is_counting_right then                
                    left_score <= left_score + '1'; --right_win  
                else
                    left_score <= left_score;
                end if;
            when left_ready_serve =>
                null;                         
            when right_ready_serve =>
                null;
            when others =>
                null;             
        end case;    
    end if;
end process;

fd:process(i_clk ,i_rst)
begin
if i_rst = '0' then 
    divclk <= (others => '0');
elsif rising_edge(i_clk) then
    divclk <= divclk +1 ;
end if;
end process fd;
led_clk <= divclk(24);

end Behavioral;