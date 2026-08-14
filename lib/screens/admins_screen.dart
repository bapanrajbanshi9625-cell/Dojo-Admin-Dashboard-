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
  String selectedFilter = 'All';

  final List<AdminData> admins = [
    AdminData(
      name: 'Super Admin',
      email: 'admin@dojo.com',
      role: 'Super Admin',
      status: 'Active',
      lastActive: 'Now',
    ),
    AdminData(
      name: 'Admin 01',
      email: 'admin01@dojo.com',
      role: 'Admin',
      status: 'Active',
      lastActive: '10 min ago',
    ),
    AdminData(
      name: 'Support Admin',
      email: 'support@dojo.com',
      role: 'Support',
      status: 'Active',
      lastActive: '1 hour ago',
    ),
    AdminData(
      name: 'Finance Admin',
      email: 'finance@dojo.com',
      role: 'Finance',
      status: 'Inactive',
      lastActive: '2 days ago',
    ),
  ];

  List<AdminData> get filteredAdmins {
    if (selectedFilter == 'All') {
      return admins;
    }

    return admins
        .where((admin) => admin.status == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final active =
        admins.where((a) => a.status == 'Active').length;

    final inactive =
        admins.where((a) => a.status == 'Inactive').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summary(active, inactive),
        const SizedBox(height: 20),
        _toolbar(),
        const SizedBox(height: 16),
        _adminList(),
      ],
    );
  }

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

  Widget _summary(int active, int inactive) {
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
            const _SummaryCard(
              title: 'Total Admins',
              value: '4',
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
    final active = selectedFilter == title;

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
          color: active ? dojoOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : dojoBlack,
          ),
        ),
      ),
    );
  }

  Widget _adminList() {
    final list = filteredAdmins;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((admin) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _adminCard(admin),
        );
      }).toList(),
    );
  }

  Widget _adminCard(AdminData admin) {
    final active = admin.status == 'Active';

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
        Row(
          children: [
            _roleChip(admin.role, roleColor),
            const SizedBox(width: 8),
            _statusChip(admin.status, statusColor),
            const Spacer(),
            Text(
              admin.lastActive,
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

  Widget _roleChip(String role, Color color) {
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

  Widget _statusChip(String status, Color color) {
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
        side: const BorderSide(color: dojoOrange),
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

  void _showAdmin(AdminData admin) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Admin Details',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detail('Name', admin.name),
              _detail('Email', admin.email),
              _detail('Role', admin.role),
              _detail('Status', admin.status),
              _detail('Last Active', admin.lastActive),
            ],
          ),
          actions: [
            if (admin.role != 'Super Admin')
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Admin edit will connect to Firebase.',
                      ),
                    ),
                  );
                },
                child: const Text('Edit'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
              value,
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

  void _addAdmin() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Admin',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();

                if (name.isEmpty || email.isEmpty) {
                  return;
                }

                setState(() {
                  admins.add(
                    AdminData(
                      name: name,
                      email: email,
                      role: 'Admin',
                      status: 'Active',
                      lastActive: 'Now',
                    ),
                  );
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Admin added locally. Firebase connection will be added next.',
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: dojoOrange,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
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

class AdminData {
  final String name;
  final String email;
  final String role;
  final String status;
  final String lastActive;

  AdminData({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastActive,
  });
}

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
        border: Border.all(color: dojoBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
