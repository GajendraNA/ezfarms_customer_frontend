import 'dart:convert';

import 'package:customer/pages/register_page.dart';
import 'package:customer/util/api.dart';
import 'package:customer/util/dialog_box.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:customer/util/session.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final response = await postJson(loginUrl, {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });
      if (!mounted) return;

      switch (response.statusCode) {
        case 200:
          final user = response.body.isEmpty ? null : json.decode(response.body);
          if (user is Map && user['id'] is int) {
            await startSession(context, user['id']);
            return;
          }
          showMessage(context, 'Invalid credentials', error: true);
        case 401:
          showMessage(context, "Email and password don't match", error: true);
        case 400:
          showMessage(context, 'No account found for this email', error: true);
        default:
          showMessage(context, 'Login failed (${response.statusCode})',
              error: true);
      }
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> _editServer() async {
    final url = TextEditingController(text: serverUrl);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server address'),
        content: TextField(
          controller: url,
          decoration: const InputDecoration(
            labelText: 'Server URL',
            hintText: 'https://example.com or 192.168.1.5:8080',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => url.text = defaultServerUrl,
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == true && url.text.trim().isNotEmpty) {
      await saveServerAddress(url.text);
      if (mounted) showMessage(context, 'Server set to $serverUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: MaxWidth(
                  maxWidth: 420,
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.storefront,
                                  size: 56, color: Colors.red[700]),
                              const SizedBox(height: 8),
                              const Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24.0),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: validateEmail,
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _checkLogin(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _showPassword
                                        ? 'Hide password'
                                        : 'Show password',
                                    icon: Icon(_showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () => setState(
                                        () => _showPassword = !_showPassword),
                                  ),
                                ),
                                validator: (v) => validateRequired(v, 'password'),
                              ),
                              const SizedBox(height: 24.0),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                  onPressed: _loading ? null : _checkLogin,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white),
                                        )
                                      : const Text('Login',
                                          style: TextStyle(fontSize: 16)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text("Don't have an account?"),
                                  TextButton(
                                    onPressed: _loading ? null : _register,
                                    child: const Text('Register'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Server address',
                icon: const Icon(Icons.settings_ethernet),
                onPressed: _editServer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
