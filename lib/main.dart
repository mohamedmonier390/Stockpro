import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
void main()=>runApp(const App());
class App extends StatelessWidget{const App({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:Colors.teal)),home:const LoginScreen());}
class LoginScreen extends StatefulWidget{const LoginScreen({super.key});@override State<LoginScreen> createState()=>LoginState();}
class LoginState extends State<LoginScreen>{
  final pin=TextEditingController();List<AppUser> users=[];AppUser? selected;bool loading=true;
  @override void initState(){super.initState();loadUsers();}
  Future<void> loadUsers()async{final p=await SharedPreferences.getInstance();try{users=(jsonDecode(p.getString('users')??'[]') as List).map((x)=>AppUser(x['n'],x['pin']??'',x['admin']??false,Set<String>.from(x['p']??AppUser.modules),Set<String>.from(x['sites']??[]),Set<String>.from(x['warehouses']??[]))).toList();}catch(_){}if(users.isEmpty){users=[AppUser('المدير','',true,Set<String>.from(AppUser.modules))];await p.setString('users',jsonEncode(users.map((u)=>u.j()).toList()));}selected=users.first;setState(()=>loading=false);}
  Future<void> enter()async{if(selected==null)return;if(pin.text!=selected!.pin){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('PIN غير صحيح')));return;}final p=await SharedPreferences.getInstance();await p.setString('activeUser',selected!.name);if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Hub()));}
  @override Widget build(BuildContext c) { if(loading)return const Scaffold(body:Center(child:CircularProgressIndicator())); return Scaffold(body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:420),child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.inventory_2,size:70,color:Colors.teal),const Text('StockPro',style:TextStyle(fontSize:30,fontWeight:FontWeight.bold)),const SizedBox(height:22),DropdownButtonFormField<AppUser>(value:selected,decoration:const InputDecoration(labelText:'المستخدم',border:OutlineInputBorder()),items:users.map((u)=>DropdownMenuItem(value:u,child:Text(u.name))).toList(),onChanged:(u)=>setState(()=>selected=u)),const SizedBox(height:12),TextField(controller:pin,obscureText:true,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'PIN',border:OutlineInputBorder()),onSubmitted:(_)=>enter()),const SizedBox(height:16),SizedBox(width:double.infinity,child:FilledButton(onPressed:enter,child:const Text('دخول'))])))));}
}
class AnimatedSplash extends StatefulWidget {const AnimatedSplash({super.key});@override State<AnimatedSplash> createState()=>_AnimatedSplashState();}
class _AnimatedSplashState extends State<AnimatedSplash> with TickerProviderStateMixin {
  late final AnimationController _intro=AnimationController(vsync:this,duration:const Duration(milliseconds:900));
  late final AnimationController _shine=AnimationController(vsync:this,duration:const Duration(milliseconds:1000));
  late final Animation<double> _scale=CurvedAnimation(parent:_intro,curve:Curves.easeOutBack);
  late final Animation<double> _fade=CurvedAnimation(parent:_intro,curve:Curves.easeOut);
  @override void initState(){super.initState();_intro.forward();_shine.repeat();}
  @override void dispose(){_intro.dispose();_shine.dispose();super.dispose();}
  @override Widget build(BuildContext c) { return Scaffold(body:Container(width:double.infinity,height:double.infinity,decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xff063f36),Color(0xff006b5b),Color(0xff073d35)])),child:Center(child:FadeTransition(opacity:_fade,child:ScaleTransition(scale:_scale,child:const Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.inventory_2_rounded,size:80,color:Colors.white),Text('StockPro',style:TextStyle(fontSize:38,fontWeight:FontWeight.bold,color:Colors.white)),Text('MONIER',style:TextStyle(color:Colors.white))])))));}
}
class Site{String name,client;double b,l,d;Site(this.name,this.client,this.b,this.l,this.d);Map j()=>{'n':name,'c':client,'b':b,'l':l,'d':d};}
class Day{String site;DateTime date;int b,l,d,e;Day(this.site,this.date,this.b,this.l,this.d,this.e);Map j()=>{'s':site,'t':date.toIso8601String(),'b':b,'l':l,'d':d,'e':e};}
class Item{String n,code,unit;double cost,q,min;Item(this.n,this.code,this.unit,this.cost,this.q,this.min);Map j()=>{'n':n,'c':code,'u':unit,'cost':cost,'q':q,'min':min};}
class Movement{String item,type,note,warehouse;double qty;DateTime date;Movement(this.item,this.type,this.qty,this.note,this.date,[this.warehouse='']);Map j()=>{'i':item,'t':type,'q':qty,'n':note,'d':date.toIso8601String(),'w':warehouse};}
class Recipe{String item,meal;double qty;Recipe(this.item,this.meal,this.qty);Map j()=>{'i':item,'m':meal,'q':qty};}
class Warehouse{String name,site,manager;bool main;Warehouse(this.name,this.site,this.manager,this.main);Map j()=>{'n':name,'s':site,'m':manager,'main':main};}
class AppUser {
  String name, pin;
  bool admin;
  Set<String> permissions; Set<String> sites; Set<String> warehouses;
  AppUser(this.name,this.pin,this.admin,this.permissions,[Set<String>? sites,Set<String>? warehouses]):sites=sites??{},warehouses=warehouses??{};
  Map j()=>{'n':name,'pin':pin,'admin':admin,'p':permissions.toList(),'sites':sites.toList(),'warehouses':warehouses.toList()};
  static const modules=['الرئيسية','المواقع','الوجبات','المخزون','التقارير','المخازن'];
}
class Hub extends StatefulWidget{const Hub({super.key});@override State<Hub> createState()=>HState();}
class HState extends State<Hub>{int tab=0;bool ready=false;final sites=<Site>[];final days=<Day>[];final items=<Item>[];final movements=<Movement>[];final recipes=<Recipe>[];final warehouses=<Warehouse>[];final users=<AppUser>[];final stockBalances=<String,Map<String,double>>{};String activeUser='المدير';AppUser get current=>users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{}));List<Site> get visibleSites=>current.admin?sites:sites.where((s)=>current.sites.contains(s.name)).toList();List<Warehouse> get visibleWarehouses=>current.admin?warehouses:warehouses.where((w)=>current.warehouses.contains(w.name)).toList();
Future<void> load()async{final p=await SharedPreferences.getInstance();try{sites.addAll((jsonDecode(p.getString('sites')??'[]') as List).map((x)=>Site(x['n'],x['c'],(x['b'] as num).toDouble(),(x['l'] as num).toDouble(),(x['d'] as num).toDouble())));days.addAll((jsonDecode(p.getString('days')??'[]') as List).map((x)=>Day(x['s'],DateTime.parse(x['t']),x['b'],x['l'],x['d'],x['e'])));items.addAll((jsonDecode(p.getString('items')??'[]') as List).map((x)=>Item(x['n'],x['c'],x['u'],(x['cost'] as num).toDouble(),(x['q'] as num).toDouble(),(x['min'] as num).toDouble())));movements.addAll((jsonDecode(p.getString('movements')??'[]') as List).map((x)=>Movement(x['i'],x['t'],(x['q'] as num).toDouble(),x['n'],DateTime.parse(x['d']),x['w']??'')));recipes.addAll((jsonDecode(p.getString('recipes')??'[]') as List).map((x)=>Recipe(x['i'],x['m'],(x['q'] as num).toDouble())));warehouses.addAll((jsonDecode(p.getString('warehouses')??'[]') as List).map((x)=>Warehouse(x['n'],x['s']??'',x['m']??'',x['main']??false)));users.addAll((jsonDecode(p.getString('users')??'[]') as List).map((x)=>AppUser(x['n'],x['pin']??'',x['admin']??false,Set<String>.from(x['p']??AppUser.modules),Set<String>.from(x['sites']??[]),Set<String>.from(x['warehouses']??[]))));
activeUser=p.getString('activeUser')??'المدير';
if(users.isEmpty){users.add(AppUser('المدير','',true,Set<String>.from(AppUser.modules)));}
if(!users.any((u)=>u.name==activeUser))activeUser=users.first.name;
if(warehouses.isEmpty){warehouses.add(Warehouse('المخزن الرئيسي','كل الشركة','',true));}final raw=jsonDecode(p.getString('stockBalances')??'{}');if(raw is Map){raw.forEach((wh,v){if(v is Map)stockBalances[wh.toString()]=v.map((k,val)=>MapEntry(k.toString(),(val as num).toDouble()));});}final main=warehouses.firstWhere((w)=>w.main,orElse:()=>warehouses.first);stockBalances.putIfAbsent(main.name,()=>{});for(final item in items){stockBalances[main.name]!.putIfAbsent(item.n,()=>item.q);item.q=stockBalances[main.name]![item.n]??0;}}catch(_){if(users.isEmpty)users.add(AppUser('المدير','',true,Set<String>.from(AppUser.modules)));}setState(()=>ready=true);}
Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('sites',jsonEncode(sites.map((x)=>x.j()).toList()));await p.setString('days',jsonEncode(days.map((x)=>x.j()).toList()));await p.setString('items',jsonEncode(items.map((x)=>x.j()).toList()));await p.setString('movements',jsonEncode(movements.map((x)=>x.j()).toList()));await p.setString('recipes',jsonEncode(recipes.map((x)=>x.j()).toList()));await p.setString('warehouses',jsonEncode(warehouses.map((x)=>x.j()).toList()));await p.setString('stockBalances',jsonEncode(stockBalances));await p.setString('users',jsonEncode(users.map((x)=>x.j()).toList()));await p.setString('activeUser',activeUser);}
@override void initState(){super.initState();load();}
bool today(DateTime d){final n=DateTime.now();return d.year==n.year&&d.month==n.month&&d.day==n.day;}
double rev(Day x){final s=sites.where((z)=>z.name==x.site);return s.isEmpty?0:x.b*s.first.b+x.l*s.first.l+x.d*s.first.d;}
int get mealTotal=>days.where((x)=>today(x.date)).fold(0,(a,x)=>a+x.b+x.l+x.d+x.e);
double get revToday=>days.where((x)=>today(x.date)).fold(0.0,(a,x)=>a+rev(x));
double get stock=>items.fold(0.0,(a,x)=>a+x.q*x.cost);
bool can(String module)=>users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).admin||users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).permissions.contains(module);void siteAdd(Site x){setState(()=>sites.add(x));save();}void dayAdd(Day x){setState(()=>days.add(x));save();}void itemAdd(Item x){stockBalances.putIfAbsent(mainWarehouse.name,()=>{});stockBalances[mainWarehouse.name]![x.n]=x.q;setState(()=>items.add(x));save();}Warehouse get mainWarehouse=>warehouses.firstWhere((w)=>w.main,orElse:()=>warehouses.first);double balance(Item item,String warehouse)=>stockBalances[warehouse]?[item.n]??0;void setBalance(Item item,String warehouse,double value){stockBalances.putIfAbsent(warehouse,()=>{});stockBalances[warehouse]![item.n]=value;if(warehouse==mainWarehouse.name)item.q=value;}
@override Widget build(BuildContext c){if(!ready)return const Scaffold(body:Center(child:CircularProgressIndicator()));final views=[dashboard(),sitePage(),dayPage(),itemPage(),reportPage(),warehousePage(),userPage()];final allowedTabs=[0,1,2,3,4,5,6].where((i)=>i==6?users.firstWhere((u)=>u.name==activeUser,orElse:()=>AppUser(activeUser,'',false,{})).admin:can(AppUser.modules[i])).toList();if(!allowedTabs.contains(tab))tab=allowedTabs.isEmpty?0:allowedTabs.first;final icons=[Icons.home,Icons.apartment,Icons.restaurant,Icons.inventory,Icons.analytics,Icons.warehouse,Icons.people];final labels=['الرئيسية','المواقع','الوجبات','المخزون','التقارير','المخازن','المستخدمون'];return Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('StockPro | التغذية')),body:views[tab],bottomNavigationBar:NavigationBar(selectedIndex:allowedTabs.indexOf(tab),onDestinationSelected:(i)=>setState(()=>tab=allowedTabs[i]),destinations:allowedTabs.map((i)=>NavigationDestination(icon:Icon(icons[i]),label:labels[i])).toList())));}
Widget userPage()=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[const Expanded(child:Text('المستخدمون والصلاحيات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:userDialog,icon:const Icon(Icons.person_add),label:const Text('إضافة مستخدم'))]),Card(child:ListTile(leading:const Icon(Icons.account_circle),title:const Text('المستخدم الحالي'),subtitle:Text(activeUser),trailing:DropdownButton<String>(value:activeUser,items:users.map((u)=>DropdownMenuItem(value:u.name,child:Text(u.name))).toList(),onChanged:(v){if(v!=null){setState(()=>activeUser=v);save();}}))),const Card(child:ListTile(title:Text('تنبيه أمان'),subtitle:Text('الصلاحيات محفوظة على نفس الجهاز. اختيار المستخدم هنا للتجربة فقط وليس تسجيل دخول آمنًا؛ سنضيف شاشة دخول ورقم PIN في خطوة تالية.'))),...users.map((u)=>Card(child:ListTile(leading:Icon(u.admin?Icons.admin_panel_settings:Icons.person),title:Text(u.name),subtitle:Text(u.admin?'مدير — صلاحيات كاملة':'صلاحيات: '+u.permissions.join('، ')),trailing:IconButton(icon:const Icon(Icons.edit),onPressed:()=>userDialog(existing:u)))))]); 
Future<void> userDialog({AppUser? existing})async{
  final name=TextEditingController(text:existing?.name??'');final pin=TextEditingController(text:existing?.pin??'');bool admin=existing?.admin??false;
  final perms=Set<String>.from(existing?.permissions??{});final siteScope=Set<String>.from(existing?.sites??{});final warehouseScope=Set<String>.from(existing?.warehouses??{});
  await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(
    title:Text(existing==null?'إضافة مستخدم':'تعديل المستخدم'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      field(name,'اسم المستخدم'),field(pin,'رقم PIN (إجباري)',numeric:true,decimal:false),
      CheckboxListTile(value:admin,title:const Text('مدير — صلاحيات كاملة'),onChanged:(v)=>set(()=>admin=v??false)),
      const Divider(),...AppUser.modules.map((m)=>CheckboxListTile(dense:true,value:perms.contains(m),title:Text('السماح بـ $m'),onChanged:(v)=>set(()=>v==true?perms.add(m):perms.remove(m)))),
      const Divider(),const Text('المواقع المسموح بها'),...sites.map((site)=>CheckboxListTile(dense:true,value:siteScope.contains(site.name),title:Text(site.name),onChanged:(v)=>set(()=>v==true?siteScope.add(site.name):siteScope.remove(site.name)))),
      const Text('المخازن المسموح بها'),...warehouses.map((wh)=>CheckboxListTile(dense:true,value:warehouseScope.contains(wh.name),title:Text(wh.name),onChanged:(v)=>set(()=>v==true?warehouseScope.add(wh.name):warehouseScope.remove(wh.name))))
    ])),
    actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){
      if(name.text.trim().isEmpty||pin.text.trim().isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('اسم المستخدم والـ PIN مطلوبان')));return;}
      if(existing==null){if(users.any((u)=>u.name==name.text.trim())){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('اسم المستخدم موجود بالفعل')));return;}users.add(AppUser(name.text.trim(),pin.text.trim(),admin,Set<String>.from(perms),Set<String>.from(siteScope),Set<String>.from(warehouseScope)));}
      else{existing.name=name.text.trim();existing.pin=pin.text.trim();existing.admin=admin;existing.permissions=Set<String>.from(perms);existing.sites=Set<String>.from(siteScope);existing.warehouses=Set<String>.from(warehouseScope);}
      save();setState((){});Navigator.pop(x);
    },child:const Text('حفظ'))])));
}
Widget metric(String title,String val,IconData icon)=>Card(child:ListTile(leading:Icon(icon,color:Colors.teal),title:Text(title),subtitle:Text(val)));
Widget dashboard()=>ListView(padding:const EdgeInsets.all(14),children:[Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Colors.teal.shade900,borderRadius:BorderRadius.circular(16)),child:const Text('إدارة مواقع التغذية والعقود\nالوجبات • المخزون • الإيرادات',style:TextStyle(color:Colors.white,fontSize:21))),metric('إيراد اليوم',cash(days.where((x)=>today(x.date)&&(current.admin||current.sites.contains(x.site))).fold(0.0,(a,x)=>a+rev(x))),Icons.payments),metric('وجبات اليوم',days.where((x)=>today(x.date)&&(current.admin||current.sites.contains(x.site))).fold(0,(a,x)=>a+x.b+x.l+x.d+x.e).toString(),Icons.restaurant),metric('عدد المواقع',visibleSites.length.toString(),Icons.apartment),metric('عدد الخامات',items.length.toString(),Icons.inventory),metric('خامات وصلت حد التنبيه',items.where((x)=>x.q<=x.min).length.toString(),Icons.warning),metric('قيمة المخزون',cash(stock),Icons.warehouse),Wrap(spacing:8,children:[FilledButton(onPressed:()=>siteDialog(),child:const Text('إضافة موقع')),FilledButton(onPressed:()=>dayDialog(),child:const Text('تسجيل وجبات')),FilledButton(onPressed:()=>itemDialog(),child:const Text('إضافة خامة'))])]);

