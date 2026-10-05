import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_form.dart';

class NewTaskScreen extends StatefulWidget{const NewTaskScreen({super.key});@override State<NewTaskScreen> createState()=>_NewTaskScreenState();}
class _NewTaskScreenState extends State<NewTaskScreen>{
 final keyForm=GlobalKey<FormState>();List<Member> members=[];bool loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{members=await StorageService().getMembers();if(mounted)setState(()=>loading=false);}
 Future<void> create({required String title,required String description,required String assigneeId,required DateTime dueDate,required Priority priority,required TaskStatus status,required double progress,required String notes})async{
   try{final s=StorageService();final tasks=await s.getTasks();tasks.add(Task(id:'t_${DateTime.now().microsecondsSinceEpoch}',title:title,description:description,assigneeId:assigneeId,createdAt:DateTime.now(),dueDate:dueDate,priority:priority,status:status,progress:progress,notes:notes));await s.saveTasks(tasks);if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Task created successfully')));Navigator.pop(context);}}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('New Task')),body:loading?const Center(child:CircularProgressIndicator()):SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(20),child:TaskForm(formKey:keyForm,members:members,onSubmit:create)));
}
