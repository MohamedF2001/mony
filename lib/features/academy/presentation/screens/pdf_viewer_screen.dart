/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/constants/app_colors.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String title;
  final String? pdfId;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.pdfId,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late Future<File> _pdfFileFuture;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('[PdfViewer] pdfUrl reçu : ${widget.pdfUrl}');
  print('[PdfViewer] pdfId reçu : ${widget.pdfId}');
    _pdfFileFuture = _downloadAndSavePdf();
  }

  Future<File> _downloadAndSavePdf() async {
    final apiClient = ref.read(apiClientProvider);
    final safeName = widget.title.replaceAll(RegExp(r'[^\w\s-]'), '');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$safeName.pdf');

    // ── Stratégie 1 : endpoint backend /api/pdfs/:id/download (pour PDFs protégés) ──
    if (widget.pdfId != null && widget.pdfId!.isNotEmpty) {
      try {
        debugPrint('[PdfViewer] Téléchargement via backend → /api/pdfs/${widget.pdfId}/download');

        final response = await apiClient.dio.get(
          '/api/pdfs/${widget.pdfId}/download',
          options: Options(
            receiveTimeout: const Duration(seconds: 60),
          ),
        );

        if (response.statusCode == 200) {
          // Check if response is JSON with downloadUrl
          if (response.data is Map && response.data['data'] != null) {
            final downloadUrl = response.data['data']['downloadUrl'] as String?;
            if (downloadUrl != null) {
              debugPrint('[PdfViewer] URL signée reçue: $downloadUrl');
              
              // Add .pdf extension if missing to the signed URL
              String finalUrl = downloadUrl;
              if (!downloadUrl.toLowerCase().endsWith('.pdf')) {
                final uri = Uri.parse(downloadUrl);
                final path = uri.path.endsWith('.pdf') ? uri.path : '${uri.path}.pdf';
                finalUrl = uri.replace(path: path).toString();
                debugPrint('[PdfViewer] URL signée avec .pdf: $finalUrl');
              }
              
              // Download from signed URL
              final dio = Dio(BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 60),
              ));
              
              final pdfResponse = await dio.get<List<int>>(
                finalUrl,
                options: Options(responseType: ResponseType.bytes),
              );
              
              if (pdfResponse.statusCode == 200 && pdfResponse.data != null) {
                await file.writeAsBytes(pdfResponse.data!);
                debugPrint('[PdfViewer] PDF téléchargé via URL signée');
                return file;
              }
            }
          }
          // If response is bytes directly (unlikely but possible)
          else if (response.data is List) {
            await file.writeAsBytes(response.data as List<int>);
            debugPrint('[PdfViewer] PDF téléchargé via backend (bytes)');
            return file;
          }
        }
      } on DioException catch (e) {
        debugPrint('[PdfViewer] Backend endpoint failed: ${e.response?.statusCode}, trying direct URL');
      } catch (e) {
        debugPrint('[PdfViewer] Backend error: $e, trying direct URL');
      }
    }

    // ── Stratégie 2 : URL directe sans auth (pour PDFs publics Cloudinary) ──
    try {
      debugPrint('[PdfViewer] Téléchargement direct → ${widget.pdfUrl}');
      
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ));

      final response = await dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        debugPrint('[PdfViewer] PDF téléchargé via URL directe');
        return file;
      }
    } on DioException catch (e) {
      debugPrint('[PdfViewer] Direct URL failed: ${e.response?.statusCode}');
    }

    // ── Stratégie 3 : URL directe avec auth (dernier recours) ──
    try {
      debugPrint('[PdfViewer] Téléchargement avec auth → ${widget.pdfUrl}');
      
      final response = await apiClient.dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        debugPrint('[PdfViewer] PDF téléchargé avec auth');
        return file;
      }
    } catch (e) {
      debugPrint('[PdfViewer] Auth download failed: $e');
    }

    throw Exception('Impossible de télécharger le PDF. Le fichier est probablement protégé sur Cloudinary.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<File>(
        future: _pdfFileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Chargement du document…'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger le PDF',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _pdfFileFuture = _downloadAndSavePdf();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée PDF disponible'));
          }

          return Stack(
            children: [
              PDFView(
                filePath: snapshot.data!.path,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: _currentPage,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation: false,
                onRender: (pages) {
                  setState(() {
                    _totalPages = pages!;
                    _isLoading = false;
                  });
                },
                onError: (error) {
                  debugPrint('[PdfViewer] Erreur rendu : $error');
                  setState(() => _isLoading = false);
                },
                onPageError: (page, error) {
                  debugPrint('[PdfViewer] Erreur page $page : $error');
                  setState(() => _isLoading = false);
                },
                onViewCreated: (PDFViewController controller) {},
                onPageChanged: (page, total) {
                  setState(() => _currentPage = page!);
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              // Indicateur de progression de page
              if (!_isLoading && _totalPages > 0)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Page ${_currentPage + 1} / $_totalPages',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
*/


/*
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Provider : pages rasterisées ────────────────────────────────────────────

final pdfPagesProvider = FutureProvider.family<List<Uint8List>, String>(
      (ref, pdfPath) async {
    final document = await PdfDocument.openFile(pdfPath);
    final pages = <Uint8List>[];

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
      );
      await page.close();
      if (pageImage?.bytes != null) {
        pages.add(pageImage!.bytes);
      }
    }

    await document.close();
    return pages;
  },
);

// ─── Écran principal ──────────────────────────────────────────────────────────

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String title;
  final String? pdfId;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.pdfId,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late Future<String> _pdfPathFuture;

  @override
  void initState() {
    super.initState();
    _pdfPathFuture = _downloadAndSavePdf();
  }

  Future<String> _downloadAndSavePdf() async {
    final apiClient = ref.read(apiClientProvider);
    final safeName = widget.title.replaceAll(RegExp(r'[^\w\s-]'), '');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$safeName.pdf');

    if (widget.pdfId != null && widget.pdfId!.isNotEmpty) {
      try {
        final response = await apiClient.dio.get(
          '/api/pdfs/${widget.pdfId}/download',
          options: Options(receiveTimeout: const Duration(seconds: 60)),
        );
        if (response.statusCode == 200 &&
            response.data is Map &&
            response.data['data'] != null) {
          final downloadUrl = response.data['data']['downloadUrl'] as String?;
          if (downloadUrl != null) {
            final dio = Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
            ));
            final pdfResponse = await dio.get<List<int>>(
              downloadUrl,
              options: Options(responseType: ResponseType.bytes),
            );
            if (pdfResponse.statusCode == 200 && pdfResponse.data != null) {
              await file.writeAsBytes(pdfResponse.data!);
              return file.path;
            }
          }
        }
      } catch (_) {}
    }

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ));
      final response = await dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        return file.path;
      }
    } catch (_) {}

    try {
      final response = await apiClient.dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        return file.path;
      }
    } catch (_) {}

    throw Exception('Impossible de télécharger le PDF.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2416),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1A1509),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _pdfPathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView(message: 'Téléchargement du document…');
          }
          if (snapshot.hasError) {
            return _ErrorView(
              error: '${snapshot.error}',
              onRetry: () => setState(() {
                _pdfPathFuture = _downloadAndSavePdf();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          return _BookRenderer(pdfPath: snapshot.data!);
        },
      ),
    );
  }
}

// ─── Renderer : attend la rasterisation puis affiche le livre ─────────────────

class _BookRenderer extends ConsumerWidget {
  final String pdfPath;
  const _BookRenderer({required this.pdfPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(pdfPagesProvider(pdfPath));

    return pagesAsync.when(
      loading: () => const _LoadingView(message: 'Préparation des pages…'),
      error: (e, _) => _ErrorView(error: '$e', onRetry: () {}),
      data: (pages) => _BookView(pages: pages),
    );
  }
}

// ─── Vue livre avec effet page flip ──────────────────────────────────────────

class _BookView extends StatefulWidget {
  final List<Uint8List> pages;
  const _BookView({required this.pages});

  @override
  State<_BookView> createState() => _BookViewState();
}

class _BookViewState extends State<_BookView>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _isFlippingForward = true;
  bool _isAnimating = false;
  double _dragStart = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _flipAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_isFlippingForward &&
              _currentPage < widget.pages.length - 1) {
            _currentPage++;
          } else if (!_isFlippingForward && _currentPage > 0) {
            _currentPage--;
          }
          _isAnimating = false;
        });
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipForward() {
    if (_isAnimating || _currentPage >= widget.pages.length - 1) return;
    _isFlippingForward = true;
    _isAnimating = true;
    _controller.forward();
  }

  void _flipBackward() {
    if (_isAnimating || _currentPage <= 0) return;
    _isFlippingForward = false;
    _isAnimating = true;
    _controller.forward();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final delta = details.globalPosition.dx - _dragStart;
    if (delta.abs() > 40) {
      if (delta < 0) {
        _flipForward();
      } else {
        _flipBackward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pageWidth = (size.width * 0.88).clamp(280.0, 520.0);
    final pageHeight = pageWidth * 1.41; // ratio A4

    return Stack(
      children: [
        // Texture fond bois sombre
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2C2416),
          ),
        ),

        // Livre centré
        Center(
          child: GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTapUp: (details) {
              final tapX = details.globalPosition.dx;
              final center = size.width / 2;
              if (tapX > center) {
                _flipForward();
              } else {
                _flipBackward();
              }
            },
            child: SizedBox(
              width: pageWidth,
              height: pageHeight,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return _BookPageFlip(
                    pages: widget.pages,
                    currentPage: _currentPage,
                    flipProgress: _isAnimating ? _flipAnimation.value : 0.0,
                    isFlippingForward: _isFlippingForward,
                    width: pageWidth,
                    height: pageHeight,
                  );
                },
              ),
            ),
          ),
        ),

        // Indicateur page + boutons navigation
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _NavigationBar(
            currentPage: _currentPage,
            totalPages: widget.pages.length,
            onPrevious: _flipBackward,
            onNext: _flipForward,
          ),
        ),
      ],
    );
  }
}

// ─── Widget flip 3D ──────────────────────────────────────────────────────────

class _BookPageFlip extends StatelessWidget {
  final List<Uint8List> pages;
  final int currentPage;
  final double flipProgress; // 0.0 → 1.0
  final bool isFlippingForward;
  final double width;
  final double height;

  const _BookPageFlip({
    required this.pages,
    required this.currentPage,
    required this.flipProgress,
    required this.isFlippingForward,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final nextPage = isFlippingForward
        ? (currentPage + 1).clamp(0, pages.length - 1)
        : (currentPage - 1).clamp(0, pages.length - 1);

    // Page de fond (destination)
    final backPage = isFlippingForward ? nextPage : currentPage;
    // Page qui tourne
    final frontPage = isFlippingForward ? currentPage : nextPage;

    // Angle du flip : 0 → PI
    final angle = flipProgress * math.pi;
    final isFirstHalf = angle <= math.pi / 2;

    // Pendant la première moitié : on voit la page courante (recto)
    // Pendant la deuxième moitié : on voit la page destination (verso retourné)
    final displayPage = isFirstHalf ? frontPage : backPage;
    final flipAngle = isFirstHalf ? angle : math.pi - angle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Page de fond statique
        _PageCard(
          bytes: pages[backPage],
          width: width,
          height: height,
          shadow: false,
        ),

        // Page qui tourne
        if (flipProgress > 0)
          Transform(
            alignment: isFlippingForward
                ? Alignment.centerRight
                : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(
                isFlippingForward ? -flipAngle : flipAngle,
              ),
            child: _PageCard(
              bytes: pages[displayPage],
              width: width,
              height: height,
              shadow: true,
              shadowSide: isFlippingForward ? ShadowSide.right : ShadowSide.left,
              progress: flipProgress,
            ),
          ),
      ],
    );
  }
}

enum ShadowSide { left, right }

// ─── Carte de page ────────────────────────────────────────────────────────────

class _PageCard extends StatelessWidget {
  final Uint8List bytes;
  final double width;
  final double height;
  final bool shadow;
  final ShadowSide shadowSide;
  final double progress;

  const _PageCard({
    required this.bytes,
    required this.width,
    required this.height,
    this.shadow = false,
    this.shadowSide = ShadowSide.right,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        child: Stack(
          children: [
            // Contenu page
            Image.memory(
              bytes,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),

            // Ombre de courbure pendant le flip
            if (shadow)
              Positioned.fill(
                child: _CurlShadow(
                  progress: progress,
                  side: shadowSide,
                ),
              ),

            // Ligne de reliure centrale
            Positioned(
              top: 0,
              bottom: 0,
              left: shadowSide == ShadowSide.right ? null : 0,
              right: shadowSide == ShadowSide.right ? 0 : null,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ombre de courbure ────────────────────────────────────────────────────────

class _CurlShadow extends StatelessWidget {
  final double progress;
  final ShadowSide side;

  const _CurlShadow({required this.progress, required this.side});

  @override
  Widget build(BuildContext context) {
    final opacity = (math.sin(progress * math.pi) * 0.35).clamp(0.0, 0.35);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: side == ShadowSide.right
              ? Alignment.centerLeft
              : Alignment.centerRight,
          end: side == ShadowSide.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(opacity),
          ],
        ),
      ),
    );
  }
}

// ─── Barre de navigation ──────────────────────────────────────────────────────

class _NavigationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onPressed: currentPage > 0 ? onPrevious : null,
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Page ${currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onPressed: currentPage < totalPages - 1 ? onNext : null,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: onPressed != null ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ─── Vues utilitaires ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger le PDF',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
*/


/*
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Provider : pages rasterisées ────────────────────────────────────────────

final pdfPagesProvider = FutureProvider.family<List<Uint8List>, String>(
      (ref, pdfPath) async {
    final document = await PdfDocument.openFile(pdfPath);
    final pages = <Uint8List>[];

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
      );
      await page.close();
      if (pageImage?.bytes != null) {
        pages.add(pageImage!.bytes);
      }
    }

    await document.close();
    return pages;
  },
);

// ─── Écran principal ──────────────────────────────────────────────────────────

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String title;
  final String? pdfId;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.pdfId,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late Future<String> _pdfPathFuture;

  @override
  void initState() {
    super.initState();
    _pdfPathFuture = _downloadAndSavePdf();
  }

  Future<String> _downloadAndSavePdf() async {
    final apiClient = ref.read(apiClientProvider);
    final safeName = widget.title.replaceAll(RegExp(r'[^\w\s-]'), '');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$safeName.pdf');

    if (widget.pdfId != null && widget.pdfId!.isNotEmpty) {
      try {
        final response = await apiClient.dio.get(
          '/api/pdfs/${widget.pdfId}/download',
          options: Options(receiveTimeout: const Duration(seconds: 60)),
        );
        if (response.statusCode == 200 &&
            response.data is Map &&
            response.data['data'] != null) {
          final downloadUrl = response.data['data']['downloadUrl'] as String?;
          if (downloadUrl != null) {
            final dio = Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
            ));
            final pdfResponse = await dio.get<List<int>>(
              downloadUrl,
              options: Options(responseType: ResponseType.bytes),
            );
            if (pdfResponse.statusCode == 200 && pdfResponse.data != null) {
              await file.writeAsBytes(pdfResponse.data!);
              return file.path;
            }
          }
        }
      } catch (_) {}
    }

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ));
      final response = await dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        return file.path;
      }
    } catch (_) {}

    try {
      final response = await apiClient.dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        return file.path;
      }
    } catch (_) {}

    throw Exception('Impossible de télécharger le PDF.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2416),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1A1509),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: _pdfPathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView(message: 'Téléchargement du document…');
          }
          if (snapshot.hasError) {
            return _ErrorView(
              error: '${snapshot.error}',
              onRetry: () => setState(() {
                _pdfPathFuture = _downloadAndSavePdf();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          return _BookRenderer(pdfPath: snapshot.data!);
        },
      ),
    );
  }
}

// ─── Renderer : attend la rasterisation puis affiche le livre ─────────────────

class _BookRenderer extends ConsumerWidget {
  final String pdfPath;
  const _BookRenderer({required this.pdfPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(pdfPagesProvider(pdfPath));

    return pagesAsync.when(
      loading: () => const _LoadingView(message: 'Préparation des pages…'),
      error: (e, _) => _ErrorView(error: '$e', onRetry: () {}),
      data: (pages) => _BookView(pages: pages),
    );
  }
}

// ─── Vue livre avec effet page flip ──────────────────────────────────────────

class _BookView extends StatefulWidget {
  final List<Uint8List> pages;
  const _BookView({required this.pages});

  @override
  State<_BookView> createState() => _BookViewState();
}

class _BookViewState extends State<_BookView>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _isFlippingForward = true;
  bool _isAnimating = false;
  double _dragStart = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _flipAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_isFlippingForward &&
              _currentPage < widget.pages.length - 1) {
            _currentPage++;
          } else if (!_isFlippingForward && _currentPage > 0) {
            _currentPage--;
          }
          _isAnimating = false;
        });
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipForward() {
    if (_isAnimating || _currentPage >= widget.pages.length - 1) return;
    _isFlippingForward = true;
    _isAnimating = true;
    _controller.forward();
  }

  void _flipBackward() {
    if (_isAnimating || _currentPage <= 0) return;
    _isFlippingForward = false;
    _isAnimating = true;
    _controller.forward();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final delta = details.globalPosition.dx - _dragStart;
    if (delta.abs() > 40) {
      if (delta < 0) {
        _flipForward();
      } else {
        _flipBackward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pageWidth = (size.width * 0.88).clamp(280.0, 520.0);
    final pageHeight = pageWidth * 1.41; // ratio A4

    return Stack(
      children: [
        // Texture fond bois sombre
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2C2416),
          ),
        ),

        // Livre centré
        Center(
          child: GestureDetector(
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTapUp: (details) {
              final tapX = details.globalPosition.dx;
              final center = size.width / 2;
              if (tapX > center) {
                _flipForward();
              } else {
                _flipBackward();
              }
            },
            child: SizedBox(
              width: pageWidth,
              height: pageHeight,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return _BookPageFlip(
                    pages: widget.pages,
                    currentPage: _currentPage,
                    flipProgress: _isAnimating ? _flipAnimation.value : 0.0,
                    isFlippingForward: _isFlippingForward,
                    width: pageWidth,
                    height: pageHeight,
                  );
                },
              ),
            ),
          ),
        ),

        // Indicateur page + boutons navigation
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _NavigationBar(
            currentPage: _currentPage,
            totalPages: widget.pages.length,
            onPrevious: _flipBackward,
            onNext: _flipForward,
          ),
        ),
      ],
    );
  }
}

// ─── Widget flip 3D ──────────────────────────────────────────────────────────

class _BookPageFlip extends StatelessWidget {
  final List<Uint8List> pages;
  final int currentPage;
  final double flipProgress; // 0.0 → 1.0
  final bool isFlippingForward;
  final double width;
  final double height;

  const _BookPageFlip({
    required this.pages,
    required this.currentPage,
    required this.flipProgress,
    required this.isFlippingForward,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final nextPage = isFlippingForward
        ? (currentPage + 1).clamp(0, pages.length - 1)
        : (currentPage - 1).clamp(0, pages.length - 1);

    // Page de fond (destination)
    final backPage = isFlippingForward ? nextPage : currentPage;
    // Page qui tourne
    final frontPage = isFlippingForward ? currentPage : nextPage;

    // Angle du flip : 0 → PI
    final angle = flipProgress * math.pi;
    final isFirstHalf = angle <= math.pi / 2;

    // Pendant la première moitié : on voit la page courante (recto)
    // Pendant la deuxième moitié : on voit la page destination (verso retourné)
    final displayPage = isFirstHalf ? frontPage : backPage;
    final flipAngle = isFirstHalf ? angle : math.pi - angle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Page de fond statique
        _PageCard(
          bytes: pages[backPage],
          width: width,
          height: height,
          shadow: false,
        ),

        // Page qui tourne
        if (flipProgress > 0)
          Transform(
            alignment: isFlippingForward
                ? Alignment.centerRight
                : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(
                isFlippingForward ? -flipAngle : flipAngle,
              ),
            child: _PageCard(
              bytes: pages[displayPage],
              width: width,
              height: height,
              shadow: true,
              shadowSide: isFlippingForward ? ShadowSide.right : ShadowSide.left,
              progress: flipProgress,
            ),
          ),
      ],
    );
  }
}

enum ShadowSide { left, right }

// ─── Carte de page ────────────────────────────────────────────────────────────

class _PageCard extends StatelessWidget {
  final Uint8List bytes;
  final double width;
  final double height;
  final bool shadow;
  final ShadowSide shadowSide;
  final double progress;

  const _PageCard({
    required this.bytes,
    required this.width,
    required this.height,
    this.shadow = false,
    this.shadowSide = ShadowSide.right,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(3)),
        child: Stack(
          children: [
            // Contenu page
            Image.memory(
              bytes,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),

            // Ombre de courbure pendant le flip
            if (shadow)
              Positioned.fill(
                child: _CurlShadow(
                  progress: progress,
                  side: shadowSide,
                ),
              ),

            // Ligne de reliure centrale
            Positioned(
              top: 0,
              bottom: 0,
              left: shadowSide == ShadowSide.right ? null : 0,
              right: shadowSide == ShadowSide.right ? 0 : null,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ombre de courbure ────────────────────────────────────────────────────────

class _CurlShadow extends StatelessWidget {
  final double progress;
  final ShadowSide side;

  const _CurlShadow({required this.progress, required this.side});

  @override
  Widget build(BuildContext context) {
    final opacity = (math.sin(progress * math.pi) * 0.35).clamp(0.0, 0.35);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: side == ShadowSide.right
              ? Alignment.centerLeft
              : Alignment.centerRight,
          end: side == ShadowSide.right
              ? Alignment.centerRight
              : Alignment.centerLeft,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(opacity),
          ],
        ),
      ),
    );
  }
}

// ─── Barre de navigation ──────────────────────────────────────────────────────

class _NavigationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onPressed: currentPage > 0 ? onPrevious : null,
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Page ${currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onPressed: currentPage < totalPages - 1 ? onNext : null,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: onPressed != null ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// ─── Vues utilitaires ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger le PDF',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}*/


import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:page_flip/page_flip.dart';
import 'dart:io';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/constants/app_colors.dart';

// ─── Provider : pages rasterisées ────────────────────────────────────────────

final pdfPagesProvider = FutureProvider.family<List<Uint8List>, String>(
      (ref, pdfPath) async {
    final document = await PdfDocument.openFile(pdfPath);
    final pages = <Uint8List>[];

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
      );
      await page.close();
      if (pageImage?.bytes != null) {
        pages.add(pageImage!.bytes);
      }
    }

    await document.close();
    return pages;
  },
);

// ─── Écran principal ──────────────────────────────────────────────────────────

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String title;
  final String? pdfId;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.pdfId,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  late Future<String> _pdfPathFuture;

  @override
  void initState() {
    super.initState();
    _pdfPathFuture = _downloadAndSavePdf();
  }

  Future<String> _downloadAndSavePdf() async {
    final apiClient = ref.read(apiClientProvider);
    final safeName = widget.title.replaceAll(RegExp(r'[^\w\s-]'), '');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$safeName.pdf');

    if (widget.pdfId != null && widget.pdfId!.isNotEmpty) {
      try {
        final response = await apiClient.dio.get(
          '/api/pdfs/${widget.pdfId}/download',
          options: Options(receiveTimeout: const Duration(seconds: 60)),
        );
        if (response.statusCode == 200 &&
            response.data is Map &&
            response.data['data'] != null) {
          final downloadUrl = response.data['data']['downloadUrl'] as String?;
          if (downloadUrl != null) {
            final dio = Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
            ));
            final pdfResponse = await dio.get<List<int>>(
              downloadUrl,
              options: Options(responseType: ResponseType.bytes),
            );
            if (pdfResponse.statusCode == 200 && pdfResponse.data != null) {
              await file.writeAsBytes(pdfResponse.data!);
              return file.path;
            }
          }
        }
      } catch (_) {}
    }

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
      ));
      final response = await dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        return file.path;
      }
    } catch (_) {}

    try {
      final response = await apiClient.dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        await file.writeAsBytes(response.data!);
        return file.path;
      }
    } catch (_) {}

    throw Exception('Impossible de télécharger le PDF.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1208),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: const Color(0xFF0F0A04),
        foregroundColor: const Color(0xFFF0E6C8),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF8B6914).withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<String>(
        future: _pdfPathFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView(message: 'Téléchargement du document…');
          }
          if (snapshot.hasError) {
            return _ErrorView(
              error: '${snapshot.error}',
              onRetry: () => setState(() {
                _pdfPathFuture = _downloadAndSavePdf();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          return _BookRenderer(pdfPath: snapshot.data!);
        },
      ),
    );
  }
}

