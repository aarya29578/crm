import 'package:flutter/material.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Persons/add_person_page.dart';
import 'package:crm_flutter/pages/Persons/persons_controller.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/api/response/all_persons_response.dart'
    as personRes;

class PersonsPage extends StatefulWidget {
  const PersonsPage({super.key});

  @override
  State<PersonsPage> createState() => _PersonsPageState();
}

class _PersonsPageState extends State<PersonsPage> {
  final PersonsController pcontroller = Get.put(PersonsController());
  final ScrollController _scrollController = ScrollController();
  final double _cardElevation = 2.0;
  final double _cardMargin = 8.0;
  final double _cardPadding = 16.0;
  final double _avatarRadius = 24.0;

  @override
  void initState() {
    pcontroller.getAllPersons();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => pcontroller.getAllPersons(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddPersonPage(isEdit: false));
        },
        backgroundColor: Colors.blueAccent,
        tooltip: 'Add Person',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(() {
          if (pcontroller.personState.value == PageState.loading) {
            return _buildLoadingState();
          } else if (pcontroller.personState.value == PageState.error) {
            return _buildErrorState();
          } else if (pcontroller.allPersonRes.value.data == null ||
              pcontroller.allPersonRes.value.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            return _buildPersonList();
          }
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading contacts...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load contacts', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => pcontroller.getAllPersons(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No contacts found', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Add new contacts to see them here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonList() {
    return RefreshIndicator(
      onRefresh: () async => await pcontroller.getAllPersons(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: pcontroller.allPersonRes.value.data!.length,
        itemBuilder: (context, index) {
          final person = pcontroller.allPersonRes.value.data![index];
          return Card(
            elevation: _cardElevation,
            color: Colors.white,
            margin: EdgeInsets.all(_cardMargin),
            child: Padding(
              padding: EdgeInsets.all(_cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonHeader(person),
                  const SizedBox(height: 12),
                  if (person.jobTitle != null && person.jobTitle!.isNotEmpty)
                    _buildInfoRow(Icons.work, person.jobTitle!),
                  if (person.emails != null && person.emails!.isNotEmpty)
                    _buildInfoRow(Icons.email, person.emails!.join(', ')),
                  if (person.contactNumbers != null &&
                      person.contactNumbers!.isNotEmpty)
                    _buildInfoRow(
                      Icons.phone,
                      person.contactNumbers!.join(', '),
                    ),
                  if (person.organization != null)
                    _buildOrganizationInfo(person.organization!),
                  const SizedBox(height: 8),
                  _buildMetaInfo(person),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //
  Widget _buildPersonHeader(personRes.Data person) {
    return Row(
      children: [
        // Avatar with person initial
        CircleAvatar(
          radius: _avatarRadius,
          backgroundColor: _getAvatarColor(person.name ?? '?'),
          child: Text(
            person.name?.isNotEmpty == true
                ? person.name![0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Name and organization
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name ?? 'No Name',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (person.organization?.name != null)
                Text(
                  person.organization!.name!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20),
              color: Colors.blue,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Get.to(AddPersonPage(isEdit: true, personData: person));
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete, size: 20),
              color: Colors.red,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _handleDeletePerson(person),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAvatarColor(String name) {
    // Generate consistent color based on name
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final hash = name.hashCode;
    return colors[hash % colors.length].shade400;
  }

  void _handleDeletePerson(personRes.Data person) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${person.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              // Example: pcontroller.deletePerson(person.sId!);
              pcontroller.deletePerson(person.sId!);
              print('Delete person: ${person.name}');
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  //
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildOrganizationInfo(personRes.Organization organization) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 20),
        const Text(
          'Organization',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        if (organization.address != null)
          _buildAddressInfo(organization.address!),
      ],
    );
  }

  Widget _buildAddressInfo(personRes.Address address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.street != null && address.street!.isNotEmpty)
          Text('Street: ${address.street}'),
        if (address.city != null && address.city!.isNotEmpty)
          Text('City: ${address.city}'),
        if (address.state != null && address.state!.isNotEmpty)
          Text('State: ${address.state}'),
        if (address.zip != null && address.zip!.isNotEmpty)
          Text('ZIP: ${address.zip}'),
      ],
    );
  }

  Widget _buildMetaInfo(personRes.Data person) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (person.createdAt != null)
          Text(
            'Created: ${_formatDate(person.createdAt!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        if (person.updatedAt != null)
          Text(
            'Updated: ${_formatDate(person.updatedAt!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
