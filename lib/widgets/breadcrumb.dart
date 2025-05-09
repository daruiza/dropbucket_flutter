// Implementación del widget Breadcrumb
import 'package:dropbucket_flutter/models/user_response.dart';
import 'package:dropbucket_flutter/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Breadcrumb extends StatefulWidget {
  // final List<String> path;
  // final Function(int)? onPathItemTap;
  final Function fetchItemsList;
  final Color primaryColor;
  final Color hoverColor;
  final Color iconColor;
  final double fontSize;

  const Breadcrumb({
    super.key,
    // required this.path,
    // this.onPathItemTap
    required this.fetchItemsList,
    required this.primaryColor,
    required this.hoverColor,
    required this.iconColor,
    required this.fontSize,
  });

  @override
  State<Breadcrumb> createState() => _BreadcrumbState();
}

class _BreadcrumbState extends State<Breadcrumb> {
  late List<bool> isHovering;
  late List<String> prefixCurrent;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    prefixCurrent = getPrefixList(authProvider.user);
    prefixCurrent.insert(0, 'Inicio');
    isHovering = List.generate(prefixCurrent.length, (_) => false);
  }

  @override
  void didUpdateWidget(covariant Breadcrumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final newPrefixCurrent = getPrefixList(authProvider.user);
    newPrefixCurrent.insert(0, 'Inicio');
    if (newPrefixCurrent.length != prefixCurrent.length) {
      isHovering = List.generate(newPrefixCurrent.length, (_) => false);
    }
    prefixCurrent = newPrefixCurrent;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        // Asegura que el contenedor permita el scroll
        constraints: BoxConstraints(maxWidth: double.infinity),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.start, // Evita centrar los items
            children: List.generate(prefixCurrent.length, (index) {
              final isLast = index == prefixCurrent.length - 1;
              return Row(
                children: [
                  MouseRegion(
                    onEnter:
                        (_) => setState(() {
                          isHovering[index] = true;
                        }),
                    onExit:
                        (_) => setState(() {
                          isHovering[index] = false;
                        }),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        onGoPrefix(context, index, () {
                          widget.fetchItemsList.call();
                        });
                      },
                      child:
                          index == 0
                              ? Icon(
                                Icons.home,
                                size: widget.fontSize + 8,
                                color:
                                    isHovering[index]
                                        ? widget.hoverColor
                                        : widget.primaryColor,
                              )
                              : Text(
                                prefixCurrent[index],
                                style: TextStyle(
                                  color:
                                      isHovering[index]
                                          ? widget.hoverColor
                                          : widget.primaryColor,
                                  // fontWeight: FontWeight.normal,
                                  fontSize: widget.fontSize,
                                ),
                              ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(
                        Icons.chevron_right,
                        size: widget.fontSize + 8,
                        color: widget.iconColor,
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

List<String> getPrefixList(UserResponse? user) {  
  if (user?.prefixcurrent == null || user?.prefixcurrent == '') {
    return [];
  }
  String currentPrefix = user?.prefixcurrent ?? '';  
  String userPrefix = user?.prefix ?? ' ';
  try {    
    String withoutPrefix = currentPrefix.replaceAll(userPrefix, '');    
    List<String> result = withoutPrefix.trim().split('/');    
    return result.where((element) => element.isNotEmpty).toList();
  } catch (e) {    
    return [];
  }
}

onGoPrefix(BuildContext context, prefix, Function fetchItemsList) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final user = authProvider.user;
  if (user == null) return;

  final userprefix = user.prefix ?? '';
  final prefixcurrent =
      '/${user.prefixcurrent?.replaceAll(userprefix, '') ?? ''}';

  final parts = prefixcurrent.split('/');
  if (prefix + 1 > parts.length) return;

  String resultado = parts
      .sublist(0, prefix + 1)
      .join('/')
      .replaceFirst('/', '');

  try {
    final currentPrefix = user.prefixcurrent?.replaceAll(userprefix, '');
    if (currentPrefix == null) return;

    if ('$resultado/' != currentPrefix && resultado != currentPrefix) {
      await authProvider.setUserPrefix(
        context,
        resultado.isEmpty ? userprefix : '$userprefix$resultado/',
        true,
      );
      await fetchItemsList();
    }
  } finally {}
}