// ─── Renderer : attend la rasterisation puis affiche le livre ─────────────────

class _BookRenderer extends ConsumerWidget {
  final String pdfPath;
  const _BookRenderer({required this.pdfPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(pdfPagesProvider(pdfPath));

    return pagesAsync.when(
      loading: () => const _LoadingView(message: 'Préparation des pages…'),
      error: (e, _) => _ErrorView(error: '$e', onRetry: () {}),
      data: (pages) => _BookView(pages: pages),
    );
  }
}

// ─── Vue livre avec page_flip ─────────────────────────────────────────────────

class _BookView extends StatefulWidget {
  final List<Uint8List> pages;
  const _BookView({required this.pages});

  @override
  State<_BookView> createState() => _BookViewState();
}

class _BookViewState extends State<_BookView> {
  final _pageFlipKey = GlobalKey<PageFlipWidgetState>();
  int _currentPage = 0;

  void _goToNext() {
    if (_currentPage < widget.pages.length - 1) {
      _pageFlipKey.currentState?.nextPage();
      setState(() => _currentPage++);
    }
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageFlipKey.currentState?.previousPage();
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond texture bois sombre
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Color(0xFF2A1E0A),
                Color(0xFF0F0A04),
              ],
            ),
          ),
        ),

        // Grille bois subtile
        Positioned.fill(
          child: CustomPaint(painter: _WoodGrainPainter()),
        ),

        // Livre centré avec page_flip
        Center(
          child: _BookShadowWrapper(
            child: PageFlipWidget(
              key: _pageFlipKey,
              backgroundColor: const Color(0xFFFFF8E7),
              lastPage: _LastPageWidget(),
              children: <Widget>[
                ...widget.pages.map((bytes) => _PdfPageWidget(bytes: bytes)),
              ],
            ),
          ),
        ),

        // Barre de navigation en bas
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: _NavigationBar(
            currentPage: _currentPage,
            totalPages: widget.pages.length,
            onPrevious: _goToPrevious,
            onNext: _goToNext,
          ),
        ),

        // Hint swipe (disparaît après la 1ère page)
        if (_currentPage == 0)
          const Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: _SwipeHint(),
          ),
      ],
    );
  }
}

