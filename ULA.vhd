
-----------------------------------------------------------------------------------------
--  Representação ULA DE 1BIT
-----------------------------------------------------------------------------------------
--  Modulo HDL com a implementação RTL de uma ULA de 1BIT
--  Operação Aritméticas Suportadas: SOMA
--  Operação Lógicas Suportadas: AND, OR e NOT
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ULA_1BIT is port (
      A       :  in   std_logic;                -- Entrada A
      B       :  in   std_logic;                -- Entrada B
      Cin     :  in   std_logic;                -- Carry de Entrada
      R_SOMA  :  out  std_logic;                -- Resultado da SOMA
      R_AND   :  out  std_logic;                -- Resultado da AND
      R_OR    :  out  std_logic;                -- Resultado da OR
      R_NOT   :  out  std_logic;                -- Resultado da NOT
      Cout    :  out  std_logic);               -- Carry Out gerado
end ULA_1BIT;


architecture ULA_1BIT of ULA_1BIT is

begin

   R_AND    <=  A and B;
   R_OR     <=  A or B;
   R_NOT    <=  not A;

   R_SOMA   <=  A xor B xor Cin;
   Cout     <=  (A and B) or (A and Cin) or (B and Cin);

end architecture;



-----------------------------------------------------------------------------------------
--  Representação ULA DE NBITS
-----------------------------------------------------------------------------------------
--  Implementação usa várias ULA_1BIT, geradas via FOR GENERATE
--  Atenção: SUBTRAÇÃO foi adicionada (funciona usando a SOMA)
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ULA is
   generic (
      NBITS  :  natural := 16);    -- Número de Bits das Entradas
   port (
      A       :  in   std_logic_vector(NBITS - 1 downto 0);    -- Entrada A
      B       :  in   std_logic_vector(NBITS - 1 downto 0);    -- Entrada B
      FUNC    :  in   std_logic_vector(2 downto 0);            -- Seleção de FUNÇÃO
      R       :  out  std_logic_vector(NBITS - 1 downto 0);    -- Resultado da Soma
      flag_C  :  out  std_logic;                               -- Flag de CARRY
      flag_V  :  out  std_logic;                               -- Flag de OVERFLOW
      flag_N  :  out  std_logic;                               -- Flag de NEGATIVO
      flag_Z  :  out  std_logic);                              -- Flag de ZERO
end ULA;


architecture ULA of ULA is

   signal Carry   :  std_logic_vector(NBITS downto 0)        := (others => '0');
   signal Result  :  std_logic_vector(NBITS - 1 downto 0)    := (others => '0');
   signal EntraB  :  std_logic_vector(NBITS - 1 downto 0)    := (others => '0');

   signal R_SOMA  :  std_logic_vector(NBITS - 1 downto 0)    := (others => '0');
   signal R_AND   :  std_logic_vector(NBITS - 1 downto 0)    := (others => '0');
   signal R_OR    :  std_logic_vector(NBITS - 1 downto 0)    := (others => '0');
   signal R_NOT   :  std_logic_vector(NBITS - 1 downto 0)    := (others => '0');

   signal Lcin    :  std_logic  := '0';
   signal Lcout   :  std_logic  := '0';

   signal ZERO    :  std_logic_vector(NBITS - 1 downto 0)    := (others => '0');

begin


   -- Geração do SOMADOR de NBITS (instancias do FAD_1BIT)
   ULAN: FOR i in 0 to NBITS - 1 GENERATE
      UL: entity  work.ULA_1BIT  port map(  A       =>  A(i),
                                            B       =>  EntraB(i),
                                            Cin     =>  Carry(i),
                                            R_SOMA  =>  R_SOMA(i),
                                            R_AND   =>  R_AND(i),
                                            R_OR    =>  R_OR(i),
                                            R_NOT   =>  R_NOT(i),
                                            Cout    =>  Carry(i + 1) );
   end GENERATE;


   -- Preparação para SUBTRAÇÃO com A-B = A+(-B)
   Carry(0)  <=  '1'   when  (FUNC = "001")  else '0';
   EntraB    <= not B  when  (FUNC = "001")  else  B;


   -- MULTIPLEXADOR da Saída R
   Result  <=  R_AND   when  FUNC = "010"  else
               R_OR    when  FUNC = "011"  else
               R_NOT   when  FUNC = "100"  else
               R_SOMA;

   R       <=  Result;

   Lcin    <=  Carry(NBITS);
   Lcout   <=  Carry(NBITS - 1);

   -- Geração das FLAGS
   flag_N  <=  '1'             when  Result(NBITS - 1) = '1'           else  '0';
   flag_Z  <=  '1'             when  Result = ZERO                     else  '0';
   flag_C  <=  Lcin            when  (FUNC = "000") or (FUNC = "001")  else  '0';
   flag_V  <=  Lcin xor Lcout  when  (FUNC = "000") or (FUNC = "001")  else  '0';


end architecture;




-----------------------------------------------------------------------------------------
--  TestBench do ULA DE 3 BITS
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ULA_TB is
end ULA_TB;


architecture ULA_TB of ULA_TB is

   signal A       :  std_logic_vector(2 downto 0)    := (others => '0');
   signal B       :  std_logic_vector(2 downto 0)    := (others => '0');
   signal FUNC    :  std_logic_vector(2 downto 0)    := (others => '0');
   signal R       :  std_logic_vector(2 downto 0)    := (others => '0');

   signal flag_C  :  std_logic  := '0';
   signal flag_V  :  std_logic  := '0';
   signal flag_N  :  std_logic  := '0';
   signal flag_Z  :  std_logic  := '0';

   signal CONT    :  std_logic_vector(8 downto 0)    := (others => '0');

begin

   -- Instancias da ULA
   dut: entity  work.ULA  generic map(  NBITS   =>  3  )
                             port map(  A       =>  A,
                                        B       =>  B,
                                        FUNC    =>  FUNC,
                                        R       =>  R,
                                        flag_C  =>  flag_C,
                                        flag_V  =>  flag_V,
                                        flag_N  =>  flag_N,
                                        flag_Z  =>  flag_Z );

   -- Processo CONTADOR (gera variações de 9 bits)
   process begin
      wait for 10 ns;
      CONT  <=  std_logic_vector(unsigned(CONT) + 1);
      wait for 10 ns;
      if CONT = "101000000" then report "FIM !!!" severity failure; end if;
   end process;


   -- Geração das ENTRADAS (distribui o Contador entre as Entradas)
   A      <=  CONT(2 downto 0);
   B      <=  CONT(5 downto 3);
   FUNC   <=  CONT(8 downto 6);

end architecture;


