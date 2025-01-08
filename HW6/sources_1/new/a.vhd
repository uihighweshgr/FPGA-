library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity vga_controller is
    Port ( i_clk            : in STD_LOGIC;
           i_rst            : in STD_LOGIC;
           i_sw_up : in STD_LOGIC;
           i_sw_dn : in STD_LOGIC;      
           hsync     : out STD_LOGIC;       -- 水平同步信號
           vsync     : out STD_LOGIC;       -- 垂直同步信號
           red       : out STD_LOGIC_VECTOR (3 downto 0);  -- 紅色顏色分量
           green     : out STD_LOGIC_VECTOR (3 downto 0);  -- 綠色顏色分量
           blue      : out STD_LOGIC_VECTOR (3 downto 0)   -- 藍色顏色分量
           );
end vga_controller;

architecture Behavioral of vga_controller is
    
signal count            : STD_LOGIC_VECTOR(7 downto 0);
signal right_score      : STD_LOGIC_VECTOR(3 downto 0);
signal left_score       : STD_LOGIC_VECTOR(3 downto 0);
signal divclk           :STD_LOGIC_VECTOR(26 downto 0);
signal pwm_clk          :STD_LOGIC;
type sw_state is (sw_up,sw_dn,sw_o);
signal pwm_sw_state: sw_state;
signal prestate: sw_state;
    
    signal           sw  : STD_LOGIC_VECTOR(1 downto 0);
    constant   default_n : integer := 1;
    constant       det_n : integer := 1; 
    constant n_MIN_cycle : integer := 0;   -- min n pwm cycles
    constant n_MAX_cycle : integer := 50;
    signal   n_cycle_PWM : integer range 0 to 50;
    signal brighter_darker : std_logic;
    signal n_cycle_PWM_complete: std_logic;
    signal prev_pwm_state: std_logic;
    signal pwm_state: std_logic;
    signal pwm_count: integer range 0 to 5000;
    signal upbnd1: integer range 0 to 255;
    signal upbnd2: integer range 0 to 255;
    signal count1: integer range 0 to 255;
    signal count2: integer range 0 to 255;
    -- VGA參數定義 (640x480解析度，60Hz刷新率)
    constant xplus         : integer := 145;
    constant H_SYNC_CYCLES : integer := 96;  -- 水平同步脈寬
    constant H_BACK_PORCH : integer := 48;   -- 水平後座標
    constant H_ACTIVE_VIDEO : integer := 640; -- 顯示區寬度
    constant H_FRONT_PORCH : integer := 16;  -- 水平前座標
    constant V_SYNC_CYCLES : integer := 2;   -- 垂直同步脈寬
    constant V_BACK_PORCH : integer := 33;   -- 垂直後座標
    constant V_ACTIVE_VIDEO : integer := 480; -- 顯示區高度
    constant V_FRONT_PORCH : integer := 10;  -- 垂直前座標
    signal fclk:STD_LOGIC;
    signal h_count : integer range 0 to 799 := 0;  -- 水平計數器
    signal v_count : integer range 0 to 524 := 0;  -- 垂直計數器

begin

    sw <= i_sw_up & i_sw_dn;


    -- 水平和垂直計數器更新
    process(pwm_clk, i_rst)
    begin
        if i_rst = '0' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(pwm_clk) then
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

    -- 圓形的繪製邏輯
    process(pwm_clk, i_rst)
    begin    
        if i_rst = '0' then
            red   <= "0000";
            green <= "0000";
            blue  <= "0000";  -- 初始為黑色
        elsif rising_edge(pwm_clk) then
            -- 圓心位置 (480, 360)，半徑 15
            if ( (  h_count  -xplus) * ( h_count -xplus) + (v_count - 360) * (v_count - 360) <= 15 * 15 ) then
                red   <= "0000";         -- 紅色為 0000
                green <= "1111";         -- 綠色為 1111
                blue  <= "0000";         -- 藍色為 0000
            else
                red   <= "0100";         -- 默認為黑色
                green <= "1000";         -- 默認為黑色
                blue  <= "0011";         -- 默認為黑色
            end if;
        end if;
    end process;

BFA:process(fclk, i_rst, i_sw_up, i_sw_dn)
begin
    if i_rst = '0' then
        n_cycle_PWM <= default_n; 
    elsif fclk'event and fclk = '1' then
        case sw is
            when "00" => 
                pwm_sw_state <=sw_o;
                null;
 
            when "01" => --呼吸急促(pwm週期數變小)
                if ((n_cycle_PWM > n_MIN_cycle) and (pwm_sw_state = sw_o)) then
                    n_cycle_PWM <= n_cycle_PWM - det_n; -- tune down det_n
                    pwm_sw_state <=sw_dn;
                else
                    null;
                end if; 
            when "10" => --呼吸減緩(pwm週期數變大)
                if ((n_cycle_PWM < n_MAX_cycle) and (pwm_sw_state = sw_o)) then
                    n_cycle_PWM <= n_cycle_PWM + det_n; -- tune up det_n
                    pwm_sw_state <=sw_up;
                else
                    null;
                end if;             
            when "11" =>
                pwm_sw_state <=sw_o;
                null;
            when others =>
                pwm_sw_state <=sw_o;
                null;
        end case;
    end if;
