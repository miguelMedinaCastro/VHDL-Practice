library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
  generic (
    tamanho_OPCODE : natural := 5
  );

  port (
    clk   : in std_logic;
    reset : in std_logic;

    opcode : in std_logic_vector(tamanho_OPCODE - 1 downto 0);
    z      : in std_logic;
    n      : in std_logic;

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
end entity;

architecture comportamento of fsm is

  type estado_t is (
    ESTADO_BUSCA,
    ESTADO_DECODIFICA,
    ESTADO_LE_MEM,
    ESTADO_ESCREVE_REG,
    ESTADO_ESCREVE_REG_2,
    ESTADO_LE_REG,
    ESTADO_ESCREVE_MEM,
    ESTADO_LE_REG_2,
    ESTADO_ULA_EXECUTA,
    ESTADO_ESCREVE_REG_3,
    ESTADO_ESCREVE_PC,
    ESTADO_FIM      
  );

  signal estado_atual   : estado_t;

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

  process (clk, reset)
  begin
    if reset = '1' then
      wrPC           <= '0';
      wrIR           <= '0';
      wrReg          <= '0';
      rdMem          <= '0';
      wrMem          <= '0';
      muxPC          <= '1';
      muxAReg        <= '1';
      muxDReg        <= "10";
      opULA          <= "000";

      estado_atual <= ESTADO_BUSCA;
    elsif rising_edge(clk) then
      case estado_atual is

        when ESTADO_BUSCA => -- le instrucao da memoria e faz pc+1
          wrPC           <= '1';
          wrIR           <= '1';
          rdMem          <= '1';
          wrMem          <= '0';
          muxPC          <= '1';
          muxAReg        <= '1';
          muxDReg        <= "10";
          
          estado_atual <= ESTADO_DECODIFICA;

        when ESTADO_DECODIFICA => -- olha o opcode e escolhe o caminho
          wrPC  <= '0';
          wrIR  <= '0';
          wrReg <= '0';
          rdMem <= '0';
          wrMem <= '0';

          if opcode = OP_LDA then
            estado_atual <= ESTADO_LE_MEM;
          elsif opcode = OP_LDAi then
            estado_atual <= ESTADO_ESCREVE_REG_2;
          elsif opcode = OP_STA then
            estado_atual <= ESTADO_LE_REG;
          elsif opcode = OP_ADD or opcode = OP_SUB or opcode = OP_AND or opcode = OP_OR or opcode = OP_NOT then
            estado_atual <= ESTADO_LE_REG_2;
          elsif opcode = OP_JZ or opcode = OP_JN or opcode = OP_JMP then
            estado_atual <= ESTADO_ESCREVE_PC;
          elsif opcode = OP_HLT then
            estado_atual <= ESTADO_FIM;
          else
            estado_atual <= ESTADO_DECODIFICA;
          end if;

        when ESTADO_LE_MEM =>
          rdMem          <= '1';
          muxAReg        <= '0';
          muxDReg        <= "01";
          estado_atual <= ESTADO_ESCREVE_REG;

        when ESTADO_ESCREVE_REG =>
          wrReg          <= '1';
          rdMem          <= '0';
          estado_atual <= ESTADO_BUSCA;

        when ESTADO_ESCREVE_REG_2 =>
          wrReg          <= '1';
          muxAReg        <= '0';
          muxDReg        <= "00";
          estado_atual <= ESTADO_BUSCA;

        when ESTADO_LE_REG =>
          estado_atual <= ESTADO_ESCREVE_MEM;

        when ESTADO_ESCREVE_MEM =>
          wrMem          <= '1';
          estado_atual <= ESTADO_BUSCA;

        when ESTADO_LE_REG_2 =>
          estado_atual <= ESTADO_ULA_EXECUTA;

        when ESTADO_ULA_EXECUTA => 
          if opcode = OP_SUB then
            opULA <= "001";
          elsif opcode = OP_AND then
            opULA <= "100";
          elsif opcode = OP_OR then
            opULA <= "110";
          elsif opcode = OP_NOT then
            opULA <= "111";
          else
            opULA <= "000";
          end if;
          
          estado_atual <= ESTADO_ESCREVE_REG_3;

        when ESTADO_ESCREVE_REG_3 => 
          wrReg          <= '1';
          opULA          <= "000";
          estado_atual <= ESTADO_BUSCA;

        when ESTADO_ESCREVE_PC =>
        if (opcode = OP_JZ and z = '1') or (opcode = OP_JN and n = '1') or (opcode = OP_JMP) then
          wrPC <= '1';
          muxPC <= '0'; 
        end if;
          estado_atual <= ESTADO_BUSCA;

        when ESTADO_FIM =>
          estado_atual <= ESTADO_FIM;

      end case;
    end if;
    end process;

end architecture;
