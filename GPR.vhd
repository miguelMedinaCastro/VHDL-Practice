
-----------------------------------------------------------------------------------------
--  Representação BANCO DE REGISTRADORES
-----------------------------------------------------------------------------------------
--  Modulo HDL com a implementação comportamental do BANCO DE REGISTRADORES
--  Tamanho = 8 Palavras de 16 Bits (com 3 Bits de Endereçamento)
--  Memória de LEITURA/ESCRITA (com 2 PORTAs de LEITURA e 1 PORTA de ESCRITA)
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity GPR is
   generic(
      NBits_EndR  :  natural := 3;     -- Num. de Bits de Endereçamento REGISTRADORES
      NBits_Dado  :  natural := 16;    -- Num. de Bits de Dados (Tamanho PALAVRA)
      N_Register  :  natural := 8);    -- Num. de REGISTRADORES
   port(
      rst      :  in   std_logic;                                   -- Reset
      clk      :  in   std_logic;                                   -- Clock
      addr_r1  :  in   std_logic_vector(NBits_EndR - 1 downto 0);   -- Endereço Leitura 1
      addr_r2  :  in   std_logic_vector(NBits_EndR - 1 downto 0);   -- Endereço Leitura 2
      data_r1  :  out  std_logic_vector(NBits_Dado - 1 downto 0);   -- Saída de Dados 1
      data_r2  :  out  std_logic_vector(NBits_Dado - 1 downto 0);   -- Saída de Dados 2
      wr_en    :  in   std_logic;                                   -- Habilita Escrita
      addr_w1  :  in   std_logic_vector(NBits_EndR - 1 downto 0);   -- Endereço Escrita
      data_w1  :  in   std_logic_vector(NBits_Dado - 1 downto 0));  -- Entrada de Dados
end GPR;


architecture GPR of GPR is

   type matriz is array (N_Register-1 downto 0) of std_logic_vector(NBits_Dado-1 downto 0);
   signal MEM : matriz  :=  (others => (others => '0'));

begin

   process (rst, clk)
   begin

      if rst = '1' then

          data_r1  <=  (others => '0');
          data_r2  <=  (others => '0');

      elsif clk'event and clk = '1' then

         -- LEITURAS estão SEMPRE HABILITADAS
         data_r1  <=  MEM(to_integer(unsigned(addr_r1)));
         data_r2  <=  MEM(to_integer(unsigned(addr_r2)));

         -- ESCRITAS dependem da Habilitação
         if  wr_en = '1' then
            MEM(to_integer(unsigned(addr_w1)))  <=  data_w1;
         end if;

      end if;
   end process;

end architecture;




-----------------------------------------------------------------------------------------
--  TestBench BANCO REGISTRADORES
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GPR_TB is
end entity;


architecture GPR_TB of GPR_TB is

   signal rst      :  std_logic  := '0';
   signal clk      :  std_logic  := '0';

   signal wr_en    :  std_logic  := '0';
   signal addr_r1  :  std_logic_vector( 2 downto 0)  := (others => '0');
   signal data_r1  :  std_logic_vector(15 downto 0)  := (others => '0');
   signal addr_r2  :  std_logic_vector( 2 downto 0)  := (others => '0');
   signal data_r2  :  std_logic_vector(15 downto 0)  := (others => '0');
   signal addr_w1  :  std_logic_vector( 2 downto 0)  := (others => '0');
   signal data_w1  :  std_logic_vector(15 downto 0)  := (others => '0');

   signal CONT     :  std_logic_vector( 4 downto 0)  := (others => '0');

begin

   -- Instancia do Bloco GPR
   dut: entity  work.GPR  port map(  rst      =>  rst,
                                     clk      =>  clk,
                                     addr_r1  =>  addr_r1,
                                     data_r1  =>  data_r1,
                                     addr_r2  =>  addr_r2,
                                     data_r2  =>  data_r2,
                                     wr_en    =>  wr_en,
                                     addr_w1  =>  addr_w1,
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


   -- Processo CONTADOR (gera todas as variações de 5 bits)
   process begin
      wait for 10 ns;
      CONT  <=  std_logic_vector(unsigned(CONT) + 1);
      wait for 10 ns;
      if CONT = "00000" then report "FIM !!!" severity failure; end if;
   end process;


   -- Geração das ENTRADAS (distribui o Contador entre as Entradas)
   addr_w1  <=  CONT(2 downto 0);
   addr_r1  <=  CONT(1 downto 0) & '0';
   addr_r2  <=  CONT(1 downto 0) & '1';
   wr_en    <=  CONT(3);
   data_w1  <=  "0000000000000" & CONT(2 downto 0) when wr_en = '1' else (others => '0');


end architecture;

