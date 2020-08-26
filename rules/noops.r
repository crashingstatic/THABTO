#!/bin/bash
# Randomly add a block of NOPs

# Create a backup of asm_code.asm
cp asm_code.asm asm_code.asm.bak

# Non-canonical NOPs
nops=(
    "nop          "
    "xor eax, 0   "
    "xor ebx, 0   "
    "xor ecx, 0   "
    "xor edx, 0   "
    "xchg eax, eax"
    "xchg ebx, ebx"
    "xchg ecx, ecx"
    "xchg edx, edx"
    "add eax, 0   "
    "add ebx, 0   "
    "add ecx, 0   "
    "add edx, 0   "
    "sub eax, 0   "
    "sub ebx, 0   "
    "sub ecx, 0   "
    "sub edx, 0   "
    )

# Find all instruction lines
lines=($(grep -n ^"  " asm_code.asm | cut -d":" -f1))

while true
do

    # Add a random number of NOPs (5-100)
    LIMIT=$((5 + RANDOM % 100))

    # Choose one at random
    RAND1=$(( RANDOM % ${#lines[@]}))

    unset new_lines

    # Populate an array with random NOPs
    for ((i = 0 ; i < $LIMIT ; i++))
    do
        RAND2=$(( RANDOM % ${#nops[@]} ))
        new_lines=("${new_lines[@]}" "${nops[$RAND2]}")
    done

    #  Insertion is done backwards (it's easier):
    sed -i "${lines[RAND1]}i\    popfd                                        ;" asm_code.asm
    for NEWOPS in "${new_lines[@]}"
    do
        sed -i "${lines[RAND1]}i\    $NEWOPS                                ;" asm_code.asm
    done
    sed -i "${lines[RAND1]}i\    pushfd                                       ;" asm_code.asm

    # Attempt to recompile. If no error, exit loop
    ./encode.rb asm_code.asm -o payload 2>/dev/null && break

    # If compile error, restore backup and try again
    cp asm_code.asm.bak asm_code.asm
done

# Delete backup
rm asm_code.asm.bak