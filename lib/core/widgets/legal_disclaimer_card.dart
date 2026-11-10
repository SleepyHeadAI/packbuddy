import 'package:flutter/material.dart';
import 'package:packbuddy/core/theme/app_colors.dart';

/// Enum representing supported legal disclaimer types
enum LegalDisclaimerType {
  airlineBaggage,
  emergencySos,
}

/// A legally protective disclaimer banner designed to safeguard the app from
/// liability regarding airline baggage policies or local emergency numbers.
/// Fully localized across all 20 supported languages and tested for zero overflow.
class LegalDisclaimerBanner extends StatelessWidget {
  final LegalDisclaimerType type;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool compact;

  const LegalDisclaimerBanner({
    super.key,
    required this.type,
    this.margin,
    this.padding,
    this.compact = false,
  });

  /// Factory constructor for airline baggage allowance sheet
  const LegalDisclaimerBanner.airline({
    super.key,
    this.margin,
    this.padding,
    this.compact = false,
  }) : type = LegalDisclaimerType.airlineBaggage;

  /// Factory constructor for emergency SOS guide sheet
  const LegalDisclaimerBanner.emergency({
    super.key,
    this.margin,
    this.padding,
    this.compact = false,
  }) : type = LegalDisclaimerType.emergencySos;

  static String getTitle(String languageCode) {
    final lang = languageCode.toLowerCase().split('_').first;
    switch (lang) {
      case 'tr':
        return 'Yasal Bilgilendirme';
      case 'de':
        return 'Haftungsausschluss';
      case 'es':
        return 'Aviso Legal';
      case 'fr':
        return 'Avis Juridique';
      case 'it':
        return 'Disclaimer Legale';
      case 'pt':
        return 'Aviso Legal';
      case 'ru':
        return 'Отказ от ответственности';
      case 'zh':
        return '法律免责声明';
      case 'ja':
        return '免責事項';
      case 'ko':
        return '법적 면책 고지';
      case 'hi':
        return 'कानूनी अस्वीकरण';
      case 'ar':
        return 'إخلاء مسؤولية قانوني';
      case 'nl':
        return 'Juridische disclaimer';
      case 'el':
        return 'Νομική Αποποίηση';
      case 'sv':
        return 'Friskrivningsklausul';
      case 'pl':
        return 'Zastrzeżenie prawne';
      case 'id':
        return 'Penafian Hukum';
      case 'th':
        return 'ข้อจำกัดความรับผิดทางกฎหมาย';
      case 'vi':
        return 'Tuyên bố từ chối trách nhiệm';
      case 'en':
      default:
        return 'Legal Disclaimer';
    }
  }

