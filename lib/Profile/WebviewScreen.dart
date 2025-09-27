import 'package:webview_flutter/webview_flutter.dart';
import '../../constant/all.dart';

class Webviewscreen extends StatefulWidget {
  final String? tittle;
  Webviewscreen({required this.tittle});

  @override
  _WebviewscreenState createState() => _WebviewscreenState();
}

class _WebviewscreenState extends State<Webviewscreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    var url = '';
    if (widget.tittle == 'About Us') {
      url = 'https://pixidrugs.com/#About_us';
    } else if (widget.tittle == 'Contact Us') {
      url = 'https://pixidrugs.com/#Contact_us';
    } else if (widget.tittle == 'Privacy Policy') {
      url = 'https://pixidrugs.com/privacy';
    } else if (widget.tittle == 'Terms & Conditions') {
      url = 'https://pixidrugs.com/terms';
    }
    _controller = WebViewController()..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppUtils.BaseAppBar(
        context: context,
        title: widget.tittle ?? "About Us",
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
