import 'package:flutter/material.dart';

const Color dojoOrange = Color(0xFFD35435);
const Color dojoBlue = Color(0xFF3F6FA5);
const Color dojoGreen = Color(0xFF3F8F68);
const Color dojoRed = Color(0xFFC94A4A);
const Color dojoBlack = Color(0xFF263238);
const Color dojoGrey = Color(0xFF6B7280);
const Color dojoBorder = Color(0xFFE7E9ED);

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String selectedFilter = 'All';

  final List<SupportTicket> tickets = const [
    SupportTicket(
      id: 'SUP-001',
      user: 'Owner 01',
      subject: 'Unable to book a walk',
      message: 'Owner needs help booking a new walk.',
      date: '14 Aug 2026',
      status: 'Open',
      type: 'Owner',
    ),
    SupportTicket(
      id: 'SUP-002',
      user: 'Walker 01',
      subject: 'Walk status issue',
      message: 'Walker reported an issue updating walk status.',
      date: '14 Aug 2026',
      status: 'In Progress',
      type: 'Walker',
    ),
    SupportTicket(
      id: 'SUP-003',
      user: 'Owner 02',
      subject: 'Payment question',
      message: 'Owner requested information about a payment.',
      date: '13 Aug 2026',
      status: 'Resolved',
      type: 'Owner',
    ),
  ];

  List<SupportTicket> get filteredTickets {
    if (selectedFilter == 'All') {
      return tickets;
    }

    return tickets
        .where((ticket) => ticket.status == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final open =
        tickets.where((t) => t.status == 'Open').length;
    final progress =
        tickets.where((t) => t.status == 'In Progress').length;
    final resolved =
        tickets.where((t) => t.status == 'Resolved').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        const SizedBox(height: 20),
        _summary(open, progress, resolved),
        const SizedBox(height: 20),
        _filters(),
        const SizedBox(height: 16),
        _ticketList(),
      ],
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            color: dojoBlack,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Manage DOJO support requests and user tickets',
          style: TextStyle(
            color: dojoGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _summary(int open, int progress, int resolved) {
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
              title: 'Open Tickets',
              value: '$open',
              icon: Icons.support_agent_outlined,
              color: dojoRed,
            ),
            _SummaryCard(
              title: 'In Progress',
              value: '$progress',
              icon: Icons.pending_actions_outlined,
              color: dojoOrange,
            ),
            _SummaryCard(
              title: 'Resolved',
              value: '$resolved',
              icon: Icons.check_circle_outline,
              color: dojoGreen,
            ),
          ],
        );
      },
    );
  }

  Widget _filters() {
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
          _filterButton('Open'),
          _filterButton('In Progress'),
          _filterButton('Resolved'),
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
          horizontal: 14,
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

  Widget _ticketList() {
    final list = filteredTickets;

    if (list.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: list.map((ticket) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ticketCard(ticket),
        );
      }).toList(),
    );
  }

  Widget _ticketCard(SupportTicket ticket) {
    final statusColor = _statusColor(ticket.status);
    final userColor =
        ticket.type == 'Owner' ? dojoBlue : dojoGreen;

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
            return _mobileTicket(
              ticket,
              statusColor,
              userColor,
            );
          }

          return _desktopTicket(
            ticket,
            statusColor,
            userColor,
          );
        },
      ),
    );
  }

  Widget _desktopTicket(
    SupportTicket ticket,
    Color statusColor,
    Color userColor,
  ) {
    return Row(
      children: [
        _ticketIcon(userColor),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: _ticketInfo(ticket),
        ),
        Expanded(
          child: _userInfo(ticket, userColor),
        ),
        _statusChip(ticket.status, statusColor),
        const SizedBox(width: 12),
        _viewButton(ticket),
      ],
    );
  }

  Widget _mobileTicket(
    SupportTicket ticket,
    Color statusColor,
    Color userColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ticketIcon(userColor),
            const SizedBox(width: 12),
            Expanded(child: _ticketInfo(ticket)),
          ],
        ),
        const SizedBox(height: 14),
        _userInfo(ticket, userColor),
        const SizedBox(height: 12),
        Row(
          children: [
            _statusChip(ticket.status, statusColor),
            const Spacer(),
            Text(
              ticket.date,
              style: const TextStyle(
                fontSize: 11,
                color: dojoGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: _viewButton(ticket),
        ),
      ],
    );
  }

  Widget _ticketIcon(Color color) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.support_agent_outlined,
        color: color,
        size: 27,
      ),
    );
  }

  Widget _ticketInfo(SupportTicket ticket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ticket.id,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          ticket.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ticket.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: dojoGrey,
          ),
        ),
      ],
    );
  }

  Widget _userInfo(SupportTicket ticket, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.person_outline,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User',
              style: TextStyle(
                fontSize: 10,
                color: dojoGrey,
              ),
            ),
            Text(
              ticket.user,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
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

  Widget _viewButton(SupportTicket ticket) {
    return OutlinedButton.icon(
      onPressed: () => _showTicket(ticket),
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

  void _showTicket(SupportTicket ticket) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Support Ticket',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('Ticket ID', ticket.id),
              _detail('User', ticket.user),
              _detail('Type', ticket.type),
              _detail('Subject', ticket.subject),
              _detail('Status', ticket.status),
              _detail('Date', ticket.date),
              const SizedBox(height: 8),
              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 11,
                  color: dojoGrey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                ticket.message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            if (ticket.status != 'Resolved')
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ticket action will connect to Firebase.',
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: dojoOrange,
                ),
                child: const Text('Update'),
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
            width: 70,
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
              Icons.support_agent_outlined,
              size: 50,
              color: dojoGrey,
            ),
            SizedBox(height: 12),
            Text(
              'No support tickets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Support requests will appear here.',
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return dojoRed;
      case 'In Progress':
        return dojoOrange;
      case 'Resolved':
        return dojoGreen;
      default:
        return dojoGrey;
    }
  }
}

class SupportTicket {
  final String id;
  final String user;
  final String subject;
  final String message;
  final String date;
  final String status;
  final String type;

  const SupportTicket({
    required this.id,
    required this.user,
    required this.subject,
    required this.message,
    required this.date,
    required this.status,
    required this.type,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
