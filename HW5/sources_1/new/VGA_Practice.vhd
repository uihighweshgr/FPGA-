library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity vga_controller is
    Port ( clk       : in  STD_LOGIC;       -- FPGA時鐘
           rst_n     : in  STD_LOGIC;       -- 重置信號
           hsync     : out STD_LOGIC;       -- 水平同步信號
           vsync     : out STD_LOGIC;       -- 垂直同步信號
           red       : out STD_LOGIC_VECTOR (3 downto 0);  -- 紅色分量
           green     : out STD_LOGIC_VECTOR (3 downto 0);  -- 綠色分量
           blue      : out STD_LOGIC_VECTOR (3 downto 0)   -- 藍色分量
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

    signal divclk : STD_LOGIC_VECTOR(1 downto 0);
    signal fclk   : STD_LOGIC;
    signal h_count : integer range 0 to 799 := 0;  -- 水平計數器
    signal v_count : integer range 0 to 524 := 0;  -- 垂直計數器
begin
    -- 水平與垂直計數器
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

    -- 顏色繪製 (圓形邏輯)
    process(fclk, rst_n)
    begin    
        if rst_n = '0' then
            red   <= "0000";
            green <= "0000";
            blue  <= "0000";  -- 初始化為黑色
        elsif rising_edge(fclk) then
            -- 判斷是否在圓形內 (圓心為 480,360，半徑為 20)
            if ( (h_count - 480) * (h_count - 480) + (v_count - 360) * (v_count - 360) ) <= 20 * 20 then
                red   <= "0000";
                green <= "1111";  -- 綠色圓形
                blue  <= "0000";
            else
                red   <= "0000";
                green <= "0000";
                blue  <= "0000";  -- 圓形外設為黑色
            end if;
        end if;
    end process;

    -- 時鐘分頻
    fd: process(clk, rst_n)
    begin
        if rst_n = '0' then 
            divclk <= (others => '0');
        elsif rising_edge(clk) then
            divclk <= divclk + 1;
        end if;
    end process;

    fclk <= divclk(1); -- 分頻信號
end Behavioral;
