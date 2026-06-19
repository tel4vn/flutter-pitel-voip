import 'package:flutter/material.dart';
import 'package:flutter_pitel_voip/component/button/action_button.dart';

/// Modes for the dialpad overlay.
enum DialpadMode { dtmf, transfer }

/// Key data for each dialpad button.
class _DialKey {
  final String digit;
  final String? sub;
  const _DialKey(this.digit, [this.sub]);
}

const _keys = [
  [_DialKey('1'), _DialKey('2', 'ABC'), _DialKey('3', 'DEF')],
  [_DialKey('4', 'GHI'), _DialKey('5', 'JKL'), _DialKey('6', 'MNO')],
  [_DialKey('7', 'PQRS'), _DialKey('8', 'TUV'), _DialKey('9', 'WXYZ')],
  [_DialKey('*'), _DialKey('0', '+'), _DialKey('#')],
];

/// Overlay widget that slides up from the bottom showing a 12-key dialpad.
///
/// Behaviour differs by [mode]:
/// - [DialpadMode.dtmf]: Each key press immediately sends a DTMF tone via
///   [onKeyPress]. The action button is a red **Hangup** button.
/// - [DialpadMode.transfer]: Keys accumulate in [dialpadInput]. The action
///   button is a green **Call** button that triggers blind-transfer via
///   [onActionBtn].
class DialpadOverlay extends StatelessWidget {
  const DialpadOverlay({
    Key? key,
    required this.dialpadInput,
    required this.mode,
    required this.onKeyPress,
    required this.onDelete,
    required this.onClose,
    required this.onActionBtn,
  }) : super(key: key);

  /// The digits accumulated so far (displayed in the input field).
  final String dialpadInput;

  /// Whether this dialpad is in DTMF or Transfer mode.
  final DialpadMode mode;

  /// Called with the digit string whenever a key is pressed.
  final Function(String digit) onKeyPress;

  /// Called when the user taps/long-presses the delete icon.
  final VoidCallback onDelete;

  /// Called when the user taps the ✕ close button.
  final VoidCallback onClose;

  /// Called when the bottom action button is tapped:
  /// - DTMF mode → hangup
  /// - Transfer mode → blind transfer
  final VoidCallback onActionBtn;

  @override
  Widget build(BuildContext context) {
    final bool isDtmf = mode == DialpadMode.dtmf;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // ── Tap-to-dismiss area ──────────────────────────────────────
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClose,
                child: const SizedBox.expand(),
              ),
            ),
            // ── Main dialpad sheet ───────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Close button row ─────────────────────────────────
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 4),
                          child: GestureDetector(
                            onTap: onClose,
                            behavior: HitTestBehavior.opaque,
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF6B6B6B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ── Input display ────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Invisible placeholder same size as backspace
                            // so text stays centered regardless
                            const SizedBox(width: 36),
                            Expanded(
                              child: Text(
                                dialpadInput.isEmpty ? '' : dialpadInput,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF1A1A1A),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Backspace icon (same width as left placeholder)
                            SizedBox(
                              width: 36,
                              child: dialpadInput.isNotEmpty
                                  ? GestureDetector(
                                      onTap: onDelete,
                                      onLongPress: onDelete,
                                      behavior: HitTestBehavior.opaque,
                                      child: const SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                          Icons.backspace_outlined,
                                          size: 20,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ── Keypad grid ──────────────────────────────────────
                      ..._keys.map(
                        (row) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: row
                              .map((k) => _DialpadKey(
                                    digit: k.digit,
                                    sub: k.sub,
                                    onTap: () => onKeyPress(k.digit),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ── Action button ────────────────────────────────────
                      ActionButton(
                        onPressed: onActionBtn,
                        icon: isDtmf ? Icons.call_end : Icons.call,
                        fillColor:
                            isDtmf ? Colors.red : const Color(0xFF2D9E2D),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single key on the dialpad — matches iOS Phone app aesthetics.
class _DialpadKey extends StatefulWidget {
  const _DialpadKey({
    required this.digit,
    this.sub,
    required this.onTap,
  });

  final String digit;
  final String? sub;
  final VoidCallback onTap;

  @override
  State<_DialpadKey> createState() => _DialpadKeyState();
}

class _DialpadKeyState extends State<_DialpadKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 80,
        height: 72,
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFFEDEDED)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.digit,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w300,
                color: Color(0xFF1A1A1A),
                height: 1.0,
              ),
            ),
            if (widget.sub != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.sub!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 1.8,
                  height: 1.0,
                ),
              ),
            ] else
              const SizedBox(height: 11),
          ],
        ),
      ),
    );
  }
}