Widget warehousePage() => ListView(padding:const EdgeInsets.all(12),children:[
Row(children:[const Expanded(child:Text('إدارة المخازن',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton.icon(onPressed:warehouseDialog,icon:const Icon(Icons.add),label:const Text('مخزن جديد'))]),
Wrap(spacing:6,children:[FilledButton.icon(onPressed:transferDialog,icon:const Icon(Icons.swap_horiz),label:const Text('تحويل مخزني')),OutlinedButton.icon(onPressed:movementHistoryDialog,icon:const Icon(Icons.history),label:const Text('سجل الحركات'))]),
const Card(child:ListTile(leading:Icon(Icons.info_outline),title:Text('رصيد مستقل لكل مخزن'),subtitle:Text('الاستلام والصرف والتحويلات تُسجل على المخزن المحدد.'))),
  ...visibleWarehouses.map((w)=>Card(child:ListTile(leading:Icon(w.main?Icons.warehouse:Icons.store,color:Colors.teal),title:Text(w.name),subtitle:Text((w.main?'مخزن رئيسي':'مخزن فرعي')+' • '+w.site+'\\nقيمة الرصيد: '+cash(items.fold(0.0,(sum,it)=>sum+balance(it,w.name)*it.cost)),trailing:IconButton(icon:const Icon(Icons.edit),onPressed:()=>warehouseDialog(existing:w)))))
]);
Widget sitePage()=>listPage('المواقع والعقود',visibleSites.map((s)=>Card(child:ListTile(title:Text(s.name),subtitle:Text(s.client+'\nإفطار '+cash(s.b)+' / غداء '+cash(s.l)+' / عشاء '+cash(s.d))))).toList(),siteDialog,'إضافة موقع');
Widget dayPage()=>listPage('سجل الوجبات',days.reversed.map((x)=>Card(child:ListTile(title:Text(x.site),subtitle:Text(x.date.day.toString()+'/'+x.date.month.toString()+' | إفطار '+x.b.toString()+' غداء '+x.l.toString()+' عشاء '+x.d.toString()+' إضافي '+x.e.toString()),trailing:Text(cash(rev(x)))))).toList(),dayDialog,'تسجيل وجبات');
Widget itemPage()=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[const Expanded(child:Text('المخزون والخامات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton(onPressed:itemDialog,child:const Text('إضافة خامة'))]),Wrap(spacing:8,children:[OutlinedButton.icon(onPressed:importExcel,icon:const Icon(Icons.upload_file),label:const Text('Import Excel')),OutlinedButton.icon(onPressed:()=>movementDialog('استلام'),icon:const Icon(Icons.add_box),label:const Text('استلام خامات')),OutlinedButton.icon(onPressed:()=>movementDialog('صرف'),icon:const Icon(Icons.remove_circle),label:const Text('صرف خامات')),OutlinedButton.icon(onPressed:recipeDialog,icon:const Icon(Icons.menu_book),label:const Text('وصفات الوجبات'))]),if(items.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('لا توجد خامات بعد'))),...items.map((x)=>Card(child:ListTile(title:Text(x.n),subtitle:Text(x.code+' | '+x.unit+' | حد التنبيه '+qtyText(x.min)+'\\n'+warehouses.map((w)=>w.name+': '+qtyText(balance(x,w.name))).join(' | ')),trailing:Text(qtyText(warehouses.fold(0.0,(sum,w)=>sum+balance(x,w.name)))+' '+x.unit+'\\n'+cash(warehouses.fold(0.0,(sum,w)=>sum+balance(x,w.name))*x.cost))))),const Padding(padding:EdgeInsets.only(top:12),child:Text('آخر حركات المخزون',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),if(movements.isEmpty)const Text('لا توجد حركات مسجلة'),...movements.reversed.take(30).map((m)=>Card(child:ListTile(leading:Icon(m.type=='استلام'?Icons.arrow_downward:Icons.arrow_upward,color:m.type=='استلام'?Colors.green:Colors.orange),title:Text(m.item+' — '+m.type+' '+qtyText(m.qty)),subtitle:Text(m.date.day.toString()+'/'+m.date.month.toString()+'/'+m.date.year.toString()+(m.note.isEmpty?'':'\\n'+m.note)))))]);
double mealCost(Day x){double total=0;for(final r in recipes){final count=r.meal=='إفطار'?x.b:r.meal=='غداء'?x.l:r.meal=='عشاء'?x.d:0;final found=items.where((i)=>i.n==r.item);if(found.isNotEmpty)total+=count*r.qty*found.first.cost;}return total;}
Widget reportPage(){
  final now=DateTime.now();
  final monthDays=days.where((x)=>x.date.year==now.year&&x.date.month==now.month&&(current.admin||current.sites.contains(x.site))).toList();
  int mealCount=0;
  double revenue=0;
  for(final entry in monthDays){mealCount+=entry.b+entry.l+entry.d+entry.e;revenue+=rev(entry);}
  final rows=<Widget>[
    const Text('تقرير الشهر الحالي',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    metric('إجمالي الوجبات',mealCount.toString(),Icons.restaurant),
    metric('إيراد الشهر',cash(revenue),Icons.payments),metric('تكلفة الخامات حسب الوصفات',cash(monthDays.fold(0.0,(a,x)=>a+mealCost(x))),Icons.calculate),metric('هامش بعد تكلفة الخامات',cash(revenue-monthDays.fold(0.0,(a,x)=>a+mealCost(x))),Icons.trending_up),
  ];
  for(final site in visibleSites){
    int count=0;double amount=0;
    for(final entry in monthDays){
      if(entry.site==site.name){count+=entry.b+entry.l+entry.d+entry.e;amount+=entry.b*site.b+entry.l*site.l+entry.d*site.d;}
    }
    rows.add(Card(child:ListTile(title:Text(site.name),subtitle:Text('$count وجبة'),trailing:Text(cash(amount)))));
  }
  return ListView(padding:const EdgeInsets.all(14),children:rows);
}
Widget listPage(String title,List<Widget> rows,VoidCallback add,String label)=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[Expanded(child:Text(title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton(onPressed:add,child:Text(label))]),if(rows.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(20),child:Text('لا توجد بيانات بعد'))),...rows]);
Future<void> warehouseDialog({Warehouse? existing}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final manager = TextEditingController(text: existing?.manager ?? '');
  final siteOptions = ['كل الشركة', ...sites.map((s) => s.name)];
  String selectedSite = siteOptions.contains(existing?.site) ? existing!.site : 'كل الشركة';
  bool isMain = existing?.main ?? false;
  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(existing == null ? 'إضافة مخزن' : 'تعديل المخزن'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            field(name, 'اسم المخزن'),
            DropdownButtonFormField<String>(
              value: selectedSite,
              decoration: const InputDecoration(labelText: 'الموقع / نطاق المخزن'),
              items: siteOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) { if (v != null) setDialogState(() => selectedSite = v); },
            ),
            field(manager, 'المسؤول'),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('مخزن رئيسي'),
              value: isMain,
              onChanged: (v) => setDialogState(() => isMain = v ?? false),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب اسم المخزن')));
                return;
              }
              if (isMain && warehouses.any((w) => w.main && w != existing)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يوجد مخزن رئيسي بالفعل')));
                return;
              }
              final updated = Warehouse(name.text.trim(), selectedSite, manager.text.trim(), isMain);
              if (existing == null) {
                warehouses.add(updated);
              } else {
                if(existing.name!=updated.name){final oldName=existing.name;final oldBalances=stockBalances.remove(oldName);if(oldBalances!=null)stockBalances[updated.name]=oldBalances;for(final u in users){if(u.warehouses.remove(oldName))u.warehouses.add(updated.name);}for(final m in movements){if(m.warehouse==oldName)m.warehouse=updated.name;}}
                existing.name = updated.name;
                existing.site = updated.site;
                existing.manager = updated.manager;
                existing.main = updated.main;
              }
              save();
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    ),
  );
}
Future<void> siteDialog()async{final n=TextEditingController(),c=TextEditingController(),b=TextEditingController(text:'0'),l=TextEditingController(text:'0'),d=TextEditingController(text:'0');await showDialog(context:context,builder:(x)=>AlertDialog(title:const Text('عقد الموقع'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n,'اسم الموقع'),field(c,'العميل'),field(b,'سعر الإفطار',numeric:true),field(l,'سعر الغداء',numeric:true),field(d,'سعر العشاء',numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){if(n.text.trim().isEmpty)return;siteAdd(Site(n.text,c.text,double.tryParse(b.text)??0,double.tryParse(l.text)??0,double.tryParse(d.text)??0));Navigator.pop(x);},child:const Text('حفظ'))]));}
Future<void> dayDialog()async{if(visibleSites.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('سجل موقع وعقد أولاً')));return;}Site chosen=visibleSites.first;final b=TextEditingController(text:'0'),l=TextEditingController(text:'0'),d=TextEditingController(text:'0'),e=TextEditingController(text:'0');await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:const Text('تسجيل الوجبات اليومية'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Site>(value:chosen,items:visibleSites.map((s)=>DropdownMenuItem(value:s,child:Text(s.name))).toList(),onChanged:(v){if(v!=null)set(()=>chosen=v);}),field(b,'عدد الإفطار',numeric:true,decimal:false),field(l,'عدد الغداء',numeric:true,decimal:false),field(d,'عدد العشاء',numeric:true,decimal:false),field(e,'وجبات إضافية غير مسعرة',numeric:true,decimal:false),Text('أسعار العقد: '+cash(chosen.b)+' / '+cash(chosen.l)+' / '+cash(chosen.d))])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){final nb=int.tryParse(b.text)??0,nl=int.tryParse(l.text)??0,nd=int.tryParse(d.text)??0,ne=int.tryParse(e.text)??0;final need=<Item,double>{};for(final r in recipes){final count=r.meal=='إفطار'?nb:r.meal=='غداء'?nl:r.meal=='عشاء'?nd:0;final found=items.where((i)=>i.n==r.item);if(found.isNotEmpty)need[found.first]=(need[found.first]??0)+count*r.qty;}final consumeWh=warehouses.where((w)=>!w.main&&w.site==chosen.name).firstOrNull??mainWarehouse;final shortage=need.entries.where((e)=>e.value>balance(e.key,consumeWh.name)).toList();if(shortage.isNotEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('رصيد غير كافٍ في '+consumeWh.name+': '+shortage.map((e)=>e.key.n+' (متاح '+qtyText(balance(e.key,consumeWh.name))+')').join('، '))));return;}dayAdd(Day(chosen.name,DateTime.now(),nb,nl,nd,ne));for(final e in need.entries){setBalance(e.key,consumeWh.name,balance(e.key,consumeWh.name)-e.value);movements.add(Movement(e.key.n,'استهلاك وجبات',e.value,'موقع: '+chosen.name,DateTime.now(),consumeWh.name));}save();Navigator.pop(x);},child:const Text('حفظ'))])));}
Future<void> movementDialog(String type) async {
if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف خامة أولاً')));return;}
Item selected=items.first;Warehouse wh=visibleWarehouses.isNotEmpty?visibleWarehouses.first:mainWarehouse;final qty=TextEditingController(),note=TextEditingController();
await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,upd)=>AlertDialog(title:Text('$type خامات'),content:Column(mainAxisSize:MainAxisSize.min,children:[
DropdownButtonFormField<Warehouse>(value:wh,items:visibleWarehouses.map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null)upd(()=>wh=v);}),
DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)upd(()=>selected=v);}),
field(qty,'الكمية بوحدة '+selected.unit,numeric:true),field(note,'ملاحظات'),Text('الرصيد الحالي: '+qtyText(balance(selected,wh.name))+' '+selected.unit)
]),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إلغاء')),FilledButton(onPressed:(){
final amount=double.tryParse(qty.text.trim().replaceAll(',','.'));if(amount==null||amount<=0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أدخل كمية صحيحة')));return;}
final current=balance(selected,wh.name);if(type=='صرف'&&amount>current){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('رصيد غير كافٍ بالمخزن')));return;}
setBalance(selected,wh.name,current+(type=='استلام'?amount:-amount));movements.add(Movement(selected.n,type,amount,note.text.trim(),DateTime.now(),wh.name));save();setState(()=>{});Navigator.pop(dc);
},child:const Text('تأكيد'))])));
}
Future<void> transferDialog()async{
final mains=warehouses.where((w)=>w.main).toList();final targets=visibleWarehouses.where((w)=>!w.main).toList();
if(mains.isEmpty||targets.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف مخزن رئيسي ومخزن فرعي أولاً')));return;}
final source=mains.first;Warehouse target=targets.first;Item selected=items.isNotEmpty?items.first:Item('','','',0,0,0);final q=TextEditingController(),note=TextEditingController();
if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف خامة أولاً')));return;}
await showDialog(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,upd)=>AlertDialog(title:const Text('إذن تحويل مخزني'),content:Column(mainAxisSize:MainAxisSize.min,children:[
ListTile(title:const Text('من المخزن'),subtitle:Text(source.name)),DropdownButtonFormField<Warehouse>(value:target,items:targets.map((w)=>DropdownMenuItem(value:w,child:Text(w.name))).toList(),onChanged:(v){if(v!=null)upd(()=>target=v);}),
DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)upd(()=>selected=v);}),
Text('رصيد المصدر: '+qtyText(balance(selected,source.name))+' '+selected.unit),field(q,'الكمية للتحويل',numeric:true),field(note,'ملاحظات / رقم الإذن')
]),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إلغاء')),FilledButton(onPressed:(){
final amount=double.tryParse(q.text.trim().replaceAll(',','.'));if(amount==null||amount<=0||amount>balance(selected,source.name)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('الكمية غير صحيحة أو رصيد المخزن الرئيسي غير كافٍ')));return;}
setBalance(selected,source.name,balance(selected,source.name)-amount);setBalance(selected,target.name,balance(selected,target.name)+amount);
final stamp=DateTime.now();final memo='تحويل إلى '+target.name+(note.text.trim().isEmpty?'':' | '+note.text.trim());movements.add(Movement(selected.n,'تحويل صادر',amount,memo,stamp,source.name));movements.add(Movement(selected.n,'تحويل وارد',amount,'من '+source.name+(note.text.trim().isEmpty?'':' | '+note.text.trim()),stamp,target.name));save();setState(()=>{});Navigator.pop(dc);
},child:const Text('اعتماد التحويل'))])));
}
Future<void> movementHistoryDialog()async{
final list=movements.reversed.toList();
  await showDialog(context:context,builder:(dc)=>AlertDialog(title:const Text('سجل حركات المخزون'),content:SizedBox(width:450,height:450,child:list.isEmpty?const Center(child:Text('لا توجد حركات')):ListView(children:list.map((m)=>ListTile(leading:Icon(m.type.contains('وارد')||m.type=='استلام'?Icons.arrow_downward:m.type.contains('صادر')||m.type=='صرف'?Icons.arrow_upward:Icons.swap_horiz),title:Text(m.item+' • '+m.type+' • '+qtyText(m.qty)),subtitle:Text(m.warehouse+' | '+m.date.toString()+(m.note.isEmpty?'':'\\n'+m.note))).toList())),actions:[TextButton(onPressed:()=>Navigator.pop(dc),child:const Text('إغلاق'))]));
}
Future<void> recipeDialog()async{if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف خامات أولاً')));return;}Item selected=items.first;String meal='إفطار';final q=TextEditingController(text:'1');await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:const Text('تحديد استهلاك الخامة لكل وجبة'),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)set(()=>selected=v);}),DropdownButtonFormField<String>(value:meal,items:['إفطار','غداء','عشاء'].map((m)=>DropdownMenuItem(value:m,child:Text(m))).toList(),onChanged:(v){if(v!=null)set(()=>meal=v);}),field(q,'الكمية لكل وجبة بوحدة المخزون',numeric:true),const Text('عند تسجيل الوجبات سيتم خصم الاستهلاك تلقائيًا.')]),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){final qty=double.tryParse(q.text.trim().replaceAll(',', '.'));if(qty==null||qty<=0)return;final old=recipes.where((r)=>r.item==selected.n&&r.meal==meal);if(old.isNotEmpty){old.first.qty=qty;}else{recipes.add(Recipe(selected.n,meal,qty));}save();setState(()=>{});Navigator.pop(x);},child:const Text('حفظ الوصفة'))])));}
Future<void> itemDialog()async{final n=TextEditingController(),code=TextEditingController(),u=TextEditingController(text:'كجم'),cost=TextEditingController(text:'0'),q=TextEditingController(text:'0'),min=TextEditingController(text:'0');await showDialog(context:context,builder:(x)=>AlertDialog(title:const Text('بيانات الخامة'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n,'اسم المادة'),field(code,'كود/باركود'),field(u,'وحدة القياس'),field(cost,'تكلفة الوحدة',numeric:true),field(q,'الرصيد الحالي',numeric:true),field(min,'حد التنبيه',numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){if(n.text.trim().isEmpty)return;itemAdd(Item(n.text,code.text,u.text,double.tryParse(cost.text.trim().replaceAll(',', '.'))??0,double.tryParse(q.text.trim().replaceAll(',', '.'))??0,double.tryParse(min.text.trim().replaceAll(',', '.'))??0));Navigator.pop(x);},child:const Text('حفظ'))]));}
}
String cash(double n)=>n.toStringAsFixed(2)+' ج.م';
String qtyText(double n){
  var value=n.toStringAsFixed(3);
  while(value.contains('.')&&value.endsWith('0')){value=value.substring(0,value.length-1);}
  if(value.endsWith('.')){value=value.substring(0,value.length-1);}
  return value;
}
Widget field(TextEditingController x,String label,{bool numeric=false,bool decimal=true})=>Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:x,keyboardType:numeric?TextInputType.numberWithOptions(decimal:decimal):TextInputType.text,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
