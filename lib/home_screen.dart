import 'dart:io';
import 'package:contact/contact_model.dart';
import 'package:contact/custom_app_bar.dart';
import 'package:contact/main.dart'; // Add this to access appLocale
import 'package:contact/widgets/contact_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Local storage
import 'dart:convert'; // For JSON encoding/decoding

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. VARIABLES & CONTROLLERS
  // ═══════════════════════════════════════════════════════════════════════════

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _contactImage;
  int? _editIndex;

  // How to think about it: Using Cairo font makes the Arabic look beautiful
  final _style = GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 20, height: 1.2, color: Colors.white);
  final _style0 = GoogleFonts.cairo(fontWeight: FontWeight.w400, fontSize: 16, height: 1.2, color: Colors.white);

  List<Contact> contacts = [];

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _loadFromDisk(); // Load data as soon as the screen is created
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. STORAGE METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  // Saves the entire list to local storage
  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert our list of objects into a single JSON string
    String encodedData = jsonEncode(contacts.map((c) => c.toJson()).toList());
    await prefs.setString('contacts_list', encodedData);

    debugPrint("Successfully saved ${contacts.length} contacts to storage."); // Check your logs for this!
  }

  // Reads the list from local storage
  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('contacts_list');

    // How to think about it: Check if we have anything in the "filing cabinet" first.
    if (encodedData != null && encodedData.isNotEmpty) {
      try {
        List<dynamic> decodedData = jsonDecode(encodedData);
        setState(() {
          // Convert each map back into a Contact object
          contacts = decodedData.map((item) => Contact.fromJson(item)).toList();
        });
        debugPrint("Successfully loaded ${contacts.length} contacts");
      } catch (e) {
        debugPrint("Error loading contacts: $e");
      }
    } else {
      debugPrint("No saved contacts found.");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  // Helper to translate words based on selected locale
  String _translate(String ar, String en) {
    return appLocale.value.languageCode == 'ar' ? ar : en;
  }

  Widget _buildContactField(String placeholder, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value.isEmpty ? placeholder : value, style: _style0, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        Container(height: 1, width: 150, color: Colors.white24),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showContactBottomSheet({int? index}) {
    if (index != null) {
      _editIndex = index;
      _nameController.text = contacts[index].name;
      _emailController.text = contacts[index].email;
      _phoneController.text = contacts[index].phone;
      _contactImage = contacts[index].image;
    } else {
      _editIndex = null;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _contactImage = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _buildSheetContent(),
      ),
    );
  }

  Widget _buildSheetContent() {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xff29384D),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final select = await ImagePicker().pickImage(source: ImageSource.gallery);
                              if (select != null) {
                                setSheetState(() {
                                  _contactImage = File(select.path);
                                });
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 120,
                                height: 120,
                                color: Colors.white12,
                                child: _contactImage != null ? Image.file(_contactImage!, fit: BoxFit.cover) : Image.asset('assets/images/media.png', fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactField(_translate('اسم المستخدم', 'User Name'), _nameController.text),
                            _buildContactField('example@email.com', _emailController.text),
                            _buildContactField(_translate('رقم الهاتف', 'Phone Number'), _phoneController.text)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(_nameController, _translate('الاسم', 'Name'), Icons.person_outline, (val) => setSheetState(() {})),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, _translate('البريد الإلكتروني', 'Email'), Icons.email_outlined, (val) => setSheetState(() {})),
                  const SizedBox(height: 15),
                  _buildTextField(_phoneController, _translate('الهاتف', 'Phone'), Icons.phone_outlined, (val) => setSheetState(() {}), keyboardType: TextInputType.phone),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: Text(
                      _editIndex != null ? _translate("تحديث جهة الاتصال", "Update Contact") : _translate("إضافة جهة اتصال", "Add Contact"),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, Function(String) onChanged, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withAlpha(13), // 0.05 opacity approx 13/255
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  void _saveContact() {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _showErrorDialog(_translate('يرجى ملء جميع الحقول', 'Please fill in all fields'));
      return;
    }

    // Check if Email is valid
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog(_translate('يرجى إدخال بريد إلكتروني صحيح', 'Please enter a valid email address'));
      return;
    }

    // Check if Phone is a real number
    if (phone.length < 10) {
      _showErrorDialog(_translate('يجب أن يتكون رقم الهاتف من 10 أرقام على الأقل', 'Phone number must be at least 10 digits'));
      return;
    }

    setState(() {
      final newContact = Contact(name: name, email: email, phone: phone, image: _contactImage);

      if (_editIndex != null) {
        contacts[_editIndex!] = newContact;
      } else {
        contacts.add(newContact);
      }
    });
    _saveToDisk(); // Save the updated list to storage
    Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff29384D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            Text(_translate("بيانات غير صالحة", "Invalid Input"), style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(25), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            child: Text(_translate("حسناً", "OK"), style: const TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff29384D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_translate("حذف جهة الاتصال؟", "Delete Contact?"), style: const TextStyle(color: Colors.white)),
        content: Text(_translate("لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟", "This action cannot be undone. Are you sure?"), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_translate("إلغاء", "Cancel"), style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                contacts.removeAt(index);
              });
              _saveToDisk();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(_translate("حذف", "Delete"), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. MAIN BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: contacts.isEmpty ? _buildEmptyState() : _buildContactsGrid(),
      floatingActionButton: FloatingActionButton(onPressed: () => _showContactBottomSheet(), backgroundColor: Colors.white, child: const Icon(Icons.add_rounded)),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Lottie.asset('assets/images/empty.json', width: 400, height: 400, repeat: true),
            const SizedBox(height: 16),
            Text(_translate('لا توجد جهات اتصال مضافة هنا', 'There is No Contacts Added Here'), style: _style),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.55),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 500 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
            );
          },
          child: ContactCard(
            contact: contacts[index],
            onEdit: () => _showContactBottomSheet(index: index),
            onDelete: () => _confirmDelete(index),
          ),
        );
      },
    );
  }
}
