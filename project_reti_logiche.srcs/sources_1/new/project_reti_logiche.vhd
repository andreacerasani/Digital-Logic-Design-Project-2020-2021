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
		i_en : in std_logic; --if 1 counter is decreased
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

-- Component to increase by 1 the memory address
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity addr_increaser is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_en : in std_logic; --if 1 addr is increased
		i_load: in std_logic;
		i_data : in std_logic_vector(15 downto 0);
		o_address : out std_logic_vector(15 downto 0)
		);
end addr_increaser;

architecture Behavioral of addr_increaser is
    signal addr_reg: unsigned(15 downto 0);
    signal addr_next: unsigned(15 downto 0);
begin
    --register
    process(i_clk, i_rst)
	begin
		if (i_rst = '1') then 
			addr_reg <= (others => '0'); --clear
		elsif (rising_edge(i_clk)) then
			addr_reg <= addr_next;
		end if;
	end process;
	--next-state logic
	addr_next <=   unsigned(i_data) when i_load = '1' else
	               addr_reg + 1  when i_en = '1' else
	               addr_reg;
    --output logic
    o_address <= std_logic_vector(addr_reg);
    
end Behavioral;

--Combinational component to compute the new value of a pixel of the image
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
entity new_value_logic is
    port(
		i_min: in std_logic_vector(7 downto 0);
		i_max: in std_logic_vector(7 downto 0);
		i_old_value: in std_logic_vector(7 downto 0);
		o_new_value: out std_logic_vector(7 downto 0)
		);
end new_value_logic;

architecture Behavioral of new_value_logic is
    signal delta : integer range 0 to 255;
    signal floorlog: natural range 0 to 8;
    signal shift_level: natural range 0 to 8;
    signal temp_pixel: STD_LOGIC_VECTOR(15 downto 0);
    
    begin
    delta <= to_integer(unsigned(i_max - i_min));         
    with delta select
        floorlog <= 8 when 255,
                    7 when 127 to 254,
                    6 when 63 to 126,
                    5 when 31 to 62,
                    4 when 15 to 30,
                    3 when 7 to 14,
                    2 when 3 to 6,
                    1 when 1 to 2,
                    0 when 0;                       
    shift_level <=  8 - floorlog;
    temp_pixel <= std_logic_vector(shift_left("00000000" & unsigned(i_old_value - i_min), shift_level));
    o_new_value <= "11111111" when (temp_pixel > "11111111") else
                    temp_pixel(7 downto 0);
                                           
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity datapath is
port(
i_clk : in std_logic;
i_rst : in std_logic;
i_data : in std_logic_vector(7 downto 0);
set_col: in std_logic;
set_row: in std_logic;
set_col_count: in std_logic;
set_row_count: in std_logic;
col_decr: in std_logic; --decrease column
row_decr: in std_logic; --decrease row
min_max_en : in std_logic;
old_img_addr_incr: in std_logic;
set_old_img_addr: in std_logic;
old_img_addr_to_load: in std_logic_vector(15 downto 0);
new_img_addr_incr: in std_logic;
set_new_img_addr: in std_logic;
o_addr_sel: in std_logic; --0 old image 1 new image
col_zero: out std_logic; -- 1 when column counter reaches zero
row_zero: out std_logic; --1 when row counter reaches zero
o_address : out std_logic_vector(15 downto 0);
o_data : out std_logic_vector (7 downto 0)
);
end datapath;

architecture Behavioral of datapath is
signal col_reg : STD_LOGIC_VECTOR (7 downto 0);
signal row_reg : STD_LOGIC_VECTOR (7 downto 0);
signal min : STD_LOGIC_VECTOR (7 downto 0);
signal max : STD_LOGIC_VECTOR (7 downto 0);
signal old_img_addr:  STD_LOGIC_VECTOR (15 downto 0);
signal new_img_addr:  STD_LOGIC_VECTOR (15 downto 0);

	--Min max comparator component
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
	
	--Down Counter
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
	
	--Addr Increaser
	component addr_increaser is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_en : in std_logic; --if 1 addr is increased
		i_load: in std_logic;
		i_data : in std_logic_vector(15 downto 0);
		o_address : out std_logic_vector(15 downto 0)
		);
    end component;
    
    --Combinational component to compute the new value of a pixel of the image
    component new_value_logic is
    port(
		i_min: in std_logic_vector(7 downto 0);
		i_max: in std_logic_vector(7 downto 0);
		i_old_value: in std_logic_vector(7 downto 0);
		o_new_value: out std_logic_vector(7 downto 0)
		);
    end component;
    
    

