// lib/features/category/presentation/widgets/add_category_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  final TransactionType type;
  final Category? category;

  const AddCategoryDialog({
    super.key,
    required this.type,
    this.category,
  });

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  IconData _selectedIcon = Icons.category;
  Color _selectedColor = AppColors.categoryColors[0];
  bool _isLoading = false;

  // Available Icons
  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.directions_car,
    Icons.home,
    Icons.flight,
    Icons.movie,
    Icons.fitness_center,
    Icons.medical_services,
    Icons.school,
    Icons.work,
    Icons.sports_esports,
    Icons.pets,
    Icons.child_care,
    Icons.local_cafe,
    Icons.shopping_cart,
    Icons.phone,
    Icons.laptop,
    Icons.music_note,
    Icons.brush,
    Icons.attach_money,
    Icons.trending_up,
    Icons.savings,
    Icons.card_giftcard,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEdit ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Preview
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _selectedIcon,
                      color: _selectedColor,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la catégorie',
                    hintText: 'Ex: Courses, Restaurant...',
                  ),
                  maxLength: 20,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est requis';
                    }
                    if (value.length < 2) {
                      return 'Minimum 2 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Icon Selection
                Text(
                  'Icône',
                  style: AppTypography.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = icon == _selectedIcon;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _selectedColor.withOpacity(0.1)
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? _selectedColor
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? _selectedColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Color Selection
                Text(
                  'Couleur',
                  style: AppTypography.textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppColors.categoryColors.map((color) {
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: ButtonStyle(
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        label: isEdit ? 'Mettre à jour' : 'Créer',
                        onPressed: _saveCategory,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final category = Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      type: widget.type,
      icon: _selectedIcon,
      color: _selectedColor,
      isDefault: widget.category?.isDefault ?? false,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
    );

    final notifier = ref.read(categoryProvider.notifier);
    final success = widget.category != null
        ? await notifier.updateCategory(category)
        : await notifier.addCategory(category);

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? widget.category != null
                  ? 'Catégorie mise à jour'
                  : 'Catégorie créée'
              : 'Une erreur s\'est produite',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}
