import 'package:uuid/uuid.dart';
import 'packing_item.dart';

/// Represents a pre-curated packing list template tailored for specific trip types
class PackingTemplate {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final List<PackingItemTemplate> items;

  const PackingTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.items,
  });
}

/// Simplified template item before instantiation with UUID
class PackingItemTemplate {
  final String name;
  final String category;
  final int quantity;
  final double weightKg;
  final String tag;
  final String compartment;

  const PackingItemTemplate({
    required this.name,
    required this.category,
    this.quantity = 1,
    this.weightKg = 0.5,
    this.tag = 'CARRY-ON',
    this.compartment = 'Main Cabin',
  });

  PackingItem toPackingItem({String? tripId}) {
    final now = DateTime.now();
    return PackingItem(
      id: const Uuid().v4(),
      tripId: tripId,
      name: name,
      category: category,
      quantity: quantity,
      weightKg: weightKg,
      isPacked: false,
      tag: tag,
      compartment: compartment,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }
}

/// Master repository of curated packing templates
class PackingTemplatesRepository {
  PackingTemplatesRepository._();

  static const List<PackingTemplate> all = [
    PackingTemplate(
      id: 'summer_beach',
      title: 'Plaj & Yaz Tatili',
      description: 'Deniz, kum, güneş ve sıcak hava kaçamakları için eksiksiz bavul hazırlığı',
      emoji: '🏖️',
      items: [
        PackingItemTemplate(name: 'Mayo / Şort (Yedekli)', category: 'Kıyafet', quantity: 2, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Keten Gömlek & Tişörtler', category: 'Kıyafet', quantity: 4, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Şort & Hafif Pantolon', category: 'Kıyafet', quantity: 2, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'İç Çamaşırı & Çorap', category: 'Kıyafet', quantity: 5, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Plaj Terliği & Sandalet', category: 'Kıyafet', quantity: 1, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Güneş Kremi (Yüksek Korumalı SPF 50+)', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
        PackingItemTemplate(name: 'Güneş Sonrası Nemlendirici Jel (Aloe Vera)', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
        PackingItemTemplate(name: 'Seyahat Boy Diş Fırçası & Macunu', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
        PackingItemTemplate(name: 'Mikrofiber Hızlı Kuruyan Plaj Havlusu', category: 'Aksesuar', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'UV Korumalı Güneş Gözlüğü & Kılıfı', category: 'Aksesuar', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Geniş Siperlikli Güneş Şapkası', category: 'Aksesuar', quantity: 1, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Su Geçirmez Telefon & Cüzdan Kılıfı', category: 'Elektronik', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Powerbank (Kabin Onaylı) & Şarj Kablosu', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Pasaport & Kimlik Kartı', category: 'Belgeler', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
      ],
    ),
    PackingTemplate(
      id: 'winter_ski',
      title: 'Kış & Kayak Seyahati',
      description: 'Soğuk iklimler, kayak merkezleri ve kış tatili için koruyucu donanımlar',
      emoji: '❄️',
      items: [
        PackingItemTemplate(name: 'Termal İçlik Üst & Alt Takımı', category: 'Kıyafet', quantity: 2, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Rüzgar & Su Geçirmez Kalın Mont / Parka', category: 'Kıyafet', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Kar / Kayak Pantolonu', category: 'Kıyafet', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Yün / Polar Kazak ve Sweatshirt', category: 'Kıyafet', quantity: 3, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Termal Yün Çoraplar', category: 'Kıyafet', quantity: 4, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Su Geçirmez Kışlık Bot / Kar Ayakkabısı', category: 'Kıyafet', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Yün Bere, Polar Boyunluk & Atkı', category: 'Aksesuar', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Su ve Soğuk Geçirmez Kayak Eldiveni', category: 'Aksesuar', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Yoğun Nemlendirici El Kremi & Dudak Balmı', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
        PackingItemTemplate(name: 'Kar Güneş Gözlüğü / Kayak Gözlüğü', category: 'Aksesuar', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Termal Matara / Çelik Termos', category: 'Aksesuar', quantity: 1, tag: 'CARRY-ON', compartment: 'Sırt Çantası'),
        PackingItemTemplate(name: 'Powerbank & Şarj Aleti', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Ön Cep'),
      ],
    ),
    PackingTemplate(
      id: 'business_trip',
      title: 'İş & Konferans Seyahati',
      description: 'Toplantılar, konferanslar ve profesyonel iş gezileri için kusursuz bavul',
      emoji: '💼',
      items: [
        PackingItemTemplate(name: 'Takım Elbise / Blazer Ceket', category: 'Kıyafet', quantity: 1, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Kırışmaz Ütülü Gömlek / Bluz', category: 'Kıyafet', quantity: 3, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Kumaş / Chino Pantolon', category: 'Kıyafet', quantity: 2, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Klasik İş Ayakkabısı & Kemer', category: 'Kıyafet', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'İç Çamaşırı & Çorap Seti', category: 'Kıyafet', quantity: 4, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Dizüstü Bilgisayar & Orijinal Şarj Adaptörü', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Sırt Çantası'),
        PackingItemTemplate(name: 'Kablosuz Mouse & Sunum Kumandası', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Sırt Çantası'),
        PackingItemTemplate(name: 'Gürültü Engelleyici Kulaklık', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Powerbank & Çoklu USB Kablosu', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Kartvizitlik, Şık Not Defteri & Kalem', category: 'Belgeler', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Uçak / Tren Biletleri & Otel Rezervasyonu', category: 'Belgeler', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Seyahat Boy Parfüm & Deodorant (100ml altı)', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
        PackingItemTemplate(name: 'Kompakt Tıraş Seti / Bakım Kiti', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
      ],
    ),
    PackingTemplate(
      id: 'camping_outdoor',
      title: 'Doğa & Kamp Keşfi',
      description: 'Çadır kampı, trekking ve doğa yürüyüşleri için dayanıklı ekipmanlar',
      emoji: '⛺',
      items: [
        PackingItemTemplate(name: 'Nefes Alabilir Trekking Pantolonu', category: 'Kıyafet', quantity: 2, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Hafif Yağmurluk / Rüzgarlık', category: 'Kıyafet', quantity: 1, tag: 'ESSENTIAL', compartment: 'Sırt Çantası'),
        PackingItemTemplate(name: 'Termal İçlik & Polar Ceket', category: 'Kıyafet', quantity: 1, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Bileklik Destekli Trekking Botu', category: 'Kıyafet', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Çadır, Mat & Kazıklar', category: 'Aksesuar', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Uyku Tulumu (Mevsime Uygun Dereceli)', category: 'Aksesuar', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Kafa Feneri & Yedek Piller', category: 'Elektronik', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Çok Amaçlı Çakı / Kamp Pensesi', category: 'Aksesuar', quantity: 1, tag: 'CHECK-IN', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'İlk Yardım Çantası (Yara Bandı, Sargı, Ağrı Kesici)', category: 'Kişisel Bakım', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Sinek & Haşere Kovucu Sprey', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
        PackingItemTemplate(name: 'Yüksek Kapasiteli Powerbank (Güneş Panelli vb.)', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Sırt Çantası'),
        PackingItemTemplate(name: 'Çelik Su Matarası & Su Arıtma Tableti', category: 'Aksesuar', quantity: 1, tag: 'CARRY-ON', compartment: 'Sırt Çantası'),
      ],
    ),
    PackingTemplate(
      id: 'city_weekend',
      title: 'Hafta Sonu Şehir Turu',
      description: 'Pratik sırt çantasıyla 2-3 günlük rahat ve kompakt şehir kaçamağı',
      emoji: '🏙️',
      items: [
        PackingItemTemplate(name: 'Rahat Şehir Yürüyüş Ayakkabısı / Sneaker', category: 'Kıyafet', quantity: 1, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Tişörtler & Hafif Sweatshirt', category: 'Kıyafet', quantity: 3, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Kot Pantolon & Rahat Eşofman', category: 'Kıyafet', quantity: 2, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'İç Çamaşırı & Çorap', category: 'Kıyafet', quantity: 3, tag: 'CARRY-ON', compartment: 'Ana Bölme'),
        PackingItemTemplate(name: 'Katlanabilir Cep Şemsiyesi / Yağmurluk', category: 'Aksesuar', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Evrensel Priz Dönüştürücü / Seyahat Adaptörü', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Hızlı Şarj Adaptörü & Telefon Kablosu', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Kompakt Powerbank', category: 'Elektronik', quantity: 1, tag: 'CABIN ONLY', compartment: 'Ön Cep'),
        PackingItemTemplate(name: 'Seyahat Boy Diş Bakım Seti', category: 'Kişisel Bakım', quantity: 1, tag: 'CABIN ONLY', compartment: 'Kozmetik Bölmesi'),
        PackingItemTemplate(name: 'Kimlik, Pasaport & Ulaşım Kartları', category: 'Belgeler', quantity: 1, tag: 'ESSENTIAL', compartment: 'Ön Cep'),
      ],
    ),
  ];
}
