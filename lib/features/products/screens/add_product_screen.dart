import 'package:flutter/material.dart';

import '../widgets/price_type_dialog.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Product',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: _buildImageUpload(context),
              ),
              const SizedBox(height: 24),

              // Product Name
              _buildTextField(
                context: context,
                label: 'Product Name',
                hint: 'Enter product name',
                prefixIcon: Icons.inventory_2_outlined,
                required: true,
              ),
              const SizedBox(height: 16),

              // Item Type
              _buildDropdownField(
                context: context,
                label: 'Item Type',
                value: 'Default',
                options: const ['Default', 'Service', 'Custom'],
              ),
              const SizedBox(height: 16),

              // Stock Options
              Row(
                children: [
                  _buildSwitch(
                    context: context,
                    label: 'Using stock',
                    value: true,
                  ),
                  const SizedBox(width: 24),
                  _buildSwitch(
                    context: context,
                    label: 'Show in transactions',
                    value: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock and Barcode
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Stock',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Barcode',
                      hint: 'Scan or enter code',
                      suffixIcon: Icons.qr_code_scanner,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prices
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Basic Price',
                      hint: 'Rp',
                      keyboardType: TextInputType.number,
                      required: true,
                      prefixText: 'Rp',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Selling Price',
                      hint: 'Rp',
                      keyboardType: TextInputType.number,
                      required: true,
                      prefixText: 'Rp',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category
              _buildDropdownField(
                context: context,
                label: 'Category',
                hint: 'Select category',
                trailingIcon: Icons.add_circle_outline,
                onTrailingTap: () {
                  // Add category action
                },
              ),
              const SizedBox(height: 16),

              // Weight and Unit
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Weight',
                      hint: 'Weight',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Unit',
                      hint: 'gram, pcs, etc.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Discount and Rack Placement
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Discount (%)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      suffixText: '%',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      context: context,
                      label: 'Rack Placement',
                      hint: 'A1, B2, etc.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Information
              _buildTextField(
                context: context,
                label: 'Information',
                hint: 'Additional information',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Price Types Section
              if (_buildPriceTypesList(context).isNotEmpty) ...[
                _buildSectionTitle(context, 'Price Type List'),
                const SizedBox(height: 16),
                ..._buildPriceTypesList(context),
                const SizedBox(height: 16),
              ],

              // Add Price Type Button
              FilledButton.tonal(
                onPressed: () => _showPriceTypeScreen(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(
                      'Add Price Type',
                      style: textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              FilledButton(
                onPressed: () {
                  // Save product
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
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Add image action
        },
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 36,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Image',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.add_a_photo,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    String? hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
    String? prefixText,
    String? suffixText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant) : null,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: colorScheme.onSurfaceVariant) : null,
            prefixText: prefixText,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
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
          maxLines: maxLines,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    String? value,
    List<String>? options,
    String? hint,
    IconData? trailingIcon,
    VoidCallback? onTrailingTap,
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Show dropdown
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? hint ?? 'Select an option',
                      style: textTheme.bodyLarge?.copyWith(
                        color: value != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    IconButton(
                      icon: Icon(trailingIcon, color: colorScheme.primary),
                      onPressed: onTrailingTap,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                        backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required BuildContext context,
    required String label,
    required bool value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Switch(
          value: value,
          onChanged: (newValue) {
            // Update state
          },
          activeColor: colorScheme.primary,
          activeTrackColor: colorScheme.primaryContainer,
        ),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _buildPriceTypesList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Example price types
    final priceTypes = [
      {
        'name': 'Agent',
        'tiers': [
          {'quantity': 1, 'price': 4500},
          {'quantity': 3, 'price': 4400},
        ]
      },
      {
        'name': 'Warung',
        'tiers': [
          {'quantity': 1, 'price': 4900},
          {'quantity': 3, 'price': 4800},
          {'quantity': 5, 'price': 4700},
          {'quantity': 10, 'price': 4600},
        ]
      },
    ];

    if (priceTypes.isEmpty) {
      return [];
    }

    return priceTypes.map((priceType) {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        color: colorScheme.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Type: ${priceType['name']}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        onPressed: () {},
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.errorContainer.withOpacity(0.5),
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
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (priceType['tiers'] as List).length,
              itemBuilder: (context, index) {
                final tier = (priceType['tiers'] as List)[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      '${tier['quantity']}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Rp ${tier['price']}',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                    ),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showPriceTypeScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (BuildContext context) => const PriceTypeScreen(),
      ),
    );
  }
}