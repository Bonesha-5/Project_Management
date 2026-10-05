import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/status_pill.dart';
import '../widgets/user_avatar.dart';

class TaskDetailsScreen extends StatefulWidget{final String taskId;const TaskDetailsScreen({super.key,required this.taskId});@override State<TaskDetailsScreen> createState()=>_TaskDetailsScreenState();}
class _TaskDetailsScreenState extends State<TaskDetailsScreen>{
 Task? task;Member? member;List<Member> members=[];bool loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final s=StorageService();final ts=await s.getTasks();members=await s.getMembers();for(final t in ts){if(t.id==widget.taskId){task=t;break;}}if(task!=null){for(final m in members){if(m.id==task!.assigneeId){member=m;break;}}}if(mounted)setState(()=>loading=false);}
 Future<void> _save()async{if(task==null)return;try{await StorageService().saveTasks(await _replace(task!));if(mounted)setState((){});}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}}
 Future<List<Task>> _replace(Task t)async{final s=StorageService();final ts=await s.getTasks();final i=ts.indexWhere((x)=>x.id==t.id);if(i>=0)ts[i]=t;return ts;}
 Future<void> _delete()async{final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Delete task?'),content:const Text('This action cannot be undone.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Delete'))]));if(ok==true&&task!=null){try{final ts=await StorageService().getTasks();ts.removeWhere((x)=>x.id==task!.id);await StorageService().saveTasks(ts);if(mounted)Navigator.pop(context);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}}}
 @override Widget build(BuildContext context){if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));if(task==null)return const Scaffold(body:Center(child:Text('Task not found')));final t=task!,status=SlaService.computeStatus(t,DateTime.now());return Scaffold(appBar:AppBar(title:const Text('Task Details'),actions:[IconButton(onPressed:()=>Navigator.pushNamed(context,'/edit-task',arguments:t.id).then((_)=>_load()),icon:const Icon(Icons.edit_outlined)),IconButton(onPressed:_delete,icon:const Icon(Icons.delete_outline))]),body:SafeArea(child:ListView(padding:const EdgeInsets.all(20),children:[
   Text(t.title,style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text(t.description,style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant)),const SizedBox(height:18),
   Card(color:AppTheme.lightPurple,child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     Row(children:[const Expanded(child:Text('SLA health',style:TextStyle(fontWeight:FontWeight.w900))),StatusPill(status:status)]),const SizedBox(height:16),
     _progressLine('Time used',SlaService.timeUsedPercent(t,DateTime.now())/100,AppTheme.deepPurple),const SizedBox(height:12),
     _progressLine('Work done',t.progress/100,AppTheme.purple),const SizedBox(height:14),Text(SlaService.message(t,DateTime.now()),style:const TextStyle(fontWeight:FontWeight.w700)),
   ]))),
   const SizedBox(height:12),
   Card(child:Column(children:[
     ListTile(leading:member==null?const CircleAvatar(child:Icon(Icons.person)):UserAvatar(member:member!),title:const Text('Assigned to'),subtitle:Text(member?.name??'Unassigned')),
     ListTile(leading:const Icon(Icons.calendar_today_outlined),title:const Text('Due'),subtitle:Text(DateFormat('EEE, MMM d, yyyy').format(t.dueDate))),
     ListTile(leading:const Icon(Icons.flag_outlined),title:const Text('Priority'),subtitle:Text(t.priority.name.toUpperCase())),
   ])),
   const SizedBox(height:12),
   Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
     const Text('Status',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:8),
     DropdownButtonFormField<TaskStatus>(value:t.status,items:TaskStatus.values.map((s)=>DropdownMenuItem(value:s,child:Text(switch(s){TaskStatus.todo=>'To Do',TaskStatus.inProgress=>'In Progress',TaskStatus.done=>'Done'}))).toList(),onChanged:(v){if(v!=null){setState((){t.status=v;if(v==TaskStatus.done)t.progress=100;});_save();}}),
     const SizedBox(height:18),Text('Work done: ${t.progress.round()}%',style:const TextStyle(fontWeight:FontWeight.w800)),Slider(value:t.progress,min:0,max:100,divisions:100,onChanged:(v){setState(()=>t.progress=v);_save();}),
     const SizedBox(height:8),const Text('Notes',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:6),Text(t.notes.isEmpty?'No notes added.':t.notes),
   ])),
 ])));
 }
 Widget _progressLine(String label,double value,Color color)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(label)),Text('${(value*100).round()}%')]),const SizedBox(height:5),ClipRRect(borderRadius:BorderRadius.circular(99),child:LinearProgressIndicator(value:value,minHeight:8,color:color))]);
}
