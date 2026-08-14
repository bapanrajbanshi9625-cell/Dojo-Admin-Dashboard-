import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../features/owners/owner_card.dart';
import '../features/owners/owner_data.dart';
import '../features/owners/owner_dialogs.dart';
import '../features/owners/owner_summary_card.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoDark = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class OwnersScreen extends StatefulWidget {
  const OwnersScreen({super.key});

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  CollectionReference<Map<String, dynamic>> get _ownersRef =>
      _firestore.collection('owners');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<OwnerData> _filterOwners(List<OwnerData> owners) {
    final query = searchController.text.trim().toLowerCase();

    return owners.where((owner) {
      final matchesSearch =
          query.isEmpty ||
          owner.uid.toLowerCase().contains(query) ||
          owner.name.toLowerCase().contains(query) ||
          owner.phone.toLowerCase().contains(query) ||
          owner.email.toLowerCase().contains(query);

      final matchesStatus =
          selectedFilter == 'All' ||
          owner.status == selectedFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _ownersRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 350,
            child: Center(
              child: CircularProgressIndicator(
                color: dojoOrange,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        final owners = snapshot.data?.docs.map((doc) {
              return OwnerData.fromFirestore(
                doc.id,
                doc.data(),
              );
            }).toList() ??
            [];

        final filteredOwners = _filterOwners(owners);

        final active = owners
            .where((owner) => owner.status == 'Active')
            .length;

        final inactive = owners
            .where((owner) => owner.status == 'Inactive')
            .length;

        final totalPets = owners.fold<int>(
          0,
          (sum, owner) => sum + owner.pets,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),

            const SizedBox(height: 20),

            _summary(
              active,
              inactive,
              totalPets,
            ),

            const SizedBox(height: 20),

            _toolbar(),

            const SizedBox(height: 16),

            _ownerList(filteredOwners),
          ],
        );
      },
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Owners',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoDark,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage all DOJO pet owners',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summary(
    int active,
    int inactive,
    int totalPets,
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
          childAspectRatio: columns == 1 ? 3.2 : 2.5,
          children: [
            OwnerSummaryCard(
              title: 'Active Owners',
              value: '$active',
              icon: Icons.people_outline,
              color: dojoGreen,
            ),
            OwnerSummaryCard(
              title: 'Inactive Owners',
              value: '$inactive',
              icon: Icons.person_off_outlined,
              color: dojoOrange,
            ),
            OwnerSummaryCard(
              title: 'Total Pets',
              value: '$totalPets',
              icon: Icons.pets_outlined,
              color: dojoBlue,
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dojoBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return Column(
              children: [
                _searchBox(),
                const SizedBox(height: 12),
                _filters(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _searchBox()),
              const SizedBox(width: 12),
              _filters(),
            ],
          );
        },
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search owner, phone or email...',
        hintStyle: const TextStyle(
          color: dojoGrey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 20,
          color: dojoGrey,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close, size: 18),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: dojoOrange),
        ),
      ),
    );
  }

  Widget _filters() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _filterButton('All'),
        _filterButton('Active'),
        _filterButton('Inactive'),
      ],
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
          horizontal: 13,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? dojoOrange
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? dojoOrange : dojoBorder,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : dojoDark,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _ownerList(List<OwnerData> owners) {
    if (owners.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: owners.map((owner) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OwnerCard(
            owner: owner,
            onView: () {
              showOwnerDetailsDialog(
                context,
                owner,
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      height: 300,
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
              Icons.people_outline,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No owners found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Owners will appear here.',
              style: TextStyle(
                color: dojoGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dojoBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load owners',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: dojoGrey,
            ),
          ),
        ],
      ),
    );
  }
}
