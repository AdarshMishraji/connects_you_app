// import 'package:connects_you/models/user.dart';
// import 'package:connects_you/providers/auth.dart';
import 'package:connects_you/screens/main/screens/users/userRow.dart';
// import 'package:connects_you/server/server.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  static const String routeName = '/users';

  const UsersScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with AutomaticKeepAliveClientMixin<UsersScreen> {
  bool _showSearchBox = false;
  // List<User>? _users;
  // final Map<String, User> _selectedUsers = {};
  List<dynamic>? _users;
  final Map<String, dynamic> _selectedUsers = {};

  Future _fetchAllUsers() async {
    const token = "";
    // Provider.of<Auth>(context, listen: false).authenticatedUser?.token;
    if (token != null) {
      dynamic serverUsers;
      // Response<List<User>?>? serverUsers =
      //     await Server.DetailsOps.getAllUsers(token);
      if (serverUsers!.response != null) {
        setState(() {
          _users = serverUsers.response!;
          _selectedUsers.clear();
        });
      } else {
        setState(() {
          _users = [];
          _selectedUsers.clear();
        });
        debugPrint('no _users');
      }
    } else {
      debugPrint('no token');
    }
  }

  _onTap(int index, [bool preSelectedMode = false]) {
    if (preSelectedMode || _selectedUsers.isNotEmpty) {
      final user = _users![index];
      final isExists = _selectedUsers.containsKey(user.userId);
      setState(() {
        if (isExists) {
          _selectedUsers.remove(user.userId);
        } else {
          _selectedUsers[user.userId] = user;
        }
      });
    } else {
      // join or create room
    }
  }

  _onLongPress(int index) {
    _onTap(index, true);
  }

  @override
  void initState() {
    _fetchAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _selectedUsers.isNotEmpty
            ? Text(_selectedUsers.length.toString())
            : _showSearchBox
                ? TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      icon: IconButton(
                          icon: Icon(Icons.search_rounded,
                              color: theme.primaryColor, size: 32),
                          onPressed: () {}),
                    ),
                  )
                : const Text(
                    'Users',
                  ),
        actions: [
          if (!_showSearchBox && _selectedUsers.isEmpty)
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: theme.primaryColor,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  _showSearchBox = true;
                });
              },
            ),
          if (_selectedUsers.length > 1)
            IconButton(
              icon: Icon(
                Icons.group_add_rounded,
                color: theme.primaryColor,
                size: 32,
              ),
              onPressed: () {
                // handler for creating groups
              },
            ),
          if (_selectedUsers.isNotEmpty || _showSearchBox)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: theme.primaryColor,
                size: 32,
              ),
              onPressed: () {
                setState(() {
                  _selectedUsers.clear();
                  _showSearchBox = false;
                });
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllUsers,
        child: _users == null || _users!.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Image.asset(
                  'assets/gifs/empty.gif',
                  height: mediaQuery.size.height * 0.75,
                ),
              )
            : ListView.builder(
                itemCount: _users!.length,
                itemBuilder: (ctx, index) {
                  return UserRow(
                    user: _users![index],
                    onLongPress: () => _onLongPress(index),
                    onTap: () => _onTap(index),
                    isSelected:
                        _selectedUsers.containsKey(_users![index].userId),
                  );
                },
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
