import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/premium_content.dart';
import 'pdf_viewer_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final PremiumContent content;
  const ProductDetailsScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: AppColors.primary.withOpacity(0.1),
              child: content.thumbnailUrl.isNotEmpty
                  ? Image.network(content.thumbnailUrl, fit: BoxFit.cover)
                  : const Icon(Icons.menu_book_rounded, size: 100, color: AppColors.primary),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBadge(content.type.name.toUpperCase()),
                      const SizedBox(width: 8),
                      _buildBadge(content.category),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(content.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(content.duration, style: const TextStyle(color: Colors.black38)),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    content.description,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final isPdf = content.type == ContentType.ebook ||
                        content.url.toLowerCase().endsWith('.pdf');
                        if (isPdf) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerScreen(
                                pdfUrl: content.url,
                                title: content.title,
                                pdfId: content.id,
                              ),
                            ),
                          );
                          return;
                        }

                        final url = Uri.parse(content.url);
                        try {
                          // Tentative d'ouverture avec le mode par défaut
                          bool launched = await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );

                          if (!launched && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur : ${e.toString()}')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Lire le contenu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}
