import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const SignUpScreen(),
    );
  }
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  int _passwordLength = 0;
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm, _birthText]) {
      controller.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _done = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account created')));
    }
  }

  Future<void> _pickBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    if (mounted == false) return;
    setState(() {
      _birth = date;
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      _birthText.text = '$day.$month.${date.year}';
    });
  }

  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthText.clear();
      _passwordLength = 0;
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SafeArea(
        child: _done
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SummaryCard(
                      name: _name.text.trim(),
                      email: _email.text.trim(),
                      group: _group ?? '',
                      birthDate: _birthText.text,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _startOver,
                      child: const Text('Start over'),
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Name'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (value) {
                          if ((value ?? '').trim().length < 2) {
                            return 'Name is too short';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        focusNode: _emailFocus,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'name@kbtu.kz',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          final at = text.indexOf('@');
                          if (at < 0 || text.indexOf('.', at + 1) < 0) {
                            return 'Email looks wrong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          helperText: 'At least 8 characters',
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) =>
                            setState(() => _passwordLength = value.length),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (value) {
                          if ((value ?? '').length < 8) {
                            return 'Password is too short';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_passwordLength of 8',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirm,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: _agreed ? (_) => _signUp() : null,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (value) {
                          if ((value ?? '').isEmpty) {
                            return 'Confirm your password';
                          }
                          if (value != _password.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _group,
                        decoration: const InputDecoration(labelText: 'Group'),
                        items: [
                          for (final group in groups)
                            DropdownMenuItem(value: group, child: Text(group)),
                        ],
                        onChanged: (value) => setState(() => _group = value),
                        validator: (group) =>
                            group == null ? 'Choose a group' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _birthText,
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: _pickBirth,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        validator: (_) =>
                            _birth == null ? 'Choose a birth date' : null,
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('I agree to the rules'),
                        value: _agreed,
                        onChanged: (value) =>
                            setState(() => _agreed = value ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _agreed ? _signUp : null,
                        child: const Text('Sign up'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
