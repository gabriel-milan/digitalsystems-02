--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:23:27 10/26/2018
-- Design Name:   
-- Module Name:   /home/sd/OPERADOR_BCD/SIMULATION.vhd
-- Project Name:  OPERADOR_BCD
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: BCD_FULLADDER_4BITS
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SIMULATION IS
END SIMULATION;
 
ARCHITECTURE behavior OF SIMULATION IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BCD_FULLADDER_4BITS
    PORT(
         A : IN  std_logic_vector(3 downto 0);
         B : IN  std_logic_vector(3 downto 0);
         Cin : IN  std_logic_vector(3 downto 0);
         S : OUT  std_logic_vector(3 downto 0);
         Cout : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(3 downto 0) := (others => '0');
   signal B : std_logic_vector(3 downto 0) := (others => '0');
   signal Cin : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal S : std_logic_vector(3 downto 0);
   signal Cout : std_logic_vector(3 downto 0);
	
	-- Creating clock signal
	signal clock : std_logic;
 
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BCD_FULLADDER_4BITS PORT MAP (
          A => A,
          B => B,
          Cin => Cin,
          S => S,
          Cout => Cout
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clock_period*10;

      -- insert stimulus here 
		A <= "1001";
		B <= "1001";
		Cin <= "1001";	
		
      wait;
   end process;

END;
