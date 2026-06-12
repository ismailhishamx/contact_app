import 'dart:io';
import 'package:contact/contact_model.dart';
import 'package:contact/custom_app_bar.dart';
import 'package:contact/main.dart';
import 'package:contact/widgets/contact_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. CONTROLLERS & STATE VARIABLES
  // ═══════════════════════════════════════════════════════════════════════════

  // Controllers: they "listen" to what the user types in each text field
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Holds the image the user picks from gallery (null = no image chosen yet)
  File? _contactImage;

  // Tracks which contact we're editing — null means we're ADDING a new one
  int? _editIndex;

  // Pre-defined text styles so we don't repeat them everywhere
  final _style  = GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 20, height: 1.2, color: Colors.white);
  final _style0 = GoogleFonts.cairo(fontWeight: FontWeight.w400, fontSize: 16, height: 1.2, color: Colors.white);

  // The main list that holds all contacts shown on screen
  List<Contact> contacts = [];

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _loadFromDisk(); // When the screen opens, immediately load saved contacts
  }

  @override
  void dispose() {
    // Always dispose controllers when the screen is removed to free memory
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. STORAGE METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  // Converts the contacts list to JSON and saves it to the device's local storage
  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();

    // jsonEncode turns our List<Contact> into a plain JSON string like:
    // '[{"name":"Ali","email":"ali@x.com","phone":"01000000000"}]'
    String encodedData = jsonEncode(contacts.map((c) => c.toJson()).toList());
    await prefs.setString('contacts_list', encodedData);

    debugPrint("✅ Saved ${contacts.length} contacts to storage.");
  }

  // Reads the JSON string from local storage and converts it back to Contact objects
  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString('contacts_list');

    // Only try to load if something was actually saved before
    if (encodedData != null && encodedData.isNotEmpty) {
      try {
        List<dynamic> decodedData = jsonDecode(encodedData);
        setState(() {
          // Map each JSON map back into a Contact object using the fromJson factory
          contacts = decodedData.map((item) => Contact.fromJson(item)).toList();
        });
        debugPrint("✅ Loaded ${contacts.length} contacts.");
      } catch (e) {
        // If something goes wrong while parsing, log it instead of crashing
        debugPrint("❌ Error loading contacts: $e");
      }
    } else {
      debugPrint("ℹ️ No saved contacts found.");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  // Returns Arabic text if the app locale is Arabic, otherwise English
  String _translate(String ar, String en) {
    return appLocale.value.languageCode == 'ar' ? ar : en;
  }

  // Builds a small preview row (label/value + a divider line) inside the sheet header
  Widget _buildContactField(String placeholder, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show the typed value if available, otherwise show the placeholder
        Text(
          value.isEmpty ? placeholder : value,
          style: _style0,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Adds "..." if text is too long
        ),
        const SizedBox(height: 12),
        // A thin horizontal divider line between fields
        Container(height: 1, width: 150, color: Colors.white24),
        const SizedBox(height: 12),
      ],
    );
  }

  // Opens the bottom sheet for either ADDING or EDITING a contact
  void _showContactBottomSheet({int? index}) {
    if (index != null) {
      // EDIT mode — pre-fill all fields with the existing contact's data
      _editIndex = index;
      _nameController.text  = contacts[index].name;
      _emailController.text = contacts[index].email;
      _phoneController.text = contacts[index].phone;
      _contactImage         = contacts[index].image;
    } else {
      // ADD mode — reset everything so we start with a blank form
      _editIndex = null;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _contactImage = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,   // Allows the sheet to grow taller when keyboard opens
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        // Pushes the sheet up exactly as much as the keyboard takes up
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _buildSheetContent(),
      ),
    );
  }

  // Builds the actual content inside the bottom sheet
  Widget _buildSheetContent() {
    return StatefulBuilder(
      // StatefulBuilder gives the sheet its own setState so it can rebuild
      // without rebuilding the whole HomeScreen (e.g., live preview while typing)
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

                  // ── Drag Handle ──────────────────────────────────────────
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ── Top Row: Avatar + Live Preview ───────────────────────
                  Row(
                    children: [

                      // Image picker with an overlay camera icon
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Opens the device gallery for the user to pick a photo
                              final selected = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                              );
                              if (selected != null) {
                                // Update only the sheet UI (not the whole screen)
                                setSheetState(() {
                                  _contactImage = File(selected.path);
                                });
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 120,
                                height: 120,
                                color: Colors.white12,
                                // Show picked image or default placeholder
                                child: _contactImage != null
                                    ? Image.file(_contactImage!, fit: BoxFit.cover)
                                    : Image.asset('assets/images/media.png', fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          // Small camera badge at the bottom-right of the avatar
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

                      // Live text preview — updates as the user types
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactField(_translate('اسم المستخدم', 'User Name'),  _nameController.text),
                            _buildContactField('example@email.com',                       _emailController.text),
                            _buildContactField(_translate('رقم الهاتف', 'Phone Number'), _phoneController.text),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ── Input Fields ─────────────────────────────────────────
                  // Each field calls setSheetState to refresh the live preview above
                  _buildTextField(
                    _nameController,
                    _translate('الاسم', 'Name'),
                    Icons.person_outline,
                        (val) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _emailController,
                    _translate('البريد الإلكتروني', 'Email'),
                    Icons.email_outlined,
                        (val) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _phoneController,
                    _translate('الهاتف', 'Phone'),
                    Icons.phone_outlined,
                        (val) => setSheetState(() {}),
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 30),

                  // ── Save Button ──────────────────────────────────────────
                  // Label changes based on whether we're adding or editing
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
                      _editIndex != null
                          ? _translate("تحديث جهة الاتصال", "Update Contact")
                          : _translate("إضافة جهة اتصال",  "Add Contact"),
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

  // Reusable styled TextField used for name, email, and phone
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      Function(String) onChanged, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,       // Called on every keystroke — used to update live preview
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        // ✅ FIX: withValues(alpha:) instead of deprecated withOpacity/withAlpha
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // No border when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white24), // Subtle border when focused
        ),
      ),
    );
  }

  // Validates form data and either adds a new contact or updates an existing one
  void _saveContact() {
    String name  = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();

    // Guard: all fields must be filled
    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _showErrorDialog(_translate('يرجى ملء جميع الحقول', 'Please fill in all fields'));
      return;
    }

    // Guard: basic email format check
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog(_translate('يرجى إدخال بريد إلكتروني صحيح', 'Please enter a valid email address'));
      return;
    }

    // Guard: phone must be at least 10 digits
    if (phone.length < 10) {
      _showErrorDialog(_translate('يجب أن يتكون رقم الهاتف من 10 أرقام على الأقل', 'Phone number must be at least 10 digits'));
      return;
    }

    setState(() {
      final newContact = Contact(name: name, email: email, phone: phone, image: _contactImage);

      if (_editIndex != null) {
        contacts[_editIndex!] = newContact; // Replace existing contact at that index
      } else {
        contacts.add(newContact);           // Append new contact to the end of the list
      }
    });

    _saveToDisk();       // Persist the updated list to device storage
    Navigator.pop(context); // Close the bottom sheet
  }

  // Shows a styled error dialog with a given message
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
            Text(
              _translate("بيانات غير صالحة", "Invalid Input"),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              // ✅ FIX: withValues(alpha:) instead of deprecated withOpacity/withAlpha
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_translate("حسناً", "OK"), style: const TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  // Shows a confirmation dialog before deleting — prevents accidental deletions
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff29384D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _translate("حذف جهة الاتصال؟", "Delete Contact?"),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          _translate(
            "لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟",
            "This action cannot be undone. Are you sure?",
          ),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          // Cancel — just closes the dialog, does nothing
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_translate("إلغاء", "Cancel"), style: const TextStyle(color: Colors.white54)),
          ),
          // Confirm — removes the contact and saves the updated list
          ElevatedButton(
            onPressed: () {
              setState(() {
                contacts.removeAt(index);
              });
              _saveToDisk();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_translate("حذف", "Delete"), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. MAIN BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      // Show empty state illustration if no contacts, otherwise show the grid
      body: contacts.isEmpty ? _buildEmptyState() : _buildContactsGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactBottomSheet(), // Opens sheet in ADD mode
        backgroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // Displayed when the contacts list is empty — shows a Lottie animation
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            // Lottie plays a looping JSON animation (like an animated SVG)
            Lottie.asset('assets/images/empty.json', width: 400, height: 400, repeat: true),
            const SizedBox(height: 16),
            Text(
              _translate('لا توجد جهات اتصال مضافة هنا', 'There is No Contacts Added Here'),
              style: _style,
            ),
          ],
        ),
      ),
    );
  }

  // Builds a 2-column grid of ContactCard widgets with a slide-in animation
  Widget _buildContactsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,       // 2 cards per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.55,  // Card height > width (tall cards)
      ),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          // Each card animates from 0→1 opacity; later cards take longer to appear
          duration: Duration(milliseconds: 500 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              // Slides the card upward as it fades in (starts 30px below its final position)
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: ContactCard(
            contact: contacts[index],
            onEdit:   () => _showContactBottomSheet(index: index), // Opens sheet in EDIT mode
            onDelete: () => _confirmDelete(index),
          ),
        );
      },
    );
  }
}