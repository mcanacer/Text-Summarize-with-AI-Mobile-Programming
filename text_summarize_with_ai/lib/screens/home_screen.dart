import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/db_helper.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  String _summaryResult = "Özet sonucu burada görünecek...";
  bool _loading = false;
  String _selectedModelKey = "BART (Dengeli)";
  int _givenScore = 0;

  void _summaryText() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen bir metin girin!")));
      return;
    }

    setState(() {
      _loading = true;
      _givenScore = 0;
    });

    try {
      String result = await ApiService.summarizeText(
        _textController.text,
        ApiService.models[_selectedModelKey]!,
      );

      setState(() {
        _summaryResult = result;
      });
    } catch (e) {
      setState(() {
        _summaryResult = "Hata: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _rateAndSave(int score) async {
    setState(() {
      _givenScore = score;
    });

    await DbHelper.saveSummary(
      _textController.text,
      _summaryResult,
      _selectedModelKey,
      score,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Model geri bildirimi kaydedildi!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Özetle AI - Metin Özetle'),
      centerTitle: true,
      backgroundColor: Colors.deepPurple.shade50,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildModelSelector(),
          const SizedBox(height: 20),
          _buildTextInput(),
          const SizedBox(height: 20),
          _buildLoadingAnimation(),
          _buildSummarizeButton(),
          const SizedBox(height: 30),
          _buildResultCard(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Merhaba 👋",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Model seç ve özetlemeye başla.",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kullanılacak Yapay Zeka Modeli:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ApiService.models.keys.map((key) {
            return ChoiceChip(
              label: Text(key),
              selected: _selectedModelKey == key,
              selectedColor: Colors.deepPurple.shade100,
              onSelected: (_) {
                setState(() {
                  _selectedModelKey = key;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: TextField(
        controller: _textController,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: "Uzun metni buraya bırak...",
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => _textController.clear(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    if (!_loading) return const SizedBox.shrink();

    return Center(child: Lottie.asset('assets/ai_animation.json', height: 120));
  }

  Widget _buildSummarizeButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _loading ? null : _summaryText,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _loading ? "Analiz Ediliyor..." : "Özetle",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_summaryResult.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 450),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: [Colors.deepPurple.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        children: [
          _buildResultHeader(),
          const Divider(),
          _buildResultText(),
          const Divider(),
          _buildRatingSection(),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "AI ANALİZİ ($_selectedModelKey)",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 12,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _summaryResult));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Kopyalandı!")));
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () => Share.share(_summaryResult),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultText() {
    return Expanded(
      child: SingleChildScrollView(
        child: Text(
          _summaryResult,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        const Text(
          "Modelin performansını puanlayın:",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _givenScore
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: Colors.amber,
              ),
              onPressed: () => _rateAndSave(index + 1),
            );
          }),
        ),
      ],
    );
  }
}
