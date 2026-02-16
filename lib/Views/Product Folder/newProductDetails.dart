import 'dart:convert';
import 'dart:developer';

import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:graba2z/Controllers/review_controller.dart';
import 'package:graba2z/Utils/image_helper.dart';
import 'package:graba2z/Views/Home/home.dart';
import 'package:graba2z/Views/Product%20Folder/add_review_view.dart';
import 'package:graba2z/Views/Product%20Folder/bulk_purchace_view.dart';
import 'package:graba2z/Views/Product%20Folder/get_coupon.dart';
import 'package:graba2z/Views/Product%20Folder/request_form.dart';
import 'package:graba2z/Views/Product%20Folder/review_show_widget.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:get/get.dart';
import 'package:graba2z/Api/Services/apiservices.dart';
import 'package:graba2z/Configs/config.dart';
import 'package:graba2z/Controllers/addtocart.dart';
import 'package:graba2z/Controllers/favController.dart';
import 'package:graba2z/Controllers/home_controller.dart';
import 'package:graba2z/Utils/appextensions.dart';
import 'package:graba2z/Views/Home/Screens/Cart/cart.dart';
import 'package:graba2z/Views/Product%20Folder/newProduct_card.dart';
import 'package:html/parser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/packages.dart';
import 'package:http/http.dart' as http;
import 'package:graba2z/Views/Payment/tamara_info_screen.dart';
import 'package:graba2z/Views/Payment/tabby_info_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graba2z/Controllers/review_update_bus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

const String _homeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M4 12L12 4L20 12" />
  <path d="M5 12V20H10V15H14V20H19V12" />
</svg>
''';

const String _chat = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-message-circle-icon lucide-message-circle"><path d="M2.992 16.342a2 2 0 0 1 .094 1.167l-1.065 3.29a1 1 0 0 0 1.236 1.168l3.413-.998a2 2 0 0 1 1.099.092 10 10 0 1 0-4.777-4.719"/></svg>
''';

class NewProductDetails extends StatefulWidget {
  List images;
  List specs;
  List reviews;
  String productId;
  String name;
  String brandName;
  String categoryName;
  String categoryId;
  String sku;
  String offerPrice;
  String price;
  String stockStatus;
  String description;
  String shortdesc;
  String subcategoryName; // already exists

  NewProductDetails({
    super.key,
    required this.images,
    required this.specs,
    required this.reviews,
    required this.productId,
    required this.name,
    required this.brandName,
    required this.categoryName,
    required this.categoryId,
    required this.sku,
    required this.offerPrice,
    required this.price,
    required this.stockStatus,
    required this.description,
    required this.shortdesc,
    this.subcategoryName = '', // already has default
  });

  @override
  State<NewProductDetails> createState() => _NewProductDetailsState();
}

