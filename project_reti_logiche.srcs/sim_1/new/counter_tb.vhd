
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity counter_tb is
--  Port ( );
end counter_tb;

architecture Behavioral of counter_tb is
component down_counter is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_load : in std_logic;
		i_en : in std_logic;
		i_data : in std_logic_vector(7 downto 0);
		o_zero : out std_logic
		);
end component;
signal i_clk : STD_LOGIC;
signal i_rst : STD_LOGIC;
signal i_load : STD_LOGIC;
signal i_en : STD_LOGIC;
signal i_data : STD_LOGIC_VECTOR (7 downto 0);
signal o_zero : STD_LOGIC;
begin
    TOP0 : down_counter port map(
        i_clk,
        i_rst,
        i_load,
        i_en,
        i_data,
        o_zero
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
        i_load <= '1';
        i_data <= "00000010";
        wait for 10 ns;
        i_load <= '0';
        wait for 40 ns;
        i_rst <= '1';
        wait for 10 ns;
        i_en <= '0';
        i_rst <= '0';
        i_load <= '0';
        i_data <= "00110010";
        wait for 10 ns;
        i_en <= '1';
        i_load <= '1';
        i_data <= "00000001";
        wait for 10 ns;
        i_load <= '0';
        wait for 200 ns;
        assert false report "simulation ended" severity failure;
    end process;

end Behavioral;
