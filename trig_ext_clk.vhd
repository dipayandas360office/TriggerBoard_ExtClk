library IEEE;
library UNISIM;
use UNISIM.VComponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity Trigger is 
generic (
        clock_frequency     : positive := 100_000_000
    );
port (
--    clock : in std_logic;
    clk_in : in std_logic;
    clk_out : out std_logic;
    trig_in : in std_logic;
    trig_out1 : out std_logic;
    trig_out2 : out std_logic;
    bin_number : in std_logic_vector (3 downto 0);
    reset_in : in std_logic
    --light : out std_logic
);
end Trigger;

architecture behav of Trigger is 
signal clk_40 , clk_100 , clk_400 : std_logic:='0';
signal reset_s : std_logic :='0';
signal mono_out : std_logic := '0' ;
signal mono_on : std_logic := '0';
signal count : integer := 0;
signal trig_out : std_logic := '0';
signal clk_locked : std_logic;
signal trig_in_d1 , trig_in_d2 , trig_rise , clk_in_d1 , clk_in_d2 , clk_in_rise ,trig_out_and: std_logic := '0';
signal count_bin    : unsigned(3 downto 0):="0000";
signal trig_out_buf ,gate : std_logic;

    -- Component declaration for clk_wiz_0
component clk_wiz_0
    port(
       clk_out1   : out std_logic;
       reset      : in  std_logic;
       locked     : out std_logic;
       clk_in1    : in std_logic
    );
end component;
 
begin

    ClockGen : clk_wiz_0
    port map(
        clk_out1  => clk_400,
        reset     => reset_s,
        clk_in1   => clk_in,
        locked    => clk_locked
    );

    OBUF_inst : OBUF
        generic map (
            DRIVE => 12,
            IOSTANDARD => "LVCMOS33",
            SLEW => "FAST"
        )
        port map(
            I => clk_in,
            O => clk_out
        );

trig    : process (clk_400) 
          begin
          if rising_edge(clk_400) then
              if (reset_s ='1') then
                    count_bin <= "0000";
--                    count <= 0;
--                    mono_on    <= '0';
--                    trig_out   <= '0';
              else
                  

                  if count_bin = 9 then
                     count_bin <= "0000";
                     
                  else 
                    count_bin <= count_bin +1; 
                  end if;
                   
                  
                  trig_in_d1 <= trig_in;
                  trig_in_d2 <= trig_in_d1;
                  
--                  clk_in_d1 <= clk_in;
--                  clk_in_d2 <= clk_in_d1;
                                                      
--                  if (count_bin >= "0011" and count_bin <="0100"  ) then ------------- select the bin (phase)
                 if (bin_number = "1111") then 
                    gate <= '1';
                 else                                     
                      if (count_bin = unsigned(bin_number)) then ------------- select the bin (phase)
                        gate <='1';
                      else
                        gate <= '0';
                      end if;
                 end if; 
               end if;
          end if;
       end process; 
        
monoshot : process (clk_400)
       begin
           if rising_edge(clk_400) then
               if (reset_s = '1') then
                   count <= 0;
                   trig_out_buf <= '0';
--               elsif (gate = '1' and trig_rise = '1') then
               elsif (gate = '1' and trig_in = '1') then -- ANDed with Trig_in
                   count <= 0;
                   trig_out_buf <= '1';
               elsif (trig_out_buf = '1') then
                   if (count < 39) then
                       count <= count + 1;
                   else
                       count <= 0;
                       trig_out_buf <= '0';
                   end if;
               end if;
           end if;
       end process;

    
          

--trig_out1 <= gate;
trig_out1 <= trig_out_buf;                   
reset_s <= reset_in;   
trig_rise <= trig_in_d1 and not trig_in_d2;   -- rising edge detect  
trig_out_and <= gate and trig_rise;
clk_40 <= clk_in;
--trig_out2 <= trig_out_and;
trig_out2 <= trig_out_buf;
--clk_out <= clk_40;
--counterOut <= std_logic(count_bin(2));
end behav;
