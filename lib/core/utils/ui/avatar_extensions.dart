// lib/core/utils/ui/avatar_extensions.dart
import 'package:flutter/material.dart';
import 'avatar_utils.dart';

extension StringAvatarX on String {
  /// "Juan Pérez".initials → "JP"
  String get initials => AvatarUtils.initials(this);

  /// "Juan Pérez".avatarColor → Color(0xFF1976D2)
  Color get avatarColor => AvatarUtils.color(this);
}