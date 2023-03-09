// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../node_modules/@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "../node_modules/@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract Toko24Jam is stokBarang, AccessControl {
 // konstan
            bytes32 public constant ADMIN_TOKO = keccak256(abi.encode("ADMIN_TOKO"));

            address public immutable pasarV3pengelola; // tambahkan alamat uniswapV3Factory
            address public immutable GULA; // tambahkan alamat GULA
            address public immutable RUPIAH; // tambahkan alamat RUPIAH

// penyimapan
            uint32 public periodeObservasi;
            mapping(address => uint24) public pasarV3fee;

// Konstruktor
            constructor(address _pasarV3PengelolaAlamat, uint32 _inisialPeriodeObservasi, address _gula, address _rupiah) {
            require (_pasarV3PengelolaAlamat != address (0), "INISIAL_PENGELOLA_PASAR_ERROR");
            require (_rupiah != address (0), "INISIAL_RUPIAH_ERROR");
            pasarV3Pengelola = _pasarV3PengelolaAlamat;
            periodeObservasi = _inisialPeriodeObservasi;
            GULA = _gula;
            RUPIAH = _rupiah;
            _aturRole(ADMIN_TOKO, msg.sender);
            }
// fungsi luar
            function jumlahGula(address barangMasuk, uint256 jumlah) public view sampingan
            returns(uint256 nilaiGula, uint256 lamaObservasi) {
                if (barangMasuk == GULA) {return(jumlah, block.timestamp);}
                return ambilHarga(barangMasuk, GULA, jumlah);}
            function ambilHarga(address basis, address kutipan) public view sampingan 
            returns(uint256, uint256) { 
                uint8 decimals = IERC20Metadata(basis).decimals();
                uint256 jumlah = 10 ** decimals;
                return ambilHarga(basis, kutipan, jumlah );
            }
            function ambilHarga(address basis, address kutipan, uint256 jumlah) public view sampingan
        returns(uint256, uint256) {
            uint24 basisFee = (pasarV3fee[basis]>0) ? pasarV3fee[basis] : 3000;
            (uint256 nilaiLangsung, uint256 stempelWaktuLangsung) = 
                        ambilHarga(basis, basisFee, kutipan, jumlah);

            if (basis !=RUPIAH && kutipan != RUPIAH) {
                (uint256 nilaiRupiah, uint256 basisStempelWaktu) =
                        ambilHarga(basis, basisFee, RUPIAH,jumlah);
                uint24 rupiahFee = (pasarV3fee[RUPIAH]>0) ? pasarV3fee[RUPIAH] : 3000;
                (uint256 nilaiTidakLangsung, uint256 stempelWaktuTidakLangsung) = 
                        ambilHarga(RUPIAH, rupiahFee, kutipan, nilaiRupiah);
                if (nilaiTidakLangsung > nilaiLangsung) {
                    uint256 stempelJamTertua = (stempelWaktuTidakLangsung < basisStempelWaktu) ? stempelWaktuTidakLangsung : basisStempelWaktu;
                    return (nilaiTidakLangsung, stempelWaktuTertua);
                }
            }
            return (nilaiLangsung, stempelWaktuLangsung);
}

}