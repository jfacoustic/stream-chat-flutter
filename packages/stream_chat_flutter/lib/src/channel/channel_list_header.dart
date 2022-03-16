import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stream_chat_flutter/src/extension.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Widget builder for title
typedef TitleBuilder = Widget Function(
  BuildContext context,
  ConnectionStatus status,
  StreamChatClient client,
);

/// {@template channelListHeader}
/// Shows the current [StreamChatClient] status.
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   final StreamChatClient client;
///
///   MyApp(this.client);
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: StreamChat(
///         client: client,
///         child: Scaffold(
///             appBar: ChannelListHeader(),
///           ),
///         ),
///     );
///   }
/// }
/// ```
///
/// Usually you would use this widget as an [AppBar] inside a [Scaffold].
/// However, you can also use it as a normal widget.
///
/// Uses the inherited [StreamChatClient], by default, to fetch information
/// about the status of the [client]. You can also pass your own
/// [StreamChatClient] if you don't have it in the widget tree.
///
/// Renders the UI based on the first ancestor of type [StreamChatTheme] and
/// the [ChannelListHeaderThemeData] property. Modify it to change the widget's
/// appearance.
/// {@endtemplate}
class ChannelListHeader extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro channelListHeader}
  const ChannelListHeader({
    Key? key,
    this.client,
    this.titleBuilder,
    this.onUserAvatarTap,
    this.onNewChatButtonTap,
    this.showConnectionStateTile = false,
    this.preNavigationCallback,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
  }) : super(key: key);

  /// Use this if you don't have a [StreamChatClient] in your widget tree.
  final StreamChatClient? client;

  /// Custom title widget builder.
  ///
  /// Use this to build your own title widget based on the current
  /// [ConnectionStatus].
  final TitleBuilder? titleBuilder;

  /// The action to perform when pressing the user avatar button.
  ///
  /// By default it calls `Scaffold.of(context).openDrawer()`.
  final Function(User)? onUserAvatarTap;

  /// The action to perform when pressing the "new chat" button.
  final VoidCallback? onNewChatButtonTap;

  /// Whether to show the connection state tile
  final bool showConnectionStateTile;

  /// The function to execute before navigation is performed
  final VoidCallback? preNavigationCallback;

  /// Subtitle widget
  final Widget? subtitle;

  /// Leading widget
  ///
  /// By default it shows the logged in user's avatar
  final Widget? leading;

  /// {@macro flutter.material.appbar.actions}
  ///
  /// The "new chat" button is shown by default.
  final List<Widget>? actions;

  /// The background color for this [ChannelListHeader].
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final _client = client ?? StreamChat.of(context).client;
    final user = _client.state.currentUser;
    return ConnectionStatusBuilder(
      statusBuilder: (context, status) {
        var statusString = '';
        var showStatus = true;

        switch (status) {
          case ConnectionStatus.connected:
            statusString = context.translations.connectedLabel;
            showStatus = false;
            break;
          case ConnectionStatus.connecting:
            statusString = context.translations.reconnectingLabel;
            break;
          case ConnectionStatus.disconnected:
            statusString = context.translations.disconnectedLabel;
            break;
        }

        final chatThemeData = StreamChatTheme.of(context);
        final channelListHeaderThemeData = ChannelListHeaderTheme.of(context);
        final theme = Theme.of(context);
        return InfoTile(
          showMessage: showConnectionStateTile && showStatus,
          message: statusString,
          child: AppBar(
            toolbarTextStyle: theme.textTheme.bodyText2,
            titleTextStyle: theme.textTheme.headline6,
            systemOverlayStyle: theme.brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            elevation: 1,
            backgroundColor:
                backgroundColor ?? channelListHeaderThemeData.color,
            centerTitle: true,
            leading: leading ??
                Center(
                  child: user != null
                      ? UserAvatar(
                          user: user,
                          showOnlineStatus: false,
                          onTap: onUserAvatarTap ??
                              (_) {
                                if (preNavigationCallback != null) {
                                  preNavigationCallback!();
                                }
                                Scaffold.of(context).openDrawer();
                              },
                          borderRadius: channelListHeaderThemeData
                              .avatarTheme?.borderRadius,
                          constraints: channelListHeaderThemeData
                              .avatarTheme?.constraints,
                        )
                      : const Offstage(),
                ),
            actions: actions ??
                [
                  StreamNeumorphicButton(
                    child: IconButton(
                      icon: ConnectionStatusBuilder(
                        statusBuilder: (context, status) {
                          Color? color;
                          switch (status) {
                            case ConnectionStatus.connected:
                              color = chatThemeData.colorTheme.accentPrimary;
                              break;
                            case ConnectionStatus.connecting:
                              color = Colors.grey;
                              break;
                            case ConnectionStatus.disconnected:
                              color = Colors.grey;
                              break;
                          }
                          return SvgPicture.asset(
                            'svgs/icon_pen_write.svg',
                            package: 'stream_chat_flutter',
                            width: 24,
                            height: 24,
                            color: color,
                          );
                        },
                      ),
                      onPressed: onNewChatButtonTap,
                    ),
                  ),
                ],
            title: Column(
              children: [
                Builder(
                  builder: (context) {
                    if (titleBuilder != null) {
                      return titleBuilder!(context, status, _client);
                    }
                    switch (status) {
                      case ConnectionStatus.connected:
                        return const _ConnectedTitleState();
                      case ConnectionStatus.connecting:
                        return const _ConnectingTitleState();
                      case ConnectionStatus.disconnected:
                        return _DisconnectedTitleState(client: _client);
                      default:
                        return const Offstage();
                    }
                  },
                ),
                subtitle ?? const Offstage(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConnectedTitleState extends StatelessWidget {
  const _ConnectedTitleState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatThemeData = StreamChatTheme.of(context);
    return Text(
      context.translations.streamChatLabel,
      style: chatThemeData.textTheme.headlineBold.copyWith(
        color: chatThemeData.colorTheme.textHighEmphasis,
      ),
    );
  }
}

class _ConnectingTitleState extends StatelessWidget {
  const _ConnectingTitleState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 16,
          width: 16,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          context.translations.searchingForNetworkText,
          style: ChannelListHeaderTheme.of(context).titleStyle?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _DisconnectedTitleState extends StatelessWidget {
  const _DisconnectedTitleState({
    Key? key,
    required this.client,
  }) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    final chatThemeData = StreamChatTheme.of(context);
    final channelListHeaderTheme = ChannelListHeaderTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.translations.offlineLabel,
          style: channelListHeaderTheme.titleStyle?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => client
            ..closeConnection()
            ..openConnection(),
          child: Text(
            context.translations.tryAgainLabel,
            style: channelListHeaderTheme.titleStyle?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: chatThemeData.colorTheme.accentPrimary,
            ),
          ),
        ),
      ],
    );
  }
}