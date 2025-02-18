--Copyright 2014 by Emmanuel D. Bello <emabello42@gmail.com>
--Laboratorio de Computacion Reconfigurable (LCR)
--Universidad Tecnologica Nacional
--Facultad Regional Mendoza
--Argentina

--This file is part of FREAK-on-FPGA.

--FREAK-on-FPGA is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.

--FREAK-on-FPGA is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.

--You should have received a copy of the GNU General Public License
--along with FREAK-on-FPGA.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:05:32 12/21/2013
-- Design Name:   
-- Module Name:   /media/DATA42/Projects/ComputerVision/RetinaDescriptors/tb_PatchReader.vhd
-- Project Name:  RetinaDescriptors
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PatchReader
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.RetinaParameters.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY tb_PatchReader IS
END tb_PatchReader;
 
ARCHITECTURE behavior OF tb_PatchReader IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
   component ImagePatchReader
   port ( addr        : in    std_logic_vector (31 downto 0); 
          busy_in     : in    std_logic; 
          clk         : in    std_logic; 
          memData     : in    std_logic_vector (PIXEL_BW-1 downto 0); 
          rst         : in    std_logic; 
          addrKernel  : out   std_logic_vector (N_GAUSS_KERNEL_BW-1 downto 0); 
          en_out      : out   std_logic; 
          memAddr     : out   std_logic_vector (31 downto 0); 
          patchColumn : out   T_INPUT_VERTICAL_CONVOLUTION; 
          readMem     : out   std_logic; 
          request_out : out   std_logic);
	end component;
    
    COMPONENT RAM
    PORT(
                clk:            IN std_logic;
		address:        IN std_logic_vector(31 downto 0);
		read_en:        IN std_logic;
		data_out:       OUT std_logic_vector(7 downto 0)
    );
    END COMPONENT;    

--signals of PathReader component
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal busy_in : std_logic := '0';
   signal mem_data : std_logic_vector(7 downto 0) := (others => '0');
   signal mem_addr_in : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal req_out : std_logic;
   signal enable_out : std_logic;
   signal mem_addr_out : std_logic_vector(31 downto 0);
   signal read_mem : std_logic;
   signal patch_column : input_vert_conv_type;
	signal addrKernel: std_logic_vector (N_GAUSS_KERNEL_BW-1 downto 0);
   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
   --control signals for FSM producer of addresses
   type producer_FSM_states is (INIT, REQ, READY);
   signal s_producerState: producer_FSM_states;

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ImagePatchReader PORT MAP (
          clk => clk,
          rst => rst,
          busy_in => busy_in,
          request_out => req_out,
          en_out => enable_out,
          memAddr => mem_addr_out,
          readMem => read_mem,
          memData => mem_data,
          addr => mem_addr_in,
          patchColumn => patch_column,
		  addrKernel => addrKernel
        );

   comp_ram: RAM PORT MAP(
             clk => clk,
             address => mem_addr_out,
             read_en => read_mem,
             data_out => mem_data
             );
             
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   reset_proc: process
   begin
      -- hold reset state for 100 ns.
      rst <= '1';
      wait for 100 ns;	
      rst <= '0';
      
    --  wait for clk_period*100;
      -- insert stimulus here 
      
      wait;
   end process;

--simulate the AddressGenerator's producer
        stim_proc: process(clk)
        begin
                if rising_edge(clk) then
                        if rst = '1' then
                                mem_addr_in <= std_logic_vector(to_unsigned(480, mem_addr_in'length));
                                busy_in <= '0';
                                s_producerState <= INIT;
                        else
                                case s_producerState is
                                when INIT =>
                                        if req_out = '1' then
                                                busy_in <= '1';
                                                s_producerState <= REQ;
                                        end if;
                                when REQ =>
                                        busy_in <= '0'; 
                                        s_producerState <= READY;
                                when READY =>
                                        busy_in <= '1';
                                end case;
                        end if;
                end if;
        end process;   
END;
