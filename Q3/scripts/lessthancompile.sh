#!/bin/bash

# [assignment] create your own bash script to compile Multipler3.circom using PLONK below

cd contracts/circuits

mkdir lessthan

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling lesstha.circom..."

# compile circuit

circom LessThan10.circom --r1cs --wasm --sym -o lessthan
snarkjs r1cs info lessthan/LessThan10.r1cs


#generate the witness
node lessthan/LessThan10_js/generate_witness.js lessthan/LessThan10_js/LessThan10.wasm input.json witness.wtns
#witness is in binary, covert to json to read
snarkjs wtns export json witness.wtns witness.json


# Start a new zkey and make a contribution
#generate the verification key
snarkjs plonk setup lessthan/LessThan10.r1cs powersOfTau28_hez_final_10.ptau lessthan/circuit_0000.zkey
# snarkjs zkey contribute _plonk_Multiplier/circuit_0000.zkey _plonk_Multiplier/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"

#get verification key in json format
snarkjs zkey export verificationkey lessthan/circuit_0000.zkey lessthan/verification_key.json

#generate the proof
snarkjs plonk prove lessthan/circuit_0000.zkey witness.wtns proof.json public.json
#verify the proof
snarkjs plonk verify lessthan/verification_key.json public.json proof.json
# generate solidity contract
snarkjs zkey export solidityverifier lessthan/circuit_0000.zkey ../lessthanVerifier.sol

#generateproof in bytes format
snarkjs zkey export soliditycalldata public.json proof.json


cd ../..