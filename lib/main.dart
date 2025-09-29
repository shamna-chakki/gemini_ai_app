import 'package:flutter/material.dart';
import 'package:gemini_ai_app/caption_provider.dart';
import 'package:gemini_ai_app/env.dart';
import 'package:gemini_ai_app/screen_gemini.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';

import 'gemini_service.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const apiKey = Env.apiKey;
    final geminiService = GeminiService(apiKey);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: ChangeNotifierProvider(create: (context) => CaptionProvider(geminiService:geminiService ),child: ScreenGemini()),
    );
  }
}

class GeminiAppScreen extends StatefulWidget {
  const GeminiAppScreen({super.key});

  @override
  State<GeminiAppScreen> createState() => _GeminiAppScreenState();
}

class _GeminiAppScreenState extends State<GeminiAppScreen> {
  late final GenerativeModel _model;

  List<Content> history = [];
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  bool _loading = false;
  static const _apiKey = 'AIzaSyBIWl5bqnDfZt8zc8VQroRUbu5fI84_ry4';

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _chat = _model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini AI')),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 90),
            itemCount: history.reversed.length,
            controller: _scrollController,
            reverse: true,
            itemBuilder: (context, index) {
              var content = history.reversed.toList()[index];
              var text = content.parts
                  .whereType<TextPart>()
                  .map<String>((e) => e.text)
                  .join('');
              return MessageTile(
                sendByMe: content.role == 'user',
                message: text,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 15);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: TextField(
                        cursorColor: Colors.grey,
                        controller: _textController,
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        history.add(
                          Content('user', [TextPart(_textController.text)]),
                        );
                      });
                      _sendChatMessage(_textController.text, history.length);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                            spreadRadius: 3,
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message, int historyIndex) async {
    setState(() {
      _loading = true;
      _textController.clear();
      _textFieldFocus.unfocus();
      _scrollDown();
    });

    List<Part> parts = [];

    try {
      var response = _chat.sendMessageStream(Content.text(message));
      await for (var item in response) {
        var text = item.text;
        if (text == null) {
          _showError('No response from API.');
          return;
        } else {
          setState(() {
            _loading = false;
            parts.add(TextPart(text));
            if ((history.length - 1) == historyIndex) {
              history.removeAt(historyIndex);
            }
            history.insert(historyIndex, Content('model', parts));
          });
        }
      }
    } catch (e, t) {
      print(e);
      print(t);
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(child: SelectableText(message)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class MessageTile extends StatelessWidget {
  final bool sendByMe;
  final String message;

  const MessageTile({super.key, required this.sendByMe, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: sendByMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(color: sendByMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
