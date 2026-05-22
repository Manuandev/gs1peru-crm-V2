// lib\core\utils\ui\file_type_utils.dart

import 'package:flutter/material.dart';

IconData fileIcon(String mensaje) {
  final ext = mensaje.toLowerCase().split('.').last;
  switch (ext) {
    case 'pdf':              return Icons.picture_as_pdf_rounded;
    case 'doc': case 'docx': return Icons.description_rounded;
    case 'xls': case 'xlsx': return Icons.table_chart_rounded;
    case 'ppt': case 'pptx': return Icons.slideshow_rounded;
    default:                 return Icons.insert_drive_file_rounded;
  }
}

String fileLabel(String mensaje) {
  final ext = mensaje.toLowerCase().split('.').last;
  switch (ext) {
    case 'pdf':              return 'PDF';
    case 'doc': case 'docx': return 'Word';
    case 'xls': case 'xlsx': return 'Excel';
    case 'ppt': case 'pptx': return 'PowerPoint';
    default:                 return 'Archivo';
  }
}

Color fileColor(String mensaje) {
  final ext = mensaje.toLowerCase().split('.').last;
  switch (ext) {
    case 'pdf':              return Colors.red.shade400;
    case 'doc': case 'docx': return Colors.blue.shade500;
    case 'xls': case 'xlsx': return Colors.green.shade600;
    case 'ppt': case 'pptx': return Colors.orange.shade600;
    default:                 return Colors.grey.shade500;
  }
}