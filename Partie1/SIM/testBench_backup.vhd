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
	signal s_echo : std_logic := '0';
	signal s_trig : std_logic := '0';
	signal s_dis_cm : std_logic_vector (9 downto 0) := "0000000000";
	signal s_cs : std_logic := '0';
	signal s_read_n : std_logic := '1';
	signal s_read_data : std_logic_vector(31 downto 0);

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
		wait until s_trig = '0';

		wait for 10 us;
		-- là on simule le comportement du télémètre avec différents échos.
		-- Il emettra ici un écho de 1ms
		s_echo <= '1';
		wait for 1 ms;
		s_echo <= '0'; 
	------------------------
		s_cs <= '1';
		s_read_n <= '0';
		wait for 5*Period;

		s_cs <= '0';
		s_read_n <= '1';
		wait for 5*Period;

		wait until s_trig = '1';
		wait until s_trig = '0';
		s_cs <= '1';
		s_read_n <= '0';
		wait for Period;

		s_cs <= '0';
		s_read_n <= '1';
		wait for 5*Period;
		wait for 10 us;
		s_echo <= '1';
		wait for 2 ms;
		s_echo <= '0'; 
	------------------------
		
		wait until s_trig = '1';
		wait until s_trig = '0';

		wait for 10 us;
		s_echo <= '1';
		wait for 5 ms;
		s_echo <= '0'; 
		s_cs <= '1';
		s_read_n <= '0';
		wait for Period;

		s_cs <= '0';
		s_read_n <= '1';
		wait for 5*Period;

		wait until s_trig = '1';
		--instructions d'arrêt
		done <= true;
		wait;
	end process bench;

	UUT : entity work.telemetre_us_avalon(RTL)
	--generic map()
	port map(
		clk => s_clk,
		rst_n => s_rst,
		echo => s_echo,
		trig => s_trig,
		dis_cm => s_dis_cm,
		read_n => s_read_n,
		chipselect => s_cs,
		readdata => s_read_data

	);

end architecture;