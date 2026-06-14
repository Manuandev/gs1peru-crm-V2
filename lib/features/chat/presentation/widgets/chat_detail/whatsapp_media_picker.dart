// lib/features/chat/presentation/widgets/chat_detail/whatsapp_media_picker.dart
// whatsapp_media_picker.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

class WhatsAppMediaPicker extends StatefulWidget {
  final void Function(List<AssetEntity> selected) onConfirm;
  const WhatsAppMediaPicker({super.key, required this.onConfirm});

  @override
  State<WhatsAppMediaPicker> createState() => _WhatsAppMediaPickerState();
}

class _WhatsAppMediaPickerState extends State<WhatsAppMediaPicker> {
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  List<AssetEntity> _assets = [];
  final List<AssetEntity> _selected = [];
  bool _loading = true;

  static const _pageSize = 60;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.photos.request();
    await Permission.videos.request();
    await PhotoManager.setIgnorePermissionCheck(true);

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      onlyAll: false,
    );
    if (albums.isEmpty || !mounted) return;

    setState(() {
      _albums = albums;
      _currentAlbum = albums.first;
    });
    await _loadAssets();
  }

  Future<void> _loadAssets() async {
    if (_currentAlbum == null) return;
    final list = await _currentAlbum!.getAssetListPaged(
      page: 0,
      size: _pageSize,
    );
    if (!mounted) return;
    setState(() {
      _assets = list;
      _loading = false;
    });
  }

  void _toggleSelect(AssetEntity asset) {
    setState(() {
      final idx = _selected.indexWhere((a) => a.id == asset.id);
      if (idx == -1) {
        _selected.add(asset);
      } else {
        _selected.removeAt(idx);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          width: AppSizing.handleWidth,
          height: AppSpacing.xs,
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.smPlus),
          decoration: BoxDecoration(
            color: AppColors.grey300,
            borderRadius: BorderRadius.circular(AppSizing.radiusXxs),
          ),
        ),

        // Header
        _PickerHeader(
          albums: _albums,
          current: _currentAlbum,
          selectedCount: _selected.length,
          onAlbumChanged: (album) {
            setState(() {
              _currentAlbum = album;
              _loading = true;
            });
            _loadAssets();
          },
          onConfirm: () => widget.onConfirm(List.from(_selected)),
        ),

        // Grid
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.xxs,
                    mainAxisSpacing: AppSpacing.xxs,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (_, i) {
                    final asset = _assets[i];
                    final idx =
                        _selected.indexWhere((a) => a.id == asset.id);
                    return _MediaTile(
                      asset: asset,
                      selectionIndex: idx != -1 ? idx + 1 : null,
                      onTap: () => _toggleSelect(asset),
                    );
                  },
                ),
        ),

        // Preview bar
        if (_selected.isNotEmpty)
          _PreviewBar(selected: _selected, onRemove: _toggleSelect),
      ],
    );
  }
}

// _PickerHeader

class _PickerHeader extends StatelessWidget {
  final List<AssetPathEntity> albums;
  final AssetPathEntity? current;
  final int selectedCount;
  final void Function(AssetPathEntity) onAlbumChanged;
  final VoidCallback onConfirm;

