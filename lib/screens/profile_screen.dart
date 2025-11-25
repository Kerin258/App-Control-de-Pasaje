import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(
    BuildContext context,
    ExpenseProvider provider,
  ) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      provider.updateProfileImage(pickedFile.path);
    }
  }

  ImageProvider? _getImageProvider(String? path) {
    if (path == null) return null;
    if (kIsWeb) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  void _showEditProfileDialog(BuildContext context, ExpenseProvider provider) {
    final nameController = TextEditingController(text: provider.userName);
    final surnameController = TextEditingController(text: provider.userSurname);
    final ageController = TextEditingController(text: provider.userAge);
    int selectedAge = int.tryParse(provider.userAge) ?? 18;
    if (selectedAge < 13) selectedAge = 13;
    if (selectedAge > 99) selectedAge = 99;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Editar Perfil'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: surnameController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 250,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.grey.shade100,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                ageController.text =
                                                    selectedAge.toString();
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Listo',
                                              style: TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: CupertinoPicker(
                                        itemExtent: 32.0,
                                        onSelectedItemChanged: (int index) {
                                          selectedAge = 13 + index;
                                        },
                                        scrollController:
                                            FixedExtentScrollController(
                                              initialItem: selectedAge - 13,
                                            ),
                                        children: List<Widget>.generate(
                                          87, // 99 - 13 + 1
                                          (int index) {
                                            return Center(
                                              child: Text(
                                                '${13 + index}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: ageController,
                            decoration: const InputDecoration(
                              labelText: 'Edad',
                              suffixIcon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.updateUserName(nameController.text);
                      provider.updateUserSurname(surnameController.text);
                      provider.updateUserAge(ageController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(text: provider.budget.toString());
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Presupuesto'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(prefixText: '\$ '),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  final newBudget = double.tryParse(controller.text);
                  if (newBudget != null) {
                    provider.updateBudget(newBudget);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil y Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(context, provider),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple.shade100,
                    backgroundImage: _getImageProvider(
                      provider.profileImagePath,
                    ),
                    child:
                        provider.profileImagePath == null
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.deepPurple,
                            )
                            : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${provider.userName} ${provider.userSurname}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (provider.userAge.isNotEmpty)
            Text(
              '${provider.userAge} años',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          const SizedBox(height: 32),
          ListTile(
            title: const Text('Editar Información Personal'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showEditProfileDialog(context, provider),
          ),
          const Divider(),
          ListTile(
            title: const Text('Editar Presupuesto'),
            subtitle: Text('\$${provider.budget.toStringAsFixed(2)}'),
            trailing: const Icon(Icons.edit),
            onTap: () => _showEditBudgetDialog(context, provider),
          ),
          const Divider(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Modo Oscuro'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
