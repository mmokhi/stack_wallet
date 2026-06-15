//ON
import 'package:cs_nerva/cs_nerva.dart' as lib_nerva;
import 'package:cs_nerva/src/deprecated/get_height_by_date.dart'
    as cs_nerva_deprecated;
import 'package:cs_nerva/src/ffi_bindings/nerva_wallet_bindings.dart'
    as nerva_wallet_ffi;

//END_ON
import '../../models/input.dart';
import '../interfaces/cs_monero_interface.dart';
import '../interfaces/cs_salvium_interface.dart' show WrappedWallet;
import '../interfaces/cs_nerva_interface.dart';

CsNervaInterface get csNerva => _getInterface();

//OFF
CsNervaInterface _getInterface() => throw Exception("XNV not enabled!");

//END_OFF
//ON
CsNervaInterface _getInterface() => const _CsNervaInterfaceImpl();

class _CsNervaInterfaceImpl extends CsNervaInterface {
  const _CsNervaInterfaceImpl();

  @override
  void setUseCsNervaLoggerInternal(bool enable) =>
      lib_nerva.Logging.useLogger = enable;

  @override
  bool walletExists(String path) => lib_nerva.NervaWallet.isWalletExist(path);

  @override
  Future<int> estimateFee(
    int rate,
    BigInt amount, {
    required WrappedWallet wallet,
  }) {
    lib_nerva.TransactionPriority priority;
    switch (rate) {
      case 1:
        priority = lib_nerva.TransactionPriority.low;
        break;
      case 2:
        priority = lib_nerva.TransactionPriority.medium;
        break;
      case 3:
        priority = lib_nerva.TransactionPriority.high;
        break;
      case 4:
        priority = lib_nerva.TransactionPriority.last;
        break;
      case 0:
      default:
        priority = lib_nerva.TransactionPriority.normal;
        break;
    }

    return wallet.get<lib_nerva.Wallet>().estimateFee(priority, amount.toInt());
  }

  @override
  Future<WrappedWallet> loadWallet(
    String walletId, {
    required String path,
    required String password,
  }) async {
    return WrappedWallet(
      await lib_nerva.NervaWallet.loadWallet(path: path, password: password),
    );
  }

  @override
  int getTxPriorityHigh() => lib_nerva.TransactionPriority.high.value;

  @override
  int getTxPriorityMedium() => lib_nerva.TransactionPriority.medium.value;

  @override
  int getTxPriorityNormal() => lib_nerva.TransactionPriority.normal.value;

  @override
  String getAddress(
    WrappedWallet wallet, {
    int accountIndex = 0,
    int addressIndex = 0,
  }) => wallet
      .get<lib_nerva.Wallet>()
      .getAddress(accountIndex: accountIndex, addressIndex: addressIndex)
      .value;

  @override
  Future<WrappedWallet> getCreatedWallet({
    required String path,
    required String password,
    required int wordCount,
    required String seedOffset,
  }) async {
    // Nerva only supports the standard 25-word Monero mnemonic.
    final type = switch (wordCount) {
      25 => lib_nerva.NervaSeedType.twentyFive,
      _ => throw Exception("Invalid mnemonic word count: $wordCount"),
    };

    final wallet = await lib_nerva.NervaWallet.create(
      path: path,
      password: password,
      seedType: type,
      seedOffset: seedOffset,
    );

    return WrappedWallet(wallet);
  }

  @override
  Future<WrappedWallet> getRestoredWallet({
    required String walletId,

    required String path,
    required String password,
    required String mnemonic,
    required String seedOffset,
    int height = 0,
  }) async {
    return WrappedWallet(
      await lib_nerva.NervaWallet.restoreWalletFromSeed(
        path: path,
        password: password,
        seed: mnemonic,
        restoreHeight: height,
        seedOffset: seedOffset,
      ),
    );
  }

  @override
  Future<WrappedWallet> getRestoredFromViewKeyWallet({
    required String walletId,

    required String path,
    required String password,
    required String address,
    required String privateViewKey,
    int height = 0,
  }) async {
    return WrappedWallet(
      await lib_nerva.NervaWallet.createViewOnlyWallet(
        path: path,
        password: password,
        address: address,
        viewKey: privateViewKey,
        restoreHeight: height,
      ),
    );
  }

  @override
  String getTxKey(WrappedWallet wallet, String txid) =>
      wallet.get<lib_nerva.Wallet>().getTxKey(txid);

