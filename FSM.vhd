
-----------------------------------------------------------------------------------------
--  Representação da FSM DE CONTROLE
-----------------------------------------------------------------------------------------
--  Modulo HDL com a implementação comportamental da UNIDADE DE CONTROLE
-- Entradas: OPCODE e Flags da ULA
-- Saídas: Todos os Sinais de Controle
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FSM is
   port (
      rst      :  in   std_logic;                        -- Reset
      clk      :  in   std_logic;                        -- Clock
      opcode   :  in   std_logic_vector(4 downto 0);     -- OPCODE da Instrução
      Z        :  in   std_logic;                        -- Flag Z
      N        :  in   std_logic;                        -- Flag N
      wrPC     :  out  std_logic;                        -- Habilita Escrita em PC
      wrIR     :  out  std_logic;                        -- Habilita Escrita em IR
      wrReg    :  out  std_logic;                        -- Habilita Escrita em GPR
      rdMem    :  out  std_logic;                        -- Habilita Leitura DMEM
      wrMem    :  out  std_logic;                        -- Habilita Escrita DMEM
      muxPC    :  out  std_logic;                        -- Controle MUX Entrada PC
      muxAReg  :  out  std_logic;                        -- Controle MUX Escrita Addr GPR
      muxDReg  :  out  std_logic_vector(1 downto 0);     -- Controle MUX Escrita Dado GPR
      opULA    :  out  std_logic_vector(2 downto 0));    -- Controle OPERACAO da ULA
end entity;


architecture FSM of FSM is

                                                            -- FSM DE CONTROLE
   type FSM_ESTADOS is ( BUSCA,     DECODE,                 --    Estados INICIAIS
                         RD_MEM,    WR_REG,                 --    Estados LDA
                         WR_REG2,                           --    Estados LDAi
                         RD_REG,    WR_MEM,                 --    Estados STA
                         RD_REG2,   ULA_EXEC,  WR_REG3,     --    Estados OPs ULA
                         WR_PC,                             --    Estados JUMPs
                         FIM );                             --    Estados HALT

   signal EA  : FSM_ESTADOS;   -- Estado Atual da FSM
   signal PE  : FSM_ESTADOS;   -- Próximo Estado da FSM

   constant opLDA   :  std_logic_vector(4 downto 0)  :=  "00001";
   constant opLDAi  :  std_logic_vector(4 downto 0)  :=  "00010";
   constant opSTA   :  std_logic_vector(4 downto 0)  :=  "00011";
   constant opADD   :  std_logic_vector(4 downto 0)  :=  "00100";
   constant opSUB   :  std_logic_vector(4 downto 0)  :=  "00101";
   constant opAND   :  std_logic_vector(4 downto 0)  :=  "00110";
   constant opOR    :  std_logic_vector(4 downto 0)  :=  "00111";
   constant opNOT   :  std_logic_vector(4 downto 0)  :=  "01000";
   constant opJZ    :  std_logic_vector(4 downto 0)  :=  "01001";
   constant opJN    :  std_logic_vector(4 downto 0)  :=  "01011";
   constant opJMP   :  std_logic_vector(4 downto 0)  :=  "01100";
   constant opHLT   :  std_logic_vector(4 downto 0)  :=  "01101";

   constant ulaADD  :  std_logic_vector(2 downto 0)  :=  "000";
   constant ulaSUB  :  std_logic_vector(2 downto 0)  :=  "001";
   constant ulaAND  :  std_logic_vector(2 downto 0)  :=  "100";
   constant ulaOR   :  std_logic_vector(2 downto 0)  :=  "110";
   constant ulaNOT  :  std_logic_vector(2 downto 0)  :=  "111";


