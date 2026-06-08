import 'dart:io';
import 'package:contact/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. VARIABLES & CONTROLLERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Text controllers for name, email, and phone input fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  /// Stores the selected contact image from gallery
  File? _contactImage;

  /// null = add mode, number = edit mode (index of contact being edited)
  int? _editIndex;

  /// Text styles for the UI
  final _style = GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 20, height: 1.0, letterSpacing: 0, color: Colors.white);
  final _style0 = GoogleFonts.inter(fontWeight: FontWeight.w300, fontSize: 16, height: 0, letterSpacing: 0, color: Colors.white);

  /// List to store all contacts with images
  List<Map<String, dynamic>> contacts = [];

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. DISPOSE Method to clear data
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cleanup text controllers when widget is disposed
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. HELPER METHOD - Build contact field Data of user
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build a single contact field with divider
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. UI - MODAL BOTTOM SHEET ( when press button show sheet )
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build the modal bottom sheet for adding/editing contacts
  Widget _onPressSheet() {
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
                children: [
                  Row(
                    children: [
                      /// Image picker button - tap to select photo from gallery
                      GestureDetector(
                        onTap: () async {
                          final select = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (select != null) {
                            setSheetState(() {
                              _contactImage = File(select.path);
                            });
                            setState(() {});
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
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, size: 50);
                                    },
                                  )
                                : Image.asset('assets/images/media.png', width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),

                      /// Display contact data preview
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildContactField('User Name', _nameController.text), _buildContactField('example@email.com', _emailController.text), _buildContactField('phoneNumber', _phoneController.text)]),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  /// Name input field
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: _nameController,
                      onChanged: (_) => setSheetState(() {}), // refresh preview
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        labelText: 'Enter Name',
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
                  ),
                  SizedBox(height: 10),

                  /// Email input field
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: _emailController,
                      onChanged: (_) => setSheetState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
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
                  ),
                  SizedBox(height: 10),

                  /// Phone input field
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: _phoneController,
                      onChanged: (_) => setSheetState(() {}),
                      // refresh preview
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Enter Phone',
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
                  ),
                  SizedBox(height: 10),

                  // ─────────────────────────────────────────────────────────────────
                  // Add / Update Contact button
                  // ─────────────────────────────────────────────────────────────────
                  ElevatedButton(
                    onPressed: () {
                      String name = _nameController.text;
                      String email = _emailController.text;
                      String phone = _phoneController.text;

                      /// Validate all fields are filled
                      if (name.isEmpty || email.isEmpty || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                        return;
                      }

                      setState(() {
                        if (_editIndex != null) {
                          // ── EDIT MODE: update existing contact ──
                          contacts[_editIndex!] = {'name': name, 'email': email, 'phone': phone, 'image': _contactImage};
                          _editIndex = null; // reset back to add mode
                        } else {
                          // ── ADD MODE: add new contact ──
                          contacts.add({'name': name, 'email': email, 'phone': phone, 'image': _contactImage});
                        }
                      });

                      /// Clear all input fields
                      _nameController.clear();
                      _emailController.clear();
                      _phoneController.clear();
                      setState(() {
                        _contactImage = null;
                      });

                      /// Close modal
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    // Button label changes based on mode
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. UI - MAIN BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ───────────────────────────────────────────────────────────────────────
      // App Bar--------
      // ───────────────────────────────────────────────────────────────────────

    appBar: CustomAppBar(),
      // ───────────────────────────────────────────────────────────────────────
      // Body: Show empty state or contacts grid
      // ───────────────────────────────────────────────────────────────────────
      body: contacts.isEmpty ?
            /// Empty state - no contacts added
            SingleChildScrollView(
              child: Column(
                children: [
                  Lottie.asset('assets/images/empty.json', width: 400, height: 400, repeat: true),
                  SizedBox(height: 16),
                  Text('There is No Contacts Added Here', style: _style),
                ],
              ),
            )
          :
            /// Contacts grid with card design
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 0.5),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          // ─────────────────────────────────────────────────
                          // Contact Image Section
                          // ─────────────────────────────────────────────────
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                image: contacts[index]['image'] != null ? DecorationImage(image: FileImage(contacts[index]['image']!), fit: BoxFit.cover) : null,
                                color: Colors.grey[300],
                              ),
                              child: Stack(
                                children: [
                                  /// Name badge on image
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        contacts[index]['name']!,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  /// Edit button on top right
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Set edit mode with the contact's index
                                        _editIndex = index;
                                        // Pre-fill fields with existing contact data
                                        _nameController.text = contacts[index]['name']!;
                                        _emailController.text = contacts[index]['email']!;
                                        _phoneController.text = contacts[index]['phone']!;
                                        _contactImage = contacts[index]['image'];

                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => Padding(
                                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                            child: _onPressSheet(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ─────────────────────────────────────────────────
                          // Contact Info Section
                          // ─────────────────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Email with icon
                                Row(
                                  children: [
                                    const Icon(Icons.email_rounded, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        contacts[index]['email']!,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                /// Phone with icon
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        contacts[index]['phone']!,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                /// Delete button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      contacts.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

      // ───────────────────────────────────────────────────────────────────────
      // Floating Action Button - Add new contact
      // ───────────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reset to add mode
          _editIndex = null;

          /// Clear fields for new contact
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          setState(() {
            _contactImage = null;
          });

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: _onPressSheet(),
            ),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
