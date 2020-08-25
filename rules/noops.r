# Randomly add NOPs

# Add a random number of NOPs (5-100)
LIMIT=$((5 + RANDOM % 100))

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

for ((i = 0 ; i < $LIMIT ; i++))
do
    lines=($(grep -n ^"  " asm_code.asm | cut -d":" -f1))
    RAND1=$(( RANDOM % ${#lines[@]} ))
    RAND2=$(( RANDOM % ${#nops[@]} ))
    sed -i "${lines[RAND1]}i\    ${nops[RAND2]}                                ;" asm_code.asm
done