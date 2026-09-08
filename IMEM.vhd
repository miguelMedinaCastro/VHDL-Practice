
-----------------------------------------------------------------------------------------
--  Representação de MEMÓRIA ROM
-----------------------------------------------------------------------------------------
--  Modulo HDL com a implementação comportamental da MEMÓRIA DE INSTRUÇÕES
--  Tamanho = 256 Palavras de 16 Bits (com 8 Bits de Endereçamento)
--  Memória de APENAS LEITURA (com 1 PORTA de LEITURA)
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity IMEM is
   generic(
      NBits_EndM  :  natural := 8;     -- Num. de Bits de Endereçamento MEMÓRIA
      NBits_Dado  :  natural := 16;    -- Num. de Bits de Dados (Tamanho PALAVRA)
      N_Palavras  :  natural := 256);  -- Num. de Palavras da MEMORIA
   port(
      rst     :  in   std_logic;                                   -- Reset
      clk     :  in   std_logic;                                   -- Clock
      addr_r  :  in   std_logic_vector(NBits_EndM - 1 downto 0);   -- Entrada de Endereço
      data_r  :  out  std_logic_vector(NBits_Dado - 1 downto 0));  -- Saída de Dados
end IMEM;


architecture IMEM of IMEM is

   type matriz is array (N_Palavras-1 downto 0) of std_logic_vector(NBits_Dado-1 downto 0);
   signal MEM : matriz  :=  (others => (others => '0'));

begin

   process (rst, clk)
   begin

      if rst = '1' then

          data_r  <=  (others => '0');

          MEM(000)  <=  "0000000000000"&"000";         -- INICIA DADOS na Memória
          MEM(001)  <=  "0000000000000"&"001";         -- (INSTRUÇÕES do PROGRAMA)
          MEM(002)  <=  "0000000000000"&"010";
          MEM(003)  <=  "0000000000000"&"011";

          MEM(128)  <=  "00000000"&"10000000";
          MEM(129)  <=  "00000000"&"10000001";
          MEM(130)  <=  "00000000"&"10000010";
          MEM(131)  <=  "00000000"&"10000011";

          MEM(252)  <=  "00000000"&"11111100";
          MEM(253)  <=  "00000000"&"11111101";
          MEM(254)  <=  "00000000"&"11111110";
          MEM(255)  <=  "00000000"&"11111111";

      elsif clk'event and clk = '1' then

          data_r  <=  MEM(to_integer(unsigned(addr_r)));  -- LEITURA

      end if;
   end process;

end architecture;




------------------------------------------------------------------------------------------
-- TestBench da Memória ROM
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IMEM_TB is
end entity;


architecture IMEM_TB of IMEM_TB is

   signal rst     : std_logic  := '0';
   signal clk     : std_logic  := '0';

   signal addr_r  : std_logic_vector( 7 downto 0)  := (others => '0');
   signal data_r  : std_logic_vector(15 downto 0)  := (others => '0');

   signal CONT     : std_logic_vector( 7 downto 0)  := (others => '0');

begin

   -- Instancia do Bloco IMEM
   dut: entity  work.IMEM  port map(  rst     =>  rst,
                                      clk     =>  clk,
                                      addr_r  =>  addr_r,
                                      data_r  =>  data_r );

   -- Processo RESET
   process begin
      rst  <=  '1';      wait for 13 ns;
      rst  <=  '0';      wait;
   end process;


   -- Processo CLOCK
   process begin
      wait for 10 ns;
      clk  <=  not(clk);
   end process;


   -- Processo CONTADOR (gera todas as variações de 8 bits)
   process begin
      wait for 10 ns;
      CONT  <=  std_logic_vector(unsigned(CONT) + 1);
      wait for 10 ns;
      if CONT = "00000000" then report "FIM !!!" severity failure; end if;
   end process;


   -- Geração das ENTRADAS (associa o Contador à Entrada)
   addr_r  <=  CONT(7 downto 0);


end architecture;

