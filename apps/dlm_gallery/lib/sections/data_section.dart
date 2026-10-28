import 'package:dlm_ui_kit/dlm_ui_kit.dart';
import 'package:flutter/widgets.dart';

class _Row {
  const _Row(this.id, this.name, this.size, this.progress, this.status);
  final int id;
  final String name;
  final int size;
  final double progress;
  final String status;
}

final List<_Row> _rows = [
  for (var i = 0; i < 200; i++)
    _Row(
      i,
      'download-$i.bin',
      (i * 7919 % 4000 + 10) * 1048576,
      (i * 37 % 100) / 100,
      ['Active', 'Completed', 'Paused', 'Failed'][i % 4],
    ),
];

String _size(int b) => '${(b / 1048576).toStringAsFixed(0)} MB';

/// The virtualized data table with sorting, resizing and selection.
class TableSection extends StatefulWidget {
  /// Creates the section.
  const TableSection({super.key});

  @override
  State<TableSection> createState() => _TableSectionState();
}

class _TableSectionState extends State<TableSection> {
  DlmSort _sort = const DlmSort('name', ascending: true);
  Set<Object> _selected = {2};
  Map<String, double> _widths = {};
  late List<_Row> _sorted = _rows;

  void _applySort(DlmSort s) {
    final list = [..._rows];
    int cmp(_Row a, _Row b) => switch (s.columnId) {
      'size' => a.size.compareTo(b.size),
      'progress' => a.progress.compareTo(b.progress),
      'status' => a.status.compareTo(b.status),
      _ => a.id.compareTo(b.id),
    };
    list.sort((a, b) => s.ascending ? cmp(a, b) : cmp(b, a));
    setState(() {
      _sort = s;
      _sorted = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return SizedBox(
      height: 320,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.separator),
          borderRadius: BorderRadius.circular(theme.metrics.radii.small),
        ),
        child: DlmDataTable<_Row>(
          semanticLabel: 'Downloads',
          labels: DlmTableLabels(
            sortedAscending: 'sorted ascending',
            sortedDescending: 'sorted descending',
            resizeColumn: (c) => 'Resize $c',
            loadingRow: 'Loading',
          ),
          itemCount: _sorted.length,
          itemAt: (i) => _sorted[i],
          rowId: (r) => r.id,
          rowSemanticLabel: (r) => '${r.name}, ${r.status}',
          sort: _sort,
          onSort: _applySort,
          selectedIds: _selected,
          onSelectionChanged: (s) => setState(() => _selected = s),
          columnWidths: _widths,
          onColumnResized: (id, w) =>
              setState(() => _widths = {..._widths, id: w}),
          columns: [
            DlmColumn<_Row>(
              id: 'name',
              label: 'Name',
              width: 220,
              sortable: true,
              cell: (c, r) =>
                  Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            DlmColumn<_Row>(
              id: 'status',
              label: 'Status',
              width: 110,
              sortable: true,
              cell: (c, r) => DlmBadge(
                label: r.status,
                tone: switch (r.status) {
                  'Active' => DlmTone.accent,
                  'Completed' => DlmTone.success,
                  'Failed' => DlmTone.danger,
                  _ => DlmTone.neutral,
                },
              ),
            ),
            DlmColumn<_Row>(
              id: 'progress',
              label: 'Progress',
              width: 160,
              sortable: true,
              cell: (c, r) => SizedBox(
                width: 120,
                child: DlmProgressBar(value: r.progress, semanticLabel: r.name),
              ),
            ),
            DlmColumn<_Row>(
              id: 'size',
              label: 'Size',
              width: 100,
              sortable: true,
              alignment: AlignmentDirectional.centerEnd,
              cell: (c, r) => Text(_size(r.size)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The tri-state file tree.
class TreeSection extends StatefulWidget {
  /// Creates the section.
  const TreeSection({super.key});

  @override
  State<TreeSection> createState() => _TreeSectionState();
}

class _TreeSectionState extends State<TreeSection> {
  Set<Object> _expanded = {'season1'};
  Set<Object> _checked = {'season1/e01.mkv', 'extras/trailer.mp4'};

  static final List<DlmTreeNode> _roots = [
    DlmTreeNode(
      id: 'season1',
      label: 'Season 1',
      icon: const DlmIcon(DlmIconName.chevronRight),
      children: [
        for (var i = 1; i <= 4; i++)
          DlmTreeNode(
            id: 'season1/e0$i.mkv',
            label: 'Episode 0$i.mkv',
            trailing: Text('${1 + i * 120} MB'),
          ),
      ],
    ),
    const DlmTreeNode(
      id: 'extras',
      label: 'Extras',
      children: [
        DlmTreeNode(
          id: 'extras/trailer.mp4',
          label: 'Trailer.mp4',
          trailing: Text('48 MB'),
        ),
        DlmTreeNode(
          id: 'extras/subs',
          label: 'Subtitles',
          children: [
            DlmTreeNode(id: 'extras/subs/en.srt', label: 'English.srt'),
            DlmTreeNode(id: 'extras/subs/de.srt', label: 'German.srt'),
          ],
        ),
      ],
    ),
    const DlmTreeNode(id: 'readme', label: 'README.txt'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = DlmTheme.of(context);
    return SizedBox(
      height: 280,
      width: 520,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.separator),
          borderRadius: BorderRadius.circular(theme.metrics.radii.small),
        ),
        child: DlmTree(
          semanticLabel: 'Files',
          roots: _roots,
          expandedIds: _expanded,
          checkedIds: _checked,
          onExpandedChanged: (s) => setState(() => _expanded = s),
          onCheckedChanged: (s) => setState(() => _checked = s),
        ),
      ),
    );
  }
}

/// The weekday x time editor.
class ScheduleSection extends StatefulWidget {
  /// Creates the section.
  const ScheduleSection({super.key});

  @override
  State<ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<ScheduleSection> {
  Set<int> _cells = {
    for (var d = 0; d < 5; d++)
      for (var h = 22; h < 24; h++) d * 24 + h,
    for (var d = 5; d < 7; d++)
      for (var h = 0; h < 24; h++) d * 24 + h,
  };

  @override
  Widget build(BuildContext context) {
    return DlmScheduleGrid(
      cells: _cells,
      dayLabels: const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ],
      slotLabel: (s) => '${s.toString().padLeft(2, '0')}:00',
      semanticLabel: 'Download window',
      onChanged: (c) => setState(() => _cells = c),
    );
  }
}

/// The chart frame around a painted line.
class ChartSection extends StatelessWidget {
  /// Creates the section.
  const ChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = dlmChartPalette(context);
    return SizedBox(
      width: 620,
      child: DlmChartFrame(
        title: 'Speed',
        summary: 'Download speed over the last minute: peak 12 MB/s, average 7 MB/s.',
        legend: [
          DlmLegendItem(label: 'Download', color: palette[0]),
          DlmLegendItem(label: 'Upload', color: palette[1]),
        ],
        child: CustomPaint(
          painter: _LinesPainter([
            palette[0],
            palette[1],
          ], DlmTheme.of(context).colors.separator),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  _LinesPainter(this.colors, this.grid);
  final List<Color> colors;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final g = Paint()..color = grid;
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), g);
    }
    for (var s = 0; s < colors.length; s++) {
      final path = Path();
      for (var i = 0; i <= 60; i++) {
        final x = size.width * i / 60;
        final v =
            0.5 + 0.3 * ((i * (s + 3)) % 17) / 17 + 0.1 * (s == 0 ? 1 : -1);
        final y = size.height * (1 - v.clamp(0.05, 0.95));
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[s]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_LinesPainter old) =>
      old.colors != colors || old.grid != grid;
}
