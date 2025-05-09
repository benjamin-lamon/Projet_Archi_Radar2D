library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_avalon is
	port
	(
		clk			: in std_logic;
		reset_n 	: in std_logic;
		commande 	: out std_logic;

		chipselect	: in std_logic;
		write_n 	: in std_logic;
		writeData	: in std_logic_vector(31 downto 0)
		-- N.B. writeData(7 downto 0) = position
	);
end entity servo_avalon;

architecture RTL of servo_avalon is
	signal s_commande : std_logic := '0';
	signal s_position : std_logic_vector(7 downto 0) := "00000000";

begin
	process(clk, reset_n)
	begin
		if reset_n = '0' then
			commande <= '0';
		elsif rising_edge(clk) then
			if chipselect = '1' and write_n = '0' then
				-- commande <= "000000000000000000000000" & s_commande;
				s_position <= writeData(7 downto 0);
				commande <= s_commande;
			end if;
		end if;
	end process;
	
	cerveau: entity work.servo(RTL)
	port map(
		clk => clk,
		reset_n => reset_n,
		position => s_position,
		commande => s_commande
	);

end architecture RTL;