import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController {
  late WebSocketChannel _channel;
  String lastMessage = '';

  void open(String url, String mode) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.sink.add(mode);
    _channel.stream.listen((msg) => lastMessage = msg);
  }

  void setMode(String mode) => _channel.sink.add(mode);
  void close() {
    _channel.sink.add('D');
    _channel.sink.close();
  }

  String readPacket() => lastMessage;
}
