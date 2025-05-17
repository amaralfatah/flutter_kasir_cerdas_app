import 'package:flutter/material.dart';

class PriceTypeScreen extends StatefulWidget {
  const PriceTypeScreen({super.key});

  @override
  State<PriceTypeScreen> createState() => _PriceTypeScreenState();
}

class _PriceTypeScreenState extends State<PriceTypeScreen> {
  final _nameController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _priceController = TextEditingController();

  // Example list to store tiers (would normally be passed in)
  final List<Map<String, dynamic>> _tiers = [
    {'quantity': 3, 'price': 4800},
    {'quantity': 5, 'price': 4700},
    {'quantity': 10, 'price': 4600},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _basePriceController.dispose();
    _minQuantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addTier() {
    if (_minQuantityController.text.isEmpty || _priceController.text.isEmpty) {
      return;
    }

    final quantity = int.tryParse(_minQuantityController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (quantity <= 0 || price <= 0) {
      // Show snackbar with error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid quantity and price'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _tiers.add({'quantity': quantity, 'price': price});
      _minQuantityController.clear();
      _priceController.clear();
    });
  }

  void _removeTier(int index) {
    setState(() {
      _tiers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Add Price Type',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: colorScheme.surfaceTint,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main price type info
              _buildTextField(
                controller: _nameController,
                label: 'Price Type Name',
                hint: 'e.g. Agent, Wholesaler, Retail',
                icon: Icons.label_outline,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _basePriceController,
                label: 'Base Price (1 pcs)',
                hint: 'Enter price for single item',
                keyboardType: TextInputType.number,
                prefix: 'Rp',
                icon: Icons.attach_money,
              ),
              const SizedBox(height: 24),

              // Wholesale price section header
              Card(
                color: colorScheme.secondaryContainer,
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.price_change_outlined,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WHOLESALE PRICE TIERS',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Add new tier input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Price Tier',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _minQuantityController,
                            label: 'Min Quantity',
                            hint: '3',
                            keyboardType: TextInputType.number,
                            icon: Icons.format_list_numbered,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Price',
                            hint: '4800',
                            keyboardType: TextInputType.number,
                            prefix: 'Rp',
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _addTier,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add),
                          const SizedBox(width: 8),
                          Text('Add Tier'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // List of tiers
              if (_tiers.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'QUANTITY',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'PRICE',
                                style: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 48), // Space for delete button
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Tier list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tiers.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tier = _tiers[index];
                          return Dismissible(
                            key: Key('tier_${index}_${tier['quantity']}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: colorScheme.errorContainer,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.delete,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                            onDismissed: (direction) {
                              _removeTier(index);
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.tertiaryContainer,
                                child: Text(
                                  '${tier['quantity']}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Rp ${tier['price']}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: colorScheme.error,
                                ),
                                onPressed: () => _removeTier(index),
                                tooltip: 'Remove tier',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Information text
              Card(
                elevation: 0,
                color: colorScheme.secondaryContainer.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.onSecondaryContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How wholesale pricing works',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The system will automatically apply the appropriate price based on the quantity purchased. For example, if a customer buys 5 items, they will get the price tier for quantities of 5 or more.',
                        style: textTheme.bodyMedium?.copyWith(
                          color:
                              colorScheme.onSecondaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: () {
              // Save the price type and close
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'SAVE',
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            prefixIcon: icon != null
                ? Icon(icon, color: colorScheme.onSurfaceVariant)
                : null,
            prefixText: prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: keyboardType,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}
