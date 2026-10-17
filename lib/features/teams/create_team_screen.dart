import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'teams_service.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await TeamsService.createTeam(
        name: _nameController.text,
        description: _descriptionController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your team has been created.'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a team'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppTheme.primaryColor,
                  size: 52,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bring your people together.',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your team, invite people, and compete together.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nameController,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Team name',
                  hintText: 'e.g. The Innovators',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.length < 2) {
                    return 'Enter a team name with at least 2 characters.';
                  }

                  if (name.length > 100) {
                    return 'Team names cannot exceed 100 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What is your team about?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppTheme.secondaryColor,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your account becomes the team owner. '
                          'Starter teams support up to 10 active members.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _createTeam,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(
                    _isSaving ? 'Creating team...' : 'Create team',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}