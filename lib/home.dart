// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:signature/signature.dart';

import 'utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => log('Value changed'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> exportImage(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbarPNG'),
          content: Text('No content'),
        ),
      );
      return;
    }

    final Uint8List? data =
        await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    }

    if (!mounted) return;

    await push(
      context,
      Scaffold(
        appBar: AppBar(
          title: const Text('PNG Image'),
        ),
        body: Center(
          child: Container(
            color: Colors.grey[300],
            child: Image.memory(data),
          ),
        ),
      ),
    );
  }

  Future<void> exportSVG(BuildContext context) async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbarSVG'),
          content: Text('No content'),
        ),
      );
      return;
    }

    final SvgPicture data = _controller.toSVG()!;

    if (!mounted) return;

    await push(
      context,
      Scaffold(
        appBar: AppBar(
          title: const Text('SVG Image'),
        ),
        body: Center(
          child: Container(
            color: Colors.grey[300],
            child: data,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        // accentColor: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Signature Demo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Signature(
              key: const Key('signature'),
              controller: _controller,
              height: 300,
              backgroundColor: Colors.grey[300]!,
            ),
            const SizedBox(
              height: 10, // Adjusted height
              child: Center(
                child: Text(''),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                runSpacing: 10,
                spacing: 10,

                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                // mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CustomButton(
                    onPress: () {
                      exportImage(context);
                    },
                    icon: Icons.image,
                    title: 'Export Png',
                  ),
                  CustomButton(
                    onPress: () {
                      exportSVG(context);
                    },
                    icon: Icons.image,
                    title: 'Export Svg',
                  ),
                  CustomButton(
                    onPress: () {
                      setState(() => _controller.undo());
                    },
                    icon: Icons.undo,
                    title: 'Undo',
                  ),
                  CustomButton(
                    onPress: () {
                      setState(() => _controller.redo());
                    },
                    icon: Icons.redo,
                    title: 'Redo',
                  ),
                  CustomButton(
                    onPress: () {
                      setState(() => _controller.clear());
                    },
                    icon: Icons.clear,
                    title: 'clear',
                  ),
                  CustomButton(
                    onPress: () {
                      setState(
                          () => _controller.disabled = !_controller.disabled);
                    },
                    icon: _controller.disabled ? Icons.play_arrow : Icons.pause,
                    title: _controller.disabled ? 'Enable' : 'Disable',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.onPress,
    required this.title,
    required this.icon,
  }) : super(key: key);
  final VoidCallback onPress;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent[400],
        ),
        onPressed: onPress);
  }
}
