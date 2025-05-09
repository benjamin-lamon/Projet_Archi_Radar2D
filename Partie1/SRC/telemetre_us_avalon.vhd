library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--implémentation de l'IP télémètre_us pour l'utiliser sur le bus Avalon

entity telemetre_us_avalon is
	port(
		clk 	: in std_logic;
		rst_n 	: in std_logic;
		echo 	: in std_logic := '0';
		trig 	: out std_logic := '0'; -- va vers le télémètre physique
		dis_cm 	: out std_logic_vector(9 downto 0) := "0000000000";
		read_n 	: in std_logic := '0';
		readdata	: out std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		chipselect	: in std_logic := '0'

	);
end entity;

architecture RTL of telemetre_us_avalon is
	signal s_dis_cm : std_logic_vector(9 downto 0) := "0000000000";
	signal s_readdata : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

begin
	dis_cm <= s_dis_cm;
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			readdata <= (others => '0');
		elsif rising_edge(clk) then
			
			if chipselect = '1' and read_n = '0' then
				readdata <= "0000000000000000000000" & s_dis_cm;
			end if;
		end if;
	end process;

	telemet : entity work.telemetre_us(RTL)
	port map(
		clk => clk,
		rst_n => rst_n,
		echo => echo,
		trig => trig,
		dis_cm => s_dis_cm
	);

end architecture;