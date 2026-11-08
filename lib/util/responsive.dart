import 'dart:math' as math;

import 'package:customer/util/api.dart';
import 'package:flutter/material.dart';

/// Width at which the app switches from phone to tablet/desktop layouts.
const double wideBreakpoint = 720;

bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideBreakpoint;

/// Centers its child and caps its width so forms and details don't stretch
/// across large screens.
class MaxWidth extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const MaxWidth({super.key, this.maxWidth = 480, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Icon + label + value on one line. The value wraps instead of overflowing.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Colors.red[700];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: accent),
                ),
                TextSpan(text: value),
              ]),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// A centered icon + message, with an optional retry button.
class StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const StatusMessage({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loads a list from the server and shows it with loading, error, empty and
/// pull-to-refresh states. Items are laid out in as many columns as fit.
///
/// - With [gridAspectRatio] set, items are laid out in an even grid
///   (good for image tiles).
/// - Otherwise items flow in rows of equal-width columns, each item keeping
///   its natural height (good for detail cards).
class RemoteList extends StatefulWidget {
  final Future<List<Json>> Function() load;
  final Widget Function(BuildContext context, Json item) itemBuilder;
  /// Grid mode: the widest a tile may be. Row mode: the narrowest a column
  /// may be before the list drops to fewer columns.
  final double itemWidth;
  final double? gridAspectRatio;
  final String emptyMessage;
  final IconData emptyIcon;

  /// When set, a search box filters items with this test.
  final bool Function(Json item, String query)? matches;
  final String searchHint;

  /// Optional summary shown above the items (e.g. totals).
  final Widget Function(List<Json> items)? headerBuilder;

  const RemoteList({
    super.key,
    required this.load,
    required this.itemBuilder,
    this.itemWidth = 380,
    this.gridAspectRatio,
    this.emptyMessage = 'Nothing here yet.',
    this.emptyIcon = Icons.inbox_outlined,
    this.matches,
    this.searchHint = 'Search',
    this.headerBuilder,
  });

  @override
  State<RemoteList> createState() => RemoteListState();
}

class RemoteListState extends State<RemoteList> {
  List<Json>? _items;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// Fetches the list again. Safe to call from a parent via a GlobalKey.
  Future<void> reload() async {
    try {
      final items = await widget.load();
      if (!mounted) return;
      setState(() {
        _items = items;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e is ApiException ? e.message : 'Something went wrong.');
    }
  }

  void _retry() {
    setState(() {
      _items = null;
      _error = null;
    });
    reload();
  }

  @override
  Widget build(BuildContext context) {
    final all = _items;
    if (all == null) {
      if (_error != null) {
        return StatusMessage(
            icon: Icons.cloud_off, message: _error!, onRetry: _retry);
      }
      return const Center(child: CircularProgressIndicator());
    }

    final q = _query.trim().toLowerCase();
    final items = (widget.matches == null || q.isEmpty)
        ? all
        : all.where((i) => widget.matches!(i, q)).toList();

    return Column(
      children: [
        if (widget.matches != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: MaxWidth(
              maxWidth: 600,
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        if (_error != null)
          MaterialBanner(
            content: Text(_error!),
            leading: const Icon(Icons.cloud_off),
            actions: [TextButton(onPressed: reload, child: const Text('Retry'))],
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: reload,
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _buildBody(context, items, all, constraints.maxWidth),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context, List<Json> items, List<Json> all, double width) {
    const pad = 12.0;
    const gap = 12.0;
    final header = widget.headerBuilder?.call(all);

    if (items.isEmpty) {
      // Still scrollable so pull-to-refresh works on an empty list.
      return ListView(
        padding: const EdgeInsets.all(pad),
        children: [
          if (header != null) header,
          SizedBox(
            height: 300,
            child: StatusMessage(
              icon: all.isEmpty ? widget.emptyIcon : Icons.search_off,
              message: all.isEmpty ? widget.emptyMessage : 'No matches found.',
            ),
          ),
        ],
      );
    }

    if (widget.gridAspectRatio != null) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (header != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(pad, pad, pad, 0),
              sliver: SliverToBoxAdapter(child: header),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(pad),
            sliver: SliverGrid.builder(
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: widget.itemWidth,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                childAspectRatio: widget.gridAspectRatio!,
              ),
              itemBuilder: (context, i) => widget.itemBuilder(context, items[i]),
            ),
          ),
        ],
      );
    }

    final columns =
        math.max(1, ((width - 2 * pad + gap) / (widget.itemWidth + gap)).floor());
    final rows = (items.length / columns).ceil();
    final offset = header != null ? 1 : 0;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(pad),
      itemCount: rows + offset,
      itemBuilder: (context, r) {
        if (r < offset) return header!;
        final start = (r - offset) * columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: gap),
                Expanded(
                  child: start + c < items.length
                      ? widget.itemBuilder(context, items[start + c])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
