import 'package:compudecsi/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:compudecsi/services/category_service.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final categoriesData = await CategoryService.getCategories();
      setState(() {
        categories = categoriesData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar categorias: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String selectedIcon = 'category';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicionar Categoria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                      hintText: 'Ex: Inteligência Artificial',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: 'Valor (slug)',
                      hintText: 'Ex: ai',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIcon,
                    decoration: const InputDecoration(labelText: 'Ícone'),
                    items: [
                      DropdownMenuItem(
                        value: 'category',
                        child: Text('Categoria'),
                      ),
                      DropdownMenuItem(
                        value: 'analytics',
                        child: Text('Analytics'),
                      ),
                      DropdownMenuItem(
                        value: 'security',
                        child: Text('Security'),
                      ),
                      DropdownMenuItem(
                        value: 'smart_toy',
                        child: Text('Smart Toy'),
                      ),
                      DropdownMenuItem(
                        value: 'psychology',
                        child: Text('Psychology'),
                      ),
                      DropdownMenuItem(value: 'code', child: Text('Code')),
                      DropdownMenuItem(
                        value: 'computer',
                        child: Text('Computer'),
                      ),
                      DropdownMenuItem(
                        value: 'electric_bolt',
                        child: Text('Electric Bolt'),
                      ),
                      DropdownMenuItem(
                        value: 'signal_cellular_alt',
                        child: Text('Signal'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedIcon = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        valueController.text.isNotEmpty) {
                      final success = await CategoryService.addCategory(
                        name: nameController.text,
                        value: valueController.text,
                        icon: selectedIcon,
                      );

                      if (success) {
                        Navigator.of(context).pop();
                        _loadCategories();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Categoria adicionada com sucesso!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erro ao adicionar categoria'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    final nameController = TextEditingController(text: category['name']);
    final valueController = TextEditingController(text: category['value']);
    String selectedIcon = category['icon'] ?? 'category';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Categoria'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: 'Valor (slug)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIcon,
                    decoration: const InputDecoration(labelText: 'Ícone'),
                    items: [
                      DropdownMenuItem(
                        value: 'category',
                        child: Text('Categoria'),
                      ),
                      DropdownMenuItem(
                        value: 'analytics',
                        child: Text('Analytics'),
                      ),
                      DropdownMenuItem(
                        value: 'security',
                        child: Text('Security'),
                      ),
                      DropdownMenuItem(
                        value: 'smart_toy',
                        child: Text('Smart Toy'),
                      ),
                      DropdownMenuItem(
                        value: 'psychology',
                        child: Text('Psychology'),
                      ),
                      DropdownMenuItem(value: 'code', child: Text('Code')),
                      DropdownMenuItem(
                        value: 'computer',
                        child: Text('Computer'),
                      ),
                      DropdownMenuItem(
                        value: 'electric_bolt',
                        child: Text('Electric Bolt'),
                      ),
                      DropdownMenuItem(
                        value: 'signal_cellular_alt',
                        child: Text('Signal'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedIcon = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        valueController.text.isNotEmpty) {
                      final success = await CategoryService.updateCategory(
                        id: category['id'],
                        name: nameController.text,
                        value: valueController.text,
                        icon: selectedIcon,
                      );

                      if (success) {
                        Navigator.of(context).pop();
                        _loadCategories();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Categoria atualizada com sucesso!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erro ao atualizar categoria'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir a categoria "${category['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await CategoryService.deleteCategory(
                  category['id'],
                );

                if (success) {
                  Navigator.of(context).pop();
                  _loadCategories();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categoria excluída com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao excluir categoria'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: context.customBorder, height: 1.0),
        ),
      ),
      body: Container(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: Icon(_getIconForCategory(category['icon'])),
                    title: Text(category['name']),
                    subtitle: Text('Valor: ${category['value']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditCategoryDialog(category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(category),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'analytics':
        return Icons.analytics;
      case 'security':
        return Icons.security;
      case 'smart_toy':
        return Icons.smart_toy;
      case 'psychology':
        return Icons.psychology;
      case 'code':
        return Icons.code;
      case 'computer':
        return Icons.computer;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'signal_cellular_alt':
        return Icons.signal_cellular_alt;
      default:
        return Icons.category;
    }
  }
}
