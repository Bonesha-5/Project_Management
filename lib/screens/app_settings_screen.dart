import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AppSettingsScreen extends StatefulWidget {
  final VoidCallback onToggle;
  final bool isDark;
  const AppSettingsScreen({super.key, required this.onToggle, required this.isDark});
  @override State<AppSettingsScreen> createState()=>_AppSettingsScreenState();
}
class _AppSettingsScreenState extends State<AppSettingsScreen>{
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('App Settings')),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      Card(child:SwitchListTile(
        secondary:const Icon(Icons.dark_mode_outlined),
        title:const Text('Dark mode',style:TextStyle(fontWeight:FontWeight.w800)),
        subtitle:const Text('Change the entire app theme'),
        value:widget.isDark,onChanged:(_){widget.onToggle();setState((){});},
      )),
      const SizedBox(height:12),
      Card(child:ListTile(leading:const Icon(Icons.info_outline),title:const Text('Momentum'),subtitle:const Text('Project & SLA Task Tracker • Flutter')),
      ),
    ]),
  );
}
