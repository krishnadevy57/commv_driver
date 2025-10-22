import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('OrderDetails', style: textTheme.titleLarge),
        leading: const BackButton(),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
        foregroundColor: theme.appBarTheme.iconTheme?.color,
      ),
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(textTheme, colorScheme),
                const Divider(height: 32),
                _buildLocationSection(
                  context,
                  'Pickup Location',
                  'Guwahati Railway Station Platform Overbridge, Paltan Bazaar, Guwahati, Assam 781001, India',
                  'Ggg',
                  '147852',
                  'Hshs',
                  '1478523698',
                ),
                const SizedBox(height: 16),
                _buildLocationSection(
                  context,
                  'Drop Location',
                  'Borjhar, Guwahati, Assam 781015, India',
                  'Gggg',
                  '147852',
                  'Test',
                  '1478523698',
                ),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Package Type:', 'Textile / Garments / Fashion Accessories'),
                _buildDetailRow(context, 'Vehicle:', '2 Wheeler1'),
                _buildDetailRow(context, 'Weight:', '20 kg'),
                _buildDetailRow(context, 'Price:', '₹10'),
                _buildDetailRow(context, 'Distance:', '18.32 km'),
                _buildDetailRow(context, 'Approx Total:', '₹183.20'),
                _buildDetailRow(context, 'Total Price:', '₹183.20'),
                _buildDetailRow(context, 'Payment Method:', 'Online'),
                _buildDetailRow(context, 'Status:', 'Success', statusColor: Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order ID: 100',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '25 Aug 2024',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildLocationSection(
      BuildContext context,
      String title,
      String address,
      String building,
      String pin,
      String name,
      String mobile,
      ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(address, style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        _buildDetailRow(context, 'House/Building:', building),
        _buildDetailRow(context, 'Pin Code:', pin),
        _buildDetailRow(context, 'Name:', name),
        _buildDetailRow(context, 'Mobile:', mobile),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {Color? statusColor}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: value,
              style: textTheme.bodyMedium?.copyWith(
                color: statusColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}