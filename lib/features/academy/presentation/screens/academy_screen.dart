import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../../domain/entities/premium_content.dart';
import '../providers/academy_provider.dart';
import 'pdf_viewer_screen.dart';
import 'product_details_screen.dart';

class AcademyScreen extends ConsumerStatefulWidget {
  const AcademyScreen({super.key});

  @override
  ConsumerState<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends ConsumerState<AcademyScreen> {
  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Ebooks', 'Cours', 'Templates'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(academyProvider.notifier).fetchContents());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academyProvider);

    return PremiumGate(
      title: 'Académie Mony',
      message: 'Activez Mony Premium pour accéder aux ebooks, mini-cours et templates.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Académie Mony'),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.contents.isEmpty
                    ? _buildEmptyState()
                    : _buildContentList(state.contents),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _selectedCategory = cat);
                final type = cat == 'Tous' ? null : cat.toLowerCase().replaceAll('s', '');
                ref.read(academyProvider.notifier).fetchContents(type: type);
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentList(List<PremiumContent> contents) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final content = contents[index];
        return _buildContentCard(content);
      },
    );
  }

  Widget _buildContentCard(PremiumContent content) {
    return InkWell(
      onTap: () => _openContentDetails(content),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: AppColors.primary.withOpacity(0.1),
                  child: content.thumbnailUrl.isNotEmpty
                      ? Image.network(content.thumbnailUrl, fit: BoxFit.cover)
                      : Icon(
                          _getIconForType(content.type),
                          size: 40,
                          color: AppColors.primary,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      content.type.name.toUpperCase(),
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.duration,
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(ContentType type) {
    switch (type) {
      case ContentType.ebook: return Icons.book_rounded;
      case ContentType.course: return Icons.play_circle_fill_rounded;
      case ContentType.template: return Icons.table_chart_rounded;
    }
  }

  void _openContentDetails(PremiumContent content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(content: content),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: Colors.black12),
          SizedBox(height: 16),
          Text('Aucun contenu disponible pour le moment',
              style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}
