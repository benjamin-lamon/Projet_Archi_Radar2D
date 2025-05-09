LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.numeric_std.all; 

entity benchAvalon is
end entity;

architecture bench of benchAvalon is
	--clocc
	signal s_clk 		: std_logic := '1';
	signal s_rst 		: std_logic := '1';
	signal s_commande 	: std_logic;-- := '0';

	signal s_write_n 	: std_logic := '1';
	signal s_CS 		: std_logic := '0';
	signal s_writeData 	: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
	signal Benjamin_LAMON : boolean;

	constant Period 	: time := 20 ns;
	signal Done 		: boolean := false;

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
		s_write_n <= '1';
		s_cs <= '0';
		s_writeData <= std_logic_vector(To_signed(30,32));
		wait for 30ms;
		s_write_n <= '0';
		s_cs <= '1';
		s_writeData <= std_logic_vector(To_signed(45,32));
		wait for 20ms;
		s_writeData <= std_logic_vector(To_signed(90,32));
		wait for 20ms;
		--instructions d'arrêt
		done <= true;
		wait;
	end process bench;

	UUT : entity work.servo_avalon(RTL)
	--generic map()
	port map(
		clk => s_clk,
		reset_n => s_rst,
		commande => s_commande,
		chipselect => s_cs,
		write_n => s_write_n,
		writeData => s_writedata
		);

end architecture;
