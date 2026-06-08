import 'dart:io';
import 'package:contact/contact_model.dart';
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactCard({
    Key? key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: contact.image != null
                    ? DecorationImage(image: FileImage(contact.image!), fit: BoxFit.cover)
                    : null,
                color: Colors.grey[300],
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        contact.name,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email_rounded, contact.email),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, contact.phone),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration:
                        BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