  static String getMessage(LegalDisclaimerType type, String languageCode) {
    final lang = languageCode.toLowerCase().split('_').first;
    if (type == LegalDisclaimerType.airlineBaggage) {
      switch (lang) {
        case 'tr':
          return 'Bu bilgiler yalnızca genel bilgilendirme amaçlıdır; havayolu bagaj limitleri, ölçüleri, kabin kuralları ve ücret tarifeleri bilet tipine veya rotaya göre anlık olarak değişebilir. Olası yanlışlıklar, gecikmeler veya ek ücretlerden dolayı PackBuddy hiçbir hukuki sorumluluk kabul etmez. Seyahatiniz öncesinde lütfen havayolunuzun resmi web sitesinden güncel bilgileri teyit ediniz.';
        case 'de':
          return 'Diese Angaben dienen ausschließlich der allgemeinen Information; Freigepäckgrenzen, Maße und Richtlinien der Fluggesellschaften können je nach Tarif oder Flugstrecke ohne Vorankündigung variieren. PackBuddy haftet nicht für Mehrkosten, Verspätungen oder Unstimmigkeiten. Bitte prüfen Sie die aktuellen Bestimmungen vor Abflug stets auf der offiziellen Website Ihrer Fluggesellschaft.';
        case 'es':
          return 'Esta información se proporciona únicamente como referencia general; los límites de equipaje, dimensiones y tarifas de las aerolíneas pueden cambiar sin previo aviso según la tarifa o ruta. PackBuddy no asume ninguna responsabilidad legal por cargos adicionales, demoras o discrepancias. Confirme las normas vigentes en el sitio oficial de su aerolínea antes de viajar.';
        case 'fr':
          return 'Ces informations sont fournies à titre indicatif uniquement ; les franchises de bagages, dimensions et règles des compagnies aériennes peuvent varier sans préavis selon le billet ou la destination. PackBuddy décline toute responsabilité juridique en cas de frais supplémentaires ou d\'erreurs. Veuillez vérifier les règles en vigueur sur le site officiel de votre compagnie avant votre voyage.';
        case 'it':
          return 'Queste informazioni sono fornite solo a scopo informativo generale; i limiti di peso, dimensioni e tariffe delle compagnie aeree possono cambiare senza preavviso in base alla classe di viaggio o alla tratta. PackBuddy declina ogni responsabilità legale per eventuali costi aggiuntivi o imprecisioni. Si prega di verificare sempre le regole sul sito ufficiale della compagnia aerea prima della partenza.';
        case 'pt':
          return 'Estas informações destinam-se apenas a referência geral; limites de bagagem, dimensões e políticas das companhias aéreas podem mudar sem aviso prévio conforme a tarifa ou rota. O PackBuddy não assume responsabilidade jurídica por taxas extras ou divergências. Confirme sempre as regras no site oficial da companhia aérea antes de embarcar.';
        case 'ru':
          return 'Данная информация носит исключительно ознакомительный характер; нормы провоза багажа, габариты и тарифы авиакомпаний могут изменяться без предварительного уведомления в зависимости от билета или маршрута. PackBuddy не несет юридической ответственности за доплаты или расхождения. Перед вылетом обязательно проверяйте правила на официальном сайте вашей авиакомпании.';
        case 'zh':
          return '本信息仅供一般参考；各航空公司的行李额度、尺寸限制、随身政策与收费标准可能根据舱位或航线随时调整且不另行通知。PackBuddy不对任何额外费用、延误或信息偏差承担法律责任。出行前请务必访问承运航空公司的官方网站核对最新规定。';
        case 'ja':
          return '本情報は一般的な参考情報としてのみ提供されています。航空会社の手荷物許容量、サイズ制限、運賃規則は座席クラスや路線により予告なく変更される場合があります。PackBuddyは追加料金や情報の差異に関して一切の法的責任を負いません。ご出発前に必ずご利用の航空会社公式サイトにて最新情報をご確認ください。';
        case 'ko':
          return '본 정보는 일반적인 참고 목적으로만 제공됩니다. 항공사의 수하물 허용량, 규격 및 요금 정책은 항공권 등급이나 노선에 따라 사전 고지 없이 변경될 수 있습니다. PackBuddy는 추가 요금, 지연 또는 오류에 대해 법적 책임을 지지 않습니다. 여행 전 반드시 항공사 공식 웹사이트에서 최신 규정을 확인하시기 바랍니다.';
        case 'hi':
          return 'यह जानकारी केवल सामान्य संदर्भ के लिए है; एयरलाइन की बैगेज सीमाएं, आकार और शुल्क टिकट श्रेणी या मार्ग के आधार पर बिना किसी पूर्व सूचना के बदल सकते हैं। किसी भी अतिरिक्त शुल्क या विसंगति के लिए PackBuddy कानूनी रूप से जिम्मेदार नहीं होगा। कृपया यात्रा से पहले अपनी एयरलाइन की आधिकारिक वेबसाइट से नियमों की पुष्टि करें।';
        case 'ar':
          return 'تُقدم هذه المعلومات كمرجع عام فقط؛ تخضع حدود وأبعاد الأمتعة وسياسات شركات الطيران للتغيير دون إشعار مسبق وفقًا لدرجة التذكرة أو مسار الرحلة. لا يتحمل PackBuddy أي مسؤولية قانونية عن أي رسوم إضافية أو اختلافات. يُرجى التحقق من القواعد المعتمدة عبر الموقع الرسمي لشركة الطيران قبل السفر.';
        case 'nl':
          return 'Deze informatie is uitsluitend bedoeld als algemene richtlijn; bagagelimieten, afmetingen en tarieven van luchtvaartmaatschappijen kunnen per tariefklasse of route zonder voorafgaande kennisgeving veranderen. PackBuddy aanvaardt geen aansprakelijkheid voor extra kosten of afwijkingen. Controleer voor vertrek altijd de officiële website van uw luchtvaartmaatschappij.';
        case 'el':
          return 'Οι πληροφορίες αυτές παρέχονται μόνο ως γενικός οδηγός. Τα όρια βάρους, οι διαστάσεις και οι χρεώσεις των αεροπορικών εταιρειών μπορούν να τροποποιηθούν χωρίς ειδοποίηση. Το PackBuddy δεν φέρει καμία νομική ευθύνη για επιπλέον χρεώσεις ή λάθη. Ελέγχετε πάντα τον επίσημο ιστότοπο της αεροπορικής εταιρείας πριν από την πτήση.';
        case 'sv':
          return 'Denna information tillhandahålls endast i vägledande syfte; flygbolagens bagageregler, mått och avgifter kan ändras utan förvarning beroende på biljettyp eller rutt. PackBuddy tar inget juridiskt ansvar för eventuella extra avgifter eller felaktigheter. Kontrollera alltid gällande regler direkt på flygbolagets officiella webbplats innan avresa.';
        case 'pl':
          return 'Informacje te służą wyłącznie celom ogólnoinformacyjnym; limity bagażu, wymiary oraz opłaty linii lotniczych mogą ulec zmianie bez uprzedzenia w zależności od taryfy lub trasy. PackBuddy nie ponosi odpowiedzialności prawnej za dodatkowe opłaty ani nieścisłości. Przed podróżą należy sprawdzić aktualne zasady na oficjalnej stronie linii lotniczej.';
        case 'id':
          return 'Informasi ini disediakan hanya sebagai acuan umum; batas berat, dimensi, dan tarif bagasi maskapai dapat berubah sewaktu-waktu tanpa pemberitahuan sesuai kelas tiket atau rute. PackBuddy tidak bertanggung jawab secara hukum atas biaya tambahan atau perbedaan aturan. Harap pastikan kembali informasi terbaru di situs resmi maskapai sebelum bepergian.';
        case 'th':
          return 'ข้อมูลนี้จัดทำขึ้นเพื่อเป็นข้อมูลอ้างอิงทั่วไปเท่านั้น ขีดจำกัดสัมภาระ ขนาด และอัตราค่าธรรมเนียมของสายการบินอาจเปลี่ยนแปลงได้โดยไม่ต้องแจ้งให้ทราบตามประเภทตั๋วหรือเส้นทาง PackBuddy ไม่รับผิดชอบทางกฎหมายต่อค่าธรรมเนียมเพิ่มเติมหรือข้อผิดพลาดใดๆ กรุณาตรวจสอบข้อมูลล่าสุดจากเว็บไซต์ทางการของสายการบินก่อนการเดินทาง';
        case 'vi':
          return 'Thông tin này chỉ mang tính chất tham khảo chung; quy định về hành lý, kích thước và mức phí của hãng hàng không có thể thay đổi bất cứ lúc nào tùy theo hạng vé hoặc lộ trình bay. PackBuddy không chịu trách nhiệm pháp lý đối với các khoản phí phát sinh hoặc sai sót. Vui lòng xác nhận lại trên trang web chính thức của hãng trước khi khởi hành.';
        case 'en':
        default:
          return 'This information is provided for general reference only; airline baggage limits, dimensions, cabin policies, and fare tariffs may change without prior notice based on ticket class or route. PackBuddy assumes no legal liability for any inaccuracies, delays, or additional fees. Please verify current rules directly on your airline\'s official website prior to travel.';
      }
    } else {
      // emergencySos
      switch (lang) {
        case 'tr':
          return 'Bu bilgiler yalnızca genel bilgilendirme amaçlıdır; acil durum numaraları, yerel mevzuat ve prosedürler resmi makamlarca önceden haber verilmeksizin değiştirilebilir. Olası yanlışlık, eksiklik veya güncellemelerden dolayı PackBuddy hiçbir hukuki sorumluluk kabul etmez. Acil bir durumda lütfen doğrudan yerel resmi makamlardan ve yetkili acil servislerden bilgi alınız.';
        case 'de':
          return 'Diese Angaben dienen ausschließlich der allgemeinen Information; Notrufnummern und lokale Vorschriften können sich jederzeit unangekündigt ändern. PackBuddy übernimmt keinerlei rechtliche Haftung für Fehler oder Änderungen. Wenden Sie sich im Notfall stets direkt an die zuständigen örtlichen Behörden.';
        case 'es':
          return 'Esta información se proporciona únicamente con fines informativos generales; los números de emergencia y normativas locales pueden cambiar sin previo aviso. PackBuddy no asume ninguna responsabilidad legal por errores o actualizaciones. En caso de emergencia, consulte directamente a las autoridades oficiales locales.';
        case 'fr':
          return 'Ces informations sont fournies à titre indicatif uniquement ; les numéros d\'urgence et réglementations locales peuvent changer sans préavis. PackBuddy décline toute responsabilité juridique en cas d\'erreur ou d\'omission. En cas d\'urgence, contactez toujours directement les autorités officielles compétentes.';
        case 'it':
          return 'Queste informazioni sono fornite solo a scopo informativo generale; i numeri di emergenza e le normative locali possono variare senza preavviso. PackBuddy declina ogni responsabilità legale per inesattezze o aggiornamenti. In caso di emergenza, rivolgersi direttamente alle autorità ufficiali locali.';
        case 'pt':
          return 'Estas informações são fornecidas apenas para orientação geral; números de emergência e procedimentos locais podem mudar sem aviso prévio. O PackBuddy não assume responsabilidade jurídica por imprecisões ou alterações. Em emergências, consulte diretamente as autoridades oficiais locais.';
        case 'ru':
          return 'Данная информация носит исключительно справочный характер; экстренные номера и правила могут изменяться официальными органами без уведомления. PackBuddy не несет юридической ответственности за неточности или изменения. В экстренных случаях обращайтесь напрямую в официальные службы.';
        case 'zh':
          return '本信息仅供一般参考；当地紧急救援电话、法规与程序可能随时变更且不另行通知。PackBuddy不对任何信息偏差、遗漏或后续变动承担法律责任。遇到紧急情况时，请务必直接向当地官方主管机构及救援部门核实。';
        case 'ja':
          return '本情報は一般的な参考用としてのみ提供されており、緊急連絡先や現地の公的規定は予告なく変更される場合があります。PackBuddyは誤りや最新情報との差異について一切の法的責任を負いません。緊急時は必ず現地の公式機関に直接お問い合わせください。';
        case 'ko':
          return '본 정보는 일반적인 참고 목적으로만 제공되며, 현지 긴급 전화번호 및 규정은 사전 고지 없이 변경될 수 있습니다. PackBuddy는 정보의 오류 또는 변경에 대해 어떠한 법적 책임도 지지 않습니다. 긴급 상황 시 항상 관할 공식 기관에 직접 확인하십시오.';
        case 'hi':
          return 'यह जानकारी केवल सामान्य संदर्भ के लिए प्रदान की गई है; स्थानीय आपातकालीन नंबर और नियम बिना किसी पूर्व सूचना के बदल सकते हैं। किसी भी त्रुटि या बदलाव के लिए PackBuddy कोई कानूनी दायित्व स्वीकार नहीं करता है। आपात स्थिति में हमेशा सीधे आधिकारिक स्थानीय अधिकारियों से संपर्क करें।';
        case 'ar':
          return 'تُقدم هذه المعلومات لأغراض إرشادية عامة فقط؛ قد تتغير أرقام الطوارئ والإجراءات المحلية دون إشعار مسبق. لا يتحمل PackBuddy أي مسؤولية قانونية عن أي أخطاء أو تحديثات. في حالات الطوارئ، يُرجى دائمًا مراجعة السلطات الرسمية المختصة مباشرة.';
        case 'nl':
          return 'Deze informatie is uitsluitend bedoeld als algemene richtlijn; lokale noodnummers en voorschriften kunnen zonder voorafgaande kennisgeving wijzigen. PackBuddy aanvaardt geen enkele juridische aansprakelijkheid voor onjuistheden. Neem in geval van nood altijd rechtstreeks contact op met officiële instanties.';
        case 'el':
          return 'Οι πληροφορίες αυτές παρέχονται αποκλειστικά για γενική ενημέρωση. Οι αριθμοί έκτακτης ανάγκης και οι κανονισμοί μπορούν να τροποποιηθούν χωρίς προειδοποίηση. Το PackBuddy δεν φέρει καμία νομική ευθύνη για ανακρίβειες. Σε επείγουσες καταστάσεις, επικοινωνείτε πάντοτε απευθείας με τις αρμόδιες αρχές.';
        case 'sv':
          return 'Denna information tillhandahålls endast i informativt syfte; lokala nödnummer och föreskrifter kan ändras utan föregående meddelande. PackBuddy frånsäger sig allt juridiskt ansvar för eventuella felaktigheter. Kontakta alltid behöriga lokala myndigheter direkt vid en nödsituation.';
        case 'pl':
          return 'Informacje te mają charakter wyłącznie orientacyjny; lokalne numery alarmowe i procedury mogą ulec zmianie bez powiadomienia. PackBuddy nie ponosi odpowiedzialności prawnej za jakiekolwiek błędy lub zmiany. W nagłych wypadkach należy kontaktować się bezpośrednio z oficjalnymi służbami.';
        case 'id':
          return 'Informasi ini disediakan hanya sebagai panduan umum; nomor darurat dan peraturan setempat dapat berubah tanpa pemberitahuan sebelumnya. PackBuddy tidak bertanggung jawab secara hukum atas ketidakakuratan atau pembaruan. Dalam kondisi darurat, selalu hubungi instansi resmi setempat secara langsung.';
        case 'th':
          return 'ข้อมูลนี้จัดทำขึ้นเพื่อการอ้างอิงทั่วไปเท่านั้น หมายเลขฉุกเฉินและระเบียบปฏิบัติในท้องถิ่นอาจเปลี่ยนแปลงได้โดยไม่ต้องแจ้งให้ทราบล่วงหน้า PackBuddy ไม่รับผิดชอบทางกฎหมายต่อความคลาดเคลื่อนใดๆ ในกรณีฉุกเฉินโปรดติดต่อหน่วยงานทางการในพื้นที่โดยตรง';
        case 'vi':
          return 'Thông tin này chỉ nhằm mục đích tham khảo chung; số điện thoại khẩn cấp và quy định địa phương có thể thay đổi mà không cần báo trước. PackBuddy không chịu trách nhiệm pháp lý đối với bất kỳ sai lệch nào. Trong trường hợp khẩn cấp, vui lòng liên hệ trực tiếp với cơ quan chức năng chính thức.';
        case 'en':
        default:
          return 'This information is provided for general reference only; local emergency numbers, regulations, and procedures may change without prior notice. PackBuddy disclaims any legal liability for inaccuracies, omissions, or updates. In an emergency, please verify and contact official local authorities and emergency services directly.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;
    final title = getTitle(langCode);
    final message = getMessage(type, langCode);

    final isEmergency = type == LegalDisclaimerType.emergencySos;
    final accentColor = isEmergency ? AppColors.errorPastel : AppColors.primaryAmber;
    final bgColor = isDark
        ? (isEmergency
            ? AppColors.errorPastel.withValues(alpha: 0.08)
            : AppColors.primaryAmber.withValues(alpha: 0.08))
        : (isEmergency ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB));
    final borderColor = isDark
        ? accentColor.withValues(alpha: 0.25)
        : (isEmergency ? const Color(0xFFFECACA) : const Color(0xFFFDE68A));

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.2 : 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEmergency ? Icons.shield_outlined : Icons.gavel_rounded,
              size: 15,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                    color: isDark ? theme.colorScheme.onSurface : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9)
                        : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

