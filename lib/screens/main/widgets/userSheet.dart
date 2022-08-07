import 'package:connects_you/constants/widget.dart';
import 'package:flutter/material.dart';

class UserSheet extends StatelessWidget {
  final VoidCallback onClose;
  const UserSheet({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Container(
      color: Colors.transparent,
      height: mediaQuery.size.height * 0.9,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: _Header(
          onClose: onClose,
        ),
        body: ColoredBox(
          color: theme.backgroundColor,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget with PreferredSizeWidget {
  final VoidCallback onClose;
  const _Header({Key? key, required this.onClose}) : super(key: key);

  @override
  State<_Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size(double.infinity, 100);
}

class _HeaderState extends State<_Header> {
  bool _showSearchBox = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return PreferredSize(
      preferredSize: Size(mediaQuery.size.width, 100),
      child: Container(
        color: theme.appBarTheme.backgroundColor,
        padding: const EdgeInsets.only(
          left: WidgetConstants.spacing_sm,
          right: WidgetConstants.spacing_sm,
          top: WidgetConstants.spacing_s,
          bottom: WidgetConstants.spacing_sm,
        ),
        width: mediaQuery.size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _showSearchBox
                ? Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        icon: IconButton(
                            icon: Icon(Icons.search_rounded,
                                color: theme.primaryColor, size: 32),
                            onPressed: () {}),
                      ),
                    ),
                  )
                : Text(
                    'Users',
                    style: theme.textTheme.titleLarge!.copyWith(fontSize: 24),
                  ),
            Row(
              children: [
                if (!_showSearchBox)
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
                if (!_showSearchBox)
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: theme.primaryColor,
                      size: 32,
                    ),
                    onPressed: () {},
                  ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.primaryColor,
                    size: 32,
                  ),
                  onPressed: () {
                    if (!_showSearchBox) {
                      widget.onClose();
                    }
                    setState(() {
                      _showSearchBox = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
