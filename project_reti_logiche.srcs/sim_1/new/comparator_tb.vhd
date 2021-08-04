
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator_tb is
--  Port ( );
end comparator_tb;

architecture Behavioral of comparator_tb is
component min_max_comparator is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_en : in std_logic;
		i_data : in std_logic_vector(7 downto 0);
		o_min : out std_logic_vector(7 downto 0);
		o_max : out std_logic_vector(7 downto 0)
		);
end component;
signal i_clk : STD_LOGIC;
signal i_rst : STD_LOGIC;
signal i_en : STD_LOGIC;
signal i_data : STD_LOGIC_VECTOR (7 downto 0);
signal o_min : STD_LOGIC_VECTOR (7 downto 0);
signal o_max : STD_LOGIC_VECTOR (7 downto 0);
begin
    TOP0 : min_max_comparator port map(
        i_clk,
        i_rst,
        i_en,
        i_data,
        o_min,
        o_max
    );
    
    process
    begin
        wait for 5 ns;
        i_clk <= '1';
        wait for 5 ns;
        i_clk <= '0';
    end process;
    
    process
    begin
        i_rst <= '1';
        wait for 10 ns;
        i_en <= '1';
        i_rst <= '0';
        i_data <= "00110010";
        wait for 10 ns;
        i_en <= '1';
        i_data <= "00000001";
        wait for 10 ns;
        i_en <= '1';
        i_data <= "10000000";
        wait for 10 ns;
        i_rst <= '1';
        wait for 10 ns;
        i_en <= '0';
        i_rst <= '0';
        i_data <= "00110010";
        wait for 10 ns;
        i_en <= '1';
        i_rst <= '0';
        i_data <= "01010000";
        wait for 200 ns;
        assert false report "simulation ended" severity failure;
    end process;

end Behavioral;
