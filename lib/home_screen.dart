import 'dart:convert'; // For JSON encoding/decoding
import 'dart:io';
import 'package:contact/contact_model.dart';
import 'package:contact/custom_app_bar.dart';
import 'package:contact/widgets/contact_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Local storage

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

  final _style = GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 20,
      height: 1.0,
      letterSpacing: 0,
      color: Colors.white);
  final _style0 = GoogleFonts.inter(
      fontWeight: FontWeight.w300,
      fontSize: 16,
      height: 0,
      letterSpacing: 0,
      color: Colors.white);

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
        print("Successfully loaded ${contacts.length} contacts");
      } catch (e) {
        print("Error loading contacts: $e");
      }
    } else {
      print("No saved contacts found.");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildContactField(String placeholder, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value.isEmpty ? placeholder : value,
            style: _style0, maxLines: 1, overflow: TextOverflow.ellipsis),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final select = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (select != null) {
                            setSheetState(() {
                              _contactImage = File(select.path);
                            });
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            width: 130,
                            height: 130,
                            color: Colors.grey[300],
                            child: _contactImage != null
                                ? Image.file(
                                    _contactImage!,
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset('assets/images/media.png',
                                    width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactField('User Name', _nameController.text),
                            _buildContactField('example@email.com', _emailController.text),
                            _buildContactField('phoneNumber', _phoneController.text)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nameController, 'Enter Name', (val) => setSheetState(() {})),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, 'Enter Email', (val) => setSheetState(() {})),
                  const SizedBox(height: 10),
                  _buildTextField(_phoneController, 'Enter Phone', (val) => setSheetState(() {}),
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveContact,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_editIndex != null ? "Update Contact" : "Add Contact"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      height: 55,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _saveContact() {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. MAIN BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: contacts.isEmpty ? _buildEmptyState() : _buildContactsGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactBottomSheet(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Lottie.asset('assets/images/empty.json', width: 400, height: 400, repeat: true),
            const SizedBox(height: 16),
            Text('There is No Contacts Added Here', style: _style),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.55,
      ),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return ContactCard(
          contact: contacts[index],
          onEdit: () => _showContactBottomSheet(index: index),
          onDelete: () {
            setState(() {
              contacts.removeAt(index);
            });
            _saveToDisk(); // Save the updated list after deletion
          },
        );
      },
    );
  }
}
