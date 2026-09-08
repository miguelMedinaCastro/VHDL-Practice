#!/bin/zsh

if [ -z "$1" ]; then
    echo "\n\n Formas de USO:\n\t $0 <Modulo.vhd> <2000ns>\n\t $0 <Modulo.vhd>\n\n"
    exit 1
fi

filename="${1%.*}"
tempo="${2:-100000ns}"

ghdl --clean
ghdl -a *.vhd

ghdl -e "${filename}_TB"
ghdl -r "${filename}_TB" --stop-time="${tempo}" --wave="${filename}_TB.ghw"

surfer "${filename}_TB.ghw"

rm *.o
rm *.cf
rm *.ghw
rm "${filename:l}_tb"
