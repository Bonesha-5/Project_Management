import 'package:flutter/material.dart';
import '../models/member.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override State<EditProfileScreen> createState() => _EditProfileScreenState();
}
class _EditProfileScreenState extends State<EditProfileScreen> {
  final keyForm = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController(), title = TextEditingController();
  Member? user; bool loading = true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { user=await AuthService(StorageService()).currentUser(); if(user!=null){name.text=user!.name;email.text=user!.email;title.text=user!.title;} if(mounted)setState(()=>loading=false);}
  @override void dispose(){name.dispose();email.dispose();title.dispose();super.dispose();}
  Future<void> save() async {
    if(!keyForm.currentState!.validate() || user==null)return;
    try {
      await AuthService(StorageService()).updateProfile(user!, name:name.text,email:email.text,title:title.text);
      if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Profile updated')));Navigator.pop(context);}
    } catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString().replaceFirst('Exception: ',''))));}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Edit Profile')),
    body:loading?const Center(child:CircularProgressIndicator()):SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Form(key:keyForm,child:Column(children:[
      AppTextField(controller:name,label:'Full name'),
      const SizedBox(height:14), AppTextField(controller:email,label:'Email',keyboardType:TextInputType.emailAddress,validator:(v)=>v==null||!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)?'Enter a valid email':null),
      const SizedBox(height:14), AppTextField(controller:title,label:'Title'),
      const SizedBox(height:24), AppButton(label:'Save Changes',onPressed:save,icon:Icons.save_outlined),
    ]))));
}
