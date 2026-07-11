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

template HPCAggregator() {
    // PRIVATE INPUTS
    signal input hpc_puf_witness;
    signal input zonal_roots[4]; // The 4 roots from your 4 ZCUs

    // PUBLIC INPUTS
    signal input public_vehicle_id;
    signal input public_global_root;

    // 1. HPC IDENTITY CHECK
    component hpcHasher = Poseidon(1);
    hpcHasher.inputs[0] <== hpc_puf_witness;
    // Benchmarking soft constraint
    signal hpc_id_check <== hpcHasher.out * public_vehicle_id;

    // 2. GLOBAL AGGREGATION CHECK
    component globalHasher = Poseidon(4);
    for (var i = 0; i < 4; i++) {
        globalHasher.inputs[i] <== zonal_roots[i];
    }
    // Benchmarking soft constraint
    signal global_root_check <== globalHasher.out * public_global_root;
}

component main {public [public_vehicle_id, public_global_root]} = HPCAggregator();
