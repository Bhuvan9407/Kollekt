import 'package:flutter/material.dart';

class CollectorLocalization {
  final String languageCode;

  const CollectorLocalization(this.languageCode);

  static const supported = ['en', 'hi', 'mr'];

  String get languageName {
    switch (languageCode) {
      case 'hi':
        return 'हिन्दी';
      case 'mr':
        return 'मराठी';
      default:
        return 'English';
    }
  }

  String get appTitle => _t(
    'Kollekt — Collector',
    'कोलेक्ट — कलेक्टर',
    'कोलेक्ट — कलेक्टर',
  );

  String get welcome => _t(
    'Welcome, Collector',
    'स्वागत है, कलेक्टर',
    'स्वागत आहे, कलेक्टर',
  );

  String get addWaste => _t(
    'Add E-Waste',
    'ई-कचरा जोड़ें',
    'ई-कचरा जोडा',
  );

  String get addWasteSubtitle => _t(
    'Capture, classify, weigh and create a lot',
    'फोटो लें, पहचानें, वजन करें और लॉट बनाएं',
    'फोटो घ्या, ओळखा, वजन करा आणि लॉट तयार करा',
  );

  String get prices => _t(
    'Today’s Prices',
    'आज के भाव',
    'आजचे दर',
  );

  String get pricesSubtitle => _t(
    'Current buying rates and market range',
    'वर्तमान खरीद दर और बाजार सीमा',
    'सध्याचे खरेदी दर आणि बाजार श्रेणी',
  );

  String get history => _t(
    'Price History',
    'कीमत इतिहास',
    'किंमत इतिहास',
  );

  String get historySubtitle => _t(
    'See how local prices change over time',
    'समय के साथ स्थानीय कीमतों में बदलाव देखें',
    'वेळेनुसार स्थानिक दरांमधील बदल पहा',
  );

  String get lots => _t(
    'My Lots',
    'मेरे लॉट',
    'माझे लॉट',
  );

  String get lotsSubtitle => _t(
    'Track submitted material lots',
    'जमा किए गए लॉट देखें',
    'सादर केलेले लॉट पहा',
  );

  String get offers => _t(
    'Offers',
    'ऑफर',
    'ऑफर्स',
  );

  String get offersSubtitle => _t(
    'Compare recycler offers and choose one',
    'रीसायकलर के ऑफर की तुलना करें और चुनें',
    'रीसायकलरच्या ऑफर्सची तुलना करा आणि निवडा',
  );

  String get earnings => _t(
    'My Earnings',
    'मेरी कमाई',
    'माझी कमाई',
  );

  String get earningsSubtitle => _t(
    'View completed transactions and payments',
    'पूरे हुए लेनदेन और भुगतान देखें',
    'पूर्ण झालेले व्यवहार आणि पेमेंट पहा',
  );

  String get traceability => _t(
    'Traceability',
    'ट्रेसबिलिटी',
    'ट्रेसिबिलिटी',
  );

  String get traceabilitySubtitle => _t(
    'View lot and handover history',
    'लॉट और हैंडओवर इतिहास देखें',
    'लॉट आणि हँडओव्हर इतिहास पहा',
  );

  String get logout => _t(
    'Logout',
    'लॉग आउट',
    'लॉग आउट',
  );

  String get language => _t(
    'Language',
    'भाषा',
    'भाषा',
  );

  String get totalPaid => _t(
    'Total Paid',
    'कुल भुगतान',
    'एकूण पेमेंट',
  );

  String get transactions => _t(
    'Transactions',
    'लेनदेन',
    'व्यवहार',
  );

  String get pending => _t(
    'Pending',
    'बाकी',
    'प्रलंबित',
  );

  String get paid => _t(
    'Paid',
    'भुगतान हुआ',
    'पेमेंट झाले',
  );

  String get noTransactions => _t(
    'No transactions yet',
    'अभी कोई लेनदेन नहीं',
    'अजून कोणतेही व्यवहार नाहीत',
  );

  String _t(String en, String hi, String mr) {
    switch (languageCode) {
      case 'hi':
        return hi;
      case 'mr':
        return mr;
      default:
        return en;
    }
  }
}

class CollectorLanguageController extends ChangeNotifier {
  String _languageCode = 'en';

  String get languageCode => _languageCode;

  CollectorLocalization get strings =>
      CollectorLocalization(_languageCode);

  void setLanguage(String languageCode) {
    if (!CollectorLocalization.supported.contains(languageCode)) {
      return;
    }

    if (_languageCode == languageCode) {
      return;
    }

    _languageCode = languageCode;
    notifyListeners();
  }
}

final collectorLanguageController = CollectorLanguageController();

class CollectorLanguageScope
    extends InheritedNotifier<CollectorLanguageController> {
  CollectorLanguageScope({
    super.key,
    required super.child,
  }) : super(
    notifier: collectorLanguageController,
  );

  static CollectorLanguageController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CollectorLanguageScope>();

    if (scope == null || scope.notifier == null) {
      throw FlutterError(
        'CollectorLanguageScope is missing from the widget tree.',
      );
    }

    return scope.notifier!;
  }
}