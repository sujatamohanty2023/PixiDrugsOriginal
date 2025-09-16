import '../constant/all.dart';

class ProgressDialog extends StatefulWidget {
  final int current;
  final int total;
  final String message;

  const ProgressDialog({
    super.key,
    required this.current,
    required this.total,
    this.message = "Processing Files...",
  });

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  @override
  Widget build(BuildContext context) {
    double progress = widget.total > 0 ? widget.current / widget.total : 0.0;
    int percentage = (progress * 100).round();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        widget.message,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: AppColors.kPrimary,
              minHeight: 12,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 16),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.kPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.current} of ${widget.total} files completed',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}