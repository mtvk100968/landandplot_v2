import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../../../models/user_model.dart';
import '../../../services/agent_service.dart';
import '../../../services/user_service.dart';
import './mini-components/setup_dialog.dart';
import 'agent_property_card.dart';

class AgentProfile extends StatefulWidget {
  final AppUser appUser;
  final TabController tabController;
  final VoidCallback onSignOut;

  const AgentProfile({
    Key? key,
    required this.appUser,
    required this.tabController,
    required this.onSignOut,
  }) : super(key: key);

  @override
  _AgentProfileState createState() => _AgentProfileState();
}

class _AgentProfileState extends State<AgentProfile> {
  late AppUser _agentUser;
  late Future<List<Property>> _findBuyerFuture;
  late Future<List<Property>> _inProgressFuture;

  @override
  void initState() {
    super.initState();
    _agentUser = widget.appUser;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_agentUser.name == null ||
          _agentUser.phoneNumber == null ||
          _agentUser.agentAreas.isEmpty) {
        final updated = await showDialog<AppUser>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AgentProfileSetupDialog(user: _agentUser),
        );
        if (updated != null) _agentUser = updated;
      }
      _loadProperties();
      setState(() {});
    });
  }

  void _loadProperties() {
    final svc = AgentService();
    _findBuyerFuture = svc.getFindBuyerProperties(_agentUser.uid);
    _inProgressFuture = svc.getSalesInProgressProperties(_agentUser.uid);
  }

  Widget _buildAgentDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_agentUser.name ?? '',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              if (_agentUser.email != null)
                Text(_agentUser.email!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(_agentUser.phoneNumber ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _agentUser.agentAreas
                    .map((a) => Chip(label: Text(a)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyList(List<Property> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) => AgentPropertyCard(
        property: list[i],
        currentAgentId: _agentUser.uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_findBuyerFuture == null || _inProgressFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Property>>(
      future: _findBuyerFuture,
      builder: (c1, s1) {
        if (s1.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return FutureBuilder<List<Property>>(
          future: _inProgressFuture,
          builder: (c2, s2) {
            if (s2.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Agent Profile'),
                actions: [
                  TextButton(
                      onPressed: widget.onSignOut, child: const Text('Logout')),
                ],
              ),
              body: Column(
                children: [
                  _buildAgentDetails(),
                  TabBar(
                    controller: widget.tabController,
                    tabs: const [
                      Tab(text: 'Find Buyers'),
                      Tab(text: 'Sales In Progress'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: widget.tabController,
                      children: [
                        _buildPropertyList(s1.data!),
                        _buildPropertyList(s2.data!),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
