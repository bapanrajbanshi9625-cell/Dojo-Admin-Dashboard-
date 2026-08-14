// lib/screens/admins_screen.dart

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedFilter = 'All';

  CollectionReference<Map<String, dynamic>> get _adminsRef =>
      _firestore.collection('admins');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _adminsRef
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingState();
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        final admins = snapshot.data?.docs
                .map(
                  (doc) => AdminData.fromFirestore(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList() ??
            <AdminData>[];

        final filteredAdmins = _filterAdmins(admins);

        final active = admins
            .where((admin) => admin.status.toLowerCase() == 'active')
            .length;

        final inactive = admins
            .where((admin) => admin.status.toLowerCase() == 'inactive')
            .length;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
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
            ),
          ),
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
      icon: const Icon(Icons.person_add_alt_1_outlined),
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
  // TOOLBAR
  // ==========================================================

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dojoBorder),
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
          color: selected ? dojoOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : dojoBlack,
          ),
        ),
      ),
    );
  }

  List<AdminData> _filterAdmins(List<AdminData> admins) {
    if (selectedFilter == 'All') {
      return admins;
    }

    return admins
        .where((admin) => admin.status == selectedFilter)
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
          padding: const EdgeInsets.only(bottom: 12),
          child: _adminCard(admin),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // ADMIN CARD
  // ==========================================================

  Widget _adminCard(AdminData admin) {
    final active = admin.status.toLowerCase() == 'active';

    final statusColor = active ? dojoGreen : dojoRed;
    final roleColor = _roleColor(admin.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
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
        _avatar(admin),
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
            _avatar(admin),
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

  Widget _avatar(AdminData admin) {
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
        color: color.withValues(alpha: 0.09),
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
        color: color.withValues(alpha: 0.09),
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
    showDialog<void>(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detail('Name', admin.name),
                _detail('Email', admin.email),
                _detail('Role', admin.role),
                _detail('Status', admin.status),
                _detail('Last Active', admin.lastActive),
                _detail('UID', admin.uid),
              ],
            ),
          ),
          actions: [
            if (admin.role != 'Super Admin')
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _editAdmin(admin);
                },
                child: const Text('Edit'),
              ),
            if (admin.role != 'Super Admin')
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _deleteAdmin(admin);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: dojoRed),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    String selectedRole = 'Admin';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Admin name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    await _createAdmin(
                      dialogContext,
                      nameController.text,
                      emailController.text,
                      selectedRole,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: dojoOrange,
                  ),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createAdmin(
    BuildContext dialogContext,
    String name,
    String email,
    String role,
  ) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty || cleanEmail.isEmpty) {
      _showMessage('Name and email are required.');
      return;
    }

    if (!cleanEmail.contains('@')) {
      _showMessage('Please enter a valid email.');
      return;
    }

    try {
      final now = Timestamp.now();

      await _adminsRef.add({
        'name': cleanName,
        'email': cleanEmail,
        'role': role,
        'status': 'Active',
        'uid': '',
        'lastActive': 'Never',
        'createdAt': now,
        'updatedAt': now,
      });

      if (mounted && dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      _showMessage('Admin created successfully.');
    } catch (e) {
      _showMessage('Failed to create admin: $e');
    }
  }

  // ==========================================================
  // EDIT ADMIN
  // ==========================================================

  void _editAdmin(AdminData admin) {
    final nameController =
        TextEditingController(text: admin.name);

    final emailController =
        TextEditingController(text: admin.email);

    String selectedRole = _validRole(admin.role)
        ? admin.role
        : 'Admin';

    String selectedStatus =
        admin.status == 'Inactive' ? 'Inactive' : 'Active';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Edit Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Admin name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(
                          Icons.toggle_on_outlined,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'Inactive',
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    await _updateAdmin(
                      dialogContext,
                      admin,
                      nameController.text,
                      emailController.text,
                      selectedRole,
                      selectedStatus,
                    );
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

  Future<void> _updateAdmin(
    BuildContext dialogContext,
    AdminData admin,
    String name,
    String email,
    String role,
    String status,
  ) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanName.isEmpty || cleanEmail.isEmpty) {
      _showMessage('Name and email are required.');
      return;
    }

    if (!cleanEmail.contains('@')) {
      _showMessage('Please enter a valid email.');
      return;
    }

    try {
      await _adminsRef.doc(admin.id).update({
        'name': cleanName,
        'email': cleanEmail,
        'role': role,
        'status': status,
        'updatedAt': Timestamp.now(),
      });

      if (mounted && dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      _showMessage('Admin updated successfully.');
    } catch (e) {
      _showMessage('Failed to update admin: $e');
    }
  }

  // ==========================================================
  // DELETE ADMIN
  // ==========================================================

  void _deleteAdmin(AdminData admin) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Admin?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${admin.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await _adminsRef.doc(admin.id).delete();

                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  _showMessage('Admin deleted successfully.');
                } catch (e) {
                  if (mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  _showMessage('Failed to delete admin: $e');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: dojoRed,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  bool _validRole(String role) {
    return role == 'Admin' ||
        role == 'Support' ||
        role == 'Finance';
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Support':
        return dojoBlue;
      case 'Finance':
        return dojoGreen;
      case 'Super Admin':
        return dojoOrange;
      case 'Admin':
      default:
        return dojoOrange;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // STATES
  // ==========================================================

  Widget _loadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(
          color: dojoOrange,
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dojoBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: dojoRed,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load admins',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: dojoBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: dojoGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 48,
            color: dojoGrey,
          ),
          SizedBox(height: 12),
          Text(
            'No admins found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: dojoBlack,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'There are no administrators matching this filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ADMIN DATA MODEL
// ==========================================================

class AdminData {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final String lastActive;
  final DateTime? createdAt;

  const AdminData({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastActive,
    this.createdAt,
  });

  factory AdminData.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    DateTime? createdDate;

    final createdValue = data['createdAt'];

    if (createdValue is Timestamp) {
      createdDate = createdValue.toDate();
    } else if (createdValue is DateTime) {
      createdDate = createdValue;
    }

    return AdminData(
      id: id,
      uid: (data['uid'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      role: (data['role'] ?? 'Admin').toString(),
      status: (data['status'] ?? 'Active').toString(),
      lastActive: (data['lastActive'] ?? 'Never').toString(),
      createdAt: createdDate,
    );
  }
}

// ==========================================================
// SUMMARY CARD
// ==========================================================

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: dojoGrey,
                    fontWeight: FontWeight.w600,
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
