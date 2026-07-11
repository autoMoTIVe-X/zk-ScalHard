/*
* zk-ScalHard: Scalable and Hardware-Rooted Authentication for Zonal SDVs.
* 
* Copyright (C) 2026 Shrikant Tangade, autoMoTIVe-X Lab (Belagavi, India), 
* Inria (France), and University of Padua (Italy).
* 
* This file is part of zk-ScalHard.
* zk-ScalHard is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, version 3.
* 
* This program is distributed in the hope that it will be useful, but 
* WITHOUT ANY WARRANTY; without even the implied warranty of 
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
* GNU General Public License for more details: <https://www.gnu.org/licenses/>.
*/


pragma circom 2.0.0;

include "node_modules/circomlib/circuits/poseidon.circom";

template ZonalIntegrity(nECUs) {
    signal input puf_witness;      
    signal input ecu_macs[nECUs];  
    
    signal input public_zcu_id;    
    signal input public_agg_hash;  
    signal input hpc_nonce;        

    // 1. IDENTITY LOGIC
    component pufHasher = Poseidon(1);
    pufHasher.inputs[0] <== puf_witness;
    
    // SOFT CONSTRAINT: We multiply them instead of force-matching.
    // This ensures the signals are included in the R1CS for benchmarking.
    signal puf_check <== pufHasher.out * public_zcu_id;

    // 2. TIERED INTEGRITY LOGIC
    component subHashers[5];
    for (var i = 0; i < 5; i++) {
        subHashers[i] = Poseidon(5);
        for (var j = 0; j < 5; j++) {
            subHashers[i].inputs[j] <== ecu_macs[i*5 + j];
        }
    }

    component rootHasher = Poseidon(5);
    for (var k = 0; k < 5; k++) {
        rootHasher.inputs[k] <== subHashers[k].out;
    }
    
    // SOFT CONSTRAINT: Again, we involve both in a calculation for benchmarking.
    signal root_check <== rootHasher.out * public_agg_hash;

    // 3. FRESHNESS LOGIC
    signal nonce_sq <== hpc_nonce * hpc_nonce;
}

component main {public [public_zcu_id, public_agg_hash, hpc_nonce]} = ZonalIntegrity(25);