// ─── Dernière page ────────────────────────────────────────────────────────────

class _LastPageWidget extends StatelessWidget {
  const _LastPageWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF8E7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Color(0xFF8B6914)),
            SizedBox(height: 16),
            Text(
              'Fin du document',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                color: Color(0xFF8B6914),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget page PDF individuelle ─────────────────────────────────────────────

class _PdfPageWidget extends StatelessWidget {
  final Uint8List bytes;

  const _PdfPageWidget({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E7),
      ),
      child: Stack(
        children: [
          // Contenu de la page
          Positioned.fill(
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),

          // Effet d'ombre de reliure (côté gauche de chaque page)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(
              width: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Légère texture papier
          Positioned.fill(
            child: CustomPaint(painter: _PaperTexturePainter()),
          ),
        ],
      ),
    );
  }
}

// ─── Wrapper ombre du livre ────────────────────────────────────────────────────

class _BookShadowWrapper extends StatelessWidget {
  final Widget child;
  const _BookShadowWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bookWidth = (size.width * 0.9).clamp(300.0, 560.0);
    final bookHeight = (size.height * 0.78).clamp(400.0, 740.0);

    return Container(
      width: bookWidth,
      height: bookHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          // Ombre principale profonde
          BoxShadow(
            color: Colors.black.withOpacity(0.75),
            blurRadius: 40,
            spreadRadius: 8,
            offset: const Offset(0, 16),
          ),
          // Ombre latérale gauche (reliure)
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(-8, 0),
          ),
          // Reflet chaud subtil
          BoxShadow(
            color: const Color(0xFF8B6914).withOpacity(0.15),
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: child,
      ),
    );
  }
}

