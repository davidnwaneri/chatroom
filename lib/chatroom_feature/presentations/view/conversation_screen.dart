import 'package:chatroom/chatroom_feature/domain/entities/conversation_entity.dart';
import 'package:chatroom/chatroom_feature/domain/entities/message_entity.dart';
import 'package:chatroom/chatroom_feature/presentations/blocs/conversation_list/conversation_list_bloc.dart';
import 'package:chatroom/chatroom_feature/presentations/view/chatroom_details_screen.dart';
import 'package:chatroom/chatroom_feature/presentations/widgets/chatroom_profile_avatar.dart';
import 'package:chatroom/chatroom_feature/presentations/widgets/error_view.dart';
import 'package:chatroom/chatroom_feature/presentations/widgets/loading_view.dart';
import 'package:chatroom/chatroom_feature/presentations/widgets/message_text_field.dart';
import 'package:chatroom/chatroom_feature/presentations/widgets/message_widget.dart';
import 'package:chatroom/utils/padding_constants.dart';
import 'package:chatroom/utils/widget_library/widget_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen._({
    required this.conversation,
    // ignore: unused_element
    super.key,
  });

  final ConversationEntity conversation;

  static const routeName = '/conversation';

  static Route<void> route(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeTransition(
          opacity: animation,
          child: ConversationScreen._(
            conversation: settings.arguments! as ConversationEntity,
          ),
        );
      },
    );
  }

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _fetchMessages() {
    context //
        .read<ConversationListBloc>() //
        .add(ConversationMessagesFetched(widget.conversation.id));
  }

  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _goToChatRoomDetails() {
    Navigator.of(context).pushNamed(
      ChatroomDetailsScreen.routeName,
      arguments: widget.conversation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          titleSpacing: 0,
          title: InkWell(
            onTap: _goToChatRoomDetails,
            customBorder: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ChatroomProfileAvatar(),
                  const Space(5),
                  Hero(
                    tag: widget.conversation.id,
                    transitionOnUserGestures: true,
                    child: Text(widget.conversation.name),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: horizontalPadding12 + const EdgeInsets.only(bottom: 4),
          child: BlocBuilder<ConversationListBloc, ConversationListState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: switch (state.status) {
                      ConversationListInitial() => const SizedBox(),
                      ConversationListLoading(:final conversationId) => (conversationId == widget.conversation.id)
                          ? const LoadingView()
                          : _MessageLoadedView(
                              state.messagesForConversation(widget.conversation.id),
                            ),
                      ConversationListSuccess() => _MessageLoadedView(
                          state.messagesForConversation(widget.conversation.id),
                        ),
                      ConversationListFailure(:final message, :final conversationId) =>
                        (conversationId == widget.conversation.id)
                            ? ErrorView(
                                message: message,
                                onRetry: _fetchMessages,
                              )
                            : _MessageLoadedView(
                                state.messagesForConversation(widget.conversation.id),
                              ),
                    },
                  ),
                  MessageTextField(
                    controller: _textController,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MessageLoadedView extends StatelessWidget {
  const _MessageLoadedView(this.messages);

  final List<MessageEntity> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const _EmptyMessageView();

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageWidget();
      },
    );
  }
}

class _EmptyMessageView extends StatelessWidget {
  const _EmptyMessageView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No messages yet'),
    );
  }
}