import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double walletBalance = 1200.00;
  Map<String, String>? bankDetail;
  List<Map<String, dynamic>> transferHistory = [];

  void _showTransferDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer to Bank'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '₹',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.secondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0 && amount <= walletBalance && bankDetail != null) {
                transferHistory.insert(0, {
                  'amount': amount,
                  'date': DateTime.now(),
                  'status': 'failed',
                  'reason': 'Bank server error',
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('₹$amount transferred to bank')),
                );
              }
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  void _showBankDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountController = TextEditingController(text: bankDetail?['account'] ?? '');
    final ifscController = TextEditingController(text: bankDetail?['ifsc'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bankDetail == null ? 'Add Bank Detail' : 'Update Bank Detail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: accountController,
              decoration: const InputDecoration(labelText: 'Account Number'),
            ),
            TextField(
              controller: ifscController,
              decoration: const InputDecoration(labelText: 'IFSC Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colorScheme.secondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: () {
              if (accountController.text.isNotEmpty && ifscController.text.isNotEmpty) {
                setState(() {
                  bankDetail = {
                    'account': accountController.text,
                    'ifsc': ifscController.text,
                  };
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bank detail updated')),
                );
              }
            },
            child: Text(bankDetail == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      // appBar: AppBar(
      //   title: const Text('Wallet'),
      //   backgroundColor: theme.appBarTheme.backgroundColor ?? colorScheme.surface,
      //   elevation: theme.appBarTheme.elevation,
      //   iconTheme: theme.appBarTheme.iconTheme,
      //   foregroundColor: theme.appBarTheme.iconTheme?.color,
      // ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Available Fund',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${walletBalance.toStringAsFixed(2)}',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: colorScheme.surface,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: ListTile(
                  title: Text(
                    bankDetail == null
                        ? 'No bank detail added'
                        : 'Account: ${bankDetail!['account']}\nIFSC: ${bankDetail!['ifsc']}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                    ),
                    icon: Icon(bankDetail == null ? Icons.add : Icons.edit),
                    label: Text(bankDetail == null ? 'Add Bank' : 'Update Bank'),
                    onPressed: _showBankDialog,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                icon: const Icon(Icons.account_balance),
                label: const Text('Transfer to Bank'),
                onPressed: bankDetail == null ? null : _showTransferDialog,
              ),
              const SizedBox(height: 32),
              Text(
                'Transfer History',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              transferHistory.isEmpty
                  ? Text('No transfers yet', style: theme.textTheme.bodyMedium)
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transferHistory.length,
                itemBuilder: (context, index) {
                  final item = transferHistory[index];
                  final date = item['date'] as DateTime;
                  final status = item['status'] ?? 'requested';
                  final reason = item['reason'];
                  Color statusColor;
                  switch (status) {
                    case 'completed':
                      statusColor = Colors.green;
                      break;
                    case 'pending':
                      statusColor = Colors.orange;
                      break;
                    case 'canceled':
                      statusColor = Colors.grey;
                      break;
                    case 'failed':
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.blue;
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz, color: statusColor),
                      title: Text('₹${item['amount'].toStringAsFixed(2)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Status: $status${status == 'failed' && reason != null ? ' ($reason)' : ''}',
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}