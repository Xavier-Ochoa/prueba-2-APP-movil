import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/item_coleccion.dart';
import '../../providers/collection_provider.dart';
import '../../utils/constants.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _imagenCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String _categoria = AppConstants.categorias.first;
  String _plataforma = AppConstants.plataformas.first;
  bool _isEditing = false;
  bool _saving = false;
  ItemColeccion? _editItem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ItemColeccion && !_isEditing) {
      _editItem = arg;
      _isEditing = true;
      _tituloCtrl.text = arg.titulo;
      _precioCtrl.text = arg.precio.toString();
      _stockCtrl.text = arg.stock.toString();
      _imagenCtrl.text = arg.imagen;
      _descripcionCtrl.text = arg.descripcion;
      _categoria = AppConstants.categorias.contains(arg.categoria)
          ? arg.categoria
          : AppConstants.categorias.first;
      _plataforma = AppConstants.plataformas.contains(arg.plataforma)
          ? arg.plataforma
          : AppConstants.plataformas.first;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _imagenCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final item = ItemColeccion(
      id: _isEditing ? _editItem!.id : const Uuid().v4(),
      titulo: _tituloCtrl.text.trim(),
      categoria: _categoria,
      plataforma: _plataforma,
      precio: double.tryParse(_precioCtrl.text) ?? 0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      imagen: _imagenCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      fuente: _isEditing ? _editItem!.fuente : 'manual',
    );

    final provider = context.read<CollectionProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateItem(item.id, item);
    } else {
      success = await provider.createItem(item);
    }

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? (_isEditing ? '✅ Item actualizado exitosamente' : '✅ Item creado exitosamente')
              : '❌ ${provider.error ?? "Error desconocido"}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Item' : 'Nuevo Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview imagen
            if (_imagenCtrl.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imagenCtrl.text,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            _buildSection('Información básica'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'El título es requerido' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _plataforma,
              decoration: const InputDecoration(
                labelText: 'Plataforma *',
                prefixIcon: Icon(Icons.devices_outlined),
              ),
              items: AppConstants.plataformas
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _plataforma = v!),
            ),
            const SizedBox(height: 24),

            _buildSection('Precio y stock'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (double.tryParse(v) == null) return 'Número inválido';
                      if (double.parse(v) < 0) return 'Debe ser ≥ 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Stock *',
                      prefixIcon: Icon(Icons.inventory_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (int.tryParse(v) == null) return 'Número entero';
                      if (int.parse(v) < 0) return 'Debe ser ≥ 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection('Multimedia y descripción'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _imagenCtrl,
              decoration: const InputDecoration(
                labelText: 'URL de imagen',
                prefixIcon: Icon(Icons.image_outlined),
                hintText: 'https://...',
              ),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(_isEditing ? Icons.save_outlined : Icons.add_circle_outline),
                label: Text(_saving
                    ? 'Guardando...'
                    : (_isEditing ? 'Guardar cambios' : 'Crear item')),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}