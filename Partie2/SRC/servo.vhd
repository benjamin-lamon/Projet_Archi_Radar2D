library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo is
	port
	(
		clk			: in std_logic;
		reset_n 	: in std_logic;
		position 	: in std_logic_vector(7 downto 0);
		commande 	: out std_logic
	);
end entity servo;

architecture RTL of servo is
	type WaitCase is (waiting, impulse);
	signal state	: WaitCase:= waiting;
	signal cpt_10ms	: integer := 0; --peut-être 20ms en fait, on sait pas.
	signal cpt_imp	: integer := 0;
		--
		--case 1 : on attend 10ms
		--	-> 	une variable qui s'incrémente tout le temps et on teste
		--		si c'est au-dessus d'une certaine valeur (10 à 20ms/50M ?)
		--
		--case 2 : on émet l'impulsion
		--	-> 	un compteur pour l'impulsion
		--		une fois l'impulsion finie, on repart au 1
		--		ptet faire un state (wait, emit) ou un truc du genre
		--

	begin
		process(clk, reset_n)
		begin
			if reset_n = '0' then
				cpt_10ms <= 0;
				cpt_imp	<= 0;
				state <= waiting;
				commande <= '0';

			elsif rising_edge(clk) then
				cpt_10ms <= cpt_10ms + 1;
				case state is
					when waiting =>
						commande <= '0';
						if cpt_10ms >= (500000) then -- 10ms*50MHz = 500000
							cpt_10ms <= 0;
							state <= impulse;
						end if;
					when impulse =>
						cpt_imp <= cpt_imp + 1;
						commande <= '1';
						if cpt_imp >= (50000 + 556*to_integer(unsigned(position))) then 	
							cpt_imp <= 0;
							state <= waiting;
						end if;
					when others =>
						-- nothing?
				end case;
			end if;
		end process;

			--TODO
				--Bench
					--DONE
				--Avalon
					--DONE (sort of)
				--Avalon Bench
					--DONE (sort of)
				--calculate some_value and some_other_value
					--DONE
			--probably some other stuff but eh, lets finish that first...


end architecture RTL;