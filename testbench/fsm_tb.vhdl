library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity fsm_tb is
end entity;

architecture sim of fsm_tb is

  constant tamanho_OPCODE : natural := 5;

  component fsm
    generic (
      tamanho_OPCODE : natural := 5
    );
    port (
      clk     : in std_logic;
      reset   : in std_logic;

      opcode  : in std_logic_vector(tamanho_OPCODE - 1 downto 0);
      z       : in std_logic;
      n       : in std_logic;
      
      wrPC    : out std_logic;
      wrIR    : out std_logic;
      wrReg   : out std_logic;
      rdMem   : out std_logic;
      wrMem   : out std_logic;
      muxPC   : out std_logic;
      muxAReg : out std_logic;
      muxDReg : out std_logic_vector(1 downto 0);
      opULA   : out std_logic_vector(2 downto 0) := "000"
    );
  end component;

  signal clk                                             : std_logic                                     := '0';
  signal reset                                           : std_logic                                     := '1';
  signal opcode                                          : std_logic_vector(tamanho_OPCODE - 1 downto 0) := (others => '0');
  signal z, n                                            : std_logic                                     := '0';
  signal wrPC, wrIR, wrReg, rdMem, wrMem, muxPC, muxAReg : std_logic;
  signal muxDReg                                         : std_logic_vector(1 downto 0);
  signal opULA                                           : std_logic_vector(2 downto 0);

  -- constant CLK_PERIOD : time := 10 ns;
  -- constant tempo : numeric := 10 ns;
  

  constant OP_LDA  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "00001";
  constant OP_LDAi : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "00010";
  constant OP_STA  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "00011";
  constant OP_ADD  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "00100";
  constant OP_SUB  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "00101";
  constant OP_AND  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "00110";
  constant OP_OR   : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "00111";
  constant OP_NOT  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "01000";
  constant OP_JZ   : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "01001";
  constant OP_JN   : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "01011";
  constant OP_JMP  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "01100";
  constant OP_HLT  : std_logic_vector(tamanho_OPCODE - 1 downto 0) := "01101";

begin

  uut : fsm
  generic map (
    tamanho_OPCODE => tamanho_OPCODE
  )
  port map (
    clk     => clk,
    reset   => reset,
    opcode  => opcode,
    z       => z,
    n       => n,
    wrPC    => wrPC,
    wrIR    => wrIR,
    wrReg   => wrReg,
    rdMem   => rdMem,
    wrMem   => wrMem,
    muxPC   => muxPC,
    muxAReg => muxAReg,
    muxDReg => muxDReg,
    opULA   => opULA
  );



  process
  begin

    wait for 5 ns;
    clk <= not clk;

  end process;  

  process
    begin
    reset <= '1';

    reset <= '0' after 35 ns;
  
    opcode <= OP_LDA; wait for 40 ns;

     opcode <= OP_LDAi; wait for 30 ns;
     opcode <= OP_STA; wait for 40 ns;
     opcode <= OP_ADD; wait for 50 ns;
     opcode <= OP_SUB; wait for 50 ns;
     opcode <= OP_NOT; wait for 50 ns;
     opcode <= OP_AND; wait for 50 ns;
     opcode <= OP_OR; wait for 50 ns;
    
     opcode <= OP_HLT; wait for 30 ns;

     reset <= '1';
     reset <= '0' after 12 ns;

     opcode <= OP_JMP; wait for 30 ns;
     opcode <= OP_JZ; z <= '0'; wait for 30 ns;
     opcode <= OP_JZ; z <= '1'; wait for 30 ns;
     opcode <= OP_JN; N <= '0'; wait for 30 ns;
     opcode <= OP_JN; n <= '1'; wait for 30 ns;

     opcode <= OP_HLT; wait for 30 ns;

     wait;
     -- busca
--     assert wrPC  = '1' and
--           wrIR    = '1' and
--           wrMem   = '0' and
--           muxPC   = '1' and
--           muxAReg = '1' and
--           muxDReg = "10" 
--       report "falha no ESTADO_BUSCA OPCODE_LDA"
--       severity error;
    
--     avanco_do_clock;
      
--     -- decodifica
--     assert wrPC  = '0' and
--           wrIR    = '0'
--       report "falha no ESTADO_DECODIFICA OPCODE_LDA"
--       severity error;

