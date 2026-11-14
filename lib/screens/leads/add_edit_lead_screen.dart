import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/validators.dart';
import '../../models/lead_model.dart';
import '../../providers/lead_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class AddEditLeadScreen extends StatefulWidget {
  const AddEditLeadScreen({super.key, this.lead});

  final LeadModel? lead;

  bool get isEdit => lead != null;

  @override
  State<AddEditLeadScreen> createState() => _AddEditLeadScreenState();
}

class _AddEditLeadScreenState extends State<AddEditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyController;
  String _source = kLeadSources.first;
  String _status = 'New';
  bool _saving = false;
  String? _phoneDuplicateError;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;
    _nameController = TextEditingController(text: lead?.name ?? '');
    _phoneController = TextEditingController(text: lead?.phone ?? '');
    _emailController = TextEditingController(text: lead?.email ?? '');
    _companyController = TextEditingController(text: lead?.company ?? '');
    _source = lead?.source ?? kLeadSources.first;
    _status = lead?.status ?? 'New';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  bool _isDuplicatePhone(String phone) {
    final provider = context.read<LeadProvider>();
    return provider.allLeads.any((l) {
      if (widget.isEdit && l.id == widget.lead!.id) return false;
      return l.phone == phone;
    });
  }

  Future<void> _save() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _phoneDuplicateError = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    if (_isDuplicatePhone(phone)) {
      setState(() {
        _phoneDuplicateError = 'A lead with this phone already exists';
      });
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<LeadProvider>();
    final userId = provider.currentUserId ?? '';

    try {
      if (widget.isEdit) {
        final updated = widget.lead!.copyWith(
          name: _nameController.text.trim(),
          phone: phone,
          email: _emailController.text.trim(),
          company: _companyController.text.trim(),
          source: _source,
          status: _status,
          updatedAt: DateTime.now(),
        );
        await provider.updateLead(updated);
      } else {
        final now = DateTime.now();
        final lead = LeadModel(
          id: '', // provider will assign
          userId: userId,
          name: _nameController.text.trim(),
          phone: phone,
          email: _emailController.text.trim(),
          company: _companyController.text.trim(),
          source: _source,
          status: _status,
          isFromApi: false,
          createdAt: now,
          updatedAt: now,
        );
        final ok = await provider.addLead(lead);
        if (!ok) {
          if (!mounted) return;
          setState(() {
            _saving = false;
            _phoneDuplicateError =
                provider.errorMessage ??
                'A lead with this phone already exists';
          });
          return;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdit ? 'Lead updated' : 'Lead added')),
      );
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? 'Edit lead' : 'Add lead')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Name *',
                  prefixIcon: Icons.person_outline,
                  validator: nameValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Phone *',
                    hintText: '10-digit mobile number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    counterText: '',
                    errorText: _phoneDuplicateError,
                  ),
                  validator: phoneValidator,
                  onChanged: (_) {
                    if (_phoneDuplicateError != null) {
                      setState(() => _phoneDuplicateError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: 'Email (optional)',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: emailValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _companyController,
                  label: 'Company (optional)',
                  prefixIcon: Icons.business_outlined,
                  validator: companyValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _source,
                  decoration: const InputDecoration(
                    labelText: 'Source *',
                    prefixIcon: Icon(Icons.source_outlined),
                  ),
                  items: kLeadSources
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _source = v ?? _source),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status *',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: kLeadStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: _save,
                  label: widget.isEdit ? 'Save changes' : 'Save lead',
                  isLoading: _saving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
