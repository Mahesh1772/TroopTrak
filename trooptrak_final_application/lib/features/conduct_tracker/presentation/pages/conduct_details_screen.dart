import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/conduct.dart';
import '../providers/conduct_provider.dart';
import 'add_conduct_screen.dart';

class ConductDetailsScreen extends StatelessWidget {
  final String conductId;

  const ConductDetailsScreen({
    super.key,
    required this.conductId,
  });

  void _showDeleteDialog(BuildContext context, String conductId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conduct'),
        content: const Text('Are you sure you want to delete this conduct?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ConductProvider>().deleteConduct(conductId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(BuildContext context, Conduct conductData) {
    return _buildInfoSection(
      context,
      title: 'Participants',
      children: [
        if (conductData.participants.isEmpty)
          const Text('No participants')
        else
          ...conductData.participants.map((participant) => Text(participant)),
      ],
    );
  }

  Widget _buildNonParticipantsSection(BuildContext context, Conduct conductData) {
    return _buildInfoSection(
      context,
      title: 'Non-Participants',
      children: [
        if (conductData.nonParticipants.isEmpty)
          const Text('No non-participants')
        else
          ...conductData.nonParticipants.map((nonParticipant) => Text(nonParticipant)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Conduct>(
      stream: context.read<ConductProvider>().getConductById(conductId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Conduct not found')),
          );
        }

        final conductData = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Conduct Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddConductScreen(conduct: conductData),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteDialog(context, conductData.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  context,
                  title: 'Conduct Information',
                  children: [
                    _buildInfoRow('Name', conductData.conductName),
                    _buildInfoRow('Type', conductData.conductType),
                    _buildInfoRow('Date', conductData.startDate),
                    _buildInfoRow('Time', '${conductData.startTime} - ${conductData.endTime}'),
                  ],
                ),
                _buildParticipantsSection(context, conductData),
                _buildNonParticipantsSection(context, conductData),
              ],
            ),
          ),
        );
      },
    );
  }
}