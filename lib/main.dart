// lib/main.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
return MaterialApp(
  title: 'Text Canvas ',
  theme: ThemeData(primarySwatch: Colors.green),
  home: const CanvasScreen(),
);
  return MaterialApp(
    title: "Obuli's Text Canvas",
    theme: ThemeData(primarySwatch: Colors.green),
    home: const CanvasScreen(),
  );
  }
}


class TextItem {
  late final String id;
  String text;
  double dx;
  double dy;
  double fontSize;
  String fontFamily;
  bool bold;
  bool italic;
  Color color;

  TextItem({
    required this.id,
    required this.text,
    required this.dx,
    required this.dy,
    this.fontSize = 28,
    this.fontFamily = 'Roboto',
    this.bold = false,
    this.italic = false,
    this.color = Colors.black,
  });

  TextItem copy() => TextItem(
        id: id,
        text: text,
        dx: dx,
        dy: dy,
        fontSize: fontSize,
        fontFamily: fontFamily,
        bold: bold,
        italic: italic,
        color: color,
      );
}

enum ActionType { add, remove, update }

class HistoryEntry {
  final ActionType type;
  final TextItem before;
  final TextItem? after;
  HistoryEntry({required this.type, required this.before, this.after});
}

class CanvasScreen extends StatefulWidget {
  const CanvasScreen({super.key});
  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  final Map<String, TextItem> _items = {};
  final Map<String, TextItem> _dragBefore = {};
  final List<HistoryEntry> _history = [];
  final List<HistoryEntry> _redo = [];
  String? _selectedId;
  final _canvasKey = GlobalKey();
  final _uuid = const Uuid();

