import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/storage_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/user_avatar.dart';

class AddMemberScreen extends StatefulWidget{const AddMemberScreen({super.key});@override State<AddMemberScreen> createState()=>_AddMemberScreenState();}
class _AddMemberScreenState extends State<AddMemberScreen>{
 final keyForm=GlobalKey<FormState>();final name=TextEditingController(),role=TextEditingController(),email=TextEditingController();bool saving=false;
 @override void dispose(){name.dispose();role.dispose();email.dispose();super.dispose();}
 Future<void> save()async{if(!keyForm.currentState!.validate())return;setState(()=>saving=true);try{final s=StorageService();final ms=await s.getMembers();ms.add(Member(id:'m_${DateTime.now().microsecondsSinceEpoch}',name:name.text.trim(),title:role.text.trim().isEmpty?'Team Member':role.text.trim(),email:email.text.trim()));await s.saveMembers(ms);if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Member added successfully')));Navigator.pop(context);}}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}finally{if(mounted)setState(()=>saving=false);}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Add Member')),body:SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Form(key:keyForm,child:Column(children:[
   UserAvatar(member:Member(id:'preview',name:name.text.isEmpty?'New Member':name.text,email:'',title:''),radius:38),const SizedBox(height:20),
   AppTextField(controller:name,label:'Full name'),const SizedBox(height:14),AppTextField(controller:role,label:'Role or title',validator:(_)=>null),const SizedBox(height:14),
   AppTextField(controller:email,label:'Email',keyboardType:TextInputType.emailAddress,validator:(v)=>v==null||!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)?'Enter a valid email':null),const SizedBox(height:24),
   AppButton(label:'Save Member',onPressed:save,loading:saving,icon:Icons.person_add_alt_1),
 ]))));
}
