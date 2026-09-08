library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity CPU is
    generic (
        tamanho : NATURAL := 16
    );
    port (
        clk      : in std_logic;
        reset    : in std_logic;
        opcode   : out STD_LOGIC_VECTOR(tamanho - 12 downto 0)

    );
end entity;

architecture rtl of CPU is

    -- Registradores
    signal PC  : std_logic_vector(tamanho - 9 downto 0); -- 8 bits
    signal IR  : std_logic_vector(tamanho - 1 downto 0);
    signal MAR : std_logic_vector(tamanho - 9 downto 0);
    signal MDR : std_logic_vector(tamanho - 1 downto 0);
    signal A   : std_logic_vector(tamanho - 1 downto 0);
    signal B   : std_logic_vector(tamanho - 1 downto 0);
    signal R   : std_logic_vector(tamanho - 1 downto 0);

    signal opcode_interno : std_logic_vector(tamanho - 12 downto 0);

    -- Flags ULA
    signal flag_z : std_logic;
    signal flag_n : std_logic;

    -- FSM
    signal wrPC    : std_logic;
    signal wrIR    : std_logic;
    signal wrReg   : std_logic;
    signal wrMem   : std_logic;
    signal rdMem   : std_logic;
    signal muxPC   : std_logic;
    signal muxAReg : std_logic;
    signal muxDReg : std_logic_vector(tamanho - 15 downto 0);
    signal opULA   : std_logic_vector(tamanho - 14 downto 0);
    
    -- DECOD
    signal  reg_MAR  :  std_logic_vector(tamanho - 9 downto 0);
    signal  addr_r1  :  std_logic_vector(tamanho - 14 downto 0);   
    signal  addr_r2  :  std_logic_vector(tamanho - 14 downto 0); 
    signal  addr_w1  :  std_logic_vector(tamanho - 14 downto 0); 
    signal  addr_w2  :  std_logic_vector(tamanho - 14 downto 0); 
    signal  data_w1  :  std_logic_vector(tamanho - 1 downto 0);


    signal PC_mais_1 : std_logic_vector(tamanho - 9 downto 0);


begin
    
    FAD : entity work.FAD port map (
        A   => PC,
        B   => "00000001",
        Cin => '0',
        S   => PC_mais_1
    );
    
    
    DECOD : entity work.DECOD port map (
        rst => reset,
        clk => clk,
        IR => IR,
        opcode => opcode



    );

    DMEM : entity work.DMEM port map (
        
    );

    FSM : entity work.FSM port map (
        
    );

    GPR : entity work.GPR port map (
        
    );

    IMEM : entity work.IMEM port map (
        
    );

    ULA : entity work.ULA port map (
        
    );


end architecture;