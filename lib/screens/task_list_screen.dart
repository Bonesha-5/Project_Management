import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget{const TaskListScreen({super.key});@override State<TaskListScreen> createState()=>_TaskListScreenState();}
class _TaskListScreenState extends State<TaskListScreen>{
 List<Task> tasks=[];List<Member> members=[];String search='';SlaStatus? filter;bool loading=true;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final s=StorageService();tasks=await s.getTasks();members=await s.getMembers();tasks.sort((a,b)=>a.dueDate.compareTo(b.dueDate));if(mounted)setState(()=>loading=false);}
 @override Widget build(BuildContext context){if(loading)return const Center(child:CircularProgressIndicator());final now=DateTime.now();final filtered=tasks.where((t){final okSearch=t.title.toLowerCase().contains(search.toLowerCase());final okFilter=filter==null||SlaService.computeStatus(t,now)==filter;return okSearch&&okFilter;}).toList();return ListView(padding:const EdgeInsets.fromLTRB(20,20,20,100),children:[
   const Text('Tasks',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:14),
   TextField(onChanged:(v)=>setState(()=>search=v),decoration:const InputDecoration(hintText:'Search tasks...',prefixIcon:Icon(Icons.search))),
   const SizedBox(height:12),
   SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[
     _chip('All',null),_chip('On Track',SlaStatus.onTrack),_chip('At Risk',SlaStatus.atRisk),_chip('Overdue',SlaStatus.overdue),_chip('Done',SlaStatus.completed),
   ])),const SizedBox(height:14),
   if(filtered.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(24),child:Text('No tasks yet'))),
   ...filtered.map((t)=>TaskCard(task:t,member:_member(t.assigneeId),onTap:()async{await Navigator.pushNamed(context,'/task-details',arguments:t.id);_load();})),
 ]);}
 Widget _chip(String label,SlaStatus? value)=>Padding(padding:const EdgeInsets.only(right:8),child:FilterChip(label:Text(label),selected:filter==value,onSelected:(_)=>setState(()=>filter=value)));
 Member? _member(String id){for(final m in members){if(m.id==id)return m;}return null;}
}
