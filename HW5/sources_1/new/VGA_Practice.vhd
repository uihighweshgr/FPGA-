library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity vga_controller is
    Port ( clk       : in  STD_LOGIC;       -- FPGA時鐘
           rst_n     : in  STD_LOGIC;       -- 重置信號
           hsync     : out STD_LOGIC;       -- 水平同步信號
           vsync     : out STD_LOGIC;       -- 垂直同步信號
           red       : out STD_LOGIC_VECTOR (3 downto 0);  -- 紅色顏色分量
           green     : out STD_LOGIC_VECTOR (3 downto 0);  -- 綠色顏色分量
           blue      : out STD_LOGIC_VECTOR (3 downto 0)   -- 藍色顏色分量
           );
end vga_controller;

architecture Behavioral of vga_controller is
    -- VGA參數定義 (640x480解析度，60Hz刷新率)
    constant H_SYNC_CYCLES : integer := 96;  -- 水平同步脈寬
    constant H_BACK_PORCH : integer := 48;   -- 水平後座標
    constant H_ACTIVE_VIDEO : integer := 640; -- 顯示區寬度
    constant H_FRONT_PORCH : integer := 16;  -- 水平前座標
    constant V_SYNC_CYCLES : integer := 2;   -- 垂直同步脈寬
    constant V_BACK_PORCH : integer := 33;   -- 垂直後座標
    constant V_ACTIVE_VIDEO : integer := 480; -- 顯示區高度
    constant V_FRONT_PORCH : integer := 10;  -- 垂直前座標
    signal divclk:STD_LOGIC_VECTOR(1 downto 0);
    signal fclk:STD_LOGIC;
    signal h_count : integer range 0 to 799 := 0;  -- 水平計數器
    signal v_count : integer range 0 to 524 := 0;  -- 垂直計數器
    signal random_color : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- 隨機背景顏色
begin
    process(fclk, rst_n)
    begin
        if rst_n = '0' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(fclk) then
            if h_count = 799 then
                h_count <= 0;
                if v_count = 524 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    -- 水平同步信號和垂直同步信號
    hsync <= '0' when (h_count < H_SYNC_CYCLES) else '1';
    vsync <= '0' when (v_count < V_SYNC_CYCLES) else '1';

    -- 隨機背景顏色生成 (可以改為更精細的隨機邏輯)
    random_color <= "001" when (h_count = 100 and v_count = 100) else random_color;

    -- 圓形的繪製邏輯
    -- 圓心位置 (320, 240)，半徑 100
    --    if ( (h_count - 320) * (h_count - 320) ) +(  (v_count - 240) * (v_count - 240) ) <= 100 * 100 then
process(fclk, rst_n)
    begin    
   if ( (h_count - 480) * (h_count - 480) ) +(  (v_count - 360) * (v_count - 360) ) <=20 * 20 then
        red   <= "0000";
        green <= "1111";  -- 綠色圓形
        blue  <= "0000";
    else
        -- 背景顏色設置為隨機顏色
        case random_color is
            when "000" => 
                red   <= "0000";
                green <= "0000";
                blue  <= "1111"; -- 藍色背景
            when "001" => 
                red   <= "1111";
                green <= "0000";
                blue  <= "0000"; -- 紅色背景
            when others => 
                red   <= "0000";
                green <= "1111";
                blue  <= "0000"; -- 預設綠色背景
        end case;
    end if;
   end process;    
fd:process(clk ,rst_n)
begin
if (rst_n = '0') then 
    divclk <= (others => '0');
elsif (rising_edge(clk)) then
    divclk <= divclk +1 ;
end if;
end process fd;
fclk <= divclk(1);      
end Behavioral;
