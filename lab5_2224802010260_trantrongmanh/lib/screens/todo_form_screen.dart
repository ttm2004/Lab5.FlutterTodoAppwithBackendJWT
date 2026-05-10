import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';

class TodoFormScreen extends StatefulWidget {
  final TodoModel? todo; // null = create, non-null = edit

  const TodoFormScreen({super.key, this.todo});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late bool _isCompleted;
  bool _isLoading = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.todo?.title ?? '');
    _descCtrl = TextEditingController(text: widget.todo?.description ?? '');
    _isCompleted = widget.todo?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<TodoProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateTodo(
        widget.todo!.id!,
        _titleCtrl.text.trim(),
        _descCtrl.text.trim(),
        _isCompleted,
      );
    } else {
      success = await provider.createTodo(
        _titleCtrl.text.trim(),
        _descCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_isEditing ? 'Cập nhật thành công!' : 'Tạo todo thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEditing ? 'Chỉnh sửa Todo' : 'Thêm Todo mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text('Tiêu đề',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleCtrl,
                    maxLength: 100,
                    decoration: _inputDecoration(
                        'Nhập tiêu đề công việc...', Icons.title),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Vui lòng nhập tiêu đề';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Mô tả',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: _inputDecoration(
                        'Nhập mô tả chi tiết...', Icons.description_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Vui lòng nhập mô tả';
                      }
                      return null;
                    },
                  ),

                  // Completed toggle (only when editing)
                  if (_isEditing) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: SwitchListTile(
                        title: const Text('Đã hoàn thành',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          _isCompleted ? 'Công việc đã xong' : 'Đang thực hiện',
                          style: TextStyle(
                              color: _isCompleted ? Colors.green : Colors.orange,
                              fontSize: 12),
                        ),
                        value: _isCompleted,
                        activeColor: Colors.deepPurple,
                        onChanged: (v) => setState(() => _isCompleted = v),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Icon(_isEditing ? Icons.save : Icons.add),
                      label: Text(
                        _isEditing ? 'Lưu thay đổi' : 'Tạo Todo',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
    );
  }
}
