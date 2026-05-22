import 'dart:io';
import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import '../services/theme_service.dart';
import '../widgets/menu_image.dart';

class ManageMenuPage extends StatefulWidget {
  const ManageMenuPage({super.key});
  @override
  State<ManageMenuPage> createState() => _ManageMenuPageState();
}

class _ManageMenuPageState extends State<ManageMenuPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: ThemeColors.scaffold,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showMenuForm(context),
            backgroundColor: const Color(0xFFC2713A),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: SafeArea(
            child: Column(children: [
              _buildAppBar(context),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: MenuService().menuItems,
                  builder: (context, items, child) {
                    if (items.isEmpty) return _buildEmptyState();
                    return _buildMenuList(items);
                  },
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeColors.appBar,
        boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFC2713A), size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Text('Manage Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        const Spacer(),
        GestureDetector(
          onTap: () => _showCategoryManager(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.category_outlined, color: Color(0xFFC2713A), size: 20),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () async {
            await MenuService().refreshMenu();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Menu refreshed!'), behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFFC2713A), duration: Duration(seconds: 1)));
          },
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.refresh_rounded, color: Color(0xFFC2713A), size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFC2713A).withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.restaurant_menu_outlined, size: 48, color: Color(0xFFC2713A))),
        const SizedBox(height: 20),
        Text('No Menu Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeColors.text)),
        const SizedBox(height: 8),
        Text('Tap + to add your first menu item.', style: TextStyle(fontSize: 14, color: ThemeColors.textSecondary)),
      ]),
    );
  }

  Widget _buildMenuList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildMenuCard(items[index]),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key(item['docId'] ?? ''),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _showDeleteConfirm(context, item['name']),
          onDismissed: (_) {
            final docId = item['docId'] as String?;
            if (docId != null) {
              MenuService().deleteMenuItem(docId);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${item['name']} deleted'), behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFFF3B30), duration: const Duration(seconds: 2)));
            }
          },
          background: Container(
            color: const Color(0xFFFF3B30), alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 28)),
          child: GestureDetector(
            onTap: () => _showMenuForm(context, item: item),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ThemeColors.surface, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: ThemeColors.shadow, blurRadius: 10, offset: const Offset(0, 4))]),
              child: Row(children: [
                Container(width: 70, height: 70, padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(14)),
                  child: MenuImage(imagePath: item['image'], fit: BoxFit.contain)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['name'] ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ThemeColors.text),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item['ingredients'] ?? '', style: TextStyle(fontSize: 12, color: ThemeColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC2713A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(item['category'] ?? '',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFC2713A)))),
                    const Spacer(),
                    Text('${item['price']} THB',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFC2713A))),
                  ]),
                ])),
                const SizedBox(width: 8),
                Icon(Icons.edit_outlined, color: ThemeColors.textSecondary, size: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirm(BuildContext context, String name) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Item', style: TextStyle(fontWeight: FontWeight.w700, color: ThemeColors.text)),
        content: Text('Are you sure you want to delete "$name"?',
          style: TextStyle(color: ThemeColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: ThemeColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w600))),
        ],
      ),
    ) ?? false;
  }

  void _showMenuForm(BuildContext context, {Map<String, dynamic>? item}) {
    final isEditing = item != null;
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final priceCtrl = TextEditingController(text: item != null ? '${item['price']}' : '');
    final ingredientsCtrl = TextEditingController(text: item?['ingredients'] ?? '');

    // Category dropdown state
    final cats = MenuService().categoryList.value;
    String selectedCategory = item?['category'] ?? (cats.isNotEmpty ? cats.first : '');

    // Image state: can be asset path, network URL, or local file
    String currentImagePath = item?['image'] ?? MenuService.availableImages.first;
    File? pickedFile;
    bool isUploading = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: BoxDecoration(
              color: ThemeColors.bottomSheet,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Handle bar
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: ThemeColors.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                // Header
                Row(children: [
                  Container(padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2713A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(isEditing ? Icons.edit_outlined : Icons.add_circle_outline,
                      color: const Color(0xFFC2713A), size: 22)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(isEditing ? 'Edit Menu Item' : 'Add Menu Item',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                    const SizedBox(height: 2),
                    Text(isEditing ? 'Update the details below' : 'Fill in the details below',
                      style: TextStyle(fontSize: 12, color: ThemeColors.textSecondary)),
                  ])),
                ]),
                const SizedBox(height: 24),
                // Form fields
                _buildField(nameCtrl, 'Item Name *', Icons.cake_outlined),
                const SizedBox(height: 14),
                _buildField(priceCtrl, 'Price (THB) *', Icons.attach_money, isNumber: true),
                const SizedBox(height: 14),
                _buildField(ingredientsCtrl, 'Ingredients *', Icons.description_outlined),
                const SizedBox(height: 14),
                // Category dropdown
                _buildCategoryDropdown(selectedCategory, (val) => setSheetState(() => selectedCategory = val)),
                const SizedBox(height: 18),

                // Image section
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ThemeColors.textSecondary)),
                  const SizedBox(height: 10),

                  // Current image preview
                  Container(
                    width: double.infinity, height: 120,
                    decoration: BoxDecoration(
                      color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ThemeColors.border)),
                    child: pickedFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(pickedFile!, fit: BoxFit.contain))
                      : MenuImage(imagePath: currentImagePath, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 12),

                  // Upload from phone button
                  SizedBox(width: double.infinity, height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final file = await MenuService().pickImage();
                        if (file != null) {
                          setSheetState(() => pickedFile = file);
                        }
                      },
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Upload from Phone', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC2713A),
                        side: const BorderSide(color: Color(0xFFC2713A)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Or choose from existing assets
                  Text('Or choose from existing:', style: TextStyle(fontSize: 12, color: ThemeColors.textSecondary)),
                  const SizedBox(height: 8),
                  SizedBox(height: 60, child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: MenuService.availableImages.length,
                    itemBuilder: (_, i) {
                      final img = MenuService.availableImages[i];
                      final isSelected = pickedFile == null && img == currentImagePath;
                      return GestureDetector(
                        onTap: () => setSheetState(() {
                          currentImagePath = img;
                          pickedFile = null;
                        }),
                        child: Container(width: 56, height: 56,
                          margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: ThemeColors.iconBg, borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFC2713A) : ThemeColors.border,
                              width: isSelected ? 2.5 : 1)),
                          child: Image.asset(img, fit: BoxFit.contain)),
                      );
                    },
                  )),
                ]),
                const SizedBox(height: 24),

                // Buttons
                Row(children: [
                  Expanded(child: SizedBox(height: 48, child: OutlinedButton(
                    onPressed: isUploading ? null : () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeColors.textSecondary, side: BorderSide(color: ThemeColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ))),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: SizedBox(height: 48, child: ElevatedButton(
                    onPressed: isUploading ? null : () async {
                      // Validate
                      if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty ||
                          ingredientsCtrl.text.trim().isEmpty || selectedCategory.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                          content: Text('Please fill in all required fields'),
                          backgroundColor: Color(0xFFFF3B30), behavior: SnackBarBehavior.floating));
                        return;
                      }
                      final price = int.tryParse(priceCtrl.text.trim());
                      if (price == null || price <= 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                          content: Text('Please enter a valid price'),
                          backgroundColor: Color(0xFFFF3B30), behavior: SnackBarBehavior.floating));
                        return;
                      }

                      String finalImage = currentImagePath;

                      // Upload picked file if any
                      if (pickedFile != null) {
                        setSheetState(() => isUploading = true);
                        final url = await MenuService().uploadImage(pickedFile!);
                        if (url != null) {
                          finalImage = url;
                        } else {
                          setSheetState(() => isUploading = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                              content: Text('Failed to upload image. Please try again.'),
                              backgroundColor: Color(0xFFFF3B30), behavior: SnackBarBehavior.floating));
                          }
                          return;
                        }
                        setSheetState(() => isUploading = false);
                      }

                      String? error;
                      if (isEditing) {
                        error = await MenuService().updateMenuItem(item['docId'],
                          name: nameCtrl.text.trim(), price: price, image: finalImage,
                          ingredients: ingredientsCtrl.text.trim(), category: selectedCategory);
                      } else {
                        error = await MenuService().addMenuItem(
                          name: nameCtrl.text.trim(), price: price, image: finalImage,
                          ingredients: ingredientsCtrl.text.trim(), category: selectedCategory);
                      }
                      if (!ctx.mounted) return;
                      if (error != null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(error),
                          behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFFFF3B30),
                          duration: const Duration(seconds: 3)));
                        return;
                      }
                      Navigator.pop(ctx);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEditing ? 'Menu item updated!' : 'Menu item added!'),
                        behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFFC2713A),
                        duration: const Duration(seconds: 2)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2713A), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: isUploading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEditing ? 'Update' : 'Add Item',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ))),
                ]),
                const SizedBox(height: 8),
              ])),
            ),
          );
        });
      },
    );
  }

  Widget _buildCategoryDropdown(String selected, ValueChanged<String> onChanged) {
    final cats = MenuService().categoryList.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.border, width: 1.2),
      ),
      child: Row(children: [
        Icon(Icons.category_outlined, color: ThemeColors.textSecondary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: cats.contains(selected) ? selected : (cats.isNotEmpty ? cats.first : null),
              hint: Text('Select Category *', style: TextStyle(fontSize: 13, color: ThemeColors.inputHint)),
              isExpanded: true,
              dropdownColor: ThemeColors.dropdownBg,
              style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
              icon: Icon(Icons.keyboard_arrow_down, color: ThemeColors.textSecondary, size: 20),
              items: cats.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              )).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ]),
    );
  }

  void _showCategoryManager(BuildContext context) {
    final addCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
            decoration: BoxDecoration(
              color: ThemeColors.bottomSheet,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Handle bar
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: ThemeColors.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                // Header
                Row(children: [
                  Container(padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2713A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.category_outlined, color: Color(0xFFC2713A), size: 22)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Manage Categories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeColors.text)),
                    const SizedBox(height: 2),
                    Text('Add or remove menu categories',
                      style: TextStyle(fontSize: 12, color: ThemeColors.textSecondary)),
                  ])),
                ]),
                const SizedBox(height: 20),
                // Add category row
                Row(children: [
                  Expanded(child: TextField(
                    controller: addCtrl,
                    style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
                    decoration: InputDecoration(
                      hintText: 'New category name',
                      hintStyle: TextStyle(fontSize: 13, color: ThemeColors.inputHint),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true, fillColor: ThemeColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ThemeColors.border, width: 1.2)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFC2713A), width: 2.0)),
                    ),
                  )),
                  const SizedBox(width: 10),
                  SizedBox(height: 46, child: ElevatedButton(
                    onPressed: () async {
                      final name = addCtrl.text.trim();
                      if (name.isEmpty) return;
                      final error = await MenuService().addCategory(name);
                      if (!ctx.mounted) return;
                      if (error == null) {
                        addCtrl.clear();
                        setSheetState(() {});
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text('"$name" added!'),
                          backgroundColor: const Color(0xFFC2713A), behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1)));
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(error),
                          backgroundColor: const Color(0xFFFF3B30), behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC2713A), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Icon(Icons.add, size: 22),
                  )),
                ]),
                const SizedBox(height: 16),
                // Category list
                Flexible(
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: MenuService().categoryList,
                    builder: (context, cats, child) {
                      if (cats.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('No categories yet', style: TextStyle(color: ThemeColors.textSecondary)));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: cats.length,
                        itemBuilder: (_, i) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: ThemeColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ThemeColors.border)),
                            child: Row(children: [
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFC2713A), shape: BoxShape.circle)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(cats[i],
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ThemeColors.text))),
                              GestureDetector(
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                    context: ctx,
                                    builder: (d) => AlertDialog(
                                      backgroundColor: ThemeColors.surface,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w700, color: ThemeColors.text)),
                                      content: Text('Delete "${cats[i]}"? Menu items in this category will not be deleted.',
                                        style: TextStyle(color: ThemeColors.textSecondary)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(d, false),
                                          child: Text('Cancel', style: TextStyle(color: ThemeColors.textSecondary))),
                                        TextButton(onPressed: () => Navigator.pop(d, true),
                                          child: const Text('Delete', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w600))),
                                      ],
                                    ),
                                  ) ?? false;
                                  if (confirm) {
                                    await MenuService().deleteCategory(cats[i]);
                                    setSheetState(() {});
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.delete_outline, color: Color(0xFFFF3B30), size: 18)),
                              ),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          );
        });
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(fontSize: 14, color: ThemeColors.inputText),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(fontSize: 13, color: ThemeColors.inputHint),
        prefixIcon: Icon(icon, color: ThemeColors.textSecondary, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true, fillColor: ThemeColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: ThemeColors.border, width: 1.2)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC2713A), width: 2.0)),
      ),
    );
  }
}
