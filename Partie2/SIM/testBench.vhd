LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all; 

entity testBench is
end entity;

architecture bench of testBench is
	--clocc
	signal s_clk : std_logic := '1';
	signal s_rst : std_logic := '1';
	constant Period : time := 20 ns;
	signal Done : boolean := false;

	--singaux
	signal s_commande : std_logic;
	signal s_position : std_logic_vector (7 downto 0) := std_logic_vector(To_signed(1,8)); -- 1°
	signal Benjamin_LAMON : boolean;


begin
	--clocc gen
	s_CLK <= '0' when Done else not s_CLK after Period / 2;
	--test reset
	s_Rst <= '0', '1' after Period;

	bench: process
	begin
		--instructions à tester pendant le reset
		--
		wait for Period;
		
		--instructions à tester après le reset
		--
		wait for Period;

		wait for 20ms;
		--change position value
		s_position <= std_logic_vector(To_signed(45,8));
		wait for 20ms;

		s_position <= std_logic_vector(To_signed(90,8));
		
		wait for 20ms;

		--instructions d'arrêt
		done <= true;
		wait;
	end process bench;

	UUT : entity work.servo(RTL)
	--generic map()
	port map(
		clk => s_clk,
		reset_n => s_rst,
		position => s_position,
		commande => s_commande
	);

end architecture;