--     avanco_do_clock;
    
--     -- le memoria
--     assert rdMem   = '1' and
--           muxAReg = '0' and
--           muxDReg = "01" 
--           report "falha no ESTADO_LE_MEMORIA OPCODE_LDA"
--       severity error;
    
--     avanco_do_clock;

--     -- escreve reg
--     assert wrReg   = '1' and
--           rdMem   = '0'
--       report "falha no ESTADO_ESCREVE_REG OPCODE_LDA"
--       severity error;

--     avanco_do_clock;

-- ---------------------------------------------------------------------------------------------------------------------------------

--     opcode <= OP_LDAi;

--     -- busca
--     assert wrPC  = '1' and
--           wrIR    = '1' and
--           wrMem   = '0' and
--           muxPC   = '1' and
--           muxAReg = '1' and
--           muxDReg = "10" 
--       report "falha no ESTADO_BUSCA OP_LDAi"
--       severity error;
    
--     avanco_do_clock;
    
--     -- decodifica
--     assert wrPC  = '0' and
--           wrIR    = '0'
--       report "falha no ESTADO_DECODIFICA OP_LDAi"
--       severity error;
    
--     avanco_do_clock;

--     -- escreve reg 2
--     assert wrReg   = '1' and
--           muxAReg = '0' and
--           muxDReg = "00"
--       report "falha no ESTADO_ESCREVE_REG_2 OP_LDAi"
--       severity error;
    
--     avanco_do_clock;

--     -----------------------------------------------------------------------------------------------------------------------------

--     opcode <= OP_STA;

--     -- busca
--     assert wrPC  = '1' and
--           wrIR    = '1' and
--           wrMem   = '0' and
--           muxPC   = '1' and
--           muxAReg = '1' and
--           muxDReg = "10" 
--       report "falha no ESTADO_BUSCA OP_STA"
--       severity error;
    
--     avanco_do_clock;
    
--     -- decodifica
--     assert wrPC  = '0' and
--           wrIR    = '0'
--       report "falha no ESTADO_DECODIFICA OP_STA"
--       severity error;
    
--     avanco_do_clock;


--     -- aqui seria o estado de ler registrador, leitura sempre ativada entao "faz nada".
--     avanco_do_clock; 


--     -- escreve mem
--     assert wrMem = '1'
--       report "falha no ESTADO_ESCREVE_MEM OP_STA"
--       severity error;
    
--     avanco_do_clock;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------

--     opcode <= OP_SUB;

--     -- busca
--     assert wrPC   = '1' and
--            wrIR   = '1' and
--            wrMem  = '0' and
--            muxPC  = '1' and
--            muxAReg = '1' and
--            muxDReg = "10"
--       report "falha no ESTADO_BUSCA OP_SUB"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_SUB"
--       severity error;

--     avanco_do_clock;

--     -- le reg
--     avanco_do_clock;

--     -- ula
--     assert opULA = "001"
--       report "falha no ESTADO_ULA_EXECUTA OP_SUB"
--       severity error;

--     avanco_do_clock;

--     -- escreve reg
--     assert wrReg = '1'and
--           opULA = "000"
--       report "falha no ESTADO_ESCREVE_REG OP_SUB"
--       severity error;

--     avanco_do_clock;

--     opcode <= OP_AND;

--     -- busca
--     assert wrPC   = '1' and
--            wrIR   = '1' and
--            wrMem  = '0' and
--            muxPC  = '1' and
--            muxAReg = '1' and
--            muxDReg = "10"
--       report "falha no ESTADO_BUSCA OP_AND"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_AND"
--       severity error;

--     avanco_do_clock;

--     -- le reg
--     avanco_do_clock;

--     -- ula
--     assert opULA = "100"
--       report "falha no ESTADO_ULA_EXECUTA OP_AND"
--       severity error;

--     avanco_do_clock;

--     -- escreve reg
--     assert wrReg = '1' and
--           opULA = "000"
--       report "falha no ESTADO_ESCREVE_REG OP_AND"
--       severity error;

--     avanco_do_clock;

--     opcode <= OP_OR;

