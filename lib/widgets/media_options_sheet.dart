import 'package:flutter/material.dart';

void showMediaOptionsSheet({
  required BuildContext context,
  required VoidCallback onCameraTap,
  required VoidCallback onGalleryTap,
  required VoidCallback onFilesTap,
}) {
  final theme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: theme.onSurface.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Media',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  context,
                  Icons.camera_alt,
                  'Camera',
                  theme.primary,
                  () {
                    onCameraTap();
                    Navigator.pop(context);
                  },
                ),
                _buildOptionButton(
                  context,
                  Icons.image,
                  'Gallery',
                  theme.secondary,
                  () {
                    onGalleryTap();
                    Navigator.pop(context);
                  },
                ),
                _buildOptionButton(
                  context,
                  Icons.file_copy,
                  'Files',
                  theme.tertiary,
                  () {
                    onFilesTap();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    },
  );
}

Widget _buildOptionButton(
  BuildContext context,
  IconData icon,
  String label,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
