import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // untuk format IDR

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random _random = Random();
  late Timer _timer;

  double initialCash = 5000.0;
  double totalInvestment = 15000.0;
  double cash = 5000.0;
  String searchQuery = '';

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final List<String> bankList = [
    "Bank BCA",
    "Bank Mandiri",
    "Bank BRI",
    "Bank BNI",
    "Bank CIMB Niaga"
  ];

  final List<Map<String, dynamic>> cryptos = [
    {'name': 'Bitcoin', 'symbol': 'BTC', 'price': 98313.87, 'previousPrice': 98313.87, 'image': 'assets/images/btc.jpg'},
    {'name': 'Ethereum', 'symbol': 'ETH', 'price': 5059.18, 'previousPrice': 5059.18, 'image': 'assets/images/ethereum.jpg'},
    {'name': 'Solana', 'symbol': 'SOL', 'price': 164.88, 'previousPrice': 164.88, 'image': 'assets/images/solana.jpg'},
    {'name': 'Dogecoin', 'symbol': 'DOGE', 'price': 19.21, 'previousPrice': 19.21, 'image': 'assets/images/doge.jpg'},
    {'name': 'Cardano', 'symbol': 'ADA', 'price': 12.72, 'previousPrice': 12.72, 'image': 'assets/images/cardano.jpg'},
    {'name': 'Avalanche', 'symbol': 'AVAX', 'price': 88.50, 'previousPrice': 88.50, 'image': 'assets/images/avalanche.jpg'},
    {'name': 'Polkadot', 'symbol': 'DOT', 'price': 35.20, 'previousPrice': 35.20, 'image': 'assets/images/polkadot.jpg'},
    {'name': 'XRP', 'symbol': 'XRP', 'price': 1.05, 'previousPrice': 1.05, 'image': 'assets/images/xrp.jpg'},
    {'name': 'Shiba Inu', 'symbol': 'SHIB', 'price': 0.000028, 'previousPrice': 0.000028, 'image': 'assets/images/shiba.jpg'},
    {'name': 'Litecoin', 'symbol': 'LTC', 'price': 185.75, 'previousPrice': 185.75, 'image': 'assets/images/litecoin.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _startPriceFluctuation();
  }

  void _startPriceFluctuation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        for (var crypto in cryptos) {
          crypto['previousPrice'] = crypto['price'];
          double changePercent = (_random.nextDouble() * 2 - 1) * 0.02; // ±2%
          crypto['price'] =
              (crypto['price'] * (1 + changePercent)).clamp(0, double.infinity);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ============================
  // FUNGSI BELI / JUAL CRYPTO
  // ============================
  void _showTransactionDialog(Map<String, dynamic> crypto, bool isBuying) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue.shade50,
        title: Text('${isBuying ? "Beli" : "Jual"} ${crypto['name']}',
            style: TextStyle(color: Colors.blue.shade900)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.blue.shade900),
          decoration: InputDecoration(
            labelText: "Masukkan jumlah",
            labelStyle: TextStyle(color: Colors.blue.shade400),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: Colors.blue.shade700))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: isBuying ? Colors.green.shade400 : Colors.red.shade400),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final total = amount * crypto['price'];
                setState(() {
                  if (isBuying && cash >= total) {
                    totalInvestment += total;
                    cash -= total;
                  } else if (!isBuying) {
                    totalInvestment -= total;
                    cash += total;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${isBuying ? "Berhasil membeli" : "Berhasil menjual"} $amount ${crypto['symbol']} senilai ${currencyFormat.format(total)}'),
                  backgroundColor: isBuying ? Colors.green : Colors.red,
                ));
              }
            },
            child: Text(isBuying ? "Beli" : "Jual"),
          ),
        ],
      ),
    );
  }

  // ============================
  // FUNGSI DEPOSIT UANG
  // ============================
  void _showDepositDialog() {
    String? selectedBank;
    final TextEditingController amountController = TextEditingController();
    final TextEditingController accountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          backgroundColor: Colors.blue.shade50,
          title: Text("Deposit Uang", style: TextStyle(color: Colors.blue.shade900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: Colors.blue.shade100,
                value: selectedBank,
                items: bankList
                    .map((bank) => DropdownMenuItem(
                        value: bank,
                        child: Text(bank,
                            style: TextStyle(color: Colors.blue.shade900))))
                    .toList(),
                onChanged: (value) => setInnerState(() => selectedBank = value),
                decoration: InputDecoration(labelText: "Pilih Bank"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Masukkan No. Rekening"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Masukkan jumlah deposit"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade400),
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0 && selectedBank != null) {
                  setState(() => cash += amount);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Deposit sebesar ${currencyFormat.format(amount)} melalui $selectedBank berhasil.'),
                    backgroundColor: Colors.green,
                  ));
                }
              },
              child: const Text("Deposit"),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // FITUR KIRIM UANG (TRANSFER)
  // ============================
  void _showSendDialog() {
    final TextEditingController accountController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue.shade50,
        title: Text("Kirim Uang", style: TextStyle(color: Colors.blue.shade900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: accountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Masukkan No. Rekening Tujuan"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah yang dikirim"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: Colors.blue.shade700))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              final account = accountController.text;

              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Jumlah tidak valid"), backgroundColor: Colors.red),
                );
                return;
              }

              if (account.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Nomor rekening tidak boleh kosong"),
                      backgroundColor: Colors.red),
                );
                return;
              }

              if (cash < amount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Saldo tidak cukup"), backgroundColor: Colors.red),
                );
                return;
              }

              setState(() => cash -= amount);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Berhasil mengirim ${currencyFormat.format(amount)} ke rekening $account'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }

  // ============================
  // UI UTAMA
  // ============================
  @override
  Widget build(BuildContext context) {
    final filteredCryptos = cryptos
        .where((crypto) =>
            crypto['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            crypto['symbol'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.jpg'),
              radius: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari crypto...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.blue.shade500.withOpacity(0.2),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
      ),

      // ============================
      // BODY
      // ============================
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ===================== TOTAL INVESTASI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Investasi',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(currencyFormat.format(totalInvestment),
                              style: TextStyle(
                                  color: Colors.yellow.shade600,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            'Return: ${currencyFormat.format(totalInvestment - initialCash)}',
                            style: TextStyle(
                              color: (totalInvestment - initialCash) >= 0
                                  ? Colors.green
                                  : Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // ===================== SALDO CASH
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Saldo Uang Tunai',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(currencyFormat.format(cash),
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===================== BUTTON DEPOSIT + KIRIM
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showDepositDialog,
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text("Deposit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _showSendDialog,
                        icon: const Icon(Icons.upload),
                        label: const Text("Kirim"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ============================
          // LIST CRYPTO
          // ============================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredCryptos.length,
              itemBuilder: (context, index) {
                final crypto = filteredCryptos[index];
                final bool isUp = crypto['price'] >= crypto['previousPrice'];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 6,
                  shadowColor: Colors.blue.shade200.withOpacity(0.5),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.yellow.shade600.withOpacity(0.5), width: 1.2),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(crypto['image']),
                        backgroundColor: Colors.transparent,
                      ),
                      title: Text(crypto['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow.shade600,
                              fontSize: 16)),
                      subtitle: Text(crypto['symbol'],
                          style: TextStyle(color: Colors.blue.shade900)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currencyFormat.format(crypto['price']),
                            style: TextStyle(
                              color: isUp ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _showTransactionDialog(crypto, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade400,
                                  minimumSize: const Size(50, 32),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                ),
                                child: const Text("Beli", style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () =>
                                    _showTransactionDialog(crypto, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  minimumSize: const Size(50, 32),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                ),
                                child: const Text("Jual", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
