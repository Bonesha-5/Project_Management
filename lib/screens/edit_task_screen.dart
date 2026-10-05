import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_form.dart';

class EditTaskScreen extends StatefulWidget{final String taskId;const EditTaskScreen({super.key,required this.taskId});@override State<EditTaskScreen> createState()=>_EditTaskScreenState();}
class _EditTaskScreenState extends State<EditTaskScreen>{
 final keyForm=GlobalKey<FormState>();Task? task;List<Member> members=[];bool loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final s=StorageService();final ts=await s.getTasks();members=await s.getMembers();for(final t in ts){if(t.id==widget.taskId){task=t;break;}}if(mounted)setState(()=>loading=false);}
 Future<void> save({required String title,required String description,required String assigneeId,required DateTime dueDate,required Priority priority,required TaskStatus status,required double progress,required String notes})async{
   if(task==null)return;try{final s=StorageService();final ts=await s.getTasks();final i=ts.indexWhere((x)=>x.id==task!.id);if(i<0)throw Exception('Task no longer exists.');task!.title=title;task!.description=description;task!.assigneeId=assigneeId;task!.dueDate=dueDate;task!.priority=priority;task!.status=status;task!.progress=progress;task!.notes=notes;ts[i]=task!;await s.saveTasks(ts);if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Task updated')));Navigator.pop(context);}}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
 }
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Edit Task')),body:loading?const Center(child:CircularProgressIndicator()):task==null?const Center(child:Text('Task not found')):SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(20),child:TaskForm(formKey:keyForm,members:members,initialTask:task,onSubmit:save)));
}