--     -- busca
--     assert wrPC   = '1' and
--            wrIR   = '1' and
--            wrMem  = '0' and
--            muxPC  = '1' and
--            muxAReg = '1' and
--            muxDReg = "10"
--       report "falha no ESTADO_BUSCA OP_OR"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_OR"
--       severity error;

--     avanco_do_clock;

--     -- le reg
--     avanco_do_clock;

--     -- ula
--     assert opULA = "110"
--       report "falha no ESTADO_ULA_EXECUTA OP_OR"
--       severity error;

--     avanco_do_clock;

--     -- escreve reg
--     assert wrReg = '1' and
--           opULA = "000"
--       report "falha no ESTADO_ESCREVE_REG OP_OR"
--       severity error;

--     avanco_do_clock;

--     opcode <= OP_NOT;

--     -- busca
--     assert wrPC   = '1' and
--            wrIR   = '1' and
--            wrMem  = '0' and
--            muxPC  = '1' and
--            muxAReg = '1' and
--            muxDReg = "10"
--       report "falha no ESTADO_BUSCA OP_NOT"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_NOT"
--       severity error;

--     avanco_do_clock;

--     -- le reg
--     avanco_do_clock;

--     -- ula
--     assert opULA = "111"
--       report "falha no ESTADO_ULA_EXECUTA OP_NOT"
--       severity error;

--     avanco_do_clock;

--     -- escreve reg
--     assert wrReg = '1'and
--           opULA = "000"
--       report "falha no ESTADO_ESCREVE_REG OP_NOT"
--       severity error;

--     avanco_do_clock;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------

--     opcode <= OP_JMP;

--     -- busca
--     assert wrPC   = '1' and
--            wrIR   = '1' and
--            wrMem  = '0' and
--            muxPC  = '1' and
--            muxAReg = '1' and
--            muxDReg = "10"
--       report "falha no ESTADO_BUSCA OP_JMP"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_JMP"
--       severity error;

--     avanco_do_clock;

--     -- escreve pc
--     assert wrPC   = '1' and
--            muxPC  = '0'
--       report "falha no ESTADO_ESCREVE_PC OP_JMP"
--       severity error;

--     avanco_do_clock;

--     opcode <= OP_JZ; z <= '1';

--     -- busca
--     assert wrPC = '1' and
--            wrIR = '1'
--       report "falha no ESTADO_BUSCA OP_JZ Z=1"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_JZ Z=1"
--       severity error;

--     avanco_do_clock;

--     -- escreve pc
--     assert wrPC = '1'
--       report "falha no ESTADO_ESCREVE_PC OP_JZ Z=1"
--       severity error;

--     avanco_do_clock;

--     opcode <= OP_JZ; z <= '0';

--     -- busca
--     assert wrPC = '1' and
--            wrIR = '1'
--       report "falha no ESTADO_BUSCA OP_JZ Z=0"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_JZ Z=0"
--       severity error;

--     avanco_do_clock;

--     -- nao escreve pc
--     assert wrPC = '0'
--       report "falha no ESTADO_JZ OP_JZ Z=0"
--       severity error;

--     avanco_do_clock;

--     opcode <= OP_JN; n <= '1';

--     -- busca
--     assert wrPC = '1' and
--            wrIR = '1'
--       report "falha no ESTADO_BUSCA OP_JN N=1"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_JN N=1"
--       severity error;

--     avanco_do_clock;

--     -- escreve pc
--     assert wrPC = '1'
--       report "falha no ESTADO_ESCREVE_PC OP_JN N=1"
--       severity error;

--     avanco_do_clock;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------    
--     opcode <= OP_JN;
--     n <= '0';

--     -- busca
--     assert wrPC = '1' and
--            wrIR = '1'
--       report "falha no ESTADO_BUSCA OP_JN N=0"
--       severity error;

--     avanco_do_clock;

--     -- decodifica
--     assert wrPC = '0' and
--            wrIR = '0'
--       report "falha no ESTADO_DECODIFICA OP_JN N=0"
--       severity error;

--     avanco_do_clock;

--     -- nao escreve pc
--     assert wrPC = '0'
--       report "falha no ESTADO_JN OP_JN N=0"
--       severity error;

--     avanco_do_clock;
    
--     opcode <= OP_HLT;
--     fim;

  end process;
  

end architecture;