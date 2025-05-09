library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity telemetre_us is
	port(
		clk 	: in std_logic;
		rst_n 	: in std_logic;
		echo 	: in std_logic := '0';
		trig 	: out std_logic := '0'; -- va vers le télémètre physique
		dis_cm 	: out std_logic_vector(9 downto 0) := "0000000000"
	);
end entity;

architecture RTL of telemetre_us is
	--MAE qui genere le trig, le met a 1, attend 10µs puis attend qu'on reçoive le signal echo...
	--attend que l'echo passe a zero; on a alors la duree qui représente la distance
	type Etat is (IDLE, TrigGen, WaitEcho, comptEcho, Comm);
	--TrigGen génère le trigger
	--Echo attend l'écho puis compte lorsqu'il est à 1
	--Comm renvoie la distance sur dis_cm
	signal etatActuel : Etat;
	signal compteur10u : integer := 0;
	signal compteur60m : integer := 0;
	signal compteurEcho : integer := 0;
	signal echo_r : std_logic := '0';
	signal echo_rr : std_logic := '0';

begin
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			--valeurs de reset
			etatActuel <= TrigGen;
			trig <= '1';
			dis_cm <= "0000000000";
			compteur10u <= 0;
			compteur60m <= 0;
			compteurEcho <= 0;

		--rappel : la clock est à 50MHz
		elsif rising_edge(clk) then
			echo_r <= echo;
			echo_rr <= echo_r;
			case etatActuel is
				when TrigGen =>
					if compteur10u <= 500 then --si on n'est pas à 10µs (10µ*50M = 500), on set trig à 1 et on compte
						trig <= '1';
						compteur10u <= compteur10u + 1;
					else 
						compteur10u <= 0;
						trig <= '0';
						etatActuel <= WaitEcho;
					end if;

				when WaitEcho =>
					compteur60m <= compteur60m + 1;
					if echo_rr = '1' then
						compteurEcho <= 1;
						etatActuel <= comptEcho;
						--on passe à l'état de comptage comptEcho
					end if;

				--comptEcho compteur60m <= compteur60m + 1;
				--on compte puis une fois que echo est bas, on passe à comm
				when comptEcho =>
					compteur60m <= compteur60m + 1;
					compteurEcho <= compteurEcho + 1;
					if echo_rr = '0' then
						etatActuel <= Comm;
					end if;
				when Comm =>
				--On ne communique les données qu'une seule fois
					--calcul du temps
					--t = compteur/50'000'000
					--ça ns donne ce qu'il faut en secondes
					--dc maintenant il faut utiliser la vitesse du son, 320m/s aka 32'000 cm/s
					-- et on a 2* cette distance (on émet un son, il bounce puis on le reçoit)
					-- donc il faut div cette dist par 2
					-- donc ça nous donne t*32'000/2
					-- donc (compteur/50'000'000)*32'000/2
					-- donc compteur/3125

					--pour ne pas faire pleins de calculs qui prendraient des ressources sur la carte, on ne les fait qu'une seule fois et on divise alors par 3125
					
					--p-ê faire un autre signal et on mettra la division plus tard, en-dehors du process pour économiser des ressources et du temps de calcul ?
					dis_cm <= std_logic_vector(To_signed(compteurEcho/3125,10)); 

					--on passe à IDLE, qui repassera à TrigGen une fois qu'on sera bien à 60ms
					compteur60m <= compteur60m + 1;
					etatActuel <= IDLE;
				
				when IDLE =>
					compteur60m <= compteur60m + 1;
					if compteur60m > 5e6 then --valeur à calculer. 60m * 50'000'000 = 3'000'000. On prend une marge et on met 5M
						compteur60m <= 0;
						compteurEcho <= 0;
						etatActuel <= trigGen;
					end if;

				when others =>
					dis_cm <= "0000000000";
					etatActuel <= IDLE;
					compteur10u <= 0;
					compteur60m <= 0;
					compteurEcho <= 0;

			end case;	
		end if;
	end process;
end architecture;