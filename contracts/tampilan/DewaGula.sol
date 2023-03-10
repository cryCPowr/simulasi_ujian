// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

interface dewaGula {
    function  jumlahGula(address barang, uint256 jumlah) external view 
    returns (uint256 nilaiGula, uint256 lamaObservasi);
    function ambilHarga(address basis, address kutipan) external view 
    returns (uint256 nilai, uint256 lamaObservasi);
    function dapatMengupdateHargaBarang() external pure
    returns (bool);
    function updateHargaBarang(address[] memory barangs) external
    returns (bool[] memory update);    
    }