begin


   process (rst, clk)
   begin

      if rst = '1' then

         wrPC     <=  '0';
         wrIR     <=  '0';
         wrReg    <=  '0';
         rdMem    <=  '0';
         wrMem    <=  '0';
         muxPC    <=  '1';
         muxAReg  <=  '1';
         muxDReg  <=  "10";
         opULA    <=  ulaADD;

         PE       <=  BUSCA;

      elsif clk'event and clk = '1' then

         EA  <=  PE ;

         case  PE  is

            ------------------------------------------------------------------
            when  BUSCA    =>             --  BUSCA INSTRUÇÃO          ALL  S0
            ------------------------------------------------------------------
                  wrPC     <=  '1';
                  wrIR     <=  '1';
                  rdMem    <=  '1';
                  wrMem    <=  '0';
                  muxPC    <=  '1';
                  muxAReg  <=  '1';
                  muxDReg  <=  "10";

                  PE       <=  DECODE;

            ------------------------------------------------------------------
            when  DECODE   =>             --  DECODIFICA INSTRUÇÃO     ALL  S0
            ------------------------------------------------------------------
                  wrPC     <=  '0';
                  wrIR     <=  '0';
                  wrReg    <=  '0';
                  rdMem    <=  '0';
                  wrMem    <=  '0';

                  if     opcode = opLDA   then   PE  <=  RD_MEM;
                  elsif  opcode = opLDAi  then   PE  <=  WR_REG2;
                  elsif  opcode = opSTA   then   PE  <=  RD_REG;
                  elsif  opcode = opADD   then   PE  <=  RD_REG2;
                  elsif  opcode = opSUB   then   PE  <=  RD_REG2;
                  elsif  opcode = opAND   then   PE  <=  RD_REG2;
                  elsif  opcode = opOR    then   PE  <=  RD_REG2;
                  elsif  opcode = opNOT   then   PE  <=  RD_REG2;
                  elsif  opcode = opJZ    then   PE  <=  WR_PC;
                  elsif  opcode = opJN    then   PE  <=  WR_PC;
                  elsif  opcode = opJMP   then   PE  <=  WR_PC;
                  elsif  opcode = opHLT   then   PE  <=  FIM;
                  else                           PE  <=  DECODE;
                  end if;

            ------------------------------------------------------------------
            when  RD_MEM   =>             --  LEITURA MEMÓRIA          LDA  S2
            ------------------------------------------------------------------
                  rdMem    <=  '1';
                  muxAReg  <=  '0';
                  muxDReg  <=  "01";

                  PE       <=  WR_REG;

            ------------------------------------------------------------------
            when  WR_REG   =>             --  ESCREVE REGISTRADOR      LDA  S3
            ------------------------------------------------------------------
                  wrReg    <= '1';
                  rdMem    <= '0';

                  PE       <=  BUSCA;

            ------------------------------------------------------------------
            when  WR_REG2  =>             --  ESCREVE REGISTRADOR 2    LDAi S2
            ------------------------------------------------------------------
                  wrReg    <= '1';
                  muxAReg  <= '0';
                  muxDReg  <= "00";

                  PE       <=  BUSCA;

            ------------------------------------------------------------------
            when  RD_REG   =>             --  LÊ REGISTRADORES         STA  S2
            ------------------------------------------------------------------
                  PE       <=  WR_MEM;

            ------------------------------------------------------------------
            when  WR_MEM   =>             --  ESCREVE MEMÓRIA          STA  S3
            ------------------------------------------------------------------
                  wrMem    <= '1';

                  PE       <=  BUSCA;

            ------------------------------------------------------------------
            when  RD_REG2  =>             --  LÊ REGISTRADOR 2         ULA  S2
            ------------------------------------------------------------------
                  PE       <=  ULA_EXEC;


            ------------------------------------------------------------------
            when  ULA_EXEC =>             --  ULA EXECUTA              ULA  S3
            ------------------------------------------------------------------

                  if     opcode = opSUB  then  opULA  <=  ulaSUB;
                  elsif  opcode = opAND  then  opULA  <=  ulaAND;
                  elsif  opcode = opOR   then  opULA  <=  ulaOR;
                  elsif  opcode = opNOT  then  opULA  <=  ulaNOT;
                  else                         opULA  <=  ulaADD;
                  end if;


                  PE       <=  WR_REG3;

            ------------------------------------------------------------------
            when  WR_REG3  =>             --  ESCREVE REGISTRADOR 3    ULA  S4
            ------------------------------------------------------------------
                  wrReg    <=  '1';
                  opULA    <=  ulaADD;

                  PE       <=  BUSCA;

            ------------------------------------------------------------------
            when  WR_PC    =>             --  ESCREVE PC               JMP  S1
            ------------------------------------------------------------------
                  if (opcode = opJZ and Z = '1') or
                     (opcode = opJN and N = '1') or
                     (opcode = opJMP) then
                          wrPC     <=  '1';
                          muxPC    <=  '0';
                  end if;

                  PE       <=  BUSCA;

            ------------------------------------------------------------------
            when  FIM      =>             --  FINAL PROGRAMA           HLT  S1
            ------------------------------------------------------------------
                  PE       <=  FIM;

         end case;
      end if;
   end process;