  const _PickerHeader({
    required this.albums,
    required this.current,
    required this.selectedCount,
    required this.onAlbumChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.smPlus,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          // Dropdown álbum
          Expanded(
            child: GestureDetector(
              onTap: () => _showAlbumSheet(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current?.name ?? 'Recientes',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(AppIcons.arrowDown, size: AppSizing.iconSearch),
                ],
              ),
            ),
          ),

          // Botón
          selectedCount > 0
              ? FilledButton.icon(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppIconsSocial.colorCanal(1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.mdPlus,
                      vertical: AppSpacing.sm,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(AppIcons.send, size: AppSizing.iconSm),
                  label: Text('Enviar $selectedCount'),
                )
              : TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
        ],
      ),
    );
  }

  void _showAlbumSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizing.radiusLg),
        ),
      ),
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        itemCount: albums.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(albums[i].name),
          trailing: current?.id == albums[i].id
              ? Icon(
                  AppIcons.checkRounded,
                  color: AppIconsSocial.colorCanal(1),
                )
              : null,
          onTap: () {
            onAlbumChanged(albums[i]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

// _MediaTile

class _MediaTile extends StatelessWidget {
  final AssetEntity asset;
  final int? selectionIndex;
  final VoidCallback onTap;

  const _MediaTile({
    required this.asset,
    required this.selectionIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectionIndex != null;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          FutureBuilder<Uint8List?>(
            future: asset.thumbnailDataWithSize(
              const ThumbnailSize.square(200),
            ),
            builder: (_, snap) {
              if (snap.data == null) {
                return Container(color: AppColors.grey200);
              }
              return ColorFiltered(
                colorFilter: isSelected
                    ? const ColorFilter.mode(
                        AppColors.black38,
                        BlendMode.darken,
                      )
                    : const ColorFilter.mode(
                        AppColors.transparent,
                        BlendMode.multiply,
                      ),
                child: Image.memory(snap.data!, fit: BoxFit.cover),
              );
            },
          ),

          // Badge video
          if (asset.type == AssetType.video)
            Positioned(
              bottom: AppSpacing.gridBadgePad,
              left: AppSpacing.chipGap,
              child: Row(
                children: [
                  const Icon(
                    AppIcons.playCircle,
                    color: AppColors.textOnDark,
                    size: AppSizing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.badgePadding),
                  Text(
                    _formatDuration(asset.videoDuration),
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: AppTextStyles.sizeXs,
                      fontWeight: AppTextStyles.weightSemiBold,
                      shadows: [
                        Shadow(
                          blurRadius: AppSizing.shadowBlurXs,
                          color: AppColors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Check ring
          Positioned(
            top: AppSpacing.chipGap,
            right: AppSpacing.chipGap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: AppSizing.mensajesBadgeSize,
              height: AppSizing.mensajesBadgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppIconsSocial.colorCanal(1)
                    : AppColors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppIconsSocial.colorCanal(1)
                      : AppColors.textOnDark,
                  width: AppSizing.canalBadgeBorder,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Text(
                        '$selectionIndex',
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: AppTextStyles.sizeXs,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// _PreviewBar — thumbnails seleccionados abajo

class _PreviewBar extends StatelessWidget {
  final List<AssetEntity> selected;
  final void Function(AssetEntity) onRemove;

  const _PreviewBar({required this.selected, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizing.previewBarHeight,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm2,
          vertical: AppSpacing.smPlus,
        ),
        itemCount: selected.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => _PreviewThumb(
          asset: selected[i],
          onRemove: () => onRemove(selected[i]),
        ),
      ),
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  final AssetEntity asset;
  final VoidCallback onRemove;

  const _PreviewThumb({required this.asset, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<Uint8List?>(
          future: asset.thumbnailDataWithSize(
            const ThumbnailSize.square(100),
          ),
          builder: (_, snap) => ClipRRect(
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            child: snap.data != null
                ? Image.memory(
                    snap.data!,
                    width: AppSizing.previewThumbSize,
                    height: AppSizing.previewThumbSize,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: AppSizing.previewThumbSize,
                    height: AppSizing.previewThumbSize,
                    color: AppColors.grey200,
                  ),
          ),
        ),
        Positioned(
          top: -AppSpacing.xs,
          right: -AppSpacing.xs,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: AppSizing.notifBadgeSize,
              height: AppSizing.notifBadgeSize,
              decoration: const BoxDecoration(
                color: AppColors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.close,
                size: AppSizing.iconInline,
                color: AppColors.textOnDark,
              ),
            ),
          ),
        ),
        Container(
          width: AppSizing.previewThumbSize,
          height: AppSizing.previewThumbSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            border: Border.all(
              color: AppIconsSocial.colorCanal(1),
              width: AppSizing.borderFocusWidth,
            ),
          ),
        ),
      ],
    );
  }
}
