import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Star rating input widget
class ReviewForm extends StatefulWidget {
  final void Function(int rating, String? comment) onSubmit;
  final bool isLoading;

  const ReviewForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berikan Rating',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        // Star rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  scale: _rating >= starIndex ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _rating >= starIndex ? Icons.star : Icons.star_border,
                    size: 44,
                    color: _rating >= starIndex
                        ? AppColors.warning
                        : AppColors.outline,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _ratingLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 24),
        // Comment
        TextFormField(
          controller: _commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Komentar (opsional)',
            hintText: 'Tulis pengalaman Anda...',
            prefixIcon: Icon(Icons.comment),
          ),
        ),
        const SizedBox(height: 24),
        // Submit
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _rating == 0 || widget.isLoading
                ? null
                : () {
                    widget.onSubmit(
                      _rating,
                      _commentController.text.trim().isEmpty
                          ? null
                          : _commentController.text.trim(),
                    );
                  },
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Kirim Review'),
          ),
        ),
      ],
    );
  }

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Buruk 😞';
      case 2:
        return 'Kurang 😐';
      case 3:
        return 'Cukup 🙂';
      case 4:
        return 'Bagus 😊';
      case 5:
        return 'Sangat Bagus! 🤩';
      default:
        return 'Tap untuk memberi rating';
    }
  }
}