  // ----------------- FONT MAP (expandable) -----------------
  // Map font name -> function returning TextStyle using google_fonts
  final Map<String, TextStyle Function({double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, Color? color})> fontMap = {
    'Roboto': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.roboto(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Lato': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.lato(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Montserrat': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.montserrat(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Poppins': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.poppins(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Open Sans': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.openSans(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Nunito': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.nunito(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Oswald': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.oswald(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Raleway': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.raleway(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Merriweather': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.merriweather(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Source Sans Pro': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.sourceSansPro(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Playfair Display': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.playfairDisplay(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Comfortaa': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.comfortaa(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Karla': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.karla(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'PT Sans': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.ptSans(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'PT Serif': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.ptSerif(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Abril Fatface': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.abrilFatface(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Barlow': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.barlow(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Cabin': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.cabin(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Cinzel': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.cinzel(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'DM Sans': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.dmSans(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Hind': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.hind(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Josefin Sans': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.josefinSans(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Quicksand': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.quicksand(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Rubik': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.rubik(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Satisfy': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.satisfy(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Spectral': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.spectral(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Titillium Web': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.titilliumWeb(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Work Sans': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.workSans(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Zilla Slab': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.zillaSlab(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Pacifico': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.pacifico(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    'Great Vibes': ({fontSize, fontWeight, fontStyle, color}) => GoogleFonts.greatVibes(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: color),
    // Add more here to expand the collection...
  };

  // ----------------- COLOR PALETTE -----------------
  final List<Color> colorPalette = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.amber,
    // add more shades as needed
  ];

  // ----------------- HELPERS -----------------
  void _pushHistory(HistoryEntry e) {
    _history.add(e);
    _redo.clear();
  }

  // Determine default center using canvas size (MediaQuery fallback)
  Future<Offset> _defaultCenter() async {
    await Future.delayed(Duration.zero);
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final s = box.size;
      return Offset(max(20, s.width / 2 - 60), max(20, s.height / 2 - 20));
    }
    final mq = MediaQuery.of(context);
    return Offset(mq.size.width / 2 - 60, mq.size.height * 0.4);
  }

  double _responsiveFontSize() {
    final mq = MediaQuery.of(context);
    return (mq.size.width / 18).clamp(14.0, 48.0);
  }

  // Add text with prompt
  Future<void> _addTextPrompt() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter text'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Type...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Add')),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    final center = await _defaultCenter();
    final id = _uuid.v4();
    final item = TextItem(
      id: id,
      text: result.trim(),
      dx: center.dx,
      dy: center.dy,
      fontSize: _responsiveFontSize(),
    );
    setState(() {
      _items[id] = item;
      _selectedId = id;
      _pushHistory(HistoryEntry(type: ActionType.add, before: item.copy(), after: item.copy()));
    });
  }

  void _removeSelected() {
    if (_selectedId == null) return;
    final id = _selectedId!;
    final before = _items[id]!.copy();
    setState(() {
      _items.remove(id);
      _selectedId = null;
      _pushHistory(HistoryEntry(type: ActionType.remove, before: before));
    });
  }

  void _openEditor(TextItem item) {
    final textController = TextEditingController(text: item.text);
    double fontSize = item.fontSize;
    String fontFamily = item.fontFamily;
    bool bold = item.bold;
    bool italic = item.italic;
    Color color = item.color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(builder: (context, setLocal) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(child: TextField(controller: textController, decoration: const InputDecoration(labelText: 'Text'))),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {
                          Navigator.of(ctx).pop();
                          _removeSelected();
                        })
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const Text('Size'),
                        Expanded(
                          child: Slider(value: fontSize, min: 12, max: 120, divisions: 108, label: fontSize.round().toString(), onChanged: (v) => setLocal(() => fontSize = v)),
                        ),
                        Text(fontSize.round().toString()),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      const Text('Font:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: fontMap.keys.map((f) {
                              final style = fontMap[f]!(fontSize: 18);
                              return GestureDetector(
                                onTap: () => setLocal(() => fontFamily = f),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: fontFamily == f ? Colors.green : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(f, style: style),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      IconButton(icon: Icon(bold ? Icons.format_bold : Icons.format_bold_outlined), onPressed: () => setLocal(() => bold = !bold)),
                      IconButton(icon: Icon(italic ? Icons.format_italic : Icons.format_italic_outlined), onPressed: () => setLocal(() => italic = !italic)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Color palette
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colorPalette.map((c) {
                        return GestureDetector(
                          onTap: () => setLocal(() => color = c),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              border: Border.all(color: color == c ? Colors.black : Colors.transparent, width: 2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 3,
                        children: fontMap.keys.map((f) {
                          final tstyle = fontMap[f]!(fontSize: 18, fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontStyle: italic ? FontStyle.italic : FontStyle.normal, color: color);
                          return ListTile(
                            onTap: () => setLocal(() => fontFamily = f),
                            title: Text(f, style: tstyle, overflow: TextOverflow.ellipsis),
                            selected: fontFamily == f,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final id = item.id;
                            final updated = item.copy();
                            updated.text = textController.text;
                            updated.fontSize = fontSize;
                            updated.fontFamily = fontFamily;
                            updated.bold = bold;
                            updated.italic = italic;
                            updated.color = color;
                            Navigator.of(ctx).pop();
                            setState(() {
                              _items[id] = updated;
                              _pushHistory(HistoryEntry(type: ActionType.update, before: item.copy(), after: updated.copy()));
                            });
                          },
                          child: const Text('Save'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                        const Spacer(),
                        Text('Preview', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        // preview sample
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            textController.text.isEmpty ? 'Sample' : textController.text,
                            style: fontMap[fontFamily]!(fontSize: fontSize, fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontStyle: italic ? FontStyle.italic : FontStyle.normal, color: color),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
        );
      },
    );
  }

  // Ensure item stays inside canvas bounds
  Offset _clampToCanvas(double dx, double dy) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset(dx, dy);
    final size = box.size;
    final padding = 10.0;
    final clampedX = dx.clamp(padding, size.width - padding);
    final clampedY = dy.clamp(padding, size.height - padding);
    return Offset(clampedX, clampedY);
  }

  // Build the widget for each text item - movable & clamped
  Widget _buildItem(TextItem item) {
    final isSelected = _selectedId == item.id;
    final textStyle = fontMap[item.fontFamily]!(
      fontSize: item.fontSize,
      fontWeight: item.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: item.italic ? FontStyle.italic : FontStyle.normal,
      color: item.color,
    );

    return Positioned(
      left: item.dx,
      top: item.dy,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedId = item.id);
          _openEditor(item);
        },
        onPanStart: (_) {
          setState(() {
            _selectedId = item.id;
            _dragBefore[item.id] = item.copy();
          });
        },
        onPanUpdate: (details) {
          setState(() {
            final newOffset = _clampToCanvas(item.dx + details.delta.dx, item.dy + details.delta.dy);
            item.dx = newOffset.dx;
            item.dy = newOffset.dy;
          });
        },
        onPanEnd: (_) {
          final before = _dragBefore[item.id];
          if (before != null) {
            _pushHistory(HistoryEntry(type: ActionType.update, before: before.copy(), after: item.copy()));
            _dragBefore.remove(item.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: isSelected
              ? BoxDecoration(border: Border.all(color: Colors.greenAccent, width: 2), borderRadius: BorderRadius.circular(6), color: Colors.white.withOpacity(0.6))
              : null,
          child: Text(item.text, style: textStyle),
        ),
      ),
    );
  }

  void _undo() {
    if (_history.isEmpty) return;
    final e = _history.removeLast();
    if (e.type == ActionType.add) {
      setState(() => _items.remove(e.before.id));
    } else if (e.type == ActionType.remove) {
      setState(() => _items[e.before.id] = e.before.copy());
    } else if (e.type == ActionType.update) {
      setState(() => _items[e.before.id] = e.before.copy());
    }
    _redo.add(e);
  }

  void _redoOp() {
    if (_redo.isEmpty) return;
    final e = _redo.removeLast();
    if (e.type == ActionType.add) {
      setState(() => _items[e.before.id] = e.before.copy());
    } else if (e.type == ActionType.remove) {
      setState(() => _items.remove(e.before.id));
    } else if (e.type == ActionType.update && e.after != null) {
      setState(() => _items[e.after!.id] = e.after!.copy());
    }
    _history.add(e);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final canvasHeight = (mq.size.height * 0.7).clamp(300.0, mq.size.height * 0.85);
    final sidePadding = mq.size.width * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Obuli's Text Canvas"),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _history.isNotEmpty ? _undo : null),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo.isNotEmpty ? _redoOp : null),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 8),
          child: Column(
            children: [
              // Canvas inside InteractiveViewer so user can pan/zoom entire canvas
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(500),
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Container(
                      key: _canvasKey,
                      color: Colors.grey[200],
                      width: max(800, mq.size.width - sidePadding * 2), // large canvas width to allow space (responsive)
                      height: canvasHeight,
                      child: Stack(children: _items.values.map(_buildItem).toList()),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tool area: horizontal scroll to avoid overflow + SafeArea
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      ElevatedButton.icon(onPressed: _addTextPrompt, icon: const Icon(Icons.add), label: const Text('Add text')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectedId != null ? () => _openEditor(_items[_selectedId]!) : null,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit selected'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectedId != null ? _removeSelected : null,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // quick random color apply to selected
                          if (_selectedId == null) return;
                          setState(() {
                            final it = _items[_selectedId]!;
                            it.color = colorPalette[Random().nextInt(colorPalette.length)];
                            _pushHistory(HistoryEntry(type: ActionType.update, before: it.copy(), after: it.copy()));
                          });
                        },
                        icon: const Icon(Icons.color_lens),
                        label: const Text('Random color'),
                      ),
                      const SizedBox(width: 8),
                      // font picker shortcut (open a compact font chooser)
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_selectedId == null) return;
                          // open a small font picker sheet
                          final item = _items[_selectedId]!;
                          final chosen = item.fontFamily;
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => SizedBox(
                              height: 260,
                              child: Column(
                                children: [
                                  const Padding(padding: EdgeInsets.all(8), child: Text('Pick a font')),
                                  Expanded(
                                    child: ListView(
                                      children: fontMap.keys.map((f) {
                                        return ListTile(
                                          title: Text(f, style: fontMap[f]!(fontSize: 18)),
                                          onTap: () {
                                            Navigator.pop(ctx);
                                            setState(() {
                                              final before = item.copy();
                                              item.fontFamily = f;
                                              _pushHistory(HistoryEntry(type: ActionType.update, before: before, after: item.copy()));
                                            });
                                          },
                                          selected: chosen == f,
                                        );
                                      }).toList(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.font_download),
                        label: const Text('Fonts'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // show large color picker
                          if (_selectedId == null) return;
                          final item = _items[_selectedId]!;
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => SizedBox(
                              height: 220,
                              child: GridView.count(
                                crossAxisCount: 6,
                                padding: const EdgeInsets.all(12),
                                children: colorPalette.map((c) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      setState(() {
                                        final before = item.copy();
                                        item.color = c;
                                        _pushHistory(HistoryEntry(type: ActionType.update, before: before, after: item.copy()));
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.palette),
                        label: const Text('Colors'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // duplicate selected
                          if (_selectedId == null) return;
                          final base = _items[_selectedId]!;
                          final id = _uuid.v4();
                          final dup = base.copy();
                          dup.id = id;
                          dup.dx += 20;
                          dup.dy += 20;
                          setState(() {
                            _items[id] = dup;
                            _pushHistory(HistoryEntry(type: ActionType.add, before: dup.copy(), after: dup.copy()));
                          });
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Duplicate'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // clear canvas
                          showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                    title: const Text('Clear all?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            setState(() {
                                              _items.clear();
                                              _pushHistory(HistoryEntry(type: ActionType.update, before: TextItem(id: 'clear', text: 'clear', dx: 0, dy: 0)));
                                            });
                                          },
                                          child: const Text('Clear')),
                                    ],
                                  ));
                        },
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
