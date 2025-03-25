import 'package:dropbucket_flutter/enums/http_status_code.dart';
import 'package:dropbucket_flutter/enums/http_status_icon.dart';
import 'package:dropbucket_flutter/utils/message.dart';
import 'package:flutter/material.dart';

class MessageSnackBar extends SnackBar {
  MessageSnackBar({
    super.key,
    required BuildContext context,
    required Message? message,
    super.duration,
  }) : super(
         backgroundColor: HttpStatusColor.getColor(message?.statusCode ?? 500),
         content: Builder(
           builder: (context) {
             return SizedBox(
               width: double.infinity,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Expanded(
                         child: Row(
                           children: [
                             Icon(
                               HttpStatusIcon.getIcon(message?.statusCode ?? 500),
                               color: Colors.white,
                             ),
                             const SizedBox(width: 8),
                             Expanded(
                               child: Text(
                                 message?.message ?? 'Error',
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                           ],
                         ),
                       ),
                       TextButton(
                         onPressed: () {
                           ScaffoldMessenger.of(context).hideCurrentSnackBar();
                         },
                         child: const Text(
                           'Cerrar',
                           style: TextStyle(color: Colors.white),
                         ),
                       ),
                     ],
                   ),
                   if (message?.messages != null)
                    SingleChildScrollView(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children:
                             message!.messages
                                 .map(
                                   (msg) => Padding(
                                     padding: const EdgeInsets.only(top: 4.0),
                                     child: Text(msg.toString()),
                                   ),
                                 )
                                 .toList(),
                       ),
                     ),
                    //  ...message?.messages.map(
                    //        (msg) => Text(
                    //          msg.toString(),
                    //          overflow: TextOverflow.ellipsis,
                    //        ),
                    //      ) ??
                    //      [],
                 ],
               ),
             );
           },
         ),
       );
}