  @override
  Future<void> save(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().save();

  @override
  String getPublicViewKey(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().getPublicViewKey();

  @override
  String getPrivateViewKey(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().getPrivateViewKey();

  @override
  String getPublicSpendKey(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().getPublicSpendKey();

  @override
  String getPrivateSpendKey(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().getPrivateSpendKey();

  @override
  Future<bool> isSynced(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().isSynced();

  @override
  void startSyncing(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().startSyncing();

  @override
  void stopSyncing(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().stopSyncing();

  @override
  void startAutoSaving(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().startAutoSaving();

  @override
  void stopAutoSaving(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().stopAutoSaving();

  @override
  bool hasListeners(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().getListeners().isNotEmpty;

  @override
  void addListener(WrappedWallet wallet, CsWalletListener listener) =>
      wallet.get<lib_nerva.Wallet>().addListener(
        lib_nerva.WalletListener(
          onSyncingUpdate: listener.onSyncingUpdate,
          onNewBlock: listener.onNewBlock,
          onBalancesChanged: listener.onBalancesChanged,
          onError: listener.onError,
        ),
      );

  @override
  void startListeners(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().startListeners();

  @override
  void stopListeners(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().stopListeners();

  @override
  int getRefreshFromBlockHeight(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().getRefreshFromBlockHeight();

  @override
  void setRefreshFromBlockHeight(WrappedWallet wallet, int height) =>
      wallet.get<lib_nerva.Wallet>().setRefreshFromBlockHeight(height);

  @override
  Future<bool> rescanBlockchain(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().rescanBlockchain();

  @override
  Future<bool> isConnectedToDaemon(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().isConnectedToDaemon();

  @override
  Future<void> connect(
    WrappedWallet wallet, {
    required String daemonAddress,
    required bool trusted,
    String? daemonUsername,
    String? daemonPassword,
    bool useSSL = false,
    bool isLightWallet = false,
    String? socksProxyAddress,
  }) async {
    await wallet.get<lib_nerva.Wallet>().connect(
      daemonAddress: daemonAddress,
      trusted: trusted,
      daemonUsername: daemonUsername,
      daemonPassword: daemonPassword,
      useSSL: useSSL,
      socksProxyAddress: socksProxyAddress,
      isLightWallet: isLightWallet,
    );
  }

  @override
  Future<List<String>> getAllTxids(
    WrappedWallet wallet, {
    bool refresh = false,
  }) => wallet.get<lib_nerva.Wallet>().getAllTxids(refresh: refresh);

  @override
  BigInt? getBalance(WrappedWallet wallet, {int accountIndex = 0}) =>
      wallet.get<lib_nerva.Wallet>().getBalance(accountIndex: accountIndex);

  @override
  BigInt? getUnlockedBalance(WrappedWallet wallet, {int accountIndex = 0}) =>
      wallet.get<lib_nerva.Wallet>().getUnlockedBalance(
        accountIndex: accountIndex,
      );

  @override
  Future<List<CsTransaction>> getAllTxs(
    WrappedWallet wallet, {
    bool refresh = false,
  }) async {
    final transactions = await wallet.get<lib_nerva.Wallet>().getAllTxs(
      refresh: refresh,
    );
    return transactions
        .map(
          (e) => CsTransaction(
            displayLabel: e.displayLabel,
            description: e.description,
            fee: e.fee,
            confirmations: e.confirmations,
            blockHeight: e.blockHeight,
            accountIndex: e.accountIndex,
            addressIndexes: e.addressIndexes,
            paymentId: e.paymentId,
            amount: e.amount,
            isSpend: e.isSpend,
            hash: e.hash,
            key: e.key,
            timeStamp: e.timeStamp,
            minConfirms: e.minConfirms.value,
          ),
        )
        .toList();
  }

  @override
  Future<List<CsTransaction>> getTxs(
    WrappedWallet wallet, {
    required Set<String> txids,
    bool refresh = false,
  }) async {
    final transactions = await wallet.get<lib_nerva.Wallet>().getTxs(
      txids: txids,
      refresh: refresh,
    );
    return transactions
        .map(
          (e) => CsTransaction(
            displayLabel: e.displayLabel,
            description: e.description,
            fee: e.fee,
            confirmations: e.confirmations,
            blockHeight: e.blockHeight,
            accountIndex: e.accountIndex,
            addressIndexes: e.addressIndexes,
            paymentId: e.paymentId,
            amount: e.amount,
            isSpend: e.isSpend,
            hash: e.hash,
            key: e.key,
            timeStamp: e.timeStamp,
            minConfirms: e.minConfirms.value,
          ),
        )
        .toList();
  }

  @override
  Future<CsPendingTransaction> createTx(
    WrappedWallet wallet, {
    required CsRecipient output,
    required int priority,
    required bool sweep,
    List<StandardInput>? preferredInputs,
    required int accountIndex,
    required int minConfirms,
    required int currentHeight,
  }) async {
    final pending = await wallet.get<lib_nerva.Wallet>().createTx(
      output: lib_nerva.Recipient(
        address: output.address,
        amount: output.amount,
      ),
      paymentId: "",
      sweep: sweep,
      priority: lib_nerva.TransactionPriority.values.firstWhere(
        (e) => e.value == priority,
      ),
      preferredInputs: preferredInputs
          ?.map(
            (e) => lib_nerva.Output(
              address: e.address!,
              hash: e.utxo.txid,
              keyImage: e.utxo.keyImage!,
              value: e.value,
              isFrozen: e.utxo.isBlocked,
              isUnlocked:
                  e.utxo.blockHeight != null &&
                  (currentHeight - (e.utxo.blockHeight ?? 0)) >= minConfirms,
              height: e.utxo.blockHeight ?? 0,
              vout: e.utxo.vout,
              spent: e.utxo.used ?? false,
              spentHeight: null, // doesn't matter here
              coinbase: e.utxo.isCoinbase,
            ),
          )
          .toList(),
      accountIndex: accountIndex,
    );

    return CsPendingTransaction(
      pending,
      pending.amount,
      pending.fee,
      pending.txid,
    );
  }

  @override
  Future<CsPendingTransaction> createTxMultiDest(
    WrappedWallet wallet, {
    required List<CsRecipient> outputs,
    required int priority,
    required bool sweep,
    List<StandardInput>? preferredInputs,
    required int accountIndex,
    required int minConfirms,
    required int currentHeight,
  }) async {
    final pending = await wallet.get<lib_nerva.Wallet>().createTxMultiDest(
      outputs: outputs
          .map((e) => lib_nerva.Recipient(address: e.address, amount: e.amount))
          .toList(),
      paymentId: "",
      sweep: sweep,
      priority: lib_nerva.TransactionPriority.values.firstWhere(
        (e) => e.value == priority,
      ),
      preferredInputs: preferredInputs
          ?.map(
            (e) => lib_nerva.Output(
              address: e.address!,
              hash: e.utxo.txid,
              keyImage: e.utxo.keyImage!,
              value: e.value,
              isFrozen: e.utxo.isBlocked,
              isUnlocked:
                  e.utxo.blockHeight != null &&
                  (currentHeight - (e.utxo.blockHeight ?? 0)) >= minConfirms,
              height: e.utxo.blockHeight ?? 0,
              vout: e.utxo.vout,
              spent: e.utxo.used ?? false,
              spentHeight: null, // doesn't matter here
              coinbase: e.utxo.isCoinbase,
            ),
          )
          .toList(),
      accountIndex: accountIndex,
    );

    return CsPendingTransaction(
      pending,
      pending.amount,
      pending.fee,
      pending.txid,
    );
  }

  @override
  Future<void> commitTx(WrappedWallet wallet, CsPendingTransaction tx) => wallet
      .get<lib_nerva.Wallet>()
      .commitTx(tx.value as lib_nerva.PendingTransaction);

  @override
  Future<List<CsOutput>> getOutputs(
    WrappedWallet wallet, {
    bool refresh = false,
    bool includeSpent = false,
  }) async {
    final outputs = await wallet.get<lib_nerva.Wallet>().getOutputs(
      includeSpent: includeSpent,
      refresh: refresh,
    );

    return outputs
        .map(
          (e) => CsOutput(
            address: e.address,
            hash: e.hash,
            keyImage: e.keyImage,
            value: e.value,
            isFrozen: e.isFrozen,
            isUnlocked: e.isUnlocked,
            height: e.height,
            spentHeight: e.spentHeight,
            vout: e.vout,
            spent: e.spent,
            coinbase: e.coinbase,
          ),
        )
        .toList();
  }

  @override
  Future<void> freezeOutput(WrappedWallet wallet, String keyImage) =>
      wallet.get<lib_nerva.Wallet>().freezeOutput(keyImage);

  @override
  Future<void> thawOutput(WrappedWallet wallet, String keyImage) =>
      wallet.get<lib_nerva.Wallet>().thawOutput(keyImage);

  @override
  List<String> getNervaWordList(String language) =>
      lib_nerva.getNervaWordList(language);

  @override
  int getHeightByDate(DateTime date) =>
      cs_nerva_deprecated.getNervaHeightByDate(date: date);

  @override
  bool validateAddress(String address, int network) =>
      nerva_wallet_ffi.validateAddress(address, network);

  @override
  String getSeed(WrappedWallet wallet) =>
      wallet.get<lib_nerva.Wallet>().getSeed();

  @override
  Future<void> close(WrappedWallet wallet, {bool save = false}) =>
      wallet.get<lib_nerva.Wallet>().close(save: save);
}

//END_ON
