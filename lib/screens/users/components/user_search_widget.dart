import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

import '../../../api/api.dart'; // Убедись, что путь корректен

class UserSearchWidget extends StatefulWidget {
  final void Function(Map<String, dynamic> user) onSelected;
  final Map<String, dynamic>? initialUser;

  const UserSearchWidget({
    super.key,
    required this.onSelected,
    this.initialUser,
  });

  @override
  State<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends State<UserSearchWidget> {
  final TextEditingController _userController = TextEditingController();
  Timer? _debounce;
  List<dynamic> _searchedUsers = [];
  bool _isLoading = false;
  bool _userSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _userSelected = true;
      _userController.text = widget.initialUser?['email'] ?? '';
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _userSelected = false;
    });

    if (value.trim().length < 3) {
      setState(() {
        _searchedUsers = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(value.trim());
    });
  }

  Future<void> _searchUsers(String email) async {
    try {
      final res = await ApiClient.get('api/admin/users/search/$email');
      log(res.toString());
      if (res['success']) {
        setState(() {
          _searchedUsers = res['data'];
        });
      } else {
        setState(() {
          _searchedUsers = [];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load users.')),
          );
        });
      }
    } catch (e) {
      log('Error searching users: $e');
      setState(() {
        _searchedUsers = [];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during search.')),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onUserTap(Map<String, dynamic> user) {
    widget.onSelected(user);
    _userController.text = user['email'];
    setState(() {
      _searchedUsers = [];
      _userSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _userController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: 'Найти пользователя по email...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.blueAccent,
                  width: 2,
                ),
              ),
              suffixIcon:
                  _isLoading
                      ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      : null,
            ),
            onChanged: _onEmailChanged,
          ),
        ),
        const SizedBox(height: 16),
        if (_searchedUsers.isNotEmpty && !_userSelected)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: _searchedUsers.length,
              itemBuilder: (context, index) {
                final user = _searchedUsers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onUserTap(user),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: Colors.blueAccent.withOpacity(0.1),
                      highlightColor: Colors.blueAccent.withOpacity(0.05),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['email'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ID: ${user['_id']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else if (_userController.text.isNotEmpty &&
            !_isLoading &&
            _searchedUsers.isEmpty &&
            !_userSelected)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Не найдено: "${_userController.text}"',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else if (_userSelected)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Выбранный пользователь: "${_userController.text}"',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
