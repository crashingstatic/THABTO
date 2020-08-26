#!/bin/bash

#Check for when a registery is cleared
# Right before clearing, insert some junk instructions

# Create a backup of asm_code.asm
cp asm_code.asm asm_code.asm.bak

unset line_num
unset target_reg

# Is a registry cleared? If so, where?
line_num=($(awk '/xor/ {gsub(",",""); if($2==$3)print NR}' asm_code.asm))
target_reg=($(awk '/xor/ {gsub(",",""); if($2==$3)print $2}' asm_code.asm))

while true
do
    unset new_lines
    # For random reg location:
    RAND2=$(( RANDOM % ${#line_num[@]}))

    # Create an array of junk instructions
    for reg in eax ebx ecx edx
    do
        new_lines=("${new_lines[@]}" "xor ${target_reg[RAND2]}, $reg")
    done

    for ((i = 0 ; i < 20 ; i++))
    do
        # Pick a random number between 0-2^15
        RAND1=$(( RANDOM % 32768 ))
        new_lines=("${new_lines[@]}" "mov ${target_reg[RAND2]}, $RAND1")
    done


    # Use a random number of available junk instructions
    LIMIT=$((1 + RANDOM % ${#new_lines[@]}))

    sed -i "${line_num[RAND2]}i\    popfd                                        ;" asm_code.asm

    for ((j = 0 ; j < $LIMIT ; j++))
    do
        RAND3=$(( RANDOM % ${#new_lines[@]}))
        sed -i "${line_num[RAND2]}i\    ${new_lines[RAND3]}                                ;" asm_code.asm
    done

    sed -i "${line_num[RAND2]}i\    pushfd                                       ;" asm_code.asm

    # Attempt to recompile. If no error, exit loop
    ./encode.rb asm_code.asm -o payload 2>/dev/null && break

    # If compile error, restore backup and try again
    cp asm_code.asm.bak asm_code.asm
done

# Delete backup
rm asm_code.asm.bak