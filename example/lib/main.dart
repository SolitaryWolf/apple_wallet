import 'package:flutter/material.dart';
import 'package:apple_wallet/apple_wallet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Wallet Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AppleWalletExample(),
    );
  }
}

class AppleWalletExample extends StatefulWidget {
  const AppleWalletExample({super.key});

  @override
  State<AppleWalletExample> createState() => _AppleWalletExampleState();
}

class _AppleWalletExampleState extends State<AppleWalletExample> {
  bool _isPassKitAvailable = false;
  bool _canAddPasses = false;
  List<PaymentPass> _paymentPasses = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPassKitAvailability();
    _loadPaymentPasses();
    _listenToPassLibraryChanges();
  }

  Future<void> _checkPassKitAvailability() async {
    try {
      final isAvailable = await AppleWallet.isPassKitAvailable;
      final canAdd = await AppleWallet.canAddPasses;

      setState(() {
        _isPassKitAvailable = isAvailable;
        _canAddPasses = canAdd;
        _statusMessage = 'PassKit Available: $isAvailable, Can Add Passes: $canAdd';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking PassKit availability: $e';
      });
    }
  }

  Future<void> _loadPaymentPasses() async {
    try {
      final passes = await AppleWallet.getPaymentPasses();
      setState(() {
        _paymentPasses = passes;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading payment passes: $e';
      });
    }
  }

  void _listenToPassLibraryChanges() {
    AppleWallet.passLibraryChanges.listen((change) {
      setState(() {
        _statusMessage = 'Pass library changed: ${change.type} - ${change.passTypeIdentifier}';
      });
      _loadPaymentPasses(); // Reload passes when library changes
    });
  }

  PaymentPassRequest _createSamplePaymentPassRequest() {
    return const PaymentPassRequest(
      cardholderName: 'VU BAT TAT DAT',
      primaryAccountSuffix: '0492',
      localizedDescription: 'HomeCredit Card',
      paymentNetwork: PaymentNetwork.visa,
      encryptedPassData: {
        'version': '1',
        'data': 'encrypted_pass_data_here',
        'signature': 'signature_here',
        'header': 'header_data_here',
      },
      activationData: 'activation_data_here',
      wrappingKeyHash: 'wrapping_key_hash_here',
      metadata: {'issuer': 'Sample Bank', 'cardType': 'Credit'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Wallet Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PassKit Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('PassKit Available: $_isPassKitAvailable'),
                    Text('Can Add Passes: $_canAddPasses'),
                    const SizedBox(height: 8),
                    Text(_statusMessage, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_canAddPasses) ...[
              const Text('Add Payment Pass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              AddToAppleWalletButton(
                paymentPassRequest: _createSamplePaymentPassRequest(),
                style: AddToAppleWalletButtonStyle.whiteOutline,
                onSuccess: (result) {
                  setState(() {
                    _statusMessage = 'Successfully added payment pass: $result';
                  });
                  _loadPaymentPasses();

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Payment pass added successfully!')));
                },
                onError: (error) {
                  setState(() {
                    _statusMessage = 'Error adding payment pass: ${error.message}';
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${error.message}')));
                },
                margin: const EdgeInsets.symmetric(vertical: 8.0),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Payment Passes in Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _paymentPasses.isEmpty
                  ? const Center(
                      child: Text('No payment passes found in wallet', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: _paymentPasses.length,
                      itemBuilder: (context, index) {
                        final pass = _paymentPasses[index];
                        return Card(
                          child: ListTile(
                            title: Text(pass.localizedDescription),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Organization: ${pass.organizationName}'),
                                Text('Serial: ${pass.serialNumber}'),
                                Text('Status: ${pass.isActivated ? 'Activated' : 'Not Activated'}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  final removed = await AppleWallet.removePaymentPass(pass.passTypeIdentifier);
                                  if (removed) {
                                    setState(() {
                                      _statusMessage = 'Removed payment pass: ${pass.localizedDescription}';
                                    });
                                    _loadPaymentPasses();
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(const SnackBar(content: Text('Payment pass removed')));
                                  } else {
                                    setState(() {
                                      _statusMessage = 'Failed to remove payment pass';
                                    });
                                  }
                                } catch (e) {
                                  setState(() {
                                    _statusMessage = 'Error removing payment pass: $e';
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loadPaymentPasses, child: const Text('Refresh Payment Passes')),
          ],
        ),
      ),
    );
  }
}
