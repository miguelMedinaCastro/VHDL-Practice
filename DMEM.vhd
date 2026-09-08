
-----------------------------------------------------------------------------------------
--  Representação de MEMÓRIA RAM
-----------------------------------------------------------------------------------------
--  Modulo HDL com a implementação comportamental da MEMÓRIA DE DADOS
--  Tamanho = 256 Palavras de 16 Bits (com 8 Bits de Endereçamento)
--  Memória de LEITURA/ESCRITA (com 1 PORTA de LEITURA e 1 PORTA de ESCRITA)
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DMEM is
   generic(
      NBits_EndM  :  natural := 8;     -- Num. de Bits de Endereçamento MEMÓRIA
      NBits_Dado  :  natural := 16;    -- Num. de Bits de Dados (Tamanho PALAVRA)
      N_Palavras  :  natural := 256);  -- Num. de Palavras da MEMORIA
   port(
      rst      :  in   std_logic;                                   -- Reset
      clk      :  in   std_logic;                                   -- Clock
      rd_en    :  in   std_logic;                                   -- Habilita Leitura
      wr_en    :  in   std_logic;                                   -- Habilita Escrita
      addr_rw  :  in   std_logic_vector(NBits_EndM - 1 downto 0);   -- Entrada de Endereço
      data_w   :  in   std_logic_vector(NBits_Dado - 1 downto 0);   -- Entrada de Dados
      data_r   :  out  std_logic_vector(NBits_Dado - 1 downto 0));  -- Saída de Dados
end DMEM;


architecture DMEM of DMEM is

   type matriz is array (N_Palavras-1 downto 0) of std_logic_vector(NBits_Dado-1 downto 0);
   signal MEM : matriz  :=  (others => (others => '0'));

begin

   process (rst, clk)
   begin

      if rst = '1' then

          data_r  <=  (others => '0');

          MEM(000)  <=  "0000000000000001";         -- INICIA DADOS na Memória
          MEM(001)  <=  "0000000000000010";         -- (VARIÁVEIS do PROGRAMA)
          MEM(002)  <=  "0000000000000100";
          MEM(003)  <=  "0000000000001000";
          MEM(004)  <=  "0000000000010000";
          MEM(005)  <=  "0000000000100000";
          MEM(006)  <=  "0000000001000000";
          MEM(007)  <=  "0000000010000000";
          MEM(008)  <=  "0000000100000000";
          MEM(009)  <=  "0000001000000000";
          MEM(010)  <=  "0000010000000000";
          MEM(011)  <=  "0000100000000000";
          MEM(012)  <=  "0001000000000000";
          MEM(013)  <=  "0010000000000000";
          MEM(014)  <=  "0100000000000000";
          MEM(015)  <=  "1000000000000000";

      elsif clk'event and clk = '1' then

         if    wr_en = '1' then

            MEM(to_integer(unsigned(addr_rw)))  <=  data_w;   -- ESCRITA

         elsif rd_en = '1' then

            data_r  <=  MEM(to_integer(unsigned(addr_rw)));  -- LEITURA

         end if;

      end if;
   end process;

end architecture;




-----------------------------------------------------------------------------------------
--  TestBench da Memória RAM
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DMEM_TB is
end entity;


architecture DMEM_TB of DMEM_TB is

   signal rst      :  std_logic  := '0';
   signal clk      :  std_logic  := '0';

   signal rd_en    :  std_logic  := '0';
   signal wr_en    :  std_logic  := '0';

   signal addr_rw  :  std_logic_vector( 7 downto 0)  := (others => '0');
   signal data_w   :  std_logic_vector(15 downto 0)  := (others => '0');
   signal data_r   :  std_logic_vector(15 downto 0)  := (others => '0');

   signal CONT     : std_logic_vector( 8 downto 0)  := (others => '0');

begin

   -- Instancia do Bloco DMEM
   dut: entity  work.DMEM  port map(  rst      =>  rst,
                                      clk      =>  clk,
                                      rd_en    =>  rd_en,
                                      wr_en    =>  wr_en,
                                      addr_rw  =>  addr_rw,
                                      data_w   =>  data_w,
                                      data_r   =>  data_r );

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


   -- Processo CONTADOR (gera todas as variações de 9 bits)
   process begin
      wait for 10 ns;
      CONT  <=  std_logic_vector(unsigned(CONT) + 1);
      wait for 10 ns;
      if CONT = "000000000" then report "FIM !!!" severity failure; end if;
   end process;


   -- Geração das ENTRADAS (distribui o Contador entre as Entradas)
   addr_rw  <=  CONT(7 downto 0);
   rd_en    <=  CONT(8);
   wr_en    <=  not cont(8);
   data_w   <=  "00000000" & CONT(7 downto 0) when wr_en = '1' else (others => '0');


end architecture;

