import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  CollectionReference<Map<String, dynamic>> get _adminsRef =>
      _firestore.collection('admins');

  Stream<List<AdminData>> get _adminsStream {
    return _adminsRef.snapshots().map(
      (snapshot) {
        final admins = snapshot.docs
            .map(
              (doc) => AdminData.fromFirestore(
                doc.id,
                doc.data(),
              ),
            )
            .toList();

        admins.sort(
          (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
        );

        return admins;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AdminData>>(
      stream: _adminsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(50),
              child: CircularProgressIndicator(
                color: dojoOrange,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorState(
            snapshot.error.toString(),
          );
        }

        final admins = snapshot.data ?? [];

        final active = admins
            .where(
              (admin) => admin.status == 'Active',
            )
            .length;

        final inactive = admins
            .where(
              (admin) => admin.status == 'Inactive',
            )
            .length;

        final filteredAdmins = _filterAdmins(admins);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _summary(
              admins.length,
              active,
              inactive,
            ),
            const SizedBox(height: 20),
            _toolbar(),
            const SizedBox(height: 16),
            _adminList(filteredAdmins),
          ],
        );
      },
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _header() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(),
              const SizedBox(height: 14),
              _addButton(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _title()),
            _addButton(),
          ],
        );
      },
    );
  }

  Widget _title() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admins',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage DOJO administrator accounts and access',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _addButton() {
    return FilledButton.icon(
      onPressed: _addAdmin,
      icon: const Icon(
        Icons.person_add_alt_1_outlined,
      ),
      label: const Text('Add Admin'),
      style: FilledButton.styleFrom(
        backgroundColor: dojoOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _summary(
    int total,
    int active,
    int inactive,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 550
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.2 : 2.4,
          children: [
            _SummaryCard(
              title: 'Total Admins',
              value: '$total',
              icon: Icons.admin_panel_settings_outlined,
              color: dojoBlue,
            ),
            _SummaryCard(
              title: 'Active Admins',
              value: '$active',
              icon: Icons.check_circle_outline,
              color: dojoGreen,
            ),
            _SummaryCard(
              title: 'Inactive Admins',
              value: '$inactive',
              icon: Icons.person_off_outlined,
              color: dojoRed,
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          _filterButton('All'),
          _filterButton('Active'),
          _filterButton('Inactive'),
        ],
      ),
    );
  }

  Widget _filterButton(String title) {
    final selected = selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected
                ? Colors.white
                : dojoBlack,
          ),
        ),
      ),
    );
  }

  List<AdminData> _filterAdmins(
    List<AdminData> admins,
  ) {
    if (selectedFilter == 'All') {
      return admins;
    }

    return admins
        .where(
          (admin) => admin.status == selectedFilter,
        )
        .toList();
  }

  // ==========================================================
  // ADMIN LIST
  // ==========================================================

  Widget _adminList(List<AdminData> admins) {
    if (admins.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: admins.map((admin) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
          ),
          child: _adminCard(admin),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // ADMIN CARD
  // ==========================================================

  Widget _adminCard(AdminData admin) {
    final active = admin.status == 'Active';

    final statusColor =
        active ? dojoGreen : dojoRed;

    final roleColor =
        _roleColor(admin.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _mobileCard(
              admin,
              statusColor,
              roleColor,
            );
          }

          return _desktopCard(
            admin,
            statusColor,
            roleColor,
          );
        },
      ),
    );
  }

  Widget _desktopCard(
    AdminData admin,
    Color statusColor,
    Color roleColor,
  ) {
    return Row(
      children: [
        _avatar(),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _adminInfo(admin),
        ),
        Expanded(
          child: _roleChip(
            admin.role,
            roleColor,
          ),
        ),
        _statusChip(
          admin.status,
          statusColor,
        ),
        const SizedBox(width: 14),
        _actionButton(admin),
      ],
    );
  }

  Widget _mobileCard(
    AdminData admin,
    Color statusColor,
    Color roleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(),
            const SizedBox(width: 12),
            Expanded(
              child: _adminInfo(admin),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _roleChip(
              admin.role,
              roleColor,
            ),
            _statusChip(
              admin.status,
              statusColor,
            ),
            Text(
              'Last active: ${admin.lastActive}',
              style: const TextStyle(
                fontSize: 10,
                color: dojoGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _actionButton(admin),
        ),
      ],
    );
  }

  Widget _avatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.person_outline,
        color: dojoOrange,
        size: 27,
      ),
    );
  }

  Widget _adminInfo(AdminData admin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          admin.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          admin.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last active: ${admin.lastActive}',
          style: const TextStyle(
            fontSize: 10,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _roleChip(
    String role,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _statusChip(
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(AdminData admin) {
    return OutlinedButton.icon(
      onPressed: () => _showAdmin(admin),
      icon: const Icon(
        Icons.visibility_outlined,
        size: 17,
      ),
      label: const Text('View'),
      style: OutlinedButton.styleFrom(
        foregroundColor: dojoOrange,
        side: const BorderSide(
          color: dojoOrange,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
      ),
    );
  }

  // ==========================================================
  // VIEW ADMIN
  // ==========================================================

  void _showAdmin(AdminData admin) {
    final isSuperAdmin =
        admin.role == 'Super Admin';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Admin Details',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _detail('Name', admin.name),
                _detail('Email', admin.email),
                _detail('Role', admin.role),
                _detail('Status', admin.status),
                _detail(
                  'Last Active',
                  admin.lastActive,
                ),
                _detail('UID', admin.uid),
              ],
            ),
          ),
          actions: [
            if (!isSuperAdmin)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _editAdmin(admin);
                },
                child: const Text('Edit'),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detail(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: dojoGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ADD ADMIN
  // ==========================================================

  void _addAdmin() {
    final uidController =
        TextEditingController();

    final nameController =
        TextEditingController();

    final emailController =
        TextEditingController();

    String selectedRole = 'Admin';
    bool active = true;
    bool saving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Add Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: uidController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Firebase Auth UID',
                          hintText:
                              'Enter the user UID',
                          prefixIcon:
                              Icon(Icons.key_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        textCapitalization:
                            TextCapitalization.words,
                        decoration:
                            const InputDecoration(
                          labelText: 'Admin name',
                          prefixIcon:
                              Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration:
                            const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(
                            Icons
                                .admin_panel_settings_outlined,
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
                                  setDialogState(() {
                                    selectedRole =
                                        value;
                                  });
                                }
                              },
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Active',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Allow this admin to access DOJO Admin',
                          style: TextStyle(
                            fontSize: 11,
                            color: dojoGrey,
                          ),
                        ),
                        value: active,
                        activeColor: dojoOrange,
                        onChanged: saving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  active = value;
                                });
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
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final uid =
                              uidController.text.trim();
                          final name =
                              nameController.text.trim();
                          final email =
                              emailController.text.trim();

                          if (uid.isEmpty ||
                              name.isEmpty ||
                              email.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter UID, name and email.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (uid.length < 20) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid Firebase Auth UID.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            final existing =
                                await _adminsRef
                                    .doc(uid)
                                    .get();

                            if (existing.exists) {
                              setDialogState(() {
                                saving = false;
                              });

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'This UID is already an admin.',
                                  ),
                                ),
                              );
                              return;
                            }

                            await _adminsRef
                                .doc(uid)
                                .set({
                              'uid': uid,
                              'name': name,
                              'email': email,
                              'role': selectedRole,
                              'status': active
                                  ? 'Active'
                                  : 'Inactive',
                              'active': active,
                              'lastActive': 'Never',
                              'createdAt':
                                  FieldValue
                                      .serverTimestamp(),
                              'updatedAt':
                                  FieldValue
                                      .serverTimestamp(),
                            });

                            if (!context.mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Admin added successfully.',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              saving = false;
                            });

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to add admin: $e',
                                ),
                              ),
                            );
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: dojoOrange,
                  ),
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add Admin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // EDIT ADMIN
  // ==========================================================

  void _editAdmin(AdminData admin) {
    if (admin.role == 'Super Admin') {
      return;
    }

    String selectedRole = admin.role;
    bool active = admin.active;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Edit Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _readonlyField(
                      'Name',
                      admin.name,
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    _readonlyField(
                      'Email',
                      admin.email,
                      Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
                    _readonlyField(
                      'UID',
                      admin.uid,
                      Icons.key_outlined,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration:
                          const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(
                          Icons
                              .admin_panel_settings_outlined,
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
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Active',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      value: active,
                      activeColor: dojoOrange,
                      onChanged: (value) {
                        setDialogState(() {
                          active = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await _adminsRef
                          .doc(admin.uid)
                          .update({
                        'role': selectedRole,
                        'status': active
                            ? 'Active'
                            : 'Inactive',
                        'active': active,
                        'updatedAt':
                            FieldValue
                                .serverTimestamp(),
                      });

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Admin updated successfully.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update admin: $e',
                          ),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: dojoOrange,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _readonlyField(
    String label,
    String value,
    IconData icon,
  ) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(
        text: value,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  // ==========================================================
  // EMPTY
  // ==========================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 52,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No admins found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Administrator accounts will appear here.',
              style: TextStyle(
                fontSize: 12,
                color: dojoGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _errorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: dojoRed,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load admins',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: dojoGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ROLE COLOR
  // ==========================================================

  Color _roleColor(String role) {
    switch (role) {
      case 'Super Admin':
        return dojoOrange;
      case 'Admin':
        return dojoBlue;
      case 'Support':
        return dojoGreen;
      case 'Finance':
        return const Color(0xFF7567A8);
      default:
        return dojoGrey;
    }
  }
}

// ============================================================
// ADMIN DATA
// ============================================================

class AdminData {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final String lastActive;
  final bool active;

  const AdminData({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastActive,
    required this.active,
  });

  factory AdminData.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final activeValue = data['active'];

    final bool active = activeValue is bool
        ? activeValue
        : data['status'] == 'Active';

    final lastActiveValue =
        data['lastActive'];

    String lastActive = 'Unknown';

    if (lastActiveValue is Timestamp) {
      lastActive =
          'Recently active';
    } else if (lastActiveValue is String) {
      lastActive = lastActiveValue;
    }

    return AdminData(
      uid: id,
      name: data['name']?.toString() ??
          'Unknown Admin',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'Admin',
      status: data['status']?.toString() ??
          (active ? 'Active' : 'Inactive'),
      lastActive: lastActive,
      active: active,
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dojoBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: dojoGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: dojoBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
