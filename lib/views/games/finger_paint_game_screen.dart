import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_scaffold.dart';

class FingerPaintGameScreen extends StatefulWidget {
  const FingerPaintGameScreen({super.key});

  @override
  State<FingerPaintGameScreen> createState() => _FingerPaintGameScreenState();
}

class _FingerPaintGameScreenState extends State<FingerPaintGameScreen> {
  final List<_Stroke> _strokes = <_Stroke>[];
  _Stroke? _active;

  Color _color = const Color(0xFF00BBF9);
  double _width = 18;
  double? _scorePct;
  String _badgeEmoji = '✍️';

  Size _canvasSize = Size.zero;
  bool _scoring = false;

  late final List<_TemplatePainter> _templates;
  int _templateIndex = 0;

  _TemplatePainter get _template => _templates[_templateIndex % _templates.length];

  void _nextTemplate() {
    _templateIndex = (_templateIndex + 1) % _templates.length;
  }

  void _start(Offset p) {
    _scorePct = null;
    _active = _Stroke(color: _color, width: _width, points: <Offset>[p]);
    _strokes.add(_active!);
    setState(() {});
  }

  void _add(Offset p) {
    final s = _active;
    if (s == null) return;
    s.points.add(p);
    setState(() {});
  }

  void _end() {
    _active = null;
    setState(() {});
    _scoreIfPossible();
  }

  void _clear() {
    _active = null;
    _strokes.clear();
    _scorePct = null;
    setState(() {});
  }

  void _undo() {
    _active = null;
    if (_strokes.isNotEmpty) _strokes.removeLast();
    _scorePct = null;
    setState(() {});
    _scoreIfPossible();
  }

