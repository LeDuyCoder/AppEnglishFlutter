import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speech/flutter_speech.dart';

class SpeechToTextButton extends StatefulWidget {
  const SpeechToTextButton({super.key, required this.callBackData});

  @override
  _SpeechToTextButtonState createState() => _SpeechToTextButtonState();

  final Function(String value) callBackData;

}

class _SpeechToTextButtonState extends State<SpeechToTextButton> {
  late SpeechRecognition _speech;
  bool _isListening = true;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.activate("en_US").then((result) {
      setState(() => _isListening = !result);
    });
  }

  void onSpeechAvailability(bool result) {
    setState(() => _isListening = result);
  }

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    setState(() {
      _isListening = false;
      _text = text; // Fix this line
      widget.callBackData(text);
    });
  }

  void onRecognitionComplete(String text) {
    // Xử lý kết quả sau khi nhận dạng hoàn thành ở đây
    setState(() {
      _isListening = false;
      // Ví dụ: gán kết quả vào một biến _text
    });
  }

  void startListening() {
    _speech.listen().then((result) {
      print('Listening result: $result');
    });
  }

  void cancelListening() {
    _speech.cancel().then((result) {
      setState(() => _isListening = result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_text),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _isListening ? cancelListening : startListening,
              backgroundColor: _isListening ? Colors.red : Colors.white,
              foregroundColor: _isListening ? Colors.white : Colors.black,
              child: Icon(_isListening ? Icons.mic_off : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}
