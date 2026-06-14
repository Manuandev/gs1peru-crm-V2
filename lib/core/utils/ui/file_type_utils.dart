// lib/core/utils/ui/file_type_utils.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

IconData fileIcon(String mensaje) {
  final ext = mensaje.toLowerCase().split('.').last;
  switch (ext) {
    case 'pdf':              return AppIcons.pdf;
    case 'doc': case 'docx': return AppIcons.fileWord;
    case 'xls': case 'xlsx': return AppIcons.fileExcel;
    case 'ppt': case 'pptx': return AppIcons.filePowerpoint;
    default:                 return AppIcons.fileGeneric;
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
    case 'pdf':              return AppColors.errorLight;
    case 'doc': case 'docx': return AppColors.info;
    case 'xls': case 'xlsx': return AppColors.fileColorExcel;
    case 'ppt': case 'pptx': return AppColors.fileColorPowerpoint;
    default:                 return AppColors.grey500;
  }
}
