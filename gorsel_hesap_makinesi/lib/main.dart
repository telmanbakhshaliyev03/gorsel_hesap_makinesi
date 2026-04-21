import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as matematik;

void main() {
  runApp(const BilimselHesapMakinesi());
}

class BilimselHesapMakinesi extends StatelessWidget {
  const BilimselHesapMakinesi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bilimsel Hesap Makinesi',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HesapMakinesiArayuzu(),
    );
  }
}

class HesapMakinesiArayuzu extends StatefulWidget {
  const HesapMakinesiArayuzu({super.key});

  @override
  _HesapMakinesiArayuzuState createState() => _HesapMakinesiArayuzuState();
}

class _HesapMakinesiArayuzuState extends State<HesapMakinesiArayuzu> {
  String _girisMetni = "";
  String _sonucMetni = "0";

  void _tusBasildi(String tusDegeri) {
    setState(() {
      if (tusDegeri == "C") {
        _girisMetni = "";
        _sonucMetni = "0";
      } else if (tusDegeri == "⌫") {
        if (_girisMetni.isNotEmpty) {
          _girisMetni = _girisMetni.substring(0, _girisMetni.length - 1);
        }
      } else if (tusDegeri == "=") {
        _hesapla(sonIslem: true);
      } else {
        _girisMetni += tusDegeri;
        // Eğer basılan tuş bir sayıysa anlık hesaplama yap
        if (!tusDegeri.contains(RegExp(r'[a-z(]'))) {
          _hesapla(sonIslem: false);
        }
      }
    });
  }

  void _hesapla({required bool sonIslem}) {
    if (_girisMetni.isEmpty) return;

    try {
      String islenecekMetin = _girisMetni.replaceAll('x', '*').replaceAll('÷', '/');
      
      // Dereceyi Radyana çeviren mühendislik mantığı
      islenecekMetin = islenecekMetin.replaceAllMapped(RegExp(r'(sin|cos|tan)\(([^)]+)\)'), (eslesme) {
        return '${eslesme[1]}((${eslesme[2]}) * ${matematik.pi} / 180)';
      });

      Parser ayristirici = Parser();
      Expression ifade = ayristirici.parse(islenecekMetin);
      ContextModel baglamModeli = ContextModel();
      double deger = ifade.evaluate(EvaluationType.REAL, baglamModeli);

      setState(() {
        // Hassas hesaplama düzeltmesi (cos 90 = 0 hatası için)
        if (deger.abs() < 1e-10) deger = 0;
        
        _sonucMetni = deger.toString();
        if (_sonucMetni.endsWith(".0")) {
          _sonucMetni = _sonucMetni.substring(0, _sonucMetni.length - 2);
        }
        
        if (sonIslem) {
          _girisMetni = _sonucMetni; // Sonucu ana ekrana taşı
        }
      });
    } catch (hata) {
      if (sonIslem) {
        setState(() {
          _sonucMetni = "Hata";
        });
      }
    }
  }

  Widget _butonOlustur(String metin, Color renk, {int esneklik = 1}) {
    return Expanded(
      flex: esneklik,
      child: Container(
        margin: const EdgeInsets.all(3),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: renk,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _tusBasildi(metin),
          child: Text(
            metin,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Renk Tanımlamaları
    const Color renkFonksiyon = Color(0xFF5D7685);
    const Color renkSayi = Color(0xFF262626);
    const Color renkOperator = Color(0xFFF1A33C);
    const Color renkSil = Color(0xFFF1535C);
    const Color renkEsittir = Color(0xFF57B26E);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilimsel Hesap Makinesi"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Ekran Alanı
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_girisMetni, style: const TextStyle(color: Colors.white60, fontSize: 25)),
                  const SizedBox(height: 10),
                  Text(_sonucMetni, style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // Butonlar Alanı
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(children: [
                  _butonOlustur("sin(", renkFonksiyon),
                  _butonOlustur("cos(", renkFonksiyon),
                  _butonOlustur("tan(", renkFonksiyon),
                  _butonOlustur("log(", renkFonksiyon),
                ]),
                Row(children: [
                  _butonOlustur("sqrt(", renkFonksiyon),
                  _butonOlustur("^", renkFonksiyon),
                  _butonOlustur("(", renkFonksiyon),
                  _butonOlustur(")", renkFonksiyon),
                ]),
                Row(children: [
                  _butonOlustur("7", renkSayi),
                  _butonOlustur("8", renkSayi),
                  _butonOlustur("9", renkSayi),
                  _butonOlustur("÷", renkOperator),
                ]),
                Row(children: [
                  _butonOlustur("4", renkSayi),
                  _butonOlustur("5", renkSayi),
                  _butonOlustur("6", renkSayi),
                  _butonOlustur("x", renkOperator),
                ]),
                Row(children: [
                  _butonOlustur("1", renkSayi),
                  _butonOlustur("2", renkSayi),
                  _butonOlustur("3", renkSayi),
                  _butonOlustur("-", renkOperator),
                ]),
                Row(children: [
                  _butonOlustur("0", renkSayi),
                  _butonOlustur(".", renkSayi),
                  _butonOlustur("⌫", renkSil),
                  _butonOlustur("+", renkOperator),
                ]),
                Row(children: [
                  _butonOlustur("C", renkSil, esneklik: 2),
                  _butonOlustur("=", renkEsittir, esneklik: 2),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}