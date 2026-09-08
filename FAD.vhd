
-----------------------------------------------------------------------------------------
--  Representação SOMADOR DE 1 BIT
-----------------------------------------------------------------------------------------
--  Modulo HDL com a implementação RTL de um FULL ADDER de 1BIT
--  Soma 3 bits (A, B e Carry In)
--  Gera a Soma S e a Carry Out.
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FAD_1BIT is port (
      A     :  in   std_logic;    -- Entrada A
      B     :  in   std_logic;    -- Entrada B
      Cin   :  in   std_logic;    -- Carry de Entrada
      S     :  out  std_logic;    -- Resultado da Soma
      Cout  :  out  std_logic);   -- Carry Out gerado
end FAD_1BIT;


architecture FAD_1BIT of FAD_1BIT is

begin

   S     <=  A xor B xor Cin;
   Cout  <=  (A and B) or (A and Cin) or (B and Cin);

end architecture;




-----------------------------------------------------------------------------------------
--  Representação SOMADOR DE N BITS
-----------------------------------------------------------------------------------------
--  Implementação utiliza vários FULL_ADDERs, gerados via FOR GENERATE
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FAD is
   generic (
      NBITS  :  natural := 8);    -- Número de Bits das Entradas
   port (
      A       :  in   std_logic_vector(NBITS - 1 downto 0);    -- Entrada A
      B       :  in   std_logic_vector(NBITS - 1 downto 0);    -- Entrada B
      Cin     :  in   std_logic;                               -- Carry de Entrada
      S       :  out  std_logic_vector(NBITS - 1 downto 0);    -- Resultado da Soma
      Lcin    :  out  std_logic;                               -- Último Cin gerado
      Lcout   :  out  std_logic);                              -- Último Cout gerado
end FAD;


architecture FAD of FAD is

   signal Carry  :  std_logic_vector(NBITS downto 0)         := (others => '0');

begin

   -- Geração do SOMADOR de NBITS (instancias do FAD_1BIT)
   FADN: FOR i in 0 to NBITS - 1 GENERATE
      FA: entity  work.FAD_1BIT  port map(  A     =>  A(i),
                                            B     =>  B(i),
                                            Cin   =>  Carry(i),
                                            S     =>  S(i),
                                            Cout  =>  Carry(i + 1) );
  end GENERATE;


   Carry(0) <=  Cin;
   Lcin     <=  Carry(NBITS - 1);
   Lcout    <=  Carry(NBITS);

end architecture;




-----------------------------------------------------------------------------------------
--  TestBench do SOMADOR DE 4 BITS
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FAD_TB is
end FAD_TB;


architecture FAD_TB of FAD_TB is

   signal A       :  std_logic_vector(3 downto 0)    := (others => '0');
   signal B       :  std_logic_vector(3 downto 0)    := (others => '0');
   signal S       :  std_logic_vector(3 downto 0)    := (others => '0');

   signal Cin     :  std_logic  := '0';
   signal Lcin    :  std_logic  := '0';
   signal Lcout   :  std_logic  := '0';

   signal CONT    :  std_logic_vector(8 downto 0)    := (others => '0');

begin

   -- Instancias do FAD
   dut: entity  work.FAD  generic map(  NBITS  =>  4  )
                             port map(  A      =>  A,
                                        B      =>  B,
                                        Cin    =>  Cin,
                                        S      =>  S,
                                        Lcin   =>  Lcin,
                                        Lcout  =>  Lcout );

   -- Processo CONTADOR (gera todas as variações de 9 bits)
   process begin
      wait for 10 ns;
      CONT  <=  std_logic_vector(unsigned(CONT) + 1);
      wait for 10 ns;
      if CONT = "000000000" then report "FIM !!!" severity failure; end if;
   end process;


   -- Geração das ENTRADAS (distribui o Contador entre as Entradas)
   A     <=  CONT(3 downto 0);
   B     <=  CONT(7 downto 4);
   Cin   <=  CONT(8);

end architecture;

