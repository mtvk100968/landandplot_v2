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
  AgentProfileState createState() => AgentProfileState();
}

class AgentProfileState extends State<AgentProfile> {
  late AppUser _agentUser;
  late Future<List<Property>> _findBuyerFuture;
  late Future<List<Property>> _inProgressFuture;
  bool _showAllAreas = false;

  @override
  void initState() {
    super.initState();

    // 1) Grab the passed-in user
    _agentUser = widget.appUser;

    // 2) Initialize your futures immediately so they're never null
    _loadProperties();

    // 3) After the first frame, check name/email/areas and show setup dialog if needed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_agentUser.name == null ||
          _agentUser.email == null ||
          _agentUser.agentAreas.isEmpty) {
        final updated = await showDialog<AppUser>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AgentProfileSetupDialog(user: _agentUser),
        );
        if (updated != null) {
          _agentUser = updated;
          _loadProperties(); // reload with the (possibly new) UID
          setState(() {});
        }
      }
    });
  }

  void _loadProperties() {
    final svc = AgentService();
    setState(() {
      _findBuyerFuture = svc.getFindBuyerProperties(_agentUser.uid);
      _inProgressFuture = svc.getSalesInProgressProperties(_agentUser.uid);
    });
  }

  Widget _buildFindBuyerList(List<Property> list) {
    final finding = list.where((p) => p.stage == 'findingBuyers').toList();
    final inProgress = list.where((p) => p.stage == 'saleInProgress').toList();
    final sorted = [...finding, ...inProgress];

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (ctx, i) => AgentPropertyCard(
        property: sorted[i],
        currentAgentId: _agentUser.uid,
        onBuyerUpdated: _loadProperties,
        hideTimelineInFind:
            true, // ← tell the card to never show the timeline here
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: widget.onSignOut,
                    child: const Text('Logout'),
                  ),
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
                        _buildFindBuyerList(s1.data!),
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

  Widget _buildAgentDetails() {
    final areas = _agentUser.agentAreas;
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
              Text(
                _agentUser.name ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (_agentUser.email != null)
                Text(
                  _agentUser.email!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              const SizedBox(height: 2),
              Text(
                _agentUser.phoneNumber ?? '',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // scrollable, toggleable chip list
              Container(
                constraints: BoxConstraints(
                  maxHeight: _showAllAreas ? 150 : 70,
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: areas.map((a) => Chip(label: Text(a))).toList(),
                  ),
                ),
              ),

              if (areas.length > 5)
                TextButton(
                  onPressed: () =>
                      setState(() => _showAllAreas = !_showAllAreas),
                  child: Text(_showAllAreas ? 'Show less' : 'Show more'),
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
        onBuyerUpdated: _loadProperties,
      ),
    );
  }
}
