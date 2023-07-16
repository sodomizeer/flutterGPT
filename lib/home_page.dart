import 'package:flutter/material.dart';
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
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();

  @override
  void initState() {
    super.initState();
    initSpeechToText();
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

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterGPT'),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
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
            //chat Bubble
            Container(
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
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  'Yo Whaddup Nigga?? How can I help you??',
                  style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20),
                ),
              ),
            ),
            //Suggestions of services
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 7.0, left: 25.0),
              child: const Text(
                'What do you wanna do Niggay?',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //List of services
            const Column(
              children: [
                FeatureBox(
                  color: Color.fromARGB(177, 51, 20, 105),
                  headerText: 'NiggaGPT',
                  discriptionText:
                      'Ask anything you want to, our niggaAI capGPT shall answer',
                ),
                FeatureBox(
                  color: Color.fromARGB(177, 51, 20, 105),
                  headerText: 'Dall-E',
                  discriptionText:
                      'Generate your personal Dick Pic powered by Dall-E',
                ),
                FeatureBox(
                  color: Color.fromARGB(177, 51, 20, 105),
                  headerText: 'RN Voice Assistant',
                  discriptionText:
                      'Real Nigga Voice assistant powered by Dall-E and niggAI',
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(94, 214, 4, 130),
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openAIService.isArtPromptAPI(lastWords);
            print(speech);
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: const Icon(
          Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}
