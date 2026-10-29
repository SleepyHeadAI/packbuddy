/// Comprehensive Country Name Localization across all 20 supported languages:
/// ar, de, el, en, es, fr, hi, id, it, ja, ko, nl, pl, pt, ru, sv, th, tr, vi, zh
class CountryLocalization {
  CountryLocalization._();

  static const Map<String, Map<String, String>> _countryTranslations = {
    'TR': {
      'en': 'Turkey', 'tr': 'Türkiye', 'es': 'Turquía', 'de': 'Türkei', 'fr': 'Turquie',
      'it': 'Turchia', 'pt': 'Turquia', 'ru': 'Турция', 'ar': 'تركيا', 'ja': 'トルコ',
      'ko': '튀르키예', 'zh': '土耳其', 'nl': 'Turkije', 'pl': 'Turcja', 'sv': 'Turkiet',
      'th': 'ตุรกี', 'vi': 'Thổ Nhĩ Kỳ', 'hi': 'तुर्की', 'el': 'Τουρκία', 'id': 'Turki',
    },
    'DE': {
      'en': 'Germany', 'tr': 'Almanya', 'es': 'Alemania', 'de': 'Deutschland', 'fr': 'Allemagne',
      'it': 'Germania', 'pt': 'Alemanha', 'ru': 'Германия', 'ar': 'ألمانيا', 'ja': 'ドイツ',
      'ko': '독일', 'zh': '德国', 'nl': 'Duitsland', 'pl': 'Niemcy', 'sv': 'Tyskland',
      'th': 'เยอรมนี', 'vi': 'Đức', 'hi': 'जर्मनी', 'el': 'Γερμανία', 'id': 'Jerman',
    },
    'US': {
      'en': 'United States', 'tr': 'Amerika Birleşik Devletleri', 'es': 'Estados Unidos', 'de': 'Vereinigte Staaten', 'fr': 'États-Unis',
      'it': 'Stati Uniti', 'pt': 'Estados Unidos', 'ru': 'Соединенные Штаты', 'ar': 'الولايات المتحدة', 'ja': 'アメリカ合衆国',
      'ko': '미국', 'zh': '美国', 'nl': 'Verenigde Staten', 'pl': 'Stany Zjednoczone', 'sv': 'USA',
      'th': 'สหรัฐอเมริกา', 'vi': 'Hoa Kỳ', 'hi': 'संयुक्त राज्य अमेरिका', 'el': 'Ηνωμένες Πολιτείες', 'id': 'Amerika Serikat',
    },
    'FR': {
      'en': 'France', 'tr': 'Fransa', 'es': 'Francia', 'de': 'Frankreich', 'fr': 'France',
      'it': 'Francia', 'pt': 'França', 'ru': 'Франция', 'ar': 'فرنسا', 'ja': 'フランス',
      'ko': '프랑스', 'zh': '法国', 'nl': 'Frankrijk', 'pl': 'Francja', 'sv': 'Frankrike',
      'th': 'ฝรั่งเศส', 'vi': 'Pháp', 'hi': 'फ़्रांस', 'el': 'Γαλλία', 'id': 'Prancis',
    },
    'IT': {
      'en': 'Italy', 'tr': 'İtalya', 'es': 'Italia', 'de': 'Italien', 'fr': 'Italie',
      'it': 'Italia', 'pt': 'Itália', 'ru': 'Италия', 'ar': 'إيطاليا', 'ja': 'イタリア',
      'ko': '이탈리아', 'zh': '意大利', 'nl': 'Italië', 'pl': 'Włochy', 'sv': 'Italien',
      'th': 'อิตาลี', 'vi': 'Ý', 'hi': 'इटली', 'el': 'Ιταλία', 'id': 'Italia',
    },
    'ES': {
      'en': 'Spain', 'tr': 'İspanya', 'es': 'España', 'de': 'Spanien', 'fr': 'Espagne',
      'it': 'Spagna', 'pt': 'Espanha', 'ru': 'Испания', 'ar': 'إسبانيا', 'ja': 'スペイン',
      'ko': '스페인', 'zh': '西班牙', 'nl': 'Spanje', 'pl': 'Hiszpania', 'sv': 'Spanien',
      'th': 'สเปน', 'vi': 'Tây Ban Nha', 'hi': 'स्पेन', 'el': 'Ισπανία', 'id': 'Spanyol',
    },
    'GB': {
      'en': 'United Kingdom', 'tr': 'Birleşik Krallık', 'es': 'Reino Unido', 'de': 'Vereinigtes Königreich', 'fr': 'Royaume-Uni',
      'it': 'Regno Unito', 'pt': 'Reino Unido', 'ru': 'Великобритания', 'ar': 'المملكة المتحدة', 'ja': 'イギリス',
      'ko': '영국', 'zh': '英国', 'nl': 'Verenigd Koninkrijk', 'pl': 'Wielka Brytania', 'sv': 'Storbritannien',
      'th': 'สหราชอาณาจักร', 'vi': 'Vương quốc Anh', 'hi': 'यूनाइटेड किंगडम', 'el': 'Ηνωμένο Βασίλειο', 'id': 'Inggris',
    },
    'JP': {
      'en': 'Japan', 'tr': 'Japonya', 'es': 'Japón', 'de': 'Japan', 'fr': 'Japon',
      'it': 'Giappone', 'pt': 'Japão', 'ru': 'Япония', 'ar': 'اليابان', 'ja': '日本',
      'ko': '일본', 'zh': '日本', 'nl': 'Japan', 'pl': 'Japonia', 'sv': 'Japan',
      'th': 'ญี่ปุ่น', 'vi': 'Nhật Bản', 'hi': 'जापान', 'el': 'Ιαπωνία', 'id': 'Jepang',
    },
    'CN': {
      'en': 'China', 'tr': 'Çin', 'es': 'China', 'de': 'China', 'fr': 'Chine',
      'it': 'Cina', 'pt': 'China', 'ru': 'Китай', 'ar': 'الصين', 'ja': '中国',
      'ko': '중국', 'zh': '中国', 'nl': 'China', 'pl': 'Chiny', 'sv': 'Kina',
      'th': 'จีน', 'vi': 'Trung Quốc', 'hi': 'चीन', 'el': 'Κίνα', 'id': 'Tiongkok',
    },
    'RU': {
      'en': 'Russia', 'tr': 'Rusya', 'es': 'Rusia', 'de': 'Russland', 'fr': 'Russie',
      'it': 'Russia', 'pt': 'Rússia', 'ru': 'Россия', 'ar': 'روسيا', 'ja': 'ロシア',
      'ko': '러시아', 'zh': '俄罗斯', 'nl': 'Rusland', 'pl': 'Rosja', 'sv': 'Ryssland',
      'th': 'รัสเซีย', 'vi': 'Nga', 'hi': 'रूस', 'el': 'Ρωσία', 'id': 'Rusia',
    },
    'BR': {
      'en': 'Brazil', 'tr': 'Brezilya', 'es': 'Brasil', 'de': 'Brasilien', 'fr': 'Brésil',
      'it': 'Brasile', 'pt': 'Brasil', 'ru': 'Бразилия', 'ar': 'البرازيل', 'ja': 'ブラジル',
      'ko': '브라질', 'zh': '巴西', 'nl': 'Brazilië', 'pl': 'Brazylia', 'sv': 'Brasilien',
      'th': 'บราซิล', 'vi': 'Brazil', 'hi': 'ब्राज़ील', 'el': 'Βραζιλία', 'id': 'Brasil',
    },
    'CA': {
      'en': 'Canada', 'tr': 'Kanada', 'es': 'Canadá', 'de': 'Kanada', 'fr': 'Canada',
      'it': 'Canada', 'pt': 'Canadá', 'ru': 'Канада', 'ar': 'كندا', 'ja': 'カナダ',
      'ko': '캐나다', 'zh': '加拿大', 'nl': 'Canada', 'pl': 'Kanada', 'sv': 'Kanada',
      'th': 'แคนาดา', 'vi': 'Canada', 'hi': 'कनाडा', 'el': 'Καναδάς', 'id': 'Kanada',
    },
    'AU': {
      'en': 'Australia', 'tr': 'Avustralya', 'es': 'Australia', 'de': 'Australien', 'fr': 'Australie',
      'it': 'Australia', 'pt': 'Austrália', 'ru': 'Австралия', 'ar': 'أستراليا', 'ja': 'オーストラリア',
      'ko': '호주', 'zh': '澳大利亚', 'nl': 'Australië', 'pl': 'Australia', 'sv': 'Australien',
      'th': 'ออสเตรเลีย', 'vi': 'Úc', 'hi': 'ऑस्ट्रेलिया', 'el': 'Αυστραλία', 'id': 'Australia',
    },
    'MX': {
      'en': 'Mexico', 'tr': 'Meksika', 'es': 'México', 'de': 'Mexiko', 'fr': 'Mexique',
      'it': 'Messico', 'pt': 'México', 'ru': 'Мексика', 'ar': 'المكسيك', 'ja': 'メキシコ',
      'ko': '멕시코', 'zh': '墨西哥', 'nl': 'Mexico', 'pl': 'Meksyk', 'sv': 'Mexiko',
      'th': 'เม็กซิโก', 'vi': 'Mexico', 'hi': 'मेक्सिको', 'el': 'Μεξικό', 'id': 'Meksiko',
    },
    'GR': {
      'en': 'Greece', 'tr': 'Yunanistan', 'es': 'Grecia', 'de': 'Griechenland', 'fr': 'Grèce',
      'it': 'Grecia', 'pt': 'Grécia', 'ru': 'Греция', 'ar': 'اليونان', 'ja': 'ギリシャ',
      'ko': '그리스', 'zh': '希腊', 'nl': 'Griekenland', 'pl': 'Grecja', 'sv': 'Grekland',
      'th': 'กรีซ', 'vi': 'Hy Lạp', 'hi': 'ग्रीस', 'el': 'Ελλάδα', 'id': 'Yunani',
    },
    'PT': {
      'en': 'Portugal', 'tr': 'Portekiz', 'es': 'Portugal', 'de': 'Portugal', 'fr': 'Portugal',
      'it': 'Portogallo', 'pt': 'Portugal', 'ru': 'Португалия', 'ar': 'البرتغال', 'ja': 'ポルトガル',
      'ko': '포르투갈', 'zh': '葡萄牙', 'nl': 'Portugal', 'pl': 'Portugalia', 'sv': 'Portugal',
      'th': 'โปรตุเกส', 'vi': 'Bồ Đào Nha', 'hi': 'पुर्तगाल', 'el': 'Πορτογαλία', 'id': 'Portugal',
    },
    'NL': {
      'en': 'Netherlands', 'tr': 'Hollanda', 'es': 'Países Bajos', 'de': 'Niederlande', 'fr': 'Pays-Bas',
      'it': 'Paesi Bassi', 'pt': 'Países Baixos', 'ru': 'Нидерланды', 'ar': 'هولندا', 'ja': 'オランダ',
      'ko': '네덜란드', 'zh': '荷兰', 'nl': 'Nederland', 'pl': 'Holandia', 'sv': 'Nederländerna',
      'th': 'เนเธอร์แลนด์', 'vi': 'Hà Lan', 'hi': 'नीदरलैंड', 'el': 'Κάτω Χώρες', 'id': 'Belanda',
    },
    'PL': {
      'en': 'Poland', 'tr': 'Polonya', 'es': 'Polonia', 'de': 'Polen', 'fr': 'Pologne',
      'it': 'Polonia', 'pt': 'Polônia', 'ru': 'Польша', 'ar': 'بولندا', 'ja': 'ポーランド',
      'ko': '폴란드', 'zh': '波兰', 'nl': 'Polen', 'pl': 'Polska', 'sv': 'Polen',
      'th': 'โปแลนด์', 'vi': 'Ba Lan', 'hi': 'पोलैंड', 'el': 'Πολωνία', 'id': 'Polandia',
    },
    'SE': {
      'en': 'Sweden', 'tr': 'İsveç', 'es': 'Suecia', 'de': 'Schweden', 'fr': 'Suède',
      'it': 'Svezia', 'pt': 'Suécia', 'ru': 'Швеция', 'ar': 'السويد', 'ja': 'スウェーデン',
      'ko': '스웨덴', 'zh': '瑞典', 'nl': 'Zweden', 'pl': 'Szwecja', 'sv': 'Sverige',
      'th': 'สวีเดน', 'vi': 'Thụy Điển', 'hi': 'स्वीडन', 'el': 'Σουηδία', 'id': 'Swedia',
    },
    'NO': {
      'en': 'Norway', 'tr': 'Norveç', 'es': 'Noruega', 'de': 'Norwegen', 'fr': 'Norvège',
      'it': 'Norvegia', 'pt': 'Noruega', 'ru': 'Норвегия', 'ar': 'النرويج', 'ja': 'ノルウェー',
      'ko': '노르웨이', 'zh': '挪威', 'nl': 'Noorwegen', 'pl': 'Norwegia', 'sv': 'Norge',
      'th': 'นอร์เวย์', 'vi': 'Na Uy', 'hi': 'नॉर्वे', 'el': 'Νορβηγία', 'id': 'Norwegia',
    },
    'DK': {
      'en': 'Denmark', 'tr': 'Danimarka', 'es': 'Dinamarca', 'de': 'Dänemark', 'fr': 'Danemark',
      'it': 'Danimarca', 'pt': 'Dinamarca', 'ru': 'Дания', 'ar': 'الدنمارك', 'ja': 'デンマーク',
      'ko': '덴마크', 'zh': '丹麦', 'nl': 'Denemarken', 'pl': 'Dania', 'sv': 'Danmark',
      'th': 'เดนมาร์ก', 'vi': 'Đan Mạch', 'hi': 'डेनमार्क', 'el': 'Δανία', 'id': 'Denmark',
    },
    'FI': {
      'en': 'Finland', 'tr': 'Finlandiya', 'es': 'Finlandia', 'de': 'Finnland', 'fr': 'Finlande',
      'it': 'Finlandia', 'pt': 'Finlândia', 'ru': 'Финляндия', 'ar': 'فنلندا', 'ja': 'フィンランド',
      'ko': '핀란드', 'zh': '芬兰', 'nl': 'Finland', 'pl': 'Finlandia', 'sv': 'Finland',
      'th': 'ฟินแลนด์', 'vi': 'Phần Lan', 'hi': 'फ़िनलैंड', 'el': 'Φινλανδία', 'id': 'Finlandia',
    },
    'CH': {
      'en': 'Switzerland', 'tr': 'İsviçre', 'es': 'Suiza', 'de': 'Schweiz', 'fr': 'Suisse',
      'it': 'Svizzera', 'pt': 'Suíça', 'ru': 'Швейцария', 'ar': 'سويسرا', 'ja': 'スイス',
      'ko': '스위스', 'zh': '瑞士', 'nl': 'Zwitserland', 'pl': 'Szwajcaria', 'sv': 'Schweiz',
      'th': 'สวิตเซอร์แลนด์', 'vi': 'Thụy Sĩ', 'hi': 'स्विट्ज़रलैंड', 'el': 'Ελβετία', 'id': 'Swiss',
    },
    'AT': {
      'en': 'Austria', 'tr': 'Avusturya', 'es': 'Austria', 'de': 'Österreich', 'fr': 'Autriche',
      'it': 'Austria', 'pt': 'Áustria', 'ru': 'Австрия', 'ar': 'النمسا', 'ja': 'オーストリア',
      'ko': '오스트리아', 'zh': '奥地利', 'nl': 'Oostenrijk', 'pl': 'Austria', 'sv': 'Österrike',
      'th': 'ออสเตรีย', 'vi': 'Áo', 'hi': 'ऑस्ट्रिया', 'el': 'Αυστρία', 'id': 'Austria',
    },
    'BE': {
      'en': 'Belgium', 'tr': 'Belçika', 'es': 'Bélgica', 'de': 'Belgien', 'fr': 'Belgique',
      'it': 'Belgio', 'pt': 'Bélgica', 'ru': 'Бельгия', 'ar': 'بلجيكا', 'ja': 'ベルギー',
      'ko': '벨기에', 'zh': '比利时', 'nl': 'België', 'pl': 'Belgia', 'sv': 'Belgien',
      'th': 'เบลเยียม', 'vi': 'Bỉ', 'hi': 'बेल्जियम', 'el': 'Βέλγιο', 'id': 'Belgia',
    },
    'KR': {
      'en': 'South Korea', 'tr': 'Güney Kore', 'es': 'Corea del Sur', 'de': 'Südkorea', 'fr': 'Corée du Sud',
      'it': 'Corea del Sud', 'pt': 'Coreia do Sul', 'ru': 'Южная Корея', 'ar': 'كوريا الجنوبية', 'ja': '韓国',
      'ko': '대한민국', 'zh': '韩国', 'nl': 'Zuid-Korea', 'pl': 'Korea Południowa', 'sv': 'Sydkorea',
      'th': 'เกาหลีใต้', 'vi': 'Hàn Quốc', 'hi': 'दक्षिण कोरिया', 'el': 'Νότια Κορέα', 'id': 'Korea Selatan',
    },
    'IN': {
      'en': 'India', 'tr': 'Hindistan', 'es': 'India', 'de': 'Indien', 'fr': 'Inde',
      'it': 'India', 'pt': 'Índia', 'ru': 'Индия', 'ar': 'الهند', 'ja': 'インド',
      'ko': '인도', 'zh': '印度', 'nl': 'India', 'pl': 'Indie', 'sv': 'Indien',
      'th': 'อินเดีย', 'vi': 'Ấn Độ', 'hi': 'भारत', 'el': 'Ινδία', 'id': 'India',
    },
    'TH': {
      'en': 'Thailand', 'tr': 'Tayland', 'es': 'Tailandia', 'de': 'Thailand', 'fr': 'Thaïlande',
      'it': 'Tailandia', 'pt': 'Tailândia', 'ru': 'Таиланд', 'ar': 'تايلاند', 'ja': 'タイ',
      'ko': '태국', 'zh': '泰国', 'nl': 'Thailand', 'pl': 'Tajlandia', 'sv': 'Thailand',
      'th': 'ไทย', 'vi': 'Thái Lan', 'hi': 'थाईलैंड', 'el': 'Ταϊλάνδη', 'id': 'Thailand',
    },
    'VN': {
      'en': 'Vietnam', 'tr': 'Vietnam', 'es': 'Vietnam', 'de': 'Vietnam', 'fr': 'Vietnam',
      'it': 'Vietnam', 'pt': 'Vietnã', 'ru': 'Вьетнам', 'ar': 'فيتنام', 'ja': 'ベトナム',
      'ko': '베트남', 'zh': '越南', 'nl': 'Vietnam', 'pl': 'Wietnam', 'sv': 'Vietnam',
      'th': 'เวียดนาม', 'vi': 'Việt Nam', 'hi': 'वियतनाम', 'el': 'Βιετνάμ', 'id': 'Vietnam',
    },
    'ID': {
      'en': 'Indonesia', 'tr': 'Endonezya', 'es': 'Indonesia', 'de': 'Indonesien', 'fr': 'Indonésie',
      'it': 'Indonesia', 'pt': 'Indonésia', 'ru': 'Индонезия', 'ar': 'إندونيسيا', 'ja': 'インドネシア',
      'ko': '인도네시아', 'zh': '印度尼西亚', 'nl': 'Indonesië', 'pl': 'Indonezja', 'sv': 'Indonesien',
      'th': 'อินโดนีเซีย', 'vi': 'Indonesia', 'hi': 'इंडोनेशिया', 'el': 'Ινδονησία', 'id': 'Indonesia',
    },
    'EG': {
      'en': 'Egypt', 'tr': 'Mısır', 'es': 'Egipto', 'de': 'Ägypten', 'fr': 'Égypte',
      'it': 'Egitto', 'pt': 'Egito', 'ru': 'Египет', 'ar': 'مصر', 'ja': 'エジプト',
      'ko': '이집트', 'zh': '埃及', 'nl': 'Egypte', 'pl': 'Egipt', 'sv': 'Egypten',
      'th': 'อียิปต์', 'vi': 'Ai Cập', 'hi': 'मिस्र', 'el': 'Αίγυπτος', 'id': 'Mesir',
    },
    'SA': {
      'en': 'Saudi Arabia', 'tr': 'Suudi Arabistan', 'es': 'Arabia Saudita', 'de': 'Saudi-Arabien', 'fr': 'Arabie Saoudite',
      'it': 'Arabia Saudita', 'pt': 'Arábia Saudita', 'ru': 'Саудовская Аравия', 'ar': 'المملكة العربية السعودية', 'ja': 'サウジアラビア',
      'ko': '사우디아라비아', 'zh': '沙特阿拉伯', 'nl': 'Saoedi-Arabië', 'pl': 'Arabia Saudyjska', 'sv': 'Saudiarabien',
      'th': 'ซาอุดีอาระเบีย', 'vi': 'Ả Rập Xê Út', 'hi': 'सऊदी अरब', 'el': 'Σαουδική Αραβία', 'id': 'Arab Saudi',
    },
    'AE': {
      'en': 'United Arab Emirates', 'tr': 'Birleşik Arap Emirlikleri', 'es': 'Emiratos Árabes Unidos', 'de': 'Vereinigte Arabische Emirate', 'fr': 'Émirats Arabes Unis',
      'it': 'Emirati Arabi Uniti', 'pt': 'Emirados Árabes Unidos', 'ru': 'ОАЭ', 'ar': 'الإمارات العربية المتحدة', 'ja': 'アラブ首長国連邦',
      'ko': '아랍에미리트', 'zh': '阿联酋', 'nl': 'Verenigde Arabische Emiraten', 'pl': 'Zjednoczone Emiraty Arabskie', 'sv': 'Förenade Arabemiraten',
      'th': 'สหรัฐอาหรับเอมิเรตส์', 'vi': 'Các Tiểu vương quốc Ả Rập Thống nhất', 'hi': 'संयुक्त अरब अमीरात', 'el': 'Ηνωμένα Αραβικά Εμιράτα', 'id': 'Uni Emirat Arab',
    },
    'ZA': {
      'en': 'South Africa', 'tr': 'Güney Afrika', 'es': 'Sudáfrica', 'de': 'Südafrika', 'fr': 'Afrique du Sud',
      'it': 'Sudafrica', 'pt': 'África do Sul', 'ru': 'Южная Африка', 'ar': 'جنوب أفريقيا', 'ja': '南アフリカ',
      'ko': '남아프리카 공화국', 'zh': '南非', 'nl': 'Zuid-Afrika', 'pl': 'Republika Południowej Afryki', 'sv': 'Sydafrika',
      'th': 'แอฟริกาใต้', 'vi': 'Nam Phi', 'hi': 'दक्षिण अफ्रीका', 'el': 'Νότια Αφρική', 'id': 'Afrika Selatan',
    },
    'AR': {
      'en': 'Argentina', 'tr': 'Arjantin', 'es': 'Argentina', 'de': 'Argentinien', 'fr': 'Argentine',
      'it': 'Argentina', 'pt': 'Argentina', 'ru': 'Аргентина', 'ar': 'الأرجنتين', 'ja': 'アルゼンチン',
      'ko': '아르헨티나', 'zh': '阿根廷', 'nl': 'Argentinië', 'pl': 'Argentyna', 'sv': 'Argentina',
      'th': 'อาร์เจนตินา', 'vi': 'Argentina', 'hi': 'अर्जेंटीना', 'el': 'Αργεντινή', 'id': 'Argentina',
    },
    'CL': {
      'en': 'Chile', 'tr': 'Şili', 'es': 'Chile', 'de': 'Chile', 'fr': 'Chili',
      'it': 'Cile', 'pt': 'Chile', 'ru': 'Чили', 'ar': 'تشيلي', 'ja': 'チリ',
      'ko': '칠레', 'zh': '智利', 'nl': 'Chili', 'pl': 'Chile', 'sv': 'Chile',
      'th': 'ชิลี', 'vi': 'Chile', 'hi': 'चिली', 'el': 'Χιλή', 'id': 'Chili',
    },
    'CO': {
      'en': 'Colombia', 'tr': 'Kolombiya', 'es': 'Colombia', 'de': 'Kolumbien', 'fr': 'Colombie',
      'it': 'Colombia', 'pt': 'Colômbia', 'ru': 'Колумбия', 'ar': 'كولومبيا', 'ja': 'コロンビア',
      'ko': '콜롬비아', 'zh': '哥伦比亚', 'nl': 'Colombia', 'pl': 'Kolumbia', 'sv': 'Colombia',
      'th': 'โคลอมเบีย', 'vi': 'Colombia', 'hi': 'कोलंबिया', 'el': 'Κολομβία', 'id': 'Kolombia',
    },
    'PE': {
      'en': 'Peru', 'tr': 'Peru', 'es': 'Perú', 'de': 'Peru', 'fr': 'Pérou',
      'it': 'Perù', 'pt': 'Peru', 'ru': 'Перу', 'ar': 'بيرو', 'ja': 'ペルー',
      'ko': '페루', 'zh': '秘鲁', 'nl': 'Peru', 'pl': 'Peru', 'sv': 'Peru',
      'th': 'เปรู', 'vi': 'Peru', 'hi': 'पेरू', 'el': 'Περού', 'id': 'Peru',
    },
    'NZ': {
      'en': 'New Zealand', 'tr': 'Yeni Zelanda', 'es': 'Nueva Zelanda', 'de': 'Neuseeland', 'fr': 'Nouvelle-Zélande',
      'it': 'Nuova Zelanda', 'pt': 'Nova Zelândia', 'ru': 'Новая Зеландия', 'ar': 'نيوزيلندا', 'ja': 'ニュージーランド',
      'ko': '뉴질랜드', 'zh': '新西兰', 'nl': 'Nieuw-Zeeland', 'pl': 'Nowa Zelandia', 'sv': 'Nya Zeeland',
      'th': 'นิวซีแลนด์', 'vi': 'New Zealand', 'hi': 'न्यूज़ीलैंड', 'el': 'Νέα Ζηλανδία', 'id': 'Selandia Baru',
    },
    'IE': {
      'en': 'Ireland', 'tr': 'İrlanda', 'es': 'Irlanda', 'de': 'Irland', 'fr': 'Irlande',
      'it': 'Irlanda', 'pt': 'Irlanda', 'ru': 'Ирландия', 'ar': 'أيرلندا', 'ja': 'アイルランド',
      'ko': '아일랜드', 'zh': '爱尔兰', 'nl': 'Ierland', 'pl': 'Irlandia', 'sv': 'Irland',
      'th': 'ไอร์แลนด์', 'vi': 'Ireland', 'hi': 'आयरलैंड', 'el': 'Ιρλανδία', 'id': 'Irlandia',
    },
    'IS': {
      'en': 'Iceland', 'tr': 'İzlanda', 'es': 'Islandia', 'de': 'Island', 'fr': 'Islande',
      'it': 'Islanda', 'pt': 'Islândia', 'ru': 'Исландия', 'ar': 'آيسلندا', 'ja': 'アイスランド',
      'ko': '아이슬란드', 'zh': '冰岛', 'nl': 'IJsland', 'pl': 'Islandia', 'sv': 'Island',
      'th': 'ไอซ์แลนด์', 'vi': 'Iceland', 'hi': 'आइसलैंड', 'el': 'Ισλανδία', 'id': 'Islandia',
    },
    'MA': {
      'en': 'Morocco', 'tr': 'Fas', 'es': 'Marruecos', 'de': 'Marokko', 'fr': 'Maroc',
      'it': 'Marocco', 'pt': 'Marrocos', 'ru': 'Марокко', 'ar': 'المغرب', 'ja': 'モロッコ',
      'ko': '모로코', 'zh': '摩洛哥', 'nl': 'Marokko', 'pl': 'Maroko', 'sv': 'Marocko',
      'th': 'โมร็อกโก', 'vi': 'Ma-rốc', 'hi': 'मोरक्को', 'el': 'Μαρόκο', 'id': 'Maroko',
    },
    'SG': {
      'en': 'Singapore', 'tr': 'Singapur', 'es': 'Singapur', 'de': 'Singapur', 'fr': 'Singapour',
      'it': 'Singapore', 'pt': 'Singapura', 'ru': 'Сингапур', 'ar': 'سنغافورة', 'ja': 'シンガポール',
      'ko': '싱가포르', 'zh': '新加坡', 'nl': 'Singapore', 'pl': 'Singapur', 'sv': 'Singapore',
      'th': 'สิงคโปร์', 'vi': 'Singapore', 'hi': 'सिंगापुर', 'el': 'Σιγκαπούρη', 'id': 'Singapura',
    },
    'MY': {
      'en': 'Malaysia', 'tr': 'Malezya', 'es': 'Malasia', 'de': 'Malaysia', 'fr': 'Malaisie',
      'it': 'Malesia', 'pt': 'Malásia', 'ru': 'Малайзия', 'ar': 'ماليزيا', 'ja': 'マレーシア',
      'ko': '말레이시아', 'zh': '马来西亚', 'nl': 'Maleisië', 'pl': 'Malezja', 'sv': 'Malaysia',
      'th': 'มาเลเซีย', 'vi': 'Malaysia', 'hi': 'मलेशिया', 'el': 'Μαλαισία', 'id': 'Malaysia',
    },
    'XK': {
      'en': 'Kosovo', 'tr': 'Kosova', 'es': 'Kosovo', 'de': 'Kosovo', 'fr': 'Kosovo',
      'it': 'Kosovo', 'pt': 'Kosovo', 'ru': 'Косово', 'ar': 'كوسوفو', 'ja': 'コソボ',
      'ko': '코소보', 'zh': '科索沃', 'nl': 'Kosovo', 'pl': 'Kosowo', 'sv': 'Kosovo',
      'th': 'คอซอวอ', 'vi': 'Kosovo', 'hi': 'कोसोवो', 'el': 'Κόσοβο', 'id': 'Kosovo',
    },
    'NC': {
      'en': 'Northern Cyprus', 'tr': 'Kuzey Kıbrıs Türk Cumhuriyeti', 'es': 'Chipre del Norte', 'de': 'Nordzypern', 'fr': 'Chypre du Nord',
      'it': 'Cipro del Nord', 'pt': 'Chipre do Norte', 'ru': 'Северный Кипр', 'ar': 'قبرص الشمالية', 'ja': '北キプロス',
      'ko': '북키프로스', 'zh': '北塞浦路斯', 'nl': 'Noord-Cyprus', 'pl': 'Cypr Północny', 'sv': 'Nordcypern',
      'th': 'ไซปรัสเหนือ', 'vi': 'Bắc Síp', 'hi': 'उत्तरी साइप्रस', 'el': 'Βόρεια Κύπρος', 'id': 'Siprus Utara',
    },
    'CY': {
      'en': 'Cyprus', 'tr': 'Güney Kıbrıs', 'es': 'Chipre', 'de': 'Zypern', 'fr': 'Chypre',
      'it': 'Cipro', 'pt': 'Chipre', 'ru': 'Кипр', 'ar': 'قبرص', 'ja': 'キプロス',
      'ko': '키프로스', 'zh': '塞浦路斯', 'nl': 'Cyprus', 'pl': 'Cypr', 'sv': 'Cypern',
      'th': 'ไซปรัส', 'vi': 'Síp', 'hi': 'साइप्रस', 'el': 'Κύπρος', 'id': 'Siprus',
    },
    'AZ': {
      'en': 'Azerbaijan', 'tr': 'Azerbaycan', 'es': 'Azerbaiyán', 'de': 'Aserbaidschan', 'fr': 'Azerbaïdjan',
      'it': 'Azerbaigian', 'pt': 'Azerbaijão', 'ru': 'Азербайджан', 'ar': 'أذربيجان', 'ja': 'アゼルバイジャン',
      'ko': '아제르바이잔', 'zh': '阿塞拜疆', 'nl': 'Azerbeidzjan', 'pl': 'Azerbejdżan', 'sv': 'Azerbajdzjan',
      'th': 'อาเซอร์ไบจาน', 'vi': 'Azerbaijan', 'hi': 'अज़रबैजान', 'el': 'Αζερμπαϊτζάν', 'id': 'Azerbaijan',
    },
    'GE': {
      'en': 'Georgia', 'tr': 'Gürcistan', 'es': 'Georgia', 'de': 'Georgien', 'fr': 'Géorgie',
      'it': 'Georgia', 'pt': 'Geórgia', 'ru': 'Грузия', 'ar': 'جورجيا', 'ja': 'ジョージア',
      'ko': '조지아', 'zh': '格鲁吉亚', 'nl': 'Georgië', 'pl': 'Gruzja', 'sv': 'Georgien',
      'th': 'จอร์เจีย', 'vi': 'Gruzia', 'hi': 'जॉर्जिया', 'el': 'Γεωργία', 'id': 'Georgia',
    },
    'UZ': {
      'en': 'Uzbekistan', 'tr': 'Özbekistan', 'es': 'Uzbekistán', 'de': 'Usbekistan', 'fr': 'Ouzbékistan',
      'it': 'Uzbekistan', 'pt': 'Uzbequistão', 'ru': 'Узбекистан', 'ar': 'أوزبكستان', 'ja': 'ウズベキスタン',
      'ko': '우즈베키스탄', 'zh': '乌兹别克斯坦', 'nl': 'Oezbekistan', 'pl': 'Uzbekistan', 'sv': 'Uzbekistan',
      'th': 'อุซเบกิสถาน', 'vi': 'Uzbekistan', 'hi': 'उज़्बेकिस्तान', 'el': 'Ουζμπεκιστάν', 'id': 'Uzbekistan',
    },
    'KZ': {
      'en': 'Kazakhstan', 'tr': 'Kazakistan', 'es': 'Kazajistán', 'de': 'Kasachstan', 'fr': 'Kazakhstan',
      'it': 'Kazakistan', 'pt': 'Cazaquistão', 'ru': 'Казахстан', 'ar': 'كازاخستان', 'ja': 'カザフスタン',
      'ko': '카자흐스탄', 'zh': '哈萨克斯坦', 'nl': 'Kazachstan', 'pl': 'Kazachstan', 'sv': 'Kazakstan',
      'th': 'คาซัคสถาน', 'vi': 'Kazakhstan', 'hi': 'कज़ाकिस्तान', 'el': 'Καζακστάν', 'id': 'Kazakhstan',
    },
  };

  /// Resolves the localized country name for a given ISO country code and language code.
  /// Falls back to English name or provided fallback if no exact translation found.
  static String? getCountryName(String countryCode, String languageCode) {
    final code = countryCode.toUpperCase();
    final lang = languageCode.toLowerCase();
    return _countryTranslations[code]?[lang];
  }
}
