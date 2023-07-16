import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gpt/openai_service.dart';
import 'package:gpt/pallete.dart';
import 'package:gpt/feature_box.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();

  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();

  String? generatedContent;
  String? generatedImageUrl;

  int start = 50;
  int delay = 350;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('FlutterGPT'),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              delay: Duration(milliseconds: start + delay * 2),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        color: const Color.fromARGB(255, 76, 16, 113),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 127,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/virtualAssistant.png',
                          ),
                        )),
                  )
                ],
              ),
            ),
            //chat Bubble
            SlideInRight(
              delay: Duration(milliseconds: start + delay * 2),
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 35).copyWith(
                    top: 25,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(35).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      generatedContent == null
                          ? 'Hello, How can I assist you with my services?'
                          : generatedContent!,
                      style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: Pallete.mainFontColor,
                          fontSize: generatedContent == null ? 20 : 15),
                    ),
                  ),
                ),
              ),
            ),
            //Suggestions of services
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(generatedImageUrl!),
                ),
              ),

            FadeIn(
              delay: Duration(milliseconds: start + delay * 2),
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 7.0, left: 25.0),
                  child: const Text(
                    'App features are :',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            //List of services
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Color.fromARGB(177, 51, 20, 105),
                      headerText: 'ChatGPT',
                      discriptionText:
                          'Ask anything you want to, ChatGPT shall respond',
                    ),
                  ),
                  SlideInRight(
                    delay: Duration(milliseconds: start + delay * 2),
                    child: const FeatureBox(
                      color: Color.fromARGB(177, 51, 20, 105),
                      headerText: 'Dall-E',
                      discriptionText:
                          'Get inspired and stay creative, Generate your words to Images powered by Dall-E',
                    ),
                  ),
                  SlideInUp(
                    delay: Duration(milliseconds: start + delay * 3),
                    child: const FeatureBox(
                      color: Color.fromARGB(177, 51, 20, 105),
                      headerText: 'Smart Voice Assistant',
                      discriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FadeIn(
        delay: Duration(milliseconds: start + delay * 4),
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 76, 16, 113),
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
