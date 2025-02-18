--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.6
--  \   \         Application : 
--  /   /         Filename : xil_F8MKfI
-- /___/   /\     Timestamp : 04/05/2014 20:58:17
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.RetinaParameters.ALL;
entity IntermediateBufferConv is
   port ( clk        : in    std_logic; 
          enableIn   : in    std_logic; 
          inputValue : in    std_logic_vector (OUT_VERT_CONV_BW-1 downto 0); 
          rst        : in    std_logic; 
          enableOut  : out   std_logic; 
          outputData : out   T_INPUT_HORIZONTAL_CONVOLUTION
	);
end IntermediateBufferConv;

architecture BEHAVIORAL of IntermediateBufferConv is
	signal outputArray: T_INPUT_HORIZONTAL_CONVOLUTION := (others => (others => '0'));
	signal enables: std_logic_vector(KERNEL_SIZE-2 downto 0);
	signal counter1: integer range 0 to (KERNEL_SIZE*NUMBER_OF_SCALES)-1 := 0;
	signal counter2: integer range 0 to (NUMBER_OF_SCALES-1) := 0;
	component IntermediateFifoConv is
	port (  clk        : in std_logic;  
			rst        : in std_logic;
			enableIn   : in std_logic;
			inputValue : in std_logic_vector (OUT_VERT_CONV_BW-1 downto 0);
			enableOut  : out std_logic;
			outputData : out std_logic_vector (OUT_VERT_CONV_BW-1 downto 0)
	);
	end component;
	
begin
	fifo0: IntermediateFifoConv
	port map(
		clk => clk,
		rst => rst,
		enableIn => enableIn,
		inputValue => inputValue,
		enableOut => enables(0),
		outputData => outputArray(1)
	);
	gfifo: for i in 1 to KERNEL_SIZE-2 generate
		fifoX: IntermediateFifoConv
		port map(
			clk => clk,
			rst => rst,
			enableIn => enables(i-1),
			inputValue => outputArray(i),
			enableOut => enables(i),
			outputData => outputArray(i+1)
		);
	end generate gfifo;

proceso1: process(clk)
begin
if rising_edge(clk) then
	if rst = '1' then
		--outputArray <= (others => (others => '0'));
		counter1 <= 0;
		counter2 <= 0;
		enableOut <= '0';		
	else
		if enableIn = '1' then
			outputArray(0) <= inputValue;
			if counter1 = (KERNEL_SIZE*NUMBER_OF_SCALES)-1 then
				-------WORKS ONLY FOR NUMBER_OF_SCALES > 2  ???????
				if counter2 = NUMBER_OF_SCALES-1 then
					counter2 <= 0;
					counter1 <= 0;
				else
					counter2 <= counter2+1;
				end if;
				enableOut <= '1';
			else
				counter1 <= counter1 +1;
				enableOut <= '0';
			end if;
		else
			enableOut <= '0';
		end if;
	end if;
end if;--end if rising_edge(clk)
end process proceso1;
outputData <= outputArray;
end BEHAVIORAL;