end architecture;




-----------------------------------------------------------------------------------------
--  TestBench da FSM DE CONTROLE
-----------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FSM_TB is
end entity;

architecture FSM_TB of FSM_TB is

   signal rst      :  std_logic  := '0';
   signal clk      :  std_logic  := '0';

   signal Z        :  std_logic  := '0';
   signal N        :  std_logic  := '0';
   signal wrPC     :  std_logic  := '0';
   signal wrIR     :  std_logic  := '0';
   signal wrReg    :  std_logic  := '0';
   signal rdMem    :  std_logic  := '0';
   signal wrMem    :  std_logic  := '0';
   signal muxPC    :  std_logic  := '0';
   signal muxAReg  :  std_logic  := '0';

   signal muxDReg  :  std_logic_vector(1 downto 0)   := (others => '0');
   signal opcode   :  std_logic_vector(4 downto 0)   := (others => '0');
   signal opULA    :  std_logic_vector(2 downto 0)   := (others => '0');

   constant opLDA   :  std_logic_vector(4 downto 0)  :=  "00001";
   constant opLDAi  :  std_logic_vector(4 downto 0)  :=  "00010";
   constant opSTA   :  std_logic_vector(4 downto 0)  :=  "00011";
   constant opADD   :  std_logic_vector(4 downto 0)  :=  "00100";
   constant opSUB   :  std_logic_vector(4 downto 0)  :=  "00101";
   constant opAND   :  std_logic_vector(4 downto 0)  :=  "00110";
   constant opOR    :  std_logic_vector(4 downto 0)  :=  "00111";
   constant opNOT   :  std_logic_vector(4 downto 0)  :=  "01000";
   constant opJZ    :  std_logic_vector(4 downto 0)  :=  "01001";
   constant opJN    :  std_logic_vector(4 downto 0)  :=  "01011";
   constant opJMP   :  std_logic_vector(4 downto 0)  :=  "01100";
   constant opHLT   :  std_logic_vector(4 downto 0)  :=  "01101";


begin

   -- Instancia da FSM de CONTROLE
   dut: entity  work.FSM  port map(  rst     =>  rst,
                                     clk     =>  clk,
                                     opcode  =>  opcode,
                                     Z       =>  Z,
                                     N       =>  N,
                                     wrPC    =>  wrPC,
                                     wrIR    =>  wrIR,
                                     wrReg   =>  wrReg,
                                     rdMem   =>  rdMem,
                                     wrMem   =>  wrMem,
                                     muxPC   =>  muxPC,
                                     muxAReg =>  muxAReg,
                                     muxDReg =>  muxDReg,
                                     opULA   =>  opULA );

   -- Processo RESET
   process begin
      rst  <=  '1';      wait for 5 ns;
      rst  <=  '0';      wait;
   end process;


   -- Processo CLOCK
   process begin
      wait for 10 ns;
      clk  <=  not(clk);
   end process;


   -- Geração das ENTRADAS (gera Opcodes para cada Tipo de Instrução, TODOS CAMINHOS)
   process begin
                                           wait for   5 ns;
      opcode  <=  opLDA;                   wait for  80 ns;
      opcode  <=  opLDAi;                  wait for  60 ns;
      opcode  <=  opSTA;                   wait for  80 ns;
      opcode  <=  opADD;                   wait for 100 ns;
      opcode  <=  opSUB;                   wait for 100 ns;
      opcode  <=  opAND;                   wait for 100 ns;
      opcode  <=  opOR;                    wait for 100 ns;
      opcode  <=  opNOT;                   wait for 100 ns;
      opcode  <=  opJMP;                   wait for  60 ns;
      opcode  <=  opJZ;     Z  <=  '1';    wait for  60 ns;
      opcode  <=  opJZ;     Z  <=  '0';    wait for  60 ns;
      opcode  <=  opJN;     N  <=  '1';    wait for  60 ns;
      opcode  <=  opJN;     N  <=  '0';    wait for  60 ns;
      opcode  <=  opHLT;                   wait for 100 ns;
      report "FIM !!!" severity failure;
  end process;

end architecture;

