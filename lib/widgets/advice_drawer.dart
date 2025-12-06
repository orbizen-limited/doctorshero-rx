import 'package:flutter/material.dart';

class AdviceDrawer extends StatefulWidget {
  final List<String> selectedAdvice;
  final Function(List<String>) onAdviceSelected;

  const AdviceDrawer({
    Key? key,
    required this.selectedAdvice,
    required this.onAdviceSelected,
  }) : super(key: key);

  @override
  State<AdviceDrawer> createState() => _AdviceDrawerState();
}

class _AdviceDrawerState extends State<AdviceDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  List<String> _selectedAdvice = [];
  String? _expandedCategory;
  String _searchQuery = '';
  bool _showCustomInput = false;
  List<String> _customAdviceList = [];
  
  // Medical advice categories with Bengali instructions
  // English search keywords mapped to Bengali categories
  final Map<String, String> _englishToBengaliMap = {
    'hypertension': 'Essential Hypertension (উচ্চ রক্তচাপ)',
    'blood pressure': 'Essential Hypertension (উচ্চ রক্তচাপ)',
    'heart disease': 'Ischemic Heart Disease (হৃদরোগ)',
    'coronary': 'Ischemic Heart Disease (হৃদরোগ)',
    'heart failure': 'Congestive Heart Failure (হার্ট ফেইলিউর)',
    'chf': 'Congestive Heart Failure (হার্ট ফেইলিউর)',
    'diabetes': 'Type 2 Diabetes Mellitus (ডায়াবেটিস)',
    'sugar': 'Type 2 Diabetes Mellitus (ডায়াবেটিস)',
    'copd': 'COPD (ফুসফুসের রোগ)',
    'lung': 'COPD (ফুসফুসের রোগ)',
    'ulcer': 'Peptic Ulcer Disease (পেপটিক আলসার)',
    'gastritis': 'Peptic Ulcer Disease (পেপটিক আলসার)',
    'gerd': 'GERD (গ্যাস্ট্রোইসোফেজিয়াল রিফ্লাক্স)',
    'reflux': 'GERD (গ্যাস্ট্রোইসোফেজিয়াল রিফ্লাক্স)',
    'ibs': 'IBS (ইরিটেবল বাওয়েল সিন্ড্রোম)',
    'irritable bowel': 'IBS (ইরিটেবল বাওয়েল সিন্ড্রোম)',
    'fatty liver': 'Fatty Liver Disease (ফ্যাটি লিভার)',
    'nafld': 'Fatty Liver Disease (ফ্যাটি লিভার)',
    'cirrhosis': 'Liver Cirrhosis (লিভার সিরোসিস)',
    'stroke': 'Stroke (স্ট্রোক)',
    'migraine': 'Migraine (মাইগ্রেন)',
    'headache': 'Migraine (মাইগ্রেন)',
    'back pain': 'Low Back Pain (কোমর ব্যথা)',
    'sciatica': 'Low Back Pain (কোমর ব্যথা)',
    'epilepsy': 'Epilepsy (মৃগীরোগ)',
    'seizure': 'Epilepsy (মৃগীরোগ)',
    'parkinson': "Parkinson's Disease (পারকিনসন)",
    'kidney': 'Chronic Kidney Disease (কিডনি রোগ)',
    'ckd': 'Chronic Kidney Disease (কিডনি রোগ)',
    'stone': 'Renal Stone Disease (কিডনিতে পাথর)',
  };

  final Map<String, List<String>> _medicalAdvice = {
    'Essential Hypertension (উচ্চ রক্তচাপ)': [
      'লবণ নিয়ন্ত্রণ: দিনে এক চা চামচের (৫ গ্রাম) বেশি লবণ খাবেন না।',
      'খাদ্যাভ্যাস: প্রচুর পরিমাণে শাকসবজি এবং মৌসুমি ফলমূল খান।',
      'শারীরিক পরিশ্রম: সপ্তাহে অন্তত ৫ দিন, প্রতিদিন ৩০ মিনিট করে দ্রুত হাঁটুন।',
      'ওজন নিয়ন্ত্রণ: শরীরের বাড়তি ওজন কমানোর চেষ্টা করুন।',
      'ওষুধ সেবন: ডাক্তারের নির্দেশিত উচ্চ রক্তচাপের ওষুধ প্রতিদিন নির্দিষ্ট সময়ে খাবেন।',
    ],
    'Ischemic Heart Disease (হৃদরোগ)': [
      'তামাক বর্জন: ধূমপান, গুল বা জর্দা খাওয়া এখনই বন্ধ করতে হবে।',
      'তেল ও চর্বি: ডালডা বা ঘি এড়িয়ে চলুন।',
      'বুকে ব্যথা হলে করণীয়: বুকে ব্যথা শুরু হলে কাজ থামিয়ে বিশ্রাম নিন।',
      'মাংস খাওয়া: গরুর মাংস, খাসির মাংস, মগজ ও কলিজা খাওয়া বাদ দিন।',
      'নিয়মিত ওষুধ: রক্ত পাতলা করার ওষুধ নিয়মিত খাবেন।',
    ],
    'Congestive Heart Failure (হার্ট ফেইলিউর)': [
      'পানি পানের হিসাব: সারা দিনে পানি, চা, দুধ ও ঝোল সব মিলিয়ে দেড় লিটারের বেশি তরল খাবেন না।',
      'ওজন মাপা: প্রতিদিন সকালে নাস্তার আগে ওজন মাপুন।',
      'শোয়ার নিয়ম: শ্বাসকষ্ট এড়াতে শোয়ার সময় মাথার নিচে ২-৩টি বালিশ দিন।',
      'লবণ বর্জন: রান্নায় লবণ একদম কম দেবেন।',
      'টিকা গ্রহণ: ফুসফুসের ইনফেকশন এড়াতে প্রতি বছর ফ্লু এবং নিউমোনিয়ার টিকা নিন।',
    ],
    'Type 2 Diabetes Mellitus (ডায়াবেটিস)': [
      'খাবার পরিমাপ: ভাতের পরিমাণ কমান। থালার অর্ধেকটা শাকসবজি দিয়ে পূর্ণ করুন।',
      'সুগার কমে যাওয়া (হাইপো): যদি হঠাৎ শরীর কাঁপে, ঘাম হয় তবে সাথে সাথে সুগার মাপুন।',
      'পায়ের যত্ন: প্রতিদিন হালকা গরম পানি দিয়ে পা ধুবেন।',
      'ব্যায়াম: প্রতিদিন ৩০-৪৫ মিনিট জোরে হাঁটুন।',
      'জুতা নির্বাচন: সব সময় নরম, আরামদায়ক এবং ঢাকা জুতা পরুন।',
    ],
    'COPD (ফুসফুসের রোগ)': [
      'ধূমপান বর্জন: ধূমপান এখনই পুরোপুরি বন্ধ করুন।',
      'ইনহেলার ব্যবহারের নিয়ম: ইনহেলার সঠিক নিয়মে ব্যবহার করুন।',
      'রান্নাঘরের ধোঁয়া: লাকড়ি বা পাতার চুলার ধোঁয়া থেকে দূরে থাকুন।',
      'শ্বাসের ব্যায়াম: শ্বাসকষ্ট কমাতে পার্সড-লিপ ব্রিদিং অনুশীলন করুন।',
      'টিকা: ফুসফুসের ইনফেকশন ও নিউমোনিয়া থেকে বাঁচতে প্রতি বছর ফ্লু ভ্যাকসিন নিন।',
    ],
    'Peptic Ulcer Disease (পেপটিক আলসার)': [
      'খাবারের নিয়ম: দীর্ঘক্ষণ পেট খালি রাখবেন না।',
      'ঝাল ও মসলা: অতিরিক্ত কাঁচা মরিচ, শুকনা মরিচ এড়িয়ে চলুন।',
      'গ্যাস্ট্রিকের ওষুধ: ডাক্তার যদি গ্যাস্ট্রিকের ওষুধ দেন, তবে তা নাস্তা করার ৩০ মিনিট আগে খাবেন।',
      'ব্যথানাশক ওষুধ: ডাক্তারের পরামর্শ ছাড়া কোনো ব্যথানাশক ওষুধ খাবেন না।',
      'ধূমপান: ধূমপান বা জর্দা খাওয়া সম্পূর্ণ বন্ধ করুন।',
    ],
    'GERD (গ্যাস্ট্রোইসোফেজিয়াল রিফ্লাক্স)': [
      'শোয়ার নিয়ম: খাওয়ার পরপরই শুয়ে পড়বেন না।',
      'বিছানা উচু করা: ঘুমানোর সময় খাটের মাথার দিক উচু করে দিন।',
      'রাতের খাবার: রাত ৮টার মধ্যে রাতের খাবার শেষ করার চেষ্টা করুন।',
      'নিষেধাজ্ঞা: অতিরিক্ত তেল-চর্বিযুক্ত খাবার, ভাজাপোড়া এড়িয়ে চলুন।',
      'ওজন কমানো: পেটে মেদ বা চর্বি থাকলে তা পাকস্থলীর ওপর চাপ দেয়।',
    ],
    'IBS (ইরিটেবল বাওয়েল সিন্ড্রোম)': [
      'খাবার বাছাই: কোন খাবার খেলে আপনার সমস্যা বাড়ে তা খেয়াল করুন।',
      'গ্যাসযুক্ত খাবার: পেট ফাঁপা বা গ্যাসের সমস্যা থাকলে বাঁধাকপি, ফুলকপি কম খান।',
      'দুধ ও দুগ্ধজাত: দুধ খেলে যদি পেট ডাকে তবে দুধ এড়িয়ে চলুন।',
      'দুশ্চিন্তা নিয়ন্ত্রণ: অতিরিক্ত টেনশন বা মানসিক চাপে পেটের সমস্যা বাড়ে।',
      'প্রোবায়োটিক: প্রতিদিন এক কাপ টক দই খাওয়ার অভ্যাস করুন।',
    ],
    'Fatty Liver Disease (ফ্যাটি লিভার)': [
      'ভাত কমানো: ফ্যাটি লিভারের মূল কারণ অতিরিক্ত ভাত বা শর্করা খাওয়া।',
      'চিনি বর্জন: মিষ্টি, সফট ড্রিংকস এবং চায়ে চিনি খাওয়া সম্পূর্ণ বন্ধ করুন।',
      'ওজন কমানো: ধীরে ধীরে ওজন কমানোর চেষ্টা করুন।',
      'ব্যায়াম: লিভারের চর্বি গলাতে প্রতিদিন ৪৫ মিনিট ঘাম ঝরিয়ে হাঁটুন।',
      'অ্যালকোহল নিষেধ: মদ বা অ্যালকোহল জাতীয় পানীয় স্পর্শ করবেন না।',
    ],
    'Liver Cirrhosis (লিভার সিরোসিস)': [
      'লবণ বর্জন: পেটে বা পায়ে পানি আসা রোধ করতে লবণ খাওয়া কঠোরভাবে নিয়ন্ত্রণ করুন।',
      'ঘুমের ওষুধ নিষেধ: ডাক্তারের পরামর্শ ছাড়া কখনোই ঘুমের ওষুধ খাবেন না।',
      'পায়খানা পরিষ্কার রাখা: দিনে ২-৩ বার যেন পায়খানা হয় সেদিকে খেয়াল রাখুন।',
      'প্রোটিন খাওয়া: প্রোটিন বা মাছ-মাংস একেবারে বন্ধ করবেন না।',
      'রক্তক্ষরণ সতর্কতা: শক্ত খাবার চিবিয়ে খাবেন না।',
    ],
    'Stroke (স্ট্রোক)': [
      'ওষুধ: প্রেসার এবং রক্ত পাতলা করার ওষুধ একদিনের জন্যও বাদ দেবেন না।',
      'বিছানায় নড়াচড়া: রোগী নিজে নড়তে না পারলে প্রতি ২ ঘণ্টা পর পর তাকে পাশ ফিরিয়ে দিন।',
      'খাওয়ানোর নিয়ম: রোগীকে বসিয়ে খাওয়ান।',
      'ব্যায়াম: অবশ হাত-পা দিনে ৩-৪ বার নড়াচড়া করিয়ে দিন।',
      'পড়ে যাওয়া রোধ: বাথরুমে ধরার জন্য হ্যান্ডেল লাগান।',
    ],
    'Migraine (মাইগ্রেন)': [
      'ট্রিগার এড়ানো: কড়া রোদ, বিকট শব্দ এবং তীব্র আলো এড়িয়ে চলুন।',
      'খাবার: বেশিক্ষণ না খেয়ে থাকবেন না। সকালের নাস্তা অবশ্যই করবেন।',
      'ঘুমের রুটিন: প্রতিদিন একই সময়ে ঘুমান ও জাগুন।',
      'পানি পান: শরীরে পানির অভাব হলে মাথাব্যথা হয়।',
      'দ্রুত ওষুধ: ব্যথা শুরু হওয়ার আভাস পাওয়া মাত্রই ওষুধ খেয়ে নিন।',
    ],
    'Low Back Pain (কোমর ব্যথা)': [
      'ভারী জিনিস তোলা: কোমর বাঁকিয়ে কোনো জিনিস তুলবেন না।',
      'বসার নিয়ম: একটানা দীর্ঘক্ষণ বসে থাকবেন না।',
      'বিছানা: খুব নরম বা গর্ত হয়ে যাওয়া তোশকে শোবেন না।',
      'ওজন: পেটের মেদ কমান। ভুড়ি বাড়লে কোমরের ওপর অতিরিক্ত চাপ পড়ে।',
      'ব্যায়াম: ব্যথা খুব বেশি থাকলে ব্যায়াম করবেন না।',
    ],
    'Epilepsy (মৃগীরোগ)': [
      'নিয়মিত ওষুধ: মৃগী রোগের ওষুধ প্রতিদিন নির্দিষ্ট সময়ে খেতে হবে।',
      'ঘুম: প্রতিদিন রাতে অন্তত ৭-৮ ঘণ্টা ঘুমান।',
      'আগুন ও পানি: পুকুরে একা গোসল করবেন না এবং আগুনের চুলার কাছে সাবধানে থাকবেন।',
      'কুসংস্কার: খিঁচুনি উঠলে রোগীর মুখে চামচ, আঙুল বা লোহার চাবি দেবেন না।',
      'উঁচু স্থান: ছাদ, মই বা গাছে উঠবেন না।',
    ],
    "Parkinson's Disease (পারকিনসন)": [
      'ওষুধের নিয়ম: পারকিনসনের ওষুধ খালি পেটে সবচেয়ে ভালো কাজ করে।',
      'পড়ে যাওয়া রোধ: হাঁটার সময় পা টেনে না হেঁটে পা উচু করে ফেলার চেষ্টা করুন।',
      'ব্যায়াম: শরীর শক্ত হয়ে যাওয়া রোধ করতে প্রতিদিন স্ট্রেচিং করুন।',
      'কোষ্ঠকাঠিন্য: এই রোগে কোষ্ঠকাঠিন্য খুব বেশি হয়।',
      'গিলতে সমস্যা: খাবার গিলতে বিষম খেলে শক্ত খাবার বাদ দিয়ে নরম খাবার খান।',
    ],
    'Chronic Kidney Disease (কিডনি রোগ)': [
      'প্রোটিন বা আমিষ: মাছ-মাংস খাওয়া কমাতে হবে, তবে একদম বন্ধ করবেন না।',
      'পানির মাপ: কিডনি রোগীদের বেশি পানি খাওয়া সবসময় ভালো নয়।',
      'পটাশিয়াম নিয়ন্ত্রণ: রক্তে পটাশিয়াম বেশি থাকলে কলা, ডাব খাবেন না।',
      'লবণ বর্জন: কাঁচা লবণ এবং তরকারিতে অতিরিক্ত লবণ খাওয়া কিডনির সবচেয়ে বড় শত্রু।',
      'ব্যথানাশক: শরীরে ব্যথা হলে ডাক্তারের পরামর্শ ছাড়া ডাইক্লোফেনাক খাবেন না।',
    ],
    'Renal Stone Disease (কিডনিতে পাথর)': [
      'পানি পান: দিনে ২.৫ থেকে ৩ লিটার পানি পান করুন।',
      'ক্যালসিয়াম: দুধ খাওয়া বন্ধ করবেন না।',
      'অক্সালেট: পালং শাক, বিট, বাদাম, চা এবং চকলেট কম খান।',
      'লবণ: লবণ বেশি খেলে প্রস্রাবে ক্যালসিয়াম বেড়ে পাথর হয়।',
      'লেবু জাতীয় ফল: প্রতিদিন লেবু এবং কমলা খান।',
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedAdvice = List.from(widget.selectedAdvice);
  }

  void _toggleAdvice(String advice) {
    setState(() {
      if (_selectedAdvice.contains(advice)) {
        _selectedAdvice.remove(advice);
      } else {
        _selectedAdvice.add(advice);
      }
    });
    widget.onAdviceSelected(_selectedAdvice);
  }

  void _addCustomAdvice() {
    if (_customController.text.isNotEmpty) {
      setState(() {
        _customAdviceList.add(_customController.text);
        _selectedAdvice.add(_customController.text);
        _showCustomInput = false;
      });
      _customController.clear();
      widget.onAdviceSelected(_selectedAdvice);
    }
  }

  void _removeAdvice(String advice) {
    setState(() {
      _selectedAdvice.remove(advice);
    });
    widget.onAdviceSelected(_selectedAdvice);
  }

  bool _matchesEnglishKeyword(String query, String category) {
    // Check if English keyword maps to this Bengali category
    for (var entry in _englishToBengaliMap.entries) {
      if (query.contains(entry.key) && entry.value == category) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Search and Add Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFE3001),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'পরামর্শ (ADVICE)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'ProductSans',
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Search Field
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'পরামর্শ খুঁজুন...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFFE3001), size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans'),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showCustomInput = !_showCustomInput;
                      });
                    },
                    icon: Icon(_showCustomInput ? Icons.close : Icons.add, size: 18),
                    label: const Text('যোগ করুন'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFE3001),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            // Custom Input Field (Conditional)
            if (_showCustomInput)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                color: const Color(0xFFFEF2F2),
                child: TextField(
                  controller: _customController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'কাস্টম পরামর্শ লিখুন...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFFFE3001)),
                      onPressed: _addCustomAdvice,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, fontFamily: 'ProductSans'),
                  onSubmitted: (_) => _addCustomAdvice(),
                ),
              ),

            // Medical Advice Categories (Responsive Grid)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Determine number of columns based on width
                  int crossAxisCount = 1;
                  if (constraints.maxWidth >= 1400) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth >= 1024) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth >= 600) {
                    crossAxisCount = 2;
                  }

                  final allCategories = <MapEntry<String, List<String>>>[];
                  
                  // Add custom category if exists
                  if (_customAdviceList.isNotEmpty) {
                    allCategories.add(MapEntry('Custom (কাস্টম)', _customAdviceList));
                  }
                  
                  // Add medical categories
                  allCategories.addAll(_medicalAdvice.entries);
                  
                  // Filter categories based on search
                  final filteredCategories = allCategories.where((entry) {
                    if (_searchQuery.isEmpty) return true;
                    
                    final category = entry.key;
                    final adviceList = entry.value;
                    
                    // Check if category name matches or any advice matches
                    final categoryMatches = category.toLowerCase().contains(_searchQuery) ||
                                          _matchesEnglishKeyword(_searchQuery, category);
                    
                    final adviceMatches = adviceList.any((advice) => 
                      advice.toLowerCase().contains(_searchQuery)
                    );
                    
                    return categoryMatches || adviceMatches;
                  }).toList();

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final entry = filteredCategories[index];
                      final category = entry.key;
                      final adviceList = entry.value;
                      
                      // Filter advice within category based on search
                      final filteredAdvice = _searchQuery.isEmpty
                          ? adviceList
                          : adviceList.where((advice) => 
                              advice.toLowerCase().contains(_searchQuery)
                            ).toList();
                      
                      final isExpanded = _expandedCategory == category;
                      
                      return _buildCategoryCard(category, filteredAdvice, isExpanded);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, List<String> filteredAdvice, bool isExpanded) {
    return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Category Header (Clickable)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedCategory = isExpanded ? null : category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                      fontFamily: 'ProductSans',
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: const Color(0xFFFE3001),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Advice List (Expandable)
                        if (isExpanded)
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredAdvice.length,
                              itemBuilder: (context, adviceIndex) {
                                final advice = filteredAdvice[adviceIndex];
                                final isSelected = _selectedAdvice.contains(advice);

                                return InkWell(
                                  onTap: () => _toggleAdvice(advice),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFEF2F2)
                                          : Colors.white,
                                      border: Border(
                                        bottom: adviceIndex < filteredAdvice.length - 1
                                            ? const BorderSide(
                                                color: Color(0xFFF1F5F9),
                                              )
                                            : BorderSide.none,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          color: isSelected
                                              ? const Color(0xFFFE3001)
                                              : const Color(0xFF94A3B8),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            advice,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isSelected
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFF64748B),
                                              fontFamily: 'ProductSans',
                                              fontWeight: isSelected
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
  }
}
