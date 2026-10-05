import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/member.dart';
import '../models/task.dart';
import '../services/sla_service.dart';
import '../services/storage_service.dart';
import '../widgets/status_pill.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override State<StatisticsScreen> createState()=>_StatisticsScreenState();
}
class _StatisticsScreenState extends State<StatisticsScreen>{
  List<Task> tasks=[];List<Member> members=[];bool loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{final s=StorageService();tasks=await s.getTasks();members=await s.getMembers();if(mounted)setState(()=>loading=false);}
  @override Widget build(BuildContext context){if(loading)return const Center(child:CircularProgressIndicator());final c=SlaService.counts(tasks,DateTime.now());final max=(c.values.fold<int>(0,(a,b)=>a>b?a:b));final upcoming=[...tasks]..sort((a,b)=>a.dueDate.compareTo(b.dueDate));return RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.fromLTRB(20,20,20,30),children:[
    const Text('Statistics',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text('A quick view of delivery health.',style:TextStyle(color:Theme.of(context).colorScheme.onSurfaceVariant)),const SizedBox(height:20),
    Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Tasks by SLA status',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:18),...SlaStatus.values.map((s)=>_bar(SlaService.statusLabel(s),c[s]!,max,_color(s)))]))),
    const SizedBox(height:12),
    Row(children:[Expanded(child:_metric('On-time rate','${SlaService.onTimeRate(tasks).round()}%',Icons.schedule,AppTheme.teal)),const SizedBox(width:10),Expanded(child:_metric('High priority','${SlaService.openHighPriority(tasks)}',Icons.priority_high,AppTheme.red))]),
    const SizedBox(height:12),
    Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Open tasks per member',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:12),...members.map((m){final n=SlaService.openTasksFor(tasks,m.id);return Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Expanded(child:Text(m.name)),Text('$n',style:const TextStyle(fontWeight:FontWeight.w900))]));})]))),
    const SizedBox(height:12),
    Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Upcoming deadlines',style:TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:12),...upcoming.take(4).map((t)=>ListTile(contentPadding:EdgeInsets.zero,title:Text(t.title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${t.dueDate.day}/${t.dueDate.month}/${t.dueDate.year}'),trailing:StatusPill(status:SlaService.computeStatus(t,DateTime.now())))]))),
  ]));}
  Color _color(SlaStatus s)=>switch(s){SlaStatus.onTrack=>AppTheme.teal,SlaStatus.atRisk=>AppTheme.amber,SlaStatus.overdue=>AppTheme.red,SlaStatus.completed=>AppTheme.purple};
  Widget _bar(String label,int value,int max,Color color)=>Padding(padding:const EdgeInsets.only(bottom:12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(label)),Text('$value')]),const SizedBox(height:5),ClipRRect(borderRadius:BorderRadius.circular(99),child:LinearProgressIndicator(value:max==0?0:value/max,minHeight:8,color:color))]));
  Widget _metric(String label,String value,IconData icon,Color color)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[Icon(icon,color:color),const SizedBox(height:8),Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),Text(label)])));
}