begin
    --Column register
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            col_reg <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(set_col = '1') then
                col_reg <= i_data;
            end if;
        end if;
    end process;
    
    --Row register
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            row_reg <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(set_row = '1') then
                row_reg <= i_data;
            end if;
        end if;
    end process;
    
    --o_addr mux
    with o_addr_sel select
        o_address <= old_img_addr when '0',
                     new_img_addr when '1',
                     "XXXXXXXXXXXXXXXX" when others;
                     
	
    
    old_image_addr_increaser: addr_increaser port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_en => old_img_addr_incr,
        i_load => set_old_img_addr,
        i_data => old_img_addr_to_load,
        o_address => old_img_addr
    );
    
    new_imag_addr_increaser: addr_increaser port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_en => new_img_addr_incr,
        i_load => set_new_img_addr,
        i_data => old_img_addr,
        o_address => new_img_addr
    );    
	
	MINMAX : min_max_comparator port map(
		i_clk => i_clk,
		i_rst => i_rst,
		i_en => min_max_en,
		i_data => i_data,
		o_min => min,
		o_max => max
	);
	
	down_counter_col : down_counter port map(
		i_clk => i_clk,
        i_rst => i_rst,
		i_load => set_col_count,
		i_en => col_decr,
		i_data => col_reg,
		o_zero => col_zero
	);
	
	down_counter_row : down_counter port map(
		i_clk => i_clk,
        i_rst => i_rst,
		i_load => set_row_count,
		i_en => row_decr,
		i_data => row_reg,
		o_zero => row_zero
	);
	
	new_value : new_value_logic port map(
	   i_min => min,
	   i_max => max,
	   i_old_value => i_data,
	   o_new_value => o_data
	);
	
	
    

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
component datapath is
port(
i_clk : in std_logic;
i_rst : in std_logic;
i_data : in std_logic_vector(7 downto 0);
set_col: in std_logic;
set_row: in std_logic;
set_col_count: in std_logic;
set_row_count: in std_logic;
col_decr: in std_logic; --decrease column
row_decr: in std_logic; --decrease row
min_max_en : in std_logic;
old_img_addr_incr: in std_logic;
set_old_img_addr: in std_logic;
old_img_addr_to_load: in std_logic_vector(15 downto 0);
new_img_addr_incr: in std_logic;
set_new_img_addr: in std_logic;
o_addr_sel: in std_logic; --0 old image 1 new image
col_zero: out std_logic; -- 1 when column counter reaches zero
row_zero: out std_logic; --1 when row counter reaches zero
o_address : out std_logic_vector(15 downto 0);
o_data : out std_logic_vector (7 downto 0)
);
end component;

signal set_col: std_logic;
signal set_row: std_logic;
signal set_col_count: std_logic;
signal set_row_count: std_logic;
signal col_decr: std_logic; --decrease column
signal row_decr: std_logic; --decrease row
signal min_max_en : std_logic;
signal old_img_addr_incr: std_logic;
signal set_old_img_addr: std_logic;
signal old_img_addr_to_load: std_logic_vector(15 downto 0);
signal new_img_addr_incr: std_logic;
signal set_new_img_addr: std_logic;
signal o_addr_sel: std_logic; --0 old image 1 new image
signal col_zero: std_logic; -- 1 when column counter reaches zero
signal row_zero: std_logic; --1 when row counter reaches zero

type S is (START, COL, ROW, WAITROW, MINMAX_ROW, WAITMINMAX, MINMAX_COL, PHASE_2, READ_ADDR, WRITE);
signal cur_state, next_state : S;

begin
    DATAPATH0: datapath port map(
    i_clk => i_clk,
    i_rst => i_rst,
    i_data => i_data,
    set_col => set_col,
    set_row => set_row,
    set_col_count => set_col_count,
    set_row_count => set_row_count,
    col_decr => col_decr, --decrease column
    row_decr => row_decr, --decrease row
    min_max_en => min_max_en,
    old_img_addr_incr => old_img_addr_incr,
    set_old_img_addr => set_old_img_addr,
    old_img_addr_to_load => old_img_addr_to_load,
    new_img_addr_incr => new_img_addr_incr,
    set_new_img_addr => set_new_img_addr,
    o_addr_sel => o_addr_sel, --0 old image 1 new image
    col_zero => col_zero, -- 1 when column counter reaches zero
    row_zero => row_zero, --1 when row counter reaches zero
    o_address => o_address,
    o_data => o_data
    );
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= START;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, col_zero, row_zero)
    begin
        next_state <= cur_state;
        case cur_state is
            when START =>
                if i_start = '1' then
                    next_state <= COL;
                end if;
            when COL =>
                next_state <= ROW;
            when ROW =>
                next_state <= WAITROW;
            when WAITROW =>
                next_state <= MINMAX_ROW;
            when MINMAX_ROW =>
                next_state <= WAITMINMAX;
            when WAITMINMAX =>
                 if col_zero = '1' then
                    next_state <= PHASE_2;
                elsif row_zero = '1' then
                    next_state <= MINMAX_COL;
                else next_state <= MINMAX_ROW;
                end if;  
            when PHASE_2 =>
                next_state <= READ_ADDR;
            when MINMAX_COL => 
                next_state <= WAITMINMAX;
             when others =>   
            --Completare
            
        end case;
     end process;
     
     process(cur_state)
     begin
        set_col <= '0';
        set_row <= '0';
        set_col_count <= '0';
        set_row_count <= '0';
        col_decr <= '0'; --decrease column
        row_decr <= '0'; --decrease row
        min_max_en <= '0';
        old_img_addr_incr<= '0';
        set_old_img_addr<= '0';
        old_img_addr_to_load <= "0000000000000000";
        new_img_addr_incr <= '0';
        set_new_img_addr <= '0';
        o_addr_sel <= '0'; --0 old image 1 new image
        o_done <= '0';
        o_en <= '0';
        o_we <= '0';
        
        
        case cur_state is
            when START =>
            when COL =>
                set_col <= '1';
                old_img_addr_incr <= '1';
                o_en <= '1';
           when ROW =>
                set_row <= '1';
                set_col_count <= '1'; --Si mantiene il valore dsettato in COL?
                old_img_addr_incr <= '1';
            when WAITROW =>
                set_row_count<= '1';
                o_en <= '1';
            when MINMAX_ROW =>
                row_decr <= '1';
                min_max_en <= '1';
                old_img_addr_incr <= '1';
                o_en <= '1';
            when WAITMINMAX =>
                o_en <= '1';
            when MINMAX_COL =>
                col_decr <= '1';
                min_max_en <= '1';
                set_row_count<= '1';
                o_en <= '1';    
           when others => --da togliere 
                      
        end case;
    end process; 
                      
end Behavioral;
