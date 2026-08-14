import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../features/admins/containers/admins_header.dart';
import '../features/admins/containers/admins_list.dart';
import '../features/admins/containers/admins_summary.dart';
import '../features/admins/containers/admins_toolbar.dart';
import '../features/admins/dialogs/add_admin_dialog.dart';
import '../features/admins/dialogs/admin_details_dialog.dart';
import '../features/admins/models/admin_data.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String selectedFilter = 'All';

  CollectionReference<Map<String, dynamic>>
      get _adminsRef => _firestore.collection('admins');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _adminsRef
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error loading admins:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final admins = snapshot.data?.docs
                .map(
                  (doc) => AdminData.fromFirestore(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList() ??
            [];

        final filteredAdmins = _filterAdmins(admins);

        final active = admins
            .where((admin) => admin.status == 'Active')
            .length;

        final inactive = admins
            .where((admin) => admin.status == 'Inactive')
            .length;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminsHeader(
                onAdd: _addAdmin,
              ),
              const SizedBox(height: 20),
              AdminsSummary(
                total: admins.length,
                active: active,
                inactive: inactive,
              ),
              const SizedBox(height: 20),
              AdminsToolbar(
                selectedFilter: selectedFilter,
                onFilterChanged: (value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              AdminsList(
                admins: filteredAdmins,
                onView: _showAdmin,
              ),
            ],
          ),
        );
      },
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

  void _showAdmin(AdminData admin) {
    showAdminDetailsDialog(
      context: context,
      admin: admin,
      onEdit: admin.role == 'Super Admin'
          ? null
          : () {
              Navigator.pop(context);
              // Edit function yahan add kar sakte hain.
            },
      onDelete: admin.role == 'Super Admin'
          ? null
          : () {
              Navigator.pop(context);
              _deleteAdmin(admin);
            },
    );
  }

  void _addAdmin() {
    showAddAdminDialog(
      context: context,
      firestore: _firestore,
    );
  }

  Future<void> _deleteAdmin(AdminData admin) async {
    try {
      await _adminsRef.doc(admin.id).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete admin: $e'),
        ),
      );
    }
  }
}
