import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);

Future<void> showAddAdminDialog({
  required BuildContext context,
  required FirebaseFirestore firestore,
}) async {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  String selectedRole = 'Admin';
  bool saving = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> save() async {
            final name = nameController.text.trim();
            final email = emailController.text.trim();

            if (name.isEmpty || email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter name and email.'),
                ),
              );
              return;
            }

            setState(() {
              saving = true;
            });

            try {
              await firestore.collection('admins').add({
                'name': name,
                'email': email,
                'role': selectedRole,
                'status': 'Active',
                'lastActive': 'Now',
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Admin added successfully.'),
                  ),
                );
              }
            } catch (e) {
              setState(() {
                saving = false;
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add admin: $e'),
                  ),
                );
              }
            }
          }

          return AlertDialog(
            title: const Text(
              'Add Admin',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Admin name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(
                          Icons.admin_panel_settings_outlined,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Admin',
                          child: Text('Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'Support',
                          child: Text('Support'),
                        ),
                        DropdownMenuItem(
                          value: 'Finance',
                          child: Text('Finance'),
                        ),
                      ],
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  selectedRole = value;
                                });
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving ? null : save,
                style: FilledButton.styleFrom(
                  backgroundColor: dojoOrange,
                ),
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  emailController.dispose();
}