  Future<void> _scoreIfPossible() async {
    if (_canvasSize.isEmpty) return;
    if (_strokes.isEmpty) return;
    if (_scoring) return;

    setState(() => _scoring = true);
    double? pct;
    try {
      pct = await _TraceScorer.scoreOne(
        size: _canvasSize,
        strokes: List<_Stroke>.from(_strokes),
        template: _template,
      );
      if (!mounted) return;
      setState(() {
        _scorePct = pct;
        _badgeEmoji = switch (pct ?? 0) {
          >= 92 => '🤩',
          >= 80 => '😄',
          >= 60 => '🙂',
          >= 40 => '😅',
          _ => '💪',
        };
      });
    } finally {
      if (mounted) setState(() => _scoring = false);
    }

    // Natijani 3 sekund ko‘rsatib, keyingi qolipga o‘tamiz.
    if (!mounted) return;
    if (pct == null) return;
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _nextTemplate();
      _strokes.clear();
      _scorePct = null;
      _badgeEmoji = '✍️';
    });
  }

  @override
  void initState() {
    super.initState();
    final list = <_TemplatePainter>[];
    for (var i = 0; i <= 9; i++) {
      list.add(_GlyphTemplate('$i'));
    }
    for (var code = 'A'.codeUnitAt(0); code <= 'Z'.codeUnitAt(0); code++) {
      list.add(_GlyphTemplate(String.fromCharCode(code)));
    }
    _templates = list;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final palette = <Color>[
      const Color(0xFF00BBF9),
      const Color(0xFF9B5DE5),
      const Color(0xFFFF4D6D),
      const Color(0xFFFFB703),
      const Color(0xFF2EC4B6),
      const Color(0xFF22C55E),
      const Color(0xFF111827),
      const Color(0xFFFFFFFF),
    ];

    Widget chip({
      required Widget child,
      required VoidCallback onTap,
      required bool selected,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? cs.primary.withOpacity(0.16) : cs.surface.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? cs.primary.withOpacity(0.55) : cs.outlineVariant.withOpacity(0.35),
              ),
            ),
            child: child,
          ),
        ),
      );
    }

    return GameScaffold(
      title: 'Barmoq bilan chiz',
      subtitle: 'Qolip ustidan chiz — har safar yangi rasm',
      frameAccent: const Color(0xFF00BBF9),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _clear,
        icon: const Icon(Icons.delete_sweep_rounded),
        label: const Text('Tozalash'),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: 56,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 140),
                opacity: (_scorePct != null || _scoring) ? 1 : 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.surface.withOpacity(0.35),
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      Text(_badgeEmoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _scoring
                              ? 'Tekshiryapman…'
                              : 'To‘g‘rilik: ${(_scorePct ?? 0).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface.withOpacity(0.85),
                          ),
                        ),
                      ),
                      if (!_scoring && _scorePct != null)
                        TextButton.icon(
                          onPressed: _scoreIfPossible,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Qayta'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip(
                selected: false,
                onTap: _undo,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.undo_rounded, size: 18, color: cs.onSurface.withOpacity(0.85)),
                    const SizedBox(width: 6),
                    Text(
                      'Ortga',
                      style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface.withOpacity(0.85)),
                    ),
                  ],
                ),
              ),
              chip(
                selected: false,
                onTap: () => setState(() => _width = 14),
                child: const Text('Yupqa', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              chip(
                selected: false,
                onTap: () => setState(() => _width = 18),
                child: const Text('O‘rtacha', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              chip(
                selected: false,
                onTap: () => setState(() => _width = 24),
                child: const Text('Qalin', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              for (final c in palette)
                chip(
                  selected: _color.value == c.value,
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (c.value == 0xFFFFFFFF)
                            ? cs.outlineVariant.withOpacity(0.6)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1220).withOpacity(0.35) : Colors.white.withOpacity(0.55),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final newSize = Size(constraints.maxWidth, constraints.maxHeight);
                    if (newSize != _canvasSize) {
                      _canvasSize = newSize;
                    }
                    return Listener(
                      onPointerDown: (e) => _start(e.localPosition),
                      onPointerMove: (e) => _add(e.localPosition),
                      onPointerUp: (_) => _end(),
                      onPointerCancel: (_) => _end(),
                      child: CustomPaint(
                        painter: _PaintPainter(
                          strokes: _strokes,
                          template: _template,
                          templateColor: cs.onSurface.withOpacity(isDark ? 0.25 : 0.18),
                        ),
                        child: Center(
                          child: IgnorePointer(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 160),
                              opacity: _strokes.isEmpty ? 1 : 0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.gesture_rounded, size: 34, color: cs.onSurface.withOpacity(0.6)),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Qolip ustidan chizing',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: cs.onSurface.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stroke {
  _Stroke({required this.color, required this.width, required this.points});

  final Color color;
  final double width;
  final List<Offset> points;
}

class _PaintPainter extends CustomPainter {
  const _PaintPainter({
    required this.strokes,
    required this.template,
    required this.templateColor,
  });

  final List<_Stroke> strokes;
  final _TemplatePainter template;
  final Color templateColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    template.paintOutline(canvas, size, templateColor);

    for (final s in strokes) {
      if (s.points.length < 2) continue;

      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (var i = 1; i < s.points.length; i++) {
        final p = s.points[i];
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PaintPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.template != template ||
      oldDelegate.templateColor != templateColor;
}

abstract class _TemplatePainter {
  const _TemplatePainter();

  void paintOutline(Canvas canvas, Size size, Color color);

  void paintMask(Canvas canvas, Size size, Color color);

  /// “Ichini” (fill) maska qilib chizadi — % hisoblash uchun.
  void paintFill(Canvas canvas, Size size, Color color);
}

class _GlyphTemplate extends _TemplatePainter {
  const _GlyphTemplate(this.glyph);

  final String glyph;

  @override
  void paintOutline(Canvas canvas, Size size, Color color) {
    final rect = _templateRect(size);
    final tp = _textPainter(size, mode: _GlyphMode.outline, color: color);
    canvas.save();
    canvas.translate(rect.left, rect.top);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  void paintMask(Canvas canvas, Size size, Color color) {
    final rect = _templateRect(size);
    // Scoring uchun: kontur bandini (tolerans bilan) maska qilamiz.
    final tp = _textPainter(size, mode: _GlyphMode.maskBand, color: color);
    canvas.save();
    canvas.translate(rect.left, rect.top);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  void paintFill(Canvas canvas, Size size, Color color) {
    final rect = _templateRect(size);
    final tp = _textPainter(size, mode: _GlyphMode.fill, color: color);
    canvas.save();
    canvas.translate(rect.left, rect.top);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  TextPainter _textPainter(Size size, {required _GlyphMode mode, required Color color}) {
    final fontSize = size.shortestSide * 0.78;
    // Kontur yanada yupqaroq
    final outlineW = (size.shortestSide * 0.012).clamp(2.0, 7.0);
    // Bola uchun "yumshoq" baho: kontur atrofidagi tolerant bandni kengroq qilamiz.
    final maskBandW = (outlineW * 3.6).clamp(outlineW + 6, 30.0);

    final paintingStyle = switch (mode) {
      _GlyphMode.fill => PaintingStyle.fill,
      _GlyphMode.outline => PaintingStyle.stroke,
      _GlyphMode.maskBand => PaintingStyle.stroke,
    };

    final strokeWidth = switch (mode) {
      _GlyphMode.fill => 0.0,
      _GlyphMode.outline => outlineW,
      _GlyphMode.maskBand => maskBandW,
    };

    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      foreground: Paint()
        ..style = paintingStyle
        ..strokeWidth = strokeWidth
        ..color = color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final tp = TextPainter(
      text: TextSpan(text: glyph, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    return tp;
  }

  Rect _templateRect(Size size) {
    // markazga joylash: template o'lchami TextPainter.layout() bilan keladi,
    // shu sabab anchadan keyin painter tarafida yana markazlaymiz.
    // Bu rect faqat translate uchun.
    final dummy = _textPainter(size, mode: _GlyphMode.fill, color: const Color(0xFFFFFFFF));
    final left = (size.width - dummy.width) / 2;
    final top = (size.height - dummy.height) / 2;
    return Rect.fromLTWH(left, top, dummy.width, dummy.height);
  }
}

enum _GlyphMode { fill, outline, maskBand }

class _TraceScorer {
  static Future<double> scoreOne({
    required Size size,
    required List<_Stroke> strokes,
    required _TemplatePainter template,
  }) async {
    // Telefon/web uchun barqaror: kichik bitmapda hisoblaymiz (downsample).
    final rs = _RenderSize.from(size);

    // Render: mask (template fill) and draw (strokes) -> pixels.
    // Faqat ichini bosgan chizma yuqori % beradi.
    final templateImg = await _renderTemplateFill(rs, template);
    final drawImg = await _renderStrokesMask(rs, strokes);

    final t = await _toRgba(templateImg);
    final d = await _toRgba(drawImg);
    if (t == null || d == null) return 0;

    var templateOn = 0;
    var drawOn = 0;
    var overlap = 0;

    // RGBA: alpha = i+3
    for (var i = 0; i < t.length; i += 4) {
      final ta = t[i + 3];
      final da = d[i + 3];
      final ton = ta > 20;
      final don = da > 20;
      if (ton) templateOn++;
      if (don) drawOn++;
      if (ton && don) overlap++;
    }

    if (templateOn == 0 || drawOn == 0) return 0;

    final precision = overlap / drawOn;
    final recall = overlap / templateOn;

    final r = recall.clamp(0.0, 1.0);
    final p = precision.clamp(0.0, 1.0);

    // Juda yumshoq baholash (bola uchun):
    // - Asosiy narsa: ichiga qancha tegdi (recall)
    // - Tashqariga chiqish deyarli hisobga olinmaydi
    // - Kichik recall ham tez 100% ga “ko‘tariladi”
    //
    // Mapping:
    //   recall <= 0.05  -> 0..25%
    //   recall 0.05..0.35 -> 25..95%
    //   recall >= 0.35 -> 100%
    double score01;
    if (r <= 0.05) {
      score01 = (r / 0.05) * 0.25;
    } else if (r >= 0.35) {
      score01 = 1.0;
    } else {
      final t = (r - 0.05) / (0.35 - 0.05); // 0..1
      score01 = 0.25 + t * 0.70; // 0.25..0.95
      // yana ozroq boost
      score01 = math.pow(score01, 0.6).toDouble();
      if (score01 >= 0.90) score01 = 1.0;
    }

    // Precision faqat juda-juda yomon bo‘lsa biroz tushiradi (aks holda e’tiborsiz).
    if (p < 0.25) score01 = (score01 * 0.9).clamp(0.0, 1.0);

    return (score01 * 100).clamp(0, 100).toDouble();
  }

  static Future<Uint8List?> _toRgba(ui.Image img) async {
    // Web’da rawRgba ba’zan null qaytaradi. Shunda png -> decode -> rawRgba qilamiz.
    final direct = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (direct != null) return direct.buffer.asUint8List();

    final png = await img.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) return null;

    final codec = await ui.instantiateImageCodec(png.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final rgba = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return rgba?.buffer.asUint8List();
  }

  static Future<ui.Image> _renderTemplateMask(_RenderSize rs, _TemplatePainter template) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Offset.zero & rs.logicalSize);
    template.paintMask(canvas, rs.logicalSize, const Color(0xFFFFFFFF));
    final pic = recorder.endRecording();
    return pic.toImage(rs.pixelW, rs.pixelH);
  }

  static Future<ui.Image> _renderTemplateFill(_RenderSize rs, _TemplatePainter template) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Offset.zero & rs.logicalSize);
    template.paintFill(canvas, rs.logicalSize, const Color(0xFFFFFFFF));
    final pic = recorder.endRecording();
    return pic.toImage(rs.pixelW, rs.pixelH);
  }

  static Future<ui.Image> _renderStrokesMask(_RenderSize rs, List<_Stroke> strokes) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Offset.zero & rs.logicalSize);

    for (final s in strokes) {
      if (s.points.length < 2) continue;
      final paint = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..strokeWidth = (s.width * rs.scale).clamp(2.0, 40.0)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;

      final path = Path()
        ..moveTo(s.points.first.dx * rs.scale, s.points.first.dy * rs.scale);
      for (var i = 1; i < s.points.length; i++) {
        final p = s.points[i];
        path.lineTo(p.dx * rs.scale, p.dy * rs.scale);
      }
      canvas.drawPath(path, paint);
    }

    final pic = recorder.endRecording();
    return pic.toImage(rs.pixelW, rs.pixelH);
  }
}

class _RenderSize {
  _RenderSize({
    required this.logicalSize,
    required this.pixelW,
    required this.pixelH,
    required this.scale,
  });

  final Size logicalSize;
  final int pixelW;
  final int pixelH;
  final double scale;

  static _RenderSize from(Size original) {
    const targetMax = 220.0; // tez + barqaror hisob uchun
    final maxSide = original.longestSide;
    final s = maxSide <= targetMax ? 1.0 : (targetMax / maxSide);
    final logical = Size(original.width * s, original.height * s);
    return _RenderSize(
      logicalSize: logical,
      pixelW: logical.width.ceil().clamp(1, 4096),
      pixelH: logical.height.ceil().clamp(1, 4096),
      scale: s,
    );
  }
}


