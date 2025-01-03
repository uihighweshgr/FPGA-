library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity	pwm is
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
end pwm;

architecture behavioral of pwm is

type state_counter is (counter1_is_counting, counter2_is_counting);
signal current_state_counter : state_counter;

type STATE_TYPE is (full_speed, speeding_up, speeding_dn, final);
signal state:STATE_TYPE; 
signal counter1:STD_LOGIC_VECTOR (7 downto 0);
signal counter2:STD_LOGIC_VECTOR (7 downto 0);
signal upbnd1:STD_LOGIC_VECTOR (7 downto 0);
signal upbnd2:STD_LOGIC_VECTOR (7 downto 0);

begin
       
pwm:process(i_clk,i_rst)
begin
    if current_state_counter = counter1_is_counting then
        o_pwm <= '1';              
    elsif current_state_counter = counter2_is_counting then
        o_pwm <= '0';
    end if;        
end process;       
       
       
counter:process(i_clk,i_rst)
begin
    if i_rst = '0' then
        state <= full_speed;
    elsif i_clk' event and i_clk='1' then
        case state is
            when full_speed =>
                if i_th_speed>i_speed_now then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then    
                    state <= speeding_up;  
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;             
            when speeding_up =>
                if i_th_speed>i_speed_now then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then    
                    state <= speeding_up;  
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;
            when speeding_dn =>
                if i_th_speed>i_speed_now then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then    
                    state <= speeding_up;  
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;
            when final =>
                if i_th_speed>i_speed_now then
                    state <= full_speed;
                elsif i_speed_now >= i_th_speed and i_speed_now < i_target then    
                    state <= speeding_up;  
                elsif i_speed_now > i_target then
                    state <= speeding_dn;                
                elsif i_speed_now = i_target then
                    state <= final;                               
                end if;
        end case;
    end if;                        
end process;
  
count_state:process(i_clk,i_rst)
begin
    if i_rst='0' then 
        current_state_counter <= counter1_is_counting ;        
    elsif i_clk' event and i_clk='1' then
        case current_state_counter is
            when counter1_is_counting =>
                if counter1= upbnd1 then
                    current_state_counter <= counter2_is_counting ;
                end if;
            when counter2_is_counting =>
                if counter2= upbnd2 then
                    current_state_counter <= counter1_is_counting ;
                end if;
            when others =>
                null;
        end case;
     end if;                                     
end process;
       
upbnd:process(i_clk,i_rst)
begin
    if i_rst='0' then 
        upbnd1 <= "11111111";
        upbnd2 <= "00000000";
     elsif i_clk'event and i_clk='1' then
        case state is
            when full_speed =>
                upbnd1 <= "11111111";
                upbnd2 <= "00000000";  
            when speeding_up =>
                upbnd1 <= "10111111"; --191
                upbnd2 <= "00111111"; --63             
            when speeding_dn =>
                upbnd1 <= "00111111"; --63
                upbnd2 <= "10111111"; --191                             
            when final       =>    
                upbnd1 <= "01111111"; --127
                upbnd2 <= "01111111"; --127     
            when others =>
                null;
        end case;     
    end if;   
end process;       
       
       
        
counter_1p:process(i_clk,i_rst)
begin
    if i_rst='0' then 
        counter1 <="00000000";
    elsif i_clk' event and i_clk='1' then 
        case  current_state_counter is
            when counter1_is_counting=>
                counter1 <=counter1 +'1'; 
            when counter2_is_counting =>
                counter1 <= "00000000";
            when others =>
                null;
        end case;        
    end if;
end process;                    


counter_2p:process(i_clk, i_rst)
begin
    if i_rst='0' then
        counter2 <= "00000000"; 
    elsif i_clk'event and i_clk='1' then
        case  current_state_counter is
            when counter1_is_counting =>
                --counter1 <= counter1 + '1';
                counter2  <= "00000000";
            when counter2_is_counting =>
                counter2 <= counter2 + '1';
                --counter1 <= "00000000";
            when others =>
                null;
        end case;
    end if;
end process;


end behavioral;
