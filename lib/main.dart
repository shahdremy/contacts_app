import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

const kBg = Color(0xFF29303D);
const kCream = Color(0xFFFEF5BD);
const kCardBg = Color(0xFFFFF3D6);
const kRed = Color(0xFFE5484D);

class Contact {
  final String name;
  final String email;
  final String phone;
  final File? image;
  Contact({
    required this.name,
    required this.email,
    required this.phone,
    this.image,
  });
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kCream),
      ),
      home: const SplashScreen(),
    );
  }
}

class RouteLogo extends StatelessWidget {
  final double size;
  const RouteLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Route',
      style: TextStyle(
        color: Colors.white,
        fontSize: size,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.5,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: RouteLogo(size: 48)));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Contact> contacts = [];

  Future<void> _openAddSheet() async {
    final contact = await showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddContactSheet(),
    );
    if (contact != null) setState(() => contacts.add(contact));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: RouteLogo(),
            ),
            Expanded(
              child: contacts.isEmpty
                  ? const EmptyContacts()
                  : MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 160),
                itemCount: contacts.length,
                itemBuilder: (_, i) => ContactCard(
                  contact: contacts[i],
                  imageRatio: i.isEven ? 1.0 : 1.25,
                  onDelete: () => setState(() => contacts.removeAt(i)),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contacts.isNotEmpty) ...[
            FloatingActionButton(
              heroTag: 'delete_all',
              backgroundColor: kRed,
              foregroundColor: Colors.white,
              onPressed: () => setState(contacts.clear),
              child: const Icon(Icons.delete_outline),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: 'add',
            backgroundColor: kCream,
            foregroundColor: kBg,
            onPressed: _openAddSheet,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class EmptyContacts extends StatelessWidget {
  const EmptyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/empty_list.json',
            width: 240,
            height: 240,
            repeat: true,
          ),
          const SizedBox(height: 8),
          const Text(
            'There Is No Contacts Added Here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final Contact contact;
  final double imageRatio;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.imageRatio,
    required this.onDelete,
  });

  Widget _infoRow(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: kBg.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: kBg),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kBg, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: kCardBg,
        child: Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: imageRatio,
                  child: SizedBox.expand(
                    child: contact.image != null
                        ? Image.file(contact.image!, fit: BoxFit.cover)
                        : Container(
                      color: Colors.grey.shade700,
                      child: const Icon(Icons.person,
                          size: 48, color: Colors.white54),
                    ),
                  ),
                ),
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kCardBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      contact.name,
                      style: const TextStyle(
                        color: kBg,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _infoRow(Icons.email, contact.email),
                  _infoRow(Icons.phone, contact.phone),
                  SizedBox(
                    width: double.infinity,
                    height: 26,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRed,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 12),
                      label: const Text('Delete',
                          style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddContactSheet extends StatefulWidget {
  const AddContactSheet({super.key});

  @override
  State<AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Contact(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        image: _image,
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.white70),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: kCream),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _previewLine(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.white)),
        const SizedBox(height: 4),
        Divider(height: 1, color: Colors.white.withOpacity(0.3)),
        const SizedBox(height: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([_name, _email, _phone]),
                builder: (_, __) => Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : Lottie.asset(
                          'assets/animations/image_picker.json',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _previewLine(_name.text.isEmpty
                              ? 'User Name'
                              : _name.text),
                          _previewLine(_email.text.isEmpty
                              ? 'example@gmail.com'
                              : _email.text),
                          _previewLine(_phone.text.isEmpty
                              ? '+200000000000'
                              : _phone.text),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: _decoration('Enter User Name'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration('Enter User Email'),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Required';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: _decoration('Enter User Phone'),
                validator: (v) =>
                (v == null || v.trim().length < 8) ? 'Invalid phone' : null,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kCream,
                    foregroundColor: kBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text('Enter user'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}