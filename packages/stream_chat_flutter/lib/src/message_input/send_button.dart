import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// The button for sending a message.
///
/// Used in [AnimatedSendButton]. Should not be directly used anywhere else.
class SendButton extends StatelessWidget {
  /// Builds a [SendButton].
  const SendButton({
    Key? key,
    required this.assetName,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  /// The asset name to use for the icon.
  final String assetName;

  /// The color of the icon.
  final Color color;

  /// The callback to perform when the button is pressed or clicked.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IconButton(
        onPressed: onPressed,
        padding: const EdgeInsets.all(0),
        splashRadius: 24,
        constraints: const BoxConstraints.tightFor(
          height: 24,
          width: 24,
        ),
        icon: StreamSvgIcon(
          assetName: assetName,
          color: color,
        ),
      ),
    );
  }
}