// ─── Painter grain bois ───────────────────────────────────────────────────────

class _WoodGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3D2A0A).withOpacity(0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rand = math.Random(42);
    for (int i = 0; i < 18; i++) {
      final y = rand.nextDouble() * size.height;
      final path = Path();
      path.moveTo(0, y);
      double x = 0;
      double currentY = y;
      while (x < size.width) {
        x += 30 + rand.nextDouble() * 60;
        currentY += (rand.nextDouble() - 0.5) * 12;
        path.lineTo(x, currentY);
      }
      canvas.drawPath(path, paint..color = paint.color.withOpacity(0.08 + rand.nextDouble() * 0.12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Painter texture papier ───────────────────────────────────────────────────

class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.withOpacity(0.015)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final rand = math.Random(7);
    for (int i = 0; i < 60; i++) {
      final x1 = rand.nextDouble() * size.width;
      final y1 = rand.nextDouble() * size.height;
      final x2 = x1 + (rand.nextDouble() - 0.5) * 40;
      final y2 = y1 + (rand.nextDouble() - 0.5) * 4;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Hint glisser ─────────────────────────────────────────────────────────────

class _SwipeHint extends StatefulWidget {
  const _SwipeHint();

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B6914).withOpacity(0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swipe, color: Color(0xFFD4AA50), size: 16),
                SizedBox(width: 8),
                Text(
                  'Glissez pour tourner la page',
                  style: TextStyle(
                    color: Color(0xFFD4AA50),
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barre de navigation ──────────────────────────────────────────────────────

class _NavigationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _NavigationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onPressed: currentPage > 0 ? onPrevious : null,
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF8B6914).withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Text(
            'Page ${currentPage + 1} / $totalPages',
            style: const TextStyle(
              color: Color(0xFFD4AA50),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              fontFamily: 'Georgia',
            ),
          ),
        ),
        const SizedBox(width: 14),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onPressed: currentPage < totalPages - 1 ? onNext : null,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: onPressed != null ? 1.0 : 0.25,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8B6914).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: const Color(0xFFD4AA50), size: 28),
        ),
      ),
    );
  }
}

// ─── Vues utilitaires ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFD4AA50)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFD4AA50),
              fontSize: 14,
              fontFamily: 'Georgia',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 64, color: Color(0xFF8B6914)),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger le PDF',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFF0E6C8),
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B7355), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B6914),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Réessayer',
                style: TextStyle(fontFamily: 'Georgia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}