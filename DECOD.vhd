
-----------------------------------------------------------------------------------------
--  Representação de uma Memória ROM
-----------------------------------------------------------------------------------------
--  Modulo HDL com a implementação do DECODIFICADOR DE INSTRUÇÕES
--  Entrada: Registrador de Instrução (IR)
--  Saidas:  - Endereço de Memória (1 para Leitura - MAR)
--           - Endereços de GPRs (2 para Leituras e 1 para Escrita)
--           - Valor Imediato da Instrução
--           - OpCode da Instrução recebida
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DECOD is
   generic(
      NBits_EndM  :  natural := 8;     -- Num. de Bits de Endereçamento MEMÓRIA
      NBits_EndR  :  natural := 3;     -- Num. de Bits de Endereçamento REGISTRADORES
      NBits_Dado  :  natural := 16);   -- Num. de Bits de Dados (Tamanho PALAVRA)
   port(
      rst      :  in   std_logic;                                   -- Reset
      clk      :  in   std_logic;                                   -- Clock
      IR       :  in   std_logic_vector(NBits_Dado - 1 downto 0);   -- Entrada INSTRUÇÃO
      opcode   :  out  std_logic_vector(4 downto 0);                -- Saída de OpCode
      reg_MAR  :  out  std_logic_vector(NBits_EndM - 1 downto 0);   -- Saída para Reg MAR
      addr_r1  :  out  std_logic_vector(NBits_EndR - 1 downto 0);   -- End. Leitura REG1
      addr_r2  :  out  std_logic_vector(NBits_EndR - 1 downto 0);   -- End. Leitura REG2
      addr_w1  :  out  std_logic_vector(NBits_EndR - 1 downto 0);   -- End. Escrita REG1
      addr_w2  :  out  std_logic_vector(NBits_EndR - 1 downto 0);   -- End. Escrita REG2
      data_w1  :  out  std_logic_vector(NBits_Dado - 1 downto 0));  -- Dado Escrita
end DECOD;


architecture DECOD of DECOD is

begin

   process (rst, clk)
   begin

      if rst = '1' then

         reg_MAR  <=  (others => '0');
         addr_r1  <=  (others => '0');
         addr_r2  <=  (others => '0');
         addr_w1  <=  (others => '0');
         addr_w2  <=  (others => '0');
         data_w1  <=  (others => '0');

      elsif clk'event and clk = '1' then

         reg_MAR  <=  IR( 7 downto  0);          -- Separação baseada nos
         addr_r1  <=  IR(10 downto  8);          -- FORMATOs de INSTRUÇÃO
         addr_r2  <=  IR( 7 downto  5);
         addr_w1  <=  IR(10 downto  8);
         addr_w2  <=  IR( 2 downto  0);
         data_w1  <=  "00000000" & IR(7 downto 0);

      end if;
   end process;


   -- OpCode Assíncrono (para UC gerar Sinais de Controles RAPIDAMENTE)
   opcode   <=  IR(15 downto 11);

end architecture;




-----------------------------------------------------------------------------------------
--  TestBench da Memória ROM
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DECOD_TB is
end entity;


architecture DECOD_TB of DECOD_TB is

   signal rst      :  std_logic  := '0';
   signal clk      :  std_logic  := '0';

   signal IR       :  std_logic_vector(15 downto 0)  := (others => '0');
   signal opcode   :  std_logic_vector( 4 downto 0)  := (others => '0');
   signal reg_MAR  :  std_logic_vector( 7 downto 0)  := (others => '0');
   signal addr_r1  :  std_logic_vector( 2 downto 0)  := (others => '0');
   signal addr_r2  :  std_logic_vector( 2 downto 0)  := (others => '0');
   signal addr_w1  :  std_logic_vector( 2 downto 0)  := (others => '0');
   signal addr_w2  :  std_logic_vector( 2 downto 0)  := (others => '0');
   signal data_w1  :  std_logic_vector(15 downto 0)  := (others => '0');

begin

   -- Instancia do Bloco DECOD
   dut: entity  work.DECOD  port map(  rst      =>  rst,
                                       clk      =>  clk,
                                       IR       =>  IR,
                                       opcode   =>  opcode,
                                       reg_MAR  =>  reg_MAR,
                                       addr_r1  =>  addr_r1,
                                       addr_r2  =>  addr_r2,
                                       addr_w1  =>  addr_w1,
                                       addr_w2  =>  addr_w2,
                                       data_w1  =>  data_w1 );

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


   -- Processo ESTIMULOS
   process begin
      wait for 15 ns;

      -- Primeira Parte do Teste usa CONTAGENS nos Campos (Facilita Verificação)
      IR  <=  "00001"&"000"&"010"&"00"&"101";  wait for 20 ns;    -- 01  0 2 5  45
      IR  <=  "00010"&"001"&"011"&"00"&"110";  wait for 20 ns;    -- 02  1 3 6  66
      IR  <=  "00011"&"010"&"100"&"00"&"111";  wait for 20 ns;    -- 03  2 4 7  87
      IR  <=  "00100"&"000"&"010"&"00"&"101";  wait for 20 ns;    -- 04  0 2 5  45
      IR  <=  "00101"&"001"&"011"&"00"&"110";  wait for 20 ns;    -- 05  1 3 6  66
      IR  <=  "00110"&"010"&"100"&"00"&"111";  wait for 20 ns;    -- 06  2 4 7  87
      IR  <=  "00111"&"000"&"010"&"00"&"101";  wait for 20 ns;    -- 06  0 2 5  45
      IR  <=  "01000"&"001"&"011"&"00"&"110";  wait for 20 ns;    -- 08  1 3 6  66
      IR  <=  "01001"&"010"&"100"&"00"&"111";  wait for 20 ns;    -- 09  2 4 7  87

      wait for 200 ns;

      -- Segundo Parte do Teste usa INSTRUÇÕES nos Campos (Verificação mais real)
      IR  <=  "00001"&"000"&"00000000";        wait for 20 ns;    -- LDA  RO 00000000
      IR  <=  "00001"&"001"&"00000001";        wait for 20 ns;    -- LDA  R1 00000001
      IR  <=  "00010"&"010"&"00000001";        wait for 20 ns;    -- LDAi R2 00000001
      IR  <=  "00100"&"000"&"010"&"00"&"000";  wait for 20 ns;    -- ADD  RO R2 R0
      IR  <=  "00011"&"000"&"00000000";        wait for 20 ns;    -- STA  RO 00000000
      IR  <=  "00101"&"001"&"000"&"00"&"011";  wait for 20 ns;    -- SUB  R1 RO R3
      IR  <=  "01001"&"000"&"00001000";        wait for 20 ns;    -- JZ   00001000
      IR  <=  "01100"&"000"&"00000011";        wait for 20 ns;    -- JMP  00000011
      IR  <=  "01101"&"000"&"00000000";        wait for 20 ns;    -- HLT

      report "FIM !!!" severity failure;

   end process;

end architecture;

