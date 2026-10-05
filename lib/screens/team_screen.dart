import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/user_avatar.dart';

class TeamScreen extends StatefulWidget { const TeamScreen({super.key}); @override State<TeamScreen> createState()=>_TeamScreenState(); }
class _TeamScreenState extends State<TeamScreen>{
  List<Member> members=[];List<Task> tasks=[];bool loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{final s=StorageService();members=await s.getMembers();tasks=await s.getTasks();if(mounted)setState(()=>loading=false);}
  @override Widget build(BuildContext context)=>loading?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.fromLTRB(20,20,20,30),children:[
    Row(children:[const Expanded(child:Text('Team Members',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900))),IconButton.filled(onPressed:()async{await Navigator.pushNamed(context,'/add-member');_load();},icon:const Icon(Icons.add))]),
    const SizedBox(height:6),Text('People responsible for keeping delivery moving.',style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant)),const SizedBox(height:18),
    if(members.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(24),child:Text('No team members yet.'))),
    ...members.map((m)=>Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(
      leading:UserAvatar(member:m),title:Text(m.name,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${m.title}\n${SlaService.openTasksFor(tasks,m.id)} open tasks'),isThreeLine:true,
      trailing:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:_workloadColor(m).withValues(alpha:.12),borderRadius:BorderRadius.circular(99)),child:Text(SlaService.workloadFor(tasks,m),style:TextStyle(color:_workloadColor(m),fontSize:11,fontWeight:FontWeight.w800))),
    ))),
  ]);
  Color _workloadColor(Member m){final w=SlaService.workloadFor(tasks,m);return w=='Balanced'?AppTheme.teal:w=='Heavy'?AppTheme.amber:AppTheme.red;}
}