class _NewProductDetailsState extends State<NewProductDetails>
    with TickerProviderStateMixin {
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  var _cartQuantityItems = 0;
  final GlobalKey productImageKey = GlobalKey();
  late String _selectedImageUrl;
  int _currentImageIndex = 0;
  final CarouselSliderController _slider = CarouselSliderController();

  HomeController _homeController = Get.put(HomeController());
  late TabController _tabController;

  final List<String> _tabs = [
    "Description",
    "More Information",
    "Reviews",
  ];

  ReviewController _reviewCont = Get.put(ReviewController());

  // API reviews state
  Map<String, dynamic>? _apiReviewStats;
  int _apiCurrentPage = 1;
  bool _apiHasNext = false;
  bool _apiLoading = false;

  // Frequently Bought Together state
  final Map<String, bool> _selectedBundleItems = {};
  List<Map<String, dynamic>> _frequentlyBought = [];
  bool _frequentlyBoughtLoading = false;
  static const int _maxFrequentlyBought = 2; // match website limit
  static const int _defaultPreselectedCount = 2; // match website

  // Category/keyword mapping for accessory suggestions (matches your website exactly)
  static final List<Map<String, dynamic>> _accessoryGroups = [
    {
      'match': [
        'headphone',
        'headphones',
        'headset',
        'earphone',
        'earphones',
        'earbuds',
        'earbud'
      ],
      'excludeMain': [
        'headphone',
        'headphones',
        'headset',
        'earphone',
        'earphones',
        'earbuds',
        'laptop',
        'desktop',
        'mobile',
        'phone',
        'tablet',
        'monitor',
        'printer'
      ],
      'suggestions': [
        {
          'keywords': [
            'headphone',
            'headphones',
            'headset',
            'earphone',
            'earphones',
            'earbuds'
          ],
          'searches': [
            'headphone',
            'headphones',
            'wireless headphone',
            'bluetooth headphone',
            'earbuds'
          ]
        },
        {
          'keywords': ['mouse', 'mice'],
          'searches': ['wireless mouse', 'bluetooth mouse']
        },
        {
          'keywords': ['bag', 'case', 'backpack', 'pouch'],
          'searches': ['laptop bag', 'backpack', 'carrying case', 'travel bag']
        }
      ]
    },
    {
      'match': ['laptop', 'notebook', 'macbook'],
      'excludeMain': [
        'laptop',
        'notebook',
        'macbook',
        'desktop',
        'pc',
        'all in one',
        'monitor',
        'printer',
        'headphone',
        'mobile'
      ],
      'suggestions': [
        {
          'keywords': ['mouse', 'mice'],
          'searches': ['wireless mouse', 'bluetooth mouse', 'laptop mouse']
        },
        {
          'keywords': ['keyboard'],
          'searches': [
            'wireless keyboard',
            'bluetooth keyboard',
            'laptop keyboard'
          ]
        },
        {
          'keywords': ['bag', 'case', 'backpack', 'sleeve'],
          'searches': [
            'laptop bag',
            'laptop backpack',
            'laptop case',
            'laptop sleeve'
          ]
        },
        {
          'keywords': ['hub', 'adapter', 'dongle'],
          'searches': ['usb hub', 'usb-c hub', 'hdmi adapter', 'type-c adapter']
        },
        {
          'keywords': ['stand', 'holder'],
          'searches': ['laptop stand', 'laptop holder']
        },
        {
          'keywords': ['cooler', 'cooling', 'pad'],
          'searches': ['laptop cooling pad', 'cooling stand']
        },
        {
          'keywords': ['headphone', 'headset', 'earphone', 'earbuds'],
          'searches': ['wireless headphones', 'bluetooth headset', 'earbuds']
        },
        {
          'keywords': ['ssd', 'ram', 'memory'],
          'searches': ['external ssd', 'laptop ram', 'memory upgrade']
        }
      ]
    },
    {
      'match': [
        'desktop',
        'pc',
        'computer',
        'workstation',
        'all in one',
        'aio'
      ],
      'excludeMain': [
        'desktop',
        'pc',
        'computer',
        'workstation',
        'laptop',
        'notebook',
        'macbook',
        'monitor',
        'printer',
        'mobile'
      ],
      'suggestions': [
        {
          'keywords': ['mouse', 'mice'],
          'searches': ['wired mouse', 'wireless mouse', 'gaming mouse']
        },
        {
          'keywords': ['keyboard'],
          'searches': [
            'wired keyboard',
            'wireless keyboard',
            'mechanical keyboard'
          ]
        },
        {
          'keywords': ['speaker', 'speakers'],
          'searches': ['desktop speakers', 'computer speakers']
        },
        {
          'keywords': ['webcam', 'camera'],
          'searches': ['usb webcam', 'hd webcam']
        },
        {
          'keywords': ['headphone', 'headset'],
          'searches': ['wired headset', 'usb headset', 'gaming headset']
        },
        {
          'keywords': ['ssd', 'hdd', 'storage'],
          'searches': ['internal ssd', 'external hdd', 'storage']
        },
        {
          'keywords': ['ram', 'memory'],
          'searches': ['desktop ram', 'ddr4 ram', 'memory']
        }
      ]
    },
    {
      'match': ['monitor', 'display', 'screen'],
      'excludeMain': [
        'monitor',
        'display',
        'laptop',
        'desktop',
        'pc',
        'printer',
        'mobile',
        'tablet'
      ],
      'suggestions': [
        {
          'keywords': ['cables'],
          'searches': ['cables']
        },
        {
          'keywords': ['mouse', 'mice'],
          'searches': ['wireless mouse', 'gaming mouse']
        },
      ]
    },
    {
      'match': [
        'printer',
        'printers',
        'copier',
        'scanner',
        'scanners',
        'multifunction',
        'mfp',
        'inkjet',
        'laser'
      ],
      'excludeMain': [
        'printer',
        'printers',
        'copier',
        'scanner',
        'laptop',
        'desktop',
        'monitor',
        'networking',
        'router',
        'switch',
        'access point',
        'mobile'
      ],
      'suggestions': [
        {
          'keywords': ['paper', 'a4', 'a3'],
          'searches': ['a4 paper', 'printer paper', 'copy paper']
        },
        {
          'keywords': ['ink', 'toner', 'cartridge', 'cartridges'],
          'searches': [
            'printer ink',
            'toner cartridge',
            'ink cartridge',
            'toner'
          ]
        },
        {
          'keywords': ['usb', 'cable', 'power'],
          'searches': ['usb printer cable', 'printer cable', 'power cable']
        }
      ]
    },
    {
      'match': ['mobile', 'phone', 'smartphone', 'iphone', 'samsung'],
      'excludeMain': [
        'mobile',
        'phone',
        'smartphone',
        'iphone',
        'samsung',
        'tablet',
        'laptop',
        'desktop',
        'monitor'
      ],
      'suggestions': [
        {
          'keywords': ['case', 'cover'],
          'searches': ['phone case', 'mobile cover', 'protective case']
        },
        {
          'keywords': ['screen', 'protector', 'glass'],
          'searches': ['screen protector', 'tempered glass']
        },
        {
          'keywords': ['charger', 'adapter'],
          'searches': ['fast charger', 'phone charger', 'usb charger']
        },
        {
          'keywords': ['cable', 'usb', 'type-c'],
          'searches': ['charging cable', 'usb cable', 'type-c cable']
        },
        {
          'keywords': ['power bank', 'powerbank', 'battery'],
          'searches': ['power bank', 'portable charger']
        },
        {
          'keywords': ['earphone', 'earbuds', 'headphone'],
          'searches': ['wireless earbuds', 'bluetooth earphones']
        },
        {
          'keywords': ['holder', 'stand', 'mount'],
          'searches': ['phone holder', 'car mount', 'phone stand']
        }
      ]
    }
  ];

  // Fallback keywords when no specific group matches
  static final List<String> _fallbackKeywords = [
    'mouse',
    'keyboard',
    'headphone',
    'headset',
    'earbuds',
    'earphone',
    'bag',
    'case',
    'hdmi',
    'cable',
    'ethernet',
    'router',
    'switch',
    'hub',
    'adapter',
    'ssd',
    'ram',
    'memory',
    'stand',
    'holder'
  ];

  // NEW: Generic fallback search terms (laptop-style for all categories)
  static final List<String> _genericFallbackSearches = [
    'wireless mouse',
    'bluetooth mouse',
    'wireless keyboard',
    'bluetooth keyboard',
    'usb hub',
    'usb-c hub',
    'hdmi cable',
    'laptop bag',
    'laptop stand',
    'screen cleaner',
    'headphones',
    'earbuds',
  ];

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  double _basePrice(Map p) {
    final offer = _toDouble(p['offerPrice']);
    final price = _toDouble(p['price']);
    return (offer > 0 && offer < price) ? offer : price;
  }

  double _discounted(double price, int percent) =>
      (price * (100 - percent)) / 100.0;

  String _fmt(double v) => 'AED ${v.toStringAsFixed(2)}';

  String _idOf(Map p) => (p['_id'] ?? '').toString();

  String _imgOf(Map p) {
    final img = p['image']?.toString();
    if (img != null && img.isNotEmpty) return img;
    final g = p['galleryImages'];
    if (g is List && g.isNotEmpty && g.first != null) return g.first.toString();
    return 'https://i.postimg.cc/SsWYSvq6/noimage.png';
  }

  @override
  void initState() {
    super.initState();
    log('NewProductDetails initState START ------------------------');
    log('NewProductDetails initState: Received Product ID: ${widget.productId}');
    log('NewProductDetails initState: Received Name: ${widget.name}');
    log('NewProductDetails initState: Received Images count: ${widget.images.length}');
    if (widget.images.isNotEmpty) {
      log('NewProductDetails initState: First image: ${widget.images.first}');
    } else {
      log('NewProductDetails initState: Received Images list is EMPTY');
    }
    log('NewProductDetails initState: Received Price: ${widget.price}');
    log('NewProductDetails initState: Received OfferPrice: ${widget.offerPrice}');
    log('NewProductDetails initState: Received Category ID: ${widget.categoryId}');
    log('NewProductDetails initState: Received stockStatus: ${widget.stockStatus}');

    _tabController = TabController(length: _tabs.length, vsync: this);

    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _selectedImageUrl = widget.images.isNotEmpty
        ? ImageHelper.getUrl(widget.images.first) ??
            "https://i.postimg.cc/SsWYSvq6/noimage.png"
        : "https://i.postimg.cc/SsWYSvq6/noimage.png";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.categoryId.isNotEmpty) {
          _homeController.getRelatedProducts(widget.categoryId);
        } else {
          log('NewProductDetails initState: categoryId is empty, skipping getRelatedProducts.');
        }

        if (widget.reviews is List) {
          _reviewCont.reviews.value = List<dynamic>.from(widget.reviews);
        } else {
          log('NewProductDetails initState: widget.reviews is not a List, initializing with empty list.');
          _reviewCont.reviews.value = [];
        }
        // Fetch fresh reviews from API (page 1)
        _fetchReviews(page: 1);
        // Fetch frequently bought together items using smart accessory system
        _fetchFrequentlyBought();
      }
    });

    log('NewProductDetails initState END ------------------------');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews({int page = 1}) async {
    if (widget.productId.isEmpty) return;
    if (mounted) {
      setState(() => _apiLoading = true);
    }

    try {
      final endpoint =
          Configss.getReview.replaceFirst(':productId', widget.productId);
      final url = '$endpoint?page=$page';
      log('Fetching reviews: $url');

      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(res.body) as Map<String, dynamic>;
        final List<dynamic> newReviewsRaw =
            (body['reviews'] as List?) ?? const [];
        final List<Map<String, dynamic>> newReviews = newReviewsRaw
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final Map<String, dynamic>? stats = body['stats'] is Map
            ? Map<String, dynamic>.from(body['stats'])
            : null;
        final Map<String, dynamic> pagination = body['pagination'] is Map
            ? Map<String, dynamic>.from(body['pagination'])
            : {};

        if (!mounted) return;
        setState(() {
          if (page == 1) {
            _reviewCont.reviews.value = newReviews;
          } else {
            _reviewCont.reviews.addAll(newReviews);
          }
          _apiReviewStats = stats;
          _apiCurrentPage = (pagination['currentPage'] as int?) ?? page;
          _apiHasNext = (pagination['hasNext'] as bool?) ?? false;
        });
      } else {
        log('Failed to fetch reviews. Status: ${res.statusCode} Body: ${res.body}');
      }
    } catch (e, st) {
      log('Error fetching reviews: $e\n$st');
    } finally {
      if (mounted) {
        setState(() => _apiLoading = false);
      }
    }
  }

  bool _includesAny(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    return keywords.any((k) => lower.contains(k.toLowerCase()));
  }

  bool _isMainProductType(String text, List<String> excludeWords) {
    final lower = text.toLowerCase();

    for (final word in excludeWords) {
      final w = word.toLowerCase();

      // Exact match
      if (lower == w) return true;

      // Word boundary match
      final pattern = RegExp(r'\b' + RegExp.escape(w) + r'\b');
      if (pattern.hasMatch(lower)) return true;

      // Common patterns
      if (w == 'laptop' &&
          (lower.contains('laptop') || lower.contains('notebook'))) return true;
      if (w == 'desktop' &&
          (lower.contains('desktop') ||
              lower.contains(' pc') ||
              lower.contains('workstation'))) return true;
      if (w == 'monitor' && lower.contains('monitor')) return true;
      if (w == 'printer' &&
          (lower.contains('printer') || lower.contains('copier'))) return true;
      if (w == 'mobile' &&
          (lower.contains('mobile') ||
              lower.contains('phone') ||
              lower.contains('smartphone'))) return true;
    }

    return false;
  }

  Map<String, dynamic>? _pickGroupByMatch(
      String productName, String categoryName) {
    final subcategoryName = widget.subcategoryName;
    final combined =
        '$productName $categoryName $subcategoryName'.toLowerCase();

    for (final group in _accessoryGroups) {
      final matches = (group['match'] as List).cast<String>();
      if (_includesAny(combined, matches)) {
        return group;
      }
    }
    return null;
  }

  List<String> _extractGroupFallbackKeywords(Map<String, dynamic>? group) {
    if (group == null) return const [];

    final suggestions =
        (group['suggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final keywords = <String>{};

    for (final suggestion in suggestions) {
      final kws = (suggestion['keywords'] as List?)?.cast<String>() ?? [];
      keywords.addAll(kws);
    }

    return keywords.toList();
  }

  // NEW: Helper to detect similar product names (prevents duplicate mouse/keyboard/etc.)
  String _normalizeProductName(String name) {
    final lower = name.toLowerCase().trim();

    // Common brand names to strip out completely
    final brandWords = {
      'logitech',
      'hp',
      'dell',
      'lenovo',
      'asus',
      'acer',
      'apple',
      'samsung',
      'microsoft',
      'razer',
      'corsair',
      'hyperx',
      'steelseries',
      'roccat',
      'cooler',
      'master',
      'thermaltake',
      'nzxt',
      'evga',
      'gigabyte',
      'msi',
      'sony',
      'jbl',
      'bose',
      'sennheiser',
      'audio',
      'technica',
      'beats',
      'anker',
      'belkin',
      'targus',
      'kensington',
      'sandisk',
      'western',
      'digital',
      'seagate',
      'crucial',
      'kingston',
      'corsair',
      'gskill',
      'team',
      'patriot',
    };

    // Words to skip (colors, adjectives, models)
    final skipWords = {
      'black',
      'white',
      'blue',
      'red',
      'grey',
      'gray',
      'silver',
      'gold',
      'rose',
      'new',
      'original',
      'genuine',
      'authentic',
      'official',
      'plus',
      'pro',
      'max',
      'ultra',
      'super',
      'mini',
      'slim',
      'compact',
      'portable',
      'gaming',
      'rgb',
      'led',
      'mechanical',
      'optical',
      'laser',
      'wired',
      'wireless',
      'bluetooth',
      'usb',
      'type-c',
      'lightning',
      'hdmi',
      'displayport',
      'vga',
      'dvi',
    };

    // Core product types we care about (in order of priority)
    final productTypes = {
      'mouse': ['mouse', 'mice'],
      'keyboard': ['keyboard', 'keyboards'],
      'headphone': ['headphone', 'headphones', 'headset', 'headsets'],
      'earbuds': ['earbuds', 'earbud', 'earphone', 'earphones'],
      'speaker': ['speaker', 'speakers'],
      'webcam': ['webcam', 'camera'],
      'microphone': ['microphone', 'mic'],
      'hub': ['hub', 'dock', 'adapter', 'dongle'],
      'cable': ['cable', 'cord'],
      'charger': ['charger', 'adapter'],
      'powerbank': ['powerbank', 'power bank', 'battery pack'],
      'bag': ['bag', 'case', 'backpack', 'sleeve', 'pouch'],
      'stand': ['stand', 'holder', 'mount', 'arm'],
      'pad': ['pad', 'mat', 'mousepad'],
      'cleaner': ['cleaner', 'cleaning', 'wipe'],
      'cooler': ['cooler', 'cooling', 'fan'],
      'ssd': ['ssd', 'solid state'],
      'hdd': ['hdd', 'hard drive'],
      'ram': ['ram', 'memory'],
      'router': ['router'],
      'switch': ['switch'],
      'modem': ['modem'],
    };

    final words = lower.split(RegExp(r'\s+'));

    // Find the primary product type
    for (final entry in productTypes.entries) {
      final typeName = entry.key;
      final aliases = entry.value;

      for (final word in words) {
        if (aliases
            .any((alias) => word.contains(alias) || alias.contains(word))) {
          return typeName; // Return the canonical product type
        }
      }
    }

    // Fallback: extract first non-brand, non-skip word
    for (final word in words) {
      if (word.length > 2 &&
          !brandWords.contains(word) &&
          !skipWords.contains(word)) {
        return word;
      }
    }

    // Last resort: return first word
    return words.isNotEmpty ? words.first : lower;
  }

  bool _isDuplicateProduct(
      String newProductName, List<Map<String, dynamic>> existingProducts) {
    final newNorm = _normalizeProductName(newProductName);

    for (final existing in existingProducts) {
      final existingName = (existing['name'] ?? '').toString();
      final existingNorm = _normalizeProductName(existingName);

      // Check for exact normalized match
      if (newNorm == existingNorm) return true;

      // Check for substantial overlap (e.g., "wireless mouse" vs "mouse wireless")
      final newWords = newNorm.split(' ').toSet();
      final existingWords = existingNorm.split(' ').toSet();
      final intersection = newWords.intersection(existingWords);

      // If 80%+ words overlap, consider it a duplicate
      final overlapRatio = intersection.length / newWords.length;
      if (overlapRatio >= 0.8) return true;
    }

    return false;
  }

  Future<void> _fetchFrequentlyBought() async {
    if (!mounted) return;
    setState(() {
      _frequentlyBoughtLoading = true;
      _frequentlyBought = [];
      _selectedBundleItems.clear();
    });

    try {
      final productName = widget.name;
      final categoryName = widget.categoryName;
      final subcategoryName = widget.subcategoryName;

      log('==========================================');
      log('Fetching frequently bought together for: ');
      log('  Product Name: $productName');
      log('  Category: $categoryName');
      log('  Subcategory: $subcategoryName');
      log('==========================================');

      final group = _pickGroupByMatch(productName, categoryName);
      final suggestions =
          (group?['suggestions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final excludeWords =
          (group?['excludeMain'] as List?)?.cast<String>() ?? [];

      final fallbackKeywords = _extractGroupFallbackKeywords(group);

      log('Selected group has ${suggestions.length} suggestion types');
      log('Exclude words: $excludeWords');
      log('Group fallback keywords: $fallbackKeywords');

      final results = <Map<String, dynamic>>[];
      final seenIds = <String>{widget.productId};
      // NEW: track normalized names globally across all search phases
      final seenNormalizedNames = <String>{};

      // Phase 1: Try to get products from specific suggestions (if group matched)
      if (group != null) {
        for (final suggestion in suggestions) {
          if (results.length >= _maxFrequentlyBought) break;

          final keywords = (suggestion['keywords'] as List).cast<String>();
          final searches = (suggestion['searches'] as List).cast<String>();

          log('--- Trying suggestion with keywords: $keywords ---');

          for (final searchTerm in searches) {
            if (results.length >= _maxFrequentlyBought) break;

            try {
              final url =
                  '${Configss.baseUrl}/api/products?search=${Uri.encodeComponent(searchTerm)}&limit=20';
              log('Searching: $searchTerm');

              final res = await http.get(Uri.parse(url));
              if (res.statusCode == 200) {
                final body = json.decode(res.body);
                final products =
                    (body is List) ? body : (body['products'] as List? ?? []);

                log('  Found ${products.length} products for "$searchTerm"');

                for (final p in products) {
                  if (results.length >= _maxFrequentlyBought) break;
                  if (p is! Map<String, dynamic>) continue;

                  final id = (p['_id'] ?? '').toString();
                  if (seenIds.contains(id)) continue;

                  final pName = (p['name'] ?? '').toString();
                  final pNameLower = pName.toLowerCase();
                  final pCat = ((p['category'] as Map?)?['name'] ?? '')
                      .toString()
                      .toLowerCase();
                  final combined = '$pNameLower $pCat';

                  if (_isMainProductType(combined, excludeWords)) {
                    log('  ❌ Excluding (main type): $pName');
                    continue;
                  }

                  if (!_includesAny(combined, keywords)) {
                    log('  ❌ Excluding (no keyword match): $pName');
                    continue;
                  }

                  // CHANGED: Check against global normalized names set
                  final normalized = _normalizeProductName(pName);
                  if (seenNormalizedNames.contains(normalized)) {
                    log('  ❌ Excluding (duplicate normalized name): $pName (normalized: $normalized)');
                    continue;
                  }

                  log('  ✅ Adding: $pName (normalized: $normalized)');
                  results.add(p);
                  seenIds.add(id);
                  seenNormalizedNames
                      .add(normalized); // Track this normalized name
                }
              }
            } catch (e) {
              log('Error fetching for term "$searchTerm": $e');
            }
          }
        }

        log('After specific suggestions: ${results.length} products found');

        // Phase 2: Group-specific fallback (only if group was found)
        if (results.length < _maxFrequentlyBought &&
            fallbackKeywords.isNotEmpty) {
          log('Not enough products (${results.length}), trying group-specific fallback...');
          try {
            final url = '${Configss.baseUrl}/api/products?limit=150';
            final res = await http.get(Uri.parse(url));
            if (res.statusCode == 200) {
              final body = json.decode(res.body);
              final products =
                  (body is List) ? body : (body['products'] as List? ?? []);

              for (final p in products) {
                if (results.length >= _maxFrequentlyBought) break;
                if (p is! Map<String, dynamic>) continue;

                final id = (p['_id'] ?? '').toString();
                if (seenIds.contains(id)) continue;

                final pName = (p['name'] ?? '').toString();
                final pNameLower = pName.toLowerCase();
                final pCat = ((p['category'] as Map?)?['name'] ?? '')
                    .toString()
                    .toLowerCase();
                final combined = '$pNameLower $pCat';

                if (_isMainProductType(combined, excludeWords)) {
                  log('Fallback: ❌ Excluding (main type): $pName');
                  continue;
                }

                if (!_includesAny(combined, fallbackKeywords)) continue;

                // CHANGED: Check against global normalized names set
                final normalized = _normalizeProductName(pName);
                if (seenNormalizedNames.contains(normalized)) {
                  log('Fallback: ❌ Excluding (duplicate normalized name): $pName (normalized: $normalized)');
                  continue;
                }

                log('Fallback: ✅ Adding: $pName (normalized: $normalized)');
                results.add(p);
                seenIds.add(id);
                seenNormalizedNames
                    .add(normalized); // Track this normalized name
              }
            }
          } catch (e) {
            log('Error in fallback fetch: $e');
          }
        }
      }

      // Phase 3: UNIVERSAL FALLBACK (laptop-style for all unmapped categories)
      if (results.length < _maxFrequentlyBought) {
        log('==========================================');
        log('Using UNIVERSAL FALLBACK (laptop-style accessories)');
        log('Current results count: ${results.length}');
        log('==========================================');

        // Use broader exclude list to avoid suggesting main product types
        final universalExcludes = [
          'laptop',
          'notebook',
          'desktop',
          'pc',
          'workstation',
          'monitor',
          'display',
          'printer',
          'copier',
          'scanner',
          'mobile',
          'phone',
          'smartphone',
          'tablet',
          'router',
          'switch',
          'access point',
          'gaming console',
          'playstation',
          'xbox',
        ];

        for (final searchTerm in _genericFallbackSearches) {
          if (results.length >= _maxFrequentlyBought) break;

          try {
            final url =
                '${Configss.baseUrl}/api/products?search=${Uri.encodeComponent(searchTerm)}&limit=20';
            log('Universal search: $searchTerm');

            final res = await http.get(Uri.parse(url));
            if (res.statusCode == 200) {
              final body = json.decode(res.body);
              final products =
                  (body is List) ? body : (body['products'] as List? ?? []);

              log('  Found ${products.length} products for "$searchTerm"');

              for (final p in products) {
                if (results.length >= _maxFrequentlyBought) break;
                if (p is! Map<String, dynamic>) continue;

                final id = (p['_id'] ?? '').toString();
                if (seenIds.contains(id)) continue;

                final pName = (p['name'] ?? '').toString();
                final pNameLower = pName.toLowerCase();
                final pCat = ((p['category'] as Map?)?['name'] ?? '')
                    .toString()
                    .toLowerCase();
                final combined = '$pNameLower $pCat';

                // Exclude main product types
                if (_isMainProductType(combined, universalExcludes)) {
                  log('  Universal: ❌ Excluding (main type): $pName');
                  continue;
                }

                // Simple check: must contain the search term
                if (!pNameLower.contains(searchTerm.toLowerCase()) &&
                    !pCat.contains(searchTerm.toLowerCase())) {
                  continue;
                }

                // CHANGED: Check against global normalized names set
                final normalized = _normalizeProductName(pName);
                if (seenNormalizedNames.contains(normalized)) {
                  log('  Universal: ❌ Excluding (duplicate normalized name): $pName (normalized: $normalized)');
                  continue;
                }

                log('  Universal: ✅ Adding: $pName (normalized: $normalized)');
                results.add(p);
                seenIds.add(id);
                seenNormalizedNames
                    .add(normalized); // Track this normalized name
              }
            }
          } catch (e) {
            log('Error in universal fallback for "$searchTerm": $e');
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _frequentlyBought = results;
        _frequentlyBoughtLoading = false;

        _selectedBundleItems[widget.productId] = true;
        final preselectCount = results.length >= _defaultPreselectedCount
            ? _defaultPreselectedCount
            : results.length;
        final preselect = results.take(preselectCount);
        for (final p in preselect) {
          final id = (p['_id'] ?? '').toString();
          if (id.isNotEmpty) _selectedBundleItems[id] = true;
        }
      });

      log('==========================================');
      log('FINAL RESULTS: ${results.length} items');
      log('Products: ${results.map((p) => p['name']).join(', ')}');
      log('Unique normalized names: ${seenNormalizedNames.toList()}');
      log('==========================================');
    } catch (e, st) {
      log('Error fetching frequently bought together: $e\n$st');
      if (mounted) {
        setState(() {
          _frequentlyBoughtLoading = false;
          _frequentlyBought = [];
        });
      }
    }
  }

  final String phoneNumber = '+971508604360';

  Future<void> _launchWhatsApp() async {
    final message = Uri.encodeComponent(
        "I'm interested in this product: ${widget.name}.\nHere is the link: ${Configss.baseUrl}");
    final Uri whatsappUrl =
        Uri.parse("https://wa.me/$phoneNumber?text=$message");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        log("Could not launch $whatsappUrl");
      }
    } catch (e) {
      log("Could not launch WhatsApp: $e");
    }
  }

  Future<void> requestCall() async {
    final message =
        Uri.encodeComponent("I need help with this product: ${widget.name}");
    final Uri whatsappUrl =
        Uri.parse("https://wa.me/$phoneNumber?text=$message");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        log("Could not launch $whatsappUrl for requestCall");
      }
    } catch (e) {
      log("Could not launch WhatsApp for requestCall: $e");
    }
  }

  void _shareProduct() {
    final productName = widget.name;
    final productLink = "${Configss.baseUrl}/product/${widget.productId}";
    final shareText = "Check out this product: $productName\n$productLink";
    Share.share(shareText);
  }

  void _showAddedToCartPopup() {
    final overlayState = Overlay.of(context, rootOverlay: true);
    if (overlayState == null) {
      Get.snackbar(
        'Added to cart',
        '',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 900),
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Added to cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (entry.mounted) entry.remove();
    });
  }

  // NEW: Bundle-specific notification showing total item count
  void _showBundleAddedToCartPopup(int itemCount) {
    log('📢 _showBundleAddedToCartPopup called with itemCount: $itemCount');

    if (!mounted) {
      log('⚠️ Widget not mounted, cannot show notification');
      return;
    }

    final overlayState = Overlay.of(context, rootOverlay: true);
    if (overlayState == null) {
      log('⚠️ Overlay not available, using GetX snackbar');
      Get.snackbar(
        'Bundle added',
        '$itemCount items added to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1500),
        margin: const EdgeInsets.all(16),
        isDismissible: true,
      );
      return;
    }

    log('✅ Creating overlay entry for bundle notification');

    final entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$itemCount items added to cart',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'BUNDLE DISCOUNT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);
    log('✅ Overlay inserted, will remove after 1500ms');

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (entry.mounted) {
        entry.remove();
        log('✅ Overlay removed');
      }
    });
  }

  Future<void> _addBundleToCart() async {
    final cart = Get.isRegistered<CartNotifier>()
        ? Get.find<CartNotifier>()
        : Get.put(CartNotifier());
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    int totalItemsAdded = 0;

    log('🛒 Starting bundle add to cart...');

    // Add current item (suppress notification)
    final curPrice = _toDouble(
        widget.offerPrice.isNotEmpty ? widget.offerPrice : widget.price);
    final curImg = (widget.images.isNotEmpty &&
            widget.images.first is String &&
            (widget.images.first as String).isNotEmpty)
        ? widget.images.first as String
        : 'https://i.postimg.cc/SsWYSvq6/noimage.png';
    await cart.addItemInfo(
      CartOtherInfo(
        productId: widget.productId,
        productName: widget.name,
        productImage: curImg,
        productPrice: curPrice,
        quantity: 1,
      ),
      userId,
      showNotification: false, // Suppress individual notification
    );
    totalItemsAdded++;
    log('✅ Added current item (${widget.name})');

    // Add selected extras (at discounted price, suppress notifications)
    for (final p in _frequentlyBought) {
      final id = _idOf(p);
      if (!(_selectedBundleItems[id] ?? false)) continue;
      final op = _basePrice(p);
      final dp = _discounted(op, 25);
      await cart.addItemInfo(
        CartOtherInfo(
          productId: id,
          productName: (p['name'] ?? 'Product').toString(),
          productImage: _imgOf(p),
          productPrice: dp,
          quantity: 1,
        ),
        userId,
        showNotification: false, // Suppress individual notification
      );
      totalItemsAdded++;
      log('✅ Added accessory: ${p['name']}');
    }

    log('🎉 Bundle complete! Showing notification for $totalItemsAdded items');

    // ✅ NEW: Manually trigger AwesomeNotifications for bundle
    final bool isNotificationEnabled =
        prefs.getBool('notification_enabled') ?? true;
    if (isNotificationEnabled) {
      log('📢 Triggering AwesomeNotification for bundle');
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: "basic_channel",
          title: "Bundle Added to Cart",
          body: '$totalItemsAdded items added with 25% bundle discount!',
          actionType: ActionType.Default,
        ),
      );
    } else {
      log('🔇 Notifications disabled, skipping AwesomeNotification');
    }

    // Show single bundle overlay notification after all items are added
    _showBundleAddedToCartPopup(totalItemsAdded);
  }

  @override
  Widget build(BuildContext context) {
    log('NewProductDetails build START ------------------------');
    log('NewProductDetails build: Product ID: ${widget.productId}, Name: ${widget.name}');
    const placeholderImage = 'https://i.postimg.cc/SsWYSvq6/noimage.png';

    try {
      return Scaffold(
        appBar: CustomAppBar(
          titleWidget: Image.asset(
            AppImages.logoicon,
            width: 100,
            height: 100,
            color: kdefwhiteColor,
          ),
          actionicon: GetBuilder<CartNotifier>(
            builder: (
              cartNotifier,
            ) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Get.put(BottomNavigationController()).setTabIndex(0);
                      Get.offAll(() => Home());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: SvgPicture.string(
                        _homeSvg,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        // stroke is white in SVG; matches AppBar foreground
                        semanticsLabel: 'Home',
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.route(Cart());
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Image.asset(
                            "assets/icons/addcart.png",
                            color: kdefwhiteColor,
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                      if (cartNotifier.cartOtherInfoList.isNotEmpty) ...[
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: kredColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cartNotifier.cartOtherInfoList.length.toString(),
                              style: const TextStyle(
                                color: kdefwhiteColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: defaultBoxShadow,
                              color: kdefwhiteColor,
                            ),
                            key: productImageKey,
                            child: CarouselSlider.builder(
                              carouselController: _slider,
                              itemCount: widget.images.length,
                              itemBuilder: (BuildContext context, int itemIndex,
                                  int pageViewIndex) {
                                String imageUrl =
                                    (widget.images[itemIndex] is String
                                            ? widget.images[itemIndex]
                                            : null) ??
                                        _selectedImageUrl.toString();
                                String urlForImage =
                                    ImageHelper.getUrl(imageUrl);

                                if (imageUrl.isEmpty)
                                  imageUrl = placeholderImage;

                                return CachedNetworkImage(
                                  imageUrl: urlForImage,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      maxWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 100,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/noimage.png',
                                        ),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                autoPlay: false,
                                autoPlayInterval: const Duration(seconds: 3),
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentImageIndex = index;
                                    String newSelectedImageUrl =
                                        (widget.images[index] is String
                                                ? widget.images[index]
                                                : null) ??
                                            placeholderImage;
                                    if (newSelectedImageUrl.isEmpty)
                                      newSelectedImageUrl = placeholderImage;
                                    _selectedImageUrl = newSelectedImageUrl;
                                  });
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                15.0.heightbox,
                                GestureDetector(
                                  onTap: _shareProduct,
                                  child: Image.asset(
                                    "assets/icons/share.png",
                                    width: 30,
                                    height: 30,
                                    color: kmediumblackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      20.0.heightbox,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: widget.images.length > 1
                              ? widget.images.map((imageItem) {
                                  int index = widget.images.indexOf(imageItem);
                                  String url = (imageItem is String
                                          ? imageItem
                                          : null) ??
                                      placeholderImage;

                                  String imageUrl = ImageHelper.getUrl(url);

                                  if (imageUrl.isEmpty)
                                    imageUrl = placeholderImage;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _currentImageIndex = index;
                                        String newSelectedImageUrl =
                                            (widget.images[index] is String
                                                    ? widget.images[index]
                                                    : null) ??
                                                placeholderImage.toString();

                                        if (newSelectedImageUrl.isEmpty)
                                          newSelectedImageUrl =
                                              placeholderImage;
                                        _selectedImageUrl = newSelectedImageUrl;
                                      });
                                      _slider.animateToPage(index);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          right: 8.0, left: 8),
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: kdefwhiteColor,
                                        border: Border.all(
                                          color: _currentImageIndex == index
                                              ? kPrimaryColor
                                              : Colors.grey,
                                          width: _currentImageIndex == index
                                              ? 2
                                              : 1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              imageUrl),
                                          fit: BoxFit.cover,
                                          onError: (exception, stackTrace) {
                                            log("Error loading thumbnail image: $imageUrl, error: $exception");
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList()
                              : [
                                  // Container(
                                  //   padding: EdgeInsets.all(8),
                                  //   child: const Text(
                                  //     "No additional Image available",
                                  //     style: TextStyle(
                                  //         color: kdefblackColor,
                                  //         fontWeight: FontWeight.bold),
                                  //   ),
                                  // ),
                                ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: defaultPadding(),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        10.0.heightbox,
                        AnimatedReadMoreText(
                          widget.name,
                          maxLines: 2,
                          readMoreText: 'Read More',
                          readLessText: 'Show Less',
                          textStyle:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                          buttonTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: kPrimaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              'Category:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontSize: 14, color: kSecondaryColor),
                            ),
                            Expanded(
                              child: Text(
                                ' ${widget.subcategoryName.isNotEmpty ? widget.subcategoryName : widget.categoryName}',
                                // CHANGED: prefer subcategory, fallback to category
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: kPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'Brand:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontSize: 14, color: kSecondaryColor),
                            ),
                            Expanded(
                              child: Text(
                                ' ${widget.brandName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: kPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              'SKU:',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      fontSize: 14, color: kSecondaryColor),
                            ),
                            Expanded(
                              child: Text(
                                ' ${widget.sku}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: kPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        widget.stockStatus == 'Out of Stock'
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ' ${widget.stockStatus}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.red),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ' Available in Stock',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: kPrimaryColor),
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Builder(
                          builder: (context) {
                            double offerDisplayPrice =
                                double.tryParse(widget.offerPrice) ?? 0.0;
                            double regularDisplayPrice =
                                double.tryParse(widget.price) ?? 0.0;
                            const double epsilon = 0.001;

                            bool isOfferValidAndBetter =
                                offerDisplayPrice > epsilon &&
                                    offerDisplayPrice < regularDisplayPrice;

                            if (isOfferValidAndBetter) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    'AED ${offerDisplayPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: kredColor),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'VAT',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 10,
                                        color: kredColor.withOpacity(0.8)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'AED ${regularDisplayPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ],
                              );
                            } else if (regularDisplayPrice > epsilon) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    'AED ${regularDisplayPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: kdefblackColor),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'VAT',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 10,
                                        color: kdefblackColor.withOpacity(0.8)),
                                  ),
                                ],
                              );
                            } else {
                              return const Text(
                                'Price not available',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey),
                              );
                            }
                          },
                        ),
                        10.0.heightbox,
                        const Text(
                          "Key Features:",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kdefblackColor),
                        ),
                        // Reverted: show shortdesc as plain text (no HTML)
                        widget.shortdesc.isNotEmpty
                            ? Text(
                                removeHtmlTags(widget.shortdesc),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kdefblackColor,
                                ),
                              )
                            : const Text(
                                'No description available.',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: kSecondaryColor,
                                ),
                              ),
                        const SizedBox(height: 10),
                        Builder(
                          builder: (_) {
                            final offer =
                                double.tryParse(widget.offerPrice) ?? 0.0;
                            final regular =
                                double.tryParse(widget.price) ?? 0.0;
                            const double eps = 0.0001;
                            final useOffer = offer > eps &&
                                (regular <= eps || offer < regular);
                            final price = useOffer ? offer : regular;
                            final monthly = price > eps ? (price / 4.0) : 0.0;

                            return GestureDetector(
                              onTap: () {
                                if (price > eps) {
                                  Get.to(() => TamaraInfoScreen(price: price));
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF374151), // gray-700
                                    ),
                                    children: [
                                      const TextSpan(
                                          text: 'Or split in 4 payments of '),
                                      TextSpan(
                                        text:
                                            'AED ${monthly.toStringAsFixed(2)}/mo',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827), // gray-900
                                        ),
                                      ),
                                      const TextSpan(
                                          text:
                                              ' - No late fees, Sharia compliant!\n'),
                                      const TextSpan(text: 'More options '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFBCFE8),
                                                // pink-300
                                                Color(0xFFD8B4FE),
                                                // purple-300
                                                Color(0xFFBFDBFE),
                                                // indigo-300 (approx)
                                              ],
                                            ),
                                          ),
                                          child: const Text(
                                            'tamara',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color(0xFF111827), // gray-900
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (_) {
                            final offer =
                                double.tryParse(widget.offerPrice) ?? 0.0;
                            final regular =
                                double.tryParse(widget.price) ?? 0.0;
                            const double eps = 0.0001;
                            final useOffer = offer > eps &&
                                (regular <= eps || offer < regular);
                            final price = useOffer ? offer : regular;
                            final monthly12 =
                                price > eps ? (price / 12.0) : 0.0;
                            final monthly4 = price > eps
                                ? (price / 4.0)
                                : 0.0; // informational only

                            return GestureDetector(
                              onTap: () {
                                if (price > eps) {
                                  Get.to(() => TabbyInfoScreen(price: price));
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF374151), // gray-700
                                    ),
                                    children: [
                                      const TextSpan(text: 'As low as '),
                                      TextSpan(
                                        text:
                                            'AED ${monthly12.toStringAsFixed(2)}/mo',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827), // gray-900
                                        ),
                                      ),
                                      const TextSpan(
                                          text:
                                              ' or 4 interest-free payments. '),
                                      const TextSpan(
                                        text: 'Learn more',
                                      ),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Color(
                                                0xFF059669), // emerald-600
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'tabby',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _actionButton(Icons.chat_bubble_outline,
                                    "Chat\nWith Specialist", () {
                                  requestCall();
                                }),
                                _actionButton(
                                    Icons.phone_outlined, "Request a\nCallback",
                                    () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (context) {
                                      return RequestForm();
                                    },
                                  );
                                }),
                                _actionButton(Icons.shield_outlined,
                                    "Request Bulk\nPurchase", () {
                                  Get.to(() => BulkPurchaceView());
                                }),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.local_offer,
                                          color: Colors.red),
                                      SizedBox(width: 8),
                                      Text(
                                        "Get My Coupon",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Free shipping when you spend AED500 & above.\n"
                                    "Unlimited destinations in Dubai and Abu Dhabi",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                    ),
                                    onPressed: () {
                                      showCouponBottomSheet(context);
                                    },
                                    child: const Text("Get My Coupon",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _infoTile(Icons.local_shipping, "Express Delivery",
                                "Free shipping when you spend AED500 & above.\nUnlimited destinations in Dubai and Abu Dhabi"),
                            const SizedBox(height: 12),
                            _infoTile(
                                Icons.refresh,
                                "Delivery & Returns Policy",
                                "Delivery in remote areas will be considered as normal delivery which takes place with 1 working day delivery."),
                            const SizedBox(height: 12),
                            _infoTile(
                                Icons.verified_user,
                                "Warranty Information",
                                "Standard warranty applies as per manufacturer terms"),
                            // NEW: Payment Methods section
                            const SizedBox(height: 19),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Color(0xFFEEEEEE), width: 1),
                                ),
                              ),
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Payment Methods :",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // logos column
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _pmLogo(
                                            "https://res.cloudinary.com/dyfhsu5v6/image/upload/v1757919726/1st_logo_v8x2hc.webp",
                                            "master",
                                            height: 95),
                                        const SizedBox(height: 7),
                                        _pmLogo(
                                            "https://res.cloudinary.com/dyfhsu5v6/image/upload/v1757937381/2nd_logo_x6jzhz.webp",
                                            "visa",
                                            height: 95),
                                        const SizedBox(height: 7),
                                        _pmLogo(
                                            "https://res.cloudinary.com/dyfhsu5v6/image/upload/v1757937401/3rd_logo_fmwdkp.webp",
                                            "tamara",
                                            height: 95),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Insert FBT right below Cloudinary images
                                  _buildFrequentlyBoughtSection(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                        TabBar(
                          controller: _tabController,
                          labelColor: kPrimaryColor,
                          unselectedLabelColor: Colors.black54,
                          indicatorColor: kPrimaryColor,
                          labelPadding: EdgeInsets.symmetric(horizontal: 0),
                          labelStyle: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.grey,
                          tabs: _tabs.map((e) => Tab(text: e)).toList(),
                        ),
                        Builder(
                          builder: (_) {
                            final i = _tabController.index;
                            Widget child;
                            if (i == 0) {
                              child = _buildDescription();
                            } else if (i == 1) {
                              child = buildMoreInformationTab();
                            } else {
                              child = buildReviewTab();
                            }
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: KeyedSubtree(
                                key: ValueKey<int>(i),
                                child: child,
                              ),
                            );
                          },
                        ),
                        Obx(() => _reviewCont.reviews.isNotEmpty
                            ? SizedBox(
                                height: 70,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _reviewCont.reviews.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final review = _reviewCont.reviews[index];
                                    return ReviewCard(review: review);
                                  },
                                ),
                              )
                            : SizedBox.shrink()),

                        20.0.heightbox,
                        Text(
                          'Related Products',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Obx(
                        () {
                          // Match Search/NewAll grid sizing: 2 columns, 0.64 aspect ratio
                          final screenW = MediaQuery.of(context).size.width;
                          const horizontalPadding = 5.0;
                          const itemGap = 8.0;
                          final cardWidth =
                              (screenW - (horizontalPadding * 2) - itemGap) / 2;
                          final cardHeight = (cardWidth / 0.64) -
                              1; // shave 1px to avoid overflow

                          if (_homeController.isrelatedLoading.value) {
                            return SizedBox(
                              height: cardHeight,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                scrollDirection: Axis.horizontal,
                                itemCount: 6,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: itemGap),
                                itemBuilder: (context, index) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      width: cardWidth,
                                      height: cardHeight,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          final list = _homeController.relatedProducts;
                          if (list.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return SizedBox(
                            height: cardHeight,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              scrollDirection: Axis.horizontal,
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: itemGap),
                              itemBuilder: (context, index) {
                                final productData = list[index];
                                return SizedBox(
                                  width: cardWidth,
                                  height: cardHeight,
                                  child: NewProductCard(
                                    prdouctList: productData,
                                    onAddedToCart: _showAddedToCartPopup,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      20.0.heightbox
                    ],
                  ),
                )
              ]),
        ),
        bottomNavigationBar: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _launchWhatsApp,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      color: kSecondaryColor,
                      child: Center(
                        child: Padding(
                          padding: defaultPadding(),
                          child: Text(
                            'Order By WhatsApp',
                            style: TextStyle(
                              color: kdefwhiteColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GetBuilder<CartNotifier>(builder: (
                  cart,
                ) {
                  bool isOutOfStock = widget.stockStatus == 'Out of Stock';
                  return Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (isOutOfStock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This item is out of stock.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          final prefs = await SharedPreferences.getInstance();
                          String? userId =
                              prefs.getString('userId')?.toString();

                          // Safer image access
                          String productImageForCart = placeholderImage;
                          if (widget.images.isNotEmpty &&
                              widget.images.first is String &&
                              (widget.images.first as String).isNotEmpty) {
                            productImageForCart = widget.images.first as String;
                          } else {
                            log('Add To Cart: widget.images is empty or first item is not a valid string. Using placeholder.');
                          }

                          double offerP = double.tryParse(
                                  widget.offerPrice.isNotEmpty
                                      ? widget.offerPrice
                                      : '0') ??
                              0.0;
                          double regularP = double.tryParse(
                                  widget.price.isNotEmpty
                                      ? widget.price
                                      : '0') ??
                              0.0;

                          cart.addItemInfo(
                              CartOtherInfo(
                                productId: widget.productId,
                                productName: widget.name,
                                productImage: productImageForCart,
                                productPrice: (offerP > 0) ? offerP : regularP,
                                quantity: 1,
                              ),
                              userId);
                          _showAddedToCartPopup();
                        }
                      },
                      child: Container(
                        color: isOutOfStock ? kredColor : kPrimaryColor,
                        child: Center(
                          child: Padding(
                            padding: defaultPadding(),
                            child: Text(
                              isOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                              style: TextStyle(
                                color: kdefwhiteColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      log('Error in NewProductDetails build: $e');
      log('StackTrace: $stackTrace');
      log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "An error occurred while building this page. Please try again.\n\nError: $e",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Product Description",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Html(
            data: widget.description.isNotEmpty
                ? widget.description
                : '<p>No description available.</p>',
            style: {
              "body": Style(
                fontSize: FontSize(14),
                color: kdefblackColor,
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "p": Style(margin: Margins.only(bottom: 8)),
              "strong": Style(fontWeight: FontWeight.w700),
              "b": Style(fontWeight: FontWeight.w700),
              "ul": Style(margin: Margins.only(left: 12)),
              "ol": Style(margin: Margins.only(left: 12)),
              "a": Style(
                color: kPrimaryColor,
                textDecoration: TextDecoration.underline,
              ),
              "img": Style(
                margin: Margins.only(bottom: 8),
              ),
            },
            onAnchorTap: (url, _, __) {
              if (url != null) launchUrl(Uri.parse(url));
            },
          ),
        ],
      ),
    );
  }

  String removeHtmlTags(String htmlContent) {
    if (htmlContent.isEmpty) return '';
    try {
      final document = html_parser.parse(htmlContent);
      return document.body?.text ?? '';
    } catch (e) {
      log("Error parsing HTML: $e");
      return htmlContent;
    }
  }

  bool istapped = false;
  Key descriptionKey = UniqueKey();

  Widget buildMoreInformationTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "More Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Brand',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(widget.brandName),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Model Number',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(widget.sku),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Category',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                        widget.subcategoryName), // CHANGED: prefer subcategory
                  ),
                ],
              ),
              TableRow(
                children: [
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Specifications',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  (widget.specs is List &&
                          widget.specs.isNotEmpty &&
                          widget.specs[0] is Map &&
                          widget.specs[0].containsKey('value'))
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          child: Text("${widget.specs[0]['value']}"),
                        )
                      : Container(
                          padding: const EdgeInsets.all(10),
                          child: Text('No Data Available')),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildReviewTab() {
    // Use fetched reviews from controller, not widget.reviews
    final List reviewsList = _reviewCont.reviews;

    // Build rating distribution
    Map<int, int> ratingCount = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviewsList) {
      if (review is Map && review['rating'] is num) {
        final r = (review['rating'] as num).round().clamp(1, 5);
        ratingCount[r] = (ratingCount[r] ?? 0) + 1;
      }
    }

    // Prefer API stats if provided
    final int totalReviews =
        (_apiReviewStats?['totalReviews'] as num?)?.toInt() ??
            reviewsList.length;
    final double averageRating = (_apiReviewStats?['averageRating'] is num)
        ? (_apiReviewStats!['averageRating'] as num).toDouble()
        : calculateAverageRating(reviewsList);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(5, (index) {
                      int star = 5 - index;
                      int count = ratingCount[star] ?? 0;
                      double percentage =
                          totalReviews == 0 ? 0 : count / totalReviews;
                      if (percentage.isNaN || percentage.isInfinite)
                        percentage = 0;

                      return Row(
                        children: [
                          Text('$star ', style: const TextStyle(fontSize: 14)),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.amber,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$count', style: const TextStyle(fontSize: 14)),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: const BoxDecoration(color: kPrimaryColor),
                  child: TextButton(
                    onPressed: () async {
                      final result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return WriteReviewScreen(productId: widget.productId);
                        },
                      );
                      if (result == true) {
                        await _onReviewAdded();
                      }
                    },
                    child: const Text('Add Review',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(5, (index) {
                        if (averageRating >= index + 1) {
                          return const Icon(Icons.star,
                              color: Colors.amber, size: 16);
                        } else if (averageRating > index &&
                            averageRating < index + 1) {
                          return const Icon(Icons.star_half,
                              color: Colors.amber, size: 16);
                        } else {
                          return const Icon(Icons.star_border,
                              color: Colors.grey, size: 16);
                        }
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text('$totalReviews Product Ratings'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_apiHasNext)
              Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: _apiLoading
                      ? null
                      : () => _fetchReviews(page: _apiCurrentPage + 1),
                  child: _apiLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Load more reviews'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double calculateAverageRating(List reviews) {
    // ...existing code...
    double total = 0;
    int validReviewCount = 0;
    for (var review in reviews) {
      if (review is Map &&
          review.containsKey('rating') &&
          review['rating'] is num) {
        total += (review['rating'] as num);
        validReviewCount++;
      }
    }
    if (validReviewCount == 0) return 0.0;
    return total / validReviewCount;
  }

  Future<void> _onReviewAdded() async {
    // Reset local cache and re-fetch page 1
    setState(() {
      _apiCurrentPage = 1;
      _apiHasNext = false;
      _apiReviewStats = null;
      _reviewCont.reviews.clear();
    });
    await _fetchReviews(page: 1);
    // Notify other parts of the app (e.g., HomeView cards) to refresh their stats
    ReviewUpdateBus.instance.emit(widget.productId);
  }

  Widget _actionButton(IconData icon, String label, Function()? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: kPrimaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: kPrimaryColor),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 13)),
            ],
          ),
        )
      ],
    );
  }

  // NEW: small helper to render payment method logo
  Widget _pmLogo(String url, String label, {double height = 48}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(),
      // keep simple, matches tailwind px-2 py-1
      child: Image.network(
        url,
        height: height, // larger logos
        fit: BoxFit.contain,
        semanticLabel: label,
        errorBuilder: (ctx, err, stack) => Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildFrequentlyBoughtSection() {
    // Show shimmer while loading
    if (_frequentlyBoughtLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 100,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Current product shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 18,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Bundle items shimmer (show 2 placeholders)
            ...List.generate(
                2,
                (index) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 12,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 10,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Totals shimmer
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 18,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state if no items found after loading
    final items = _frequentlyBought;
    if (items.isEmpty) return const SizedBox.shrink();

    final totals = _bundleTotals();

    // Original content (unchanged)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  "Frequently Bought Together",
                  softWrap: true,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(999)),
                child: const Text("25% OFF BUNDLE",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current product (always selected)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8), // yellow-50
              border: Border.all(color: const Color(0xFFFDE68A)), // yellow-200
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_box, color: Color(0xFFEAB308)),
                // disabled look
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _imgOf({
                      'image':
                          (widget.images.isNotEmpty ? ImageHelper.getUrl(widget.images.first) : '')
                    }),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      Text(
                        _fmt(_toDouble(widget.offerPrice.isNotEmpty
                            ? widget.offerPrice
                            : widget.price)),
                        style: const TextStyle(
                            color: Color(0xFFCA8A04),
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(999)),
                        child: const Text("Current Item",
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF92400E))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bundle items (with 25% OFF)
          Column(
            children: items.map((p) {
              final id = _idOf(p);
              final original = _basePrice(p);
              final discounted = _discounted(original, 25);
              final double savings = (original - discounted)
                  .clamp(0.0, double.infinity)
                  .toDouble();
              final alreadyDiscounted = (_toDouble(p['offerPrice']) > 0) &&
                  (_toDouble(p['offerPrice']) < _toDouble(p['price']));
              final selected = _selectedBundleItems[id] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: selected,
                      onChanged: (_) => _toggleBundleItem(id),
                      activeColor: Colors.blue,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: ImageHelper.getUrl(_imgOf(p)),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(Icons.image,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((p['name'] ?? 'Product').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827))),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(_fmt(discounted),
                                  style: const TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontWeight: FontWeight.w700)),
                              Text(_fmt(original),
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(999)),
                                child: const Text("Save 25%",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFB91C1C),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("You save ${_fmt(savings)}",
                              style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          if (alreadyDiscounted) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 2,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  _fmt(original),
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const Text(
                                  "Already discounted",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF2563EB), // blue-600
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Totals + Add bundle
          LayoutBuilder(builder: (context, _) {
            final t = _bundleTotals();
            final canAdd = t.selectedCount > 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Bundle price: ",
                        style:
                            TextStyle(fontSize: 16, color: Color(0xFF374151))),
                    Text(_fmt(t.discountedTotal),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.bold)),
                    if (t.savings > 0)
                      Text(_fmt(t.originalTotal),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              decoration: TextDecoration.lineThrough)),
                  ],
                ),
                if (t.savings > 0)
                  Text("You save ${_fmt(t.savings)} with bundle discount!",
                      style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                Text(
                  "For ${t.selectedCount} item${t.selectedCount != 1 ? "s" : ""}",
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canAdd ? _addBundleToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Add all ${t.selectedCount} to Cart",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (t.savings > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              "Save ${_fmt(t.savings)}",
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _toggleBundleItem(String id) {
    setState(
        () => _selectedBundleItems[id] = !(_selectedBundleItems[id] ?? false));
  }

  ({
    double originalTotal,
    double discountedTotal,
    double savings,
    int selectedCount
  }) _bundleTotals() {
    // Always include current product (no extra discount)
    final currentPrice = _toDouble(
        widget.offerPrice.isNotEmpty ? widget.offerPrice : widget.price);
    double orig = currentPrice;
    double disc = currentPrice;
    int count = 1; // current item
    for (final p in _frequentlyBought) {
      final id = _idOf(p);
      if (!(_selectedBundleItems[id] ?? false)) continue;
      final op = _basePrice(p);
      final dp = _discounted(op, 25);
      orig += op;
      disc += dp;
      count += 1;
    }
    final double sav = (orig - disc).clamp(0.0, double.infinity).toDouble();
    return (
      originalTotal: orig,
      discountedTotal: disc,
      savings: sav,
      selectedCount: count
    );
  }
}
