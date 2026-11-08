import 'dart:convert';

import 'package:customer/util/api.dart';
import 'package:customer/util/dialog_box.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:customer/util/session.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _addressController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final response = await postJson(registerUrl, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
      });
      if (!mounted) return;

      if (response.statusCode == 200) {
        final user = response.body.isEmpty ? null : json.decode(response.body);
        if (user is Map && user['id'] is int) {
          showMessage(context, 'Welcome, ${_nameController.text.trim()}!');
          await startSession(context, user['id']);
          return;
        }
        showMessage(context, 'Registration failed. Please try again.',
            error: true);
      } else if (response.statusCode == 409) {
        showMessage(context, 'An account with this email already exists',
            error: true);
      } else {
        showMessage(context, 'Registration failed (${response.statusCode})',
            error: true);
      }
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool password = false,
    int maxLines = 1,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: password && !_showPassword,
      maxLines: password ? 1 : maxLines,
      minLines: 1,
      autofillHints: autofillHints,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: password
            ? IconButton(
                tooltip: _showPassword ? 'Hide password' : 'Show password',
                icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              )
            : null,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameField = _field(
      controller: _nameController,
      label: 'Name',
      icon: Icons.person_outline,
      autofillHints: const [AutofillHints.name],
      validator: (v) => validateRequired(v, 'name'),
    );
    final emailField = _field(
      controller: _emailController,
      label: 'Email',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: validateEmail,
    );
    final phoneField = _field(
      controller: _phoneController,
      label: 'Phone number',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: validatePhone,
    );
    final passwordField = _field(
      controller: _passwordController,
      label: 'Password',
      icon: Icons.lock_outline,
      password: true,
      autofillHints: const [AutofillHints.newPassword],
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter a password';
        if (v.length < 4) return 'Use at least 4 characters';
        return null;
      },
    );
    final confirmField = _field(
      controller: _confirmPasswordController,
      label: 'Confirm password',
      icon: Icons.lock_outline,
      password: true,
      validator: (v) =>
          v != _passwordController.text ? 'Passwords do not match' : null,
    );
    final addressField = _field(
      controller: _addressController,
      label: 'Address',
      icon: Icons.home_outlined,
      keyboardType: TextInputType.streetAddress,
      maxLines: 3,
      autofillHints: const [AutofillHints.fullStreetAddress],
      validator: (v) => validateRequired(v, 'address'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: MaxWidth(
              maxWidth: 720,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: AutofillGroup(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Two columns of fields when there's room.
                          final twoCols = constraints.maxWidth >= 560;
                          Widget pair(Widget a, Widget b) => twoCols
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: a),
                                    const SizedBox(width: 16),
                                    Expanded(child: b),
                                  ],
                                )
                              : Column(children: [
                                  a,
                                  const SizedBox(height: 16),
                                  b,
                                ]);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Create your account',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              pair(nameField, emailField),
                              const SizedBox(height: 16),
                              pair(phoneField, addressField),
                              const SizedBox(height: 16),
                              pair(passwordField, confirmField),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                  onPressed: _loading ? null : _register,
                                  style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red[700]),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white),
                                        )
                                      : const Text('Register',
                                          style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                    'Already have an account? Login'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
