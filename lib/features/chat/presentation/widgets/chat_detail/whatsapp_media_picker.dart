// whatsapp_media_picker.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
          width: 36,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
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
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (_, i) {
                    final asset = _assets[i];
                    final idx = _selected.indexWhere((a) => a.id == asset.id);
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ),
            ),
          ),

          // Botón
          selectedCount > 0
              ? FilledButton.icon(
                  onPressed: onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 16),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        shrinkWrap: true,
        itemCount: albums.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(albums[i].name),
          trailing: current?.id == albums[i].id
              ? const Icon(Icons.check_rounded, color: Color(0xFF25D366))
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
                return Container(color: Colors.grey.shade200);
              }
              return ColorFiltered(
                colorFilter: isSelected
                    ? const ColorFilter.mode(Colors.black38, BlendMode.darken)
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                child: Image.memory(snap.data!, fit: BoxFit.cover),
              );
            },
          ),

          // Badge video
          if (asset.type == AssetType.video)
            Positioned(
              bottom: 5,
              left: 6,
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _formatDuration(asset.videoDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                ],
              ),
            ),

          // Check ring
          Positioned(
            top: 6,
            right: 6,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF25D366)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF25D366) : Colors.white,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Text(
                        '$selectionIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
      height: 72,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: selected.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
          future: asset.thumbnailDataWithSize(const ThumbnailSize.square(100)),
          builder: (_, snap) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: snap.data != null
                ? Image.memory(snap.data!, width: 52, height: 52, fit: BoxFit.cover)
                : Container(width: 52, height: 52, color: Colors.grey.shade200),
          ),
        ),
        Positioned(
          top: -4, right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
            ),
          ),
        ),
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF25D366), width: 2),
          ),
        ),
      ],
    );
  }
}