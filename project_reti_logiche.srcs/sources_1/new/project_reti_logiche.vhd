----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.08.2021 21:22:15
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
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
library work;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--Synchronous down 8-bit counter with asynchronous reset
entity down_counter is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_load : in std_logic;
		i_en : in std_logic;
		i_data : in std_logic_vector(7 downto 0);
		o_zero : out std_logic
		);
end down_counter;

architecture Behavioral of down_counter is
	signal r_reg : unsigned(7 downto 0); -- internal counter signal
	signal r_next: unsigned(7 downto 0);
begin
--register
	process(i_clk, i_rst)
	begin
		if (i_rst = '1') then 
			r_reg <= (others => '0'); --clear
		elsif (rising_edge(i_clk)) then
			r_reg <= r_next;
		end if;
	end process;
	
--next-state logic
	r_next <= unsigned(i_data) when i_load = '1' else
	
			r_reg - 1 when (i_en = '1' and not(r_reg = 0))else
			r_reg;
			
--output logic
	o_zero <= '1' when r_reg = 0 else '0';
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity min_max_comparator is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_en : in std_logic;
		i_data : in std_logic_vector(7 downto 0);
		o_min : out std_logic_vector(7 downto 0);
		o_max : out std_logic_vector(7 downto 0)
		);
end min_max_comparator;

architecture Behavioral of min_max_comparator is
	signal r_max: std_logic_vector(7 downto 0);
	signal r_min: std_logic_vector(7 downto 0);
	signal next_max: std_logic_vector(7 downto 0);
	signal next_min: std_logic_vector(7 downto 0);
begin
	--max register
	process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            r_max <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(i_en = '1') then
                r_max <= next_max;
            end if;
        end if;
    end process;

	--min register
	process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            r_min <= "11111111";
        elsif i_clk'event and i_clk = '1' then
            if(i_en = '1') then
                r_min <= next_min;
            end if;
        end if;
    end process;
	
	--compare
	next_max <= i_data when (i_data > r_max) else
				r_max;
	next_min <= i_data when (i_data < r_min) else
				r_min;
				
	--output
	o_max <= r_max;
	o_min <= r_min;
	
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
port (
i_clk : in std_logic;
i_rst : in std_logic;
i_start : in std_logic;
i_data : in std_logic_vector(7 downto 0);
o_address : out std_logic_vector(15 downto 0);
o_done : out std_logic;
o_en : out std_logic;
o_we : out std_logic;
o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

begin


end Behavioral;
