// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../node_modules/@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "../node_modules/@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "../contracts/tampilan/DewaGula.sol";

contract Toko24Jam is dewaGula, AccessControl {
 // konstan
            bytes32 public constant ADMIN_TOKO = keccak256(abi.encode("ADMIN_TOKO"));

            address public immutable pasarV3Pengelola; // tambahkan alamat uniswapV3Factory
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
                return ambilHarga(basis, kutipan, jumlah );}
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
                uint256 stempelWaktuTertua = (stempelWaktuTidakLangsung < basisStempelWaktu) ? stempelWaktuTidakLangsung : basisStempelWaktu;
                    return (nilaiTidakLangsung, stempelWaktuTertua);
                }
            }
            return (nilaiLangsung, stempelWaktuLangsung);
}
            function ambilHarga(address basis, uint24 fee, address kutipan, uint256 jumlah) public view
                returns (uint256 harga, uint256 lamaObservasi ) {
                    // v3 Dewa
                    uint32[] memory detikLalu = new uint32[](2);
                    detikLalu[0] = beberapaDetikLalu;
                    detikLalu[1] = 0;

                    address kolam = IpasarV3Pengelola(pasarV3Pengelola) .ambilKolam(basis, kutipan, fee);
                    address _basis = basis; // Memperbaiki Tumpukan Yang Dalam
                    address _kutipan = kutipan; // Memperbaiki Tumpukan Yang Dalam
                    if (kolam != address(0)) {
                        // gunakan pasar V3 saat keluar kolam
                        (int56[] memory centangKumulatif, ) = IPasarV3Kolam(kolam).observasi(detikLalu);
                        int56 centangDeltaKumulatif = centangKumulatif[1] - centangKumulatif[0];
                        // int56 / uint32 = int24
                        int24 centang = int24(centangDeltaKumulatif / int56(uint56(detikLalu)));
                            uint256 jumlahKeluar = perpustakaanDewa.ambilKutipanDiCentang( 
                                centang,
                                uint128(jumlah),
                                _basis,
                                _kutipan
                            );
                            {
                                uint16 observasiIndex;
                                (,,observasiIndex,,,,) = IPasarV3Kolam(kolam).slot0();
                                uint32 observasiStempelWaktu;
                                bool inisial;
                                (observasiStempelWaktu,,,inisial) = IPasarV3Kolam(kolam).observasi(observasiIndex);
                                if (inisial) {
                                    lamaObservasi = observasiStempelWaktu;
                                }
                            }
                            return (jumlahKeluar, lamaObservasi);
                    }
                    return (0,0);
                }
                function aturPasarV3fee (address barang, uint24 _fee ) external hanyaRole(ADMIN_TOKO) {
                    require(
                        _fee == 100 // 0.01%
                    ||   _fee == 500 // 0.05%
                    ||   _fee == 3000 // 0.3%
                    ||   _fee == 10000 // 1%
                    , "FEE_INVALID_ERROR"
                    );
                    pasarV3fee[barang] = _fee;
                }
                function dapatMengupdateHargaBarang() external pure sampingan returns (bool) { return false; }
                function updateHargaBarang(address[] memory barangs) external pure sampingan returns 
                (bool[] memory update) { return new bool[](barangs.panjang);}
}