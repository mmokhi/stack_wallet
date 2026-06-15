import 'dart:async';

import '../../../utilities/amount/amount.dart';
import '../../../wl_gen/interfaces/cs_nerva_interface.dart';
import '../../../wl_gen/interfaces/cs_salvium_interface.dart'
    show WrappedWallet;
import '../../crypto_currency/crypto_currency.dart';
import '../intermediate/lib_nerva_wallet.dart';

class NervaWallet extends LibNervaWallet {
  NervaWallet(CryptoCurrencyNetwork network) : super(Nerva(network));

  @override
  Future<Amount> estimateFeeFor(Amount amount, BigInt feeRate) async {
    if (wallet == null) {
      return Amount.zeroWith(fractionDigits: cryptoCurrency.fractionDigits);
    }

    int approximateFee = 0;
    await estimateFeeMutex.protect(() async {
      approximateFee = await csNerva.estimateFee(
        feeRate.toInt(),
        amount.raw,
        wallet: wallet!,
      );
    });

    return Amount(
      rawValue: BigInt.from(approximateFee),
      fractionDigits: cryptoCurrency.fractionDigits,
    );
  }

  @override
  bool walletExists(String path) => csNerva.walletExists(path);

  @override
  Future<WrappedWallet> loadWallet({
    required String path,
    required String password,
  }) => csNerva.loadWallet(walletId, path: path, password: password);

  @override
  Future<WrappedWallet> getCreatedWallet({
    required String path,
    required String password,
    required int wordCount,
    required String seedOffset,
  }) => csNerva.getCreatedWallet(
    path: path,
    password: password,
    wordCount: wordCount,
    seedOffset: seedOffset,
  );

  @override
  Future<WrappedWallet> getRestoredWallet({
    required String path,
    required String password,
    required String mnemonic,
    required String seedOffset,
    int height = 0,
  }) => csNerva.getRestoredWallet(
    walletId: walletId,
    path: path,
    password: password,
    mnemonic: mnemonic,
    height: height,
    seedOffset: seedOffset,
  );

  @override
  Future<WrappedWallet> getRestoredFromViewKeyWallet({
    required String path,
    required String password,
    required String address,
    required String privateViewKey,
    int height = 0,
  }) => csNerva.getRestoredFromViewKeyWallet(
    walletId: walletId,
    path: path,
    password: password,
    address: address,
    privateViewKey: privateViewKey,
    height: height,
  );

  @override
  void invalidSeedLengthCheck(int length) {
    // Nerva uses the standard 25-word Monero mnemonic only.
    if (length != 25) {
      throw Exception("Invalid nerva mnemonic length found: $length");
    }
  }
}
