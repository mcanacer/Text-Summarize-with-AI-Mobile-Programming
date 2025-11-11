import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _metinController = TextEditingController();
  final String _ozetSonucu = "Özet sonucu burada görünecek...";
  bool _yukleniyor = false;

  void _ozetleMetni() {
    if (_metinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen özetlenecek bir metin girin.")),
      );
      return;
    }

    setState(() {
      _yukleniyor = true;
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _yukleniyor = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summarize with AI'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Metin Giriş Alanı
            TextField(
              controller: _metinController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Özetlenecek metni buraya yapıştırın...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.bolt),
                    label: const Text('Özetle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _ozetleMetni,
                  ),
            const SizedBox(height: 30),

            const Text(
              'Özet Sonucu:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                _ozetSonucu,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
