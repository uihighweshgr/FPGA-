library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity pingpung is
    port(
           i_clk            : in STD_LOGIC;
           i_rst            : in STD_LOGIC;
           i_left_button    : in STD_LOGIC;
           i_right_button   : in STD_LOGIC;
           i_score_button   : in STD_LOGIC;
           o_count          : out STD_LOGIC_VECTOR(7 downto 0)     
        );   
end pingpung;

architecture Behavioral of pingpung is
signal count            : STD_LOGIC_VECTOR(7 downto 0);
signal right_score      : STD_LOGIC_VECTOR(3 downto 0);
signal left_score       : STD_LOGIC_VECTOR(3 downto 0);
signal score_button     : STD_LOGIC_VECTOR(1 downto 0);
signal score_state      : STD_LOGIC;      --0左邊贏  1右邊贏
signal divclk           :STD_LOGIC_VECTOR(26 downto 0);
signal fclk             :STD_LOGIC;
signal led_clk          :STD_LOGIC;
type counter_state is (counter_is_counting_left, counter_is_counting_right);
signal counter_move_state: counter_state;
begin

o_count <= count;

led_move_state :process (fclk , i_rst , i_left_button , i_right_button)
begin
    if i_rst = '0' then
        count <= "00000001";
    elsif fclk' event and fclk = '1' then
        case counter_move_state is 
            when counter_is_counting_left =>
                if (count = "10000000") and (i_left_button = '1') then
                    counter_move_state <= counter_is_counting_right;
                elsif (count = "00000000") or (i_left_button = '1') or count > "10000000" then
                    right_score <= right_score + '1';
                    score_state <= '1';
                elsif (count = "10000000") or (i_right_button = '1') then
                    left_score <= left_score + '1';
                    score_state <= '0';   
                end if;                   
            when counter_is_counting_right =>
                if (count = "00000001") and (i_right_button = '1') then
                    counter_move_state <= counter_is_counting_left;
                elsif (count = "00000001") or (i_left_button = '1') then
                    left_score <= left_score + '1';
                    score_state <= '0';
                elsif count > "00000001" then
                    left_score <= left_score + '1';
                    score_state <= '0';
                elsif (count = "00000001") or (i_right_button = '1') then
                    right_score <= right_score + '1';
                    score_state <= '1';   
                end if;    
            when others =>
                null;
        end case;
    end if;
end process;

serve : process (fclk , i_rst , i_left_button , i_right_button)
begin
    if i_rst = '0' then
        count <= "00000001";  -- 初始化 count    
    elsif fclk' event and fclk = '1' then
        case score_state is
            when '0' =>
                if i_right_button = '1' then
                    counter_move_state <= counter_is_counting_left;
                end if;
            when '1' =>
                if i_left_button = '1' then
                    counter_move_state <= counter_is_counting_right;
                end if;
        end case;
    end if;                
end process;

show_score : process (fclk, i_rst, i_score_button)
begin
    if i_rst = '0' then
        count <= "00000001";  -- 初始化 count
    elsif rising_edge(fclk) then
        if i_score_button = '1' then  -- 當 score_button 被按下時
            count <= left_score & right_score;-- 顯示當前分數，合併 left_score 和 right_score
        elsif i_score_button = '0' then  -- 當 score_button 釋放時 (第二次按下)
            if score_state = '0' then -- 根據 score_state 的值來設定 count
                count <= "00000001";  -- 如果 score_state 是 '0'，設置 count 為 "00000001"
            elsif score_state = '1' then
                count <= "10000000";  -- 如果 score_state 是 '1'，設置 count 為 "10000000"
            end if;
        end if;
    end if;
end process;

counter :process (led_clk , i_rst)
begin
    if i_rst = '0' then
        count <= "00000001";
    elsif led_clk' event and led_clk = '1' then
        case counter_move_state is 
            when counter_is_counting_left =>
                count <= count(6 downto 0) & '0';
            when counter_is_counting_right =>
                count <= '0' & count(7 downto 1);
            when others =>
                null;
        end case;
    end if;                
end process;

fd:process(i_clk ,i_rst)
begin
if (i_rst = '0') then 
    divclk <= (others => '0');
elsif (rising_edge(i_clk)) then
    divclk <= divclk +1 ;
end if;
end process fd;
fclk <= divclk(25);   
led_clk <= divclk(24);


end Behavioral;