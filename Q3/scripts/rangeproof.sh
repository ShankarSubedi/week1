#!/bin/bash

# [assignment] create your own bash script to compile Multipler3.circom using PLONK below

cd contracts/circuits

mkdir rangeproof

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling RangeProof.circom..."

# compile circuit

circom RangeProof.circom --r1cs --wasm --sym -o rangeproof
snarkjs r1cs info rangeproof/RangeProof.r1cs

# Start a new zkey and make a contribution

snarkjs plonk setup rangeproof/RangeProof.r1cs powersOfTau28_hez_final_10.ptau rangeproof/circuit_0000.zkey
# snarkjs zkey contribute _plonk_Multiplier/circuit_0000.zkey _plonk_Multiplier/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
# snarkjs zkey export verificationkey _plonk_Multiplier/circuit_final.zkey _plonk_Multiplier/verification_key.json
# generate solidity contract
snarkjs zkey export solidityverifier rangeproof/circuit_0000.zkey ../rangeproofVerifier.sol

cd ../..