end process;




Adapt_brighter_or_darker:process(i_clk, i_rst, upbnd1, upbnd2)
begin
    if i_rst = '0' then
        brighter_darker <= '1'; 
    elsif i_clk'event and i_clk = '1' then
        if brighter_darker = '0' then
            if upbnd1=0 then -- counter2=MAX_PWM_count最暗時
                brighter_darker <= '1';
            end if;
        else --brighter_darker = '1'
            if upbnd2=0 then -- counter1=MAX_PWM_count最亮時
                brighter_darker <= '0';
            end if;        
        end if;
    end if;
end process;
--input:
    -- pwm: pwm state feedback;
--output:
    -- n_PWM_cycle_complete: already counted n PWM cycles according to num of pwm pulses
PWM_cycle_counter:process(i_clk, i_rst, n_cycle_PWM, pwm_state)
begin
    if i_rst = '0' then
        n_cycle_PWM_complete <= '0'; 
        pwm_count <= 0;
        prev_pwm_state <= '0';
    elsif i_clk'event and i_clk = '1' then
        prev_pwm_state <= pwm_state; -- Mealey Machine
        if prev_pwm_state = '0' and pwm_state = '1' then
            if pwm_count < n_cycle_PWM then
                pwm_count <= pwm_count + 1;
                n_cycle_PWM_complete <= '0'; -- not yet
            else
                n_cycle_PWM_complete <= '1'; -- 完成 PWM 週期
                pwm_count <= 0; -- 進入下一個 PWM 週期
            end if;
        elsif prev_pwm_state = '1' and pwm_state = '0' then
            if pwm_count < n_cycle_PWM then
                pwm_count <= pwm_count + 1;
                n_cycle_PWM_complete <= '0'; -- not yet
            else
                n_cycle_PWM_complete <= '1'; -- 完成 PWM 週期
                pwm_count <= 0; -- 進入下一個 PWM 週期
            end if;
        else
            n_cycle_PWM_complete <= '0'; -- null;
        end if;
    end if;
end process;
--inputs:
    -- brighter_darker: 
    -- n_cycle_PWM_complete: 完成n個cycle PWM週期
--outputs:
    -- upbnd1, upbnd2        
upperbounds:process(i_clk, i_rst, brighter_darker, n_cycle_PWM_complete)
begin
    if i_rst = '0' then
        upbnd1 <= 0;
        upbnd2 <= 255;        
    elsif i_clk'event and i_clk = '1' then
         if brighter_darker = '0' then
             if n_cycle_PWM_complete = '1' then
                 upbnd1 <= upbnd1 - 1;
                 upbnd2 <= upbnd2 + 1;
             else
                 null;
             end if;
         else -- brighter_darker = '1'
             if n_cycle_PWM_complete = '1' then
                 upbnd1 <= upbnd1 + 1;
                 upbnd2 <= upbnd2 - 1;
             else
                 null;
             end if;         
         end if;
    end if;
end process;

FSM1_for_pwm: process(i_rst, i_clk, count1, count2)
begin
    if i_rst = '0' then
        pwm_state <= '0';
    elsif i_clk'event and i_clk = '1' then
        if pwm_state = '0' then
            if count1 = upbnd1 then
                pwm_state <= '1';
            else
                pwm_state <= '0';
            end if;
        else -- pwm_state = '1'
            if count2 = upbnd2 then
                pwm_state <= '0';
            else
                pwm_state <= '1';
            end if;    
        end if;        
    end if;
end process;
counter1:process(i_clk, i_rst, pwm_state)
begin
    if i_rst = '0' then
        count1 <= 0;
    elsif i_clk'event and i_clk = '1' then
        if pwm_state = '0' then
            count1 <= count1 + 1;
            --count2 <= 0;
        else -- pwm_state = '1'
            count1 <= 0;
        end if;   
    end if;
end process;
counter2:process(i_clk, i_rst, pwm_state)
begin
    if i_rst = '0' then
        count2 <= 0;
    elsif i_clk'event and i_clk = '1' then
        if pwm_state = '1' then
            count2 <= count2 + 1;
            --count2 <= 0;
        else -- pwm_state = '0'
            count2 <= 0;
        end if;   
    end if;
end process;


    -- 時鐘分頻處理 (為了產生fclk信號)
  fd:process(i_clk ,i_rst)
begin
if i_rst = '0' then 
    divclk <= (others => '0');
elsif rising_edge(i_clk) then
    divclk <= divclk +1 ;
end if;
end process fd;
fclk <= divclk(25); 
pwm_clk <= n_cycle_PWM_complete;
end Behavioral;