import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main()=>runApp(const App());
class App extends StatelessWidget{const App({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:Colors.teal)),home:const AnimatedSplash());}
class AnimatedSplash extends StatefulWidget {
  const AnimatedSplash({super.key});
  @override
  State<AnimatedSplash> createState() => _AnimatedSplashState();
}
class _AnimatedSplashState extends State<AnimatedSplash> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  late final AnimationController _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250));
  late final Animation<double> _scale = CurvedAnimation(parent: _intro, curve: Curves.easeOutBack);
  late final Animation<double> _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _intro.forward();
    _shine.repeat();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Hub(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff063f36), Color(0xff006b5b), Color(0xff073d35)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(.24), width: 1.2),
                      ),
                      child: const Center(child: Icon(Icons.inventory_2_rounded, size: 53, color: Color(0xffc5eee4))),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text('StockPro', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  const Text('FOOD OPERATIONS MANAGEMENT', style: TextStyle(fontSize: 11, color: Color(0xffb9ded5), letterSpacing: 2.5, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 155,
                    height: 2,
                    child: AnimatedBuilder(
                      animation: _shine,
                      builder: (context, child) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-1 + 2 * _shine.value, 0),
                            end: Alignment(2 * _shine.value, 0),
                            colors: [Colors.white.withOpacity(.12), const Color(0xffc5eee4), Colors.white.withOpacity(.12)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text('Designed and Built by Monier', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: .7)),
                  const SizedBox(height: 7),
                  const Text('MONIER', style: TextStyle(color: Color(0xffa8d8cd), fontSize: 10, letterSpacing: 4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Site{String name,client;double b,l,d;Site(this.name,this.client,this.b,this.l,this.d);Map j()=>{'n':name,'c':client,'b':b,'l':l,'d':d};}
class Day{String site;DateTime date;int b,l,d,e;Day(this.site,this.date,this.b,this.l,this.d,this.e);Map j()=>{'s':site,'t':date.toIso8601String(),'b':b,'l':l,'d':d,'e':e};}
class Item{String n,code,unit;double cost,q,min;Item(this.n,this.code,this.unit,this.cost,this.q,this.min);Map j()=>{'n':n,'c':code,'u':unit,'cost':cost,'q':q,'min':min};}
class Movement{String item,type,note;double qty;DateTime date;Movement(this.item,this.type,this.qty,this.note,this.date);Map j()=>{'i':item,'t':type,'q':qty,'n':note,'d':date.toIso8601String()};}
class Recipe{String item,meal;double qty;Recipe(this.item,this.meal,this.qty);Map j()=>{'i':item,'m':meal,'q':qty};}
class Warehouse{String name,site,manager;bool main;Warehouse(this.name,this.site,this.manager,this.main);Map j()=>{'n':name,'s':site,'m':manager,'main':main};}
class Hub extends StatefulWidget{const Hub({super.key});@override State<Hub> createState()=>HState();}
class HState extends State<Hub>{int tab=0;bool ready=false;final sites=<Site>[];final days=<Day>[];final items=<Item>[];final movements=<Movement>[];final recipes=<Recipe>[];final warehouses=<Warehouse>[];
Future<void> load()async{final p=await SharedPreferences.getInstance();try{sites.addAll((jsonDecode(p.getString('sites')??'[]') as List).map((x)=>Site(x['n'],x['c'],(x['b'] as num).toDouble(),(x['l'] as num).toDouble(),(x['d'] as num).toDouble())));days.addAll((jsonDecode(p.getString('days')??'[]') as List).map((x)=>Day(x['s'],DateTime.parse(x['t']),x['b'],x['l'],x['d'],x['e'])));items.addAll((jsonDecode(p.getString('items')??'[]') as List).map((x)=>Item(x['n'],x['c'],x['u'],(x['cost'] as num).toDouble(),(x['q'] as num).toDouble(),(x['min'] as num).toDouble())));movements.addAll((jsonDecode(p.getString('movements')??'[]') as List).map((x)=>Movement(x['i'],x['t'],(x['q'] as num).toDouble(),x['n'],DateTime.parse(x['d']))));recipes.addAll((jsonDecode(p.getString('recipes')??'[]') as List).map((x)=>Recipe(x['i'],x['m'],(x['q'] as num).toDouble())));warehouses.addAll((jsonDecode(p.getString('warehouses')??'[]') as List).map((x)=>Warehouse(x['n'],x['s']??'',x['m']??'',x['main']??false)));if(warehouses.isEmpty){warehouses.add(Warehouse('المخزن الرئيسي','كل الشركة','',true));}}catch(_){}setState(()=>ready=true);}
Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('sites',jsonEncode(sites.map((x)=>x.j()).toList()));await p.setString('days',jsonEncode(days.map((x)=>x.j()).toList()));await p.setString('items',jsonEncode(items.map((x)=>x.j()).toList()));await p.setString('movements',jsonEncode(movements.map((x)=>x.j()).toList()));await p.setString('recipes',jsonEncode(recipes.map((x)=>x.j()).toList()));await p.setString('warehouses',jsonEncode(warehouses.map((x)=>x.j()).toList()));}
@override void initState(){super.initState();load();}
bool today(DateTime d){final n=DateTime.now();return d.year==n.year&&d.month==n.month&&d.day==n.day;}
double rev(Day x){final s=sites.where((z)=>z.name==x.site);return s.isEmpty?0:x.b*s.first.b+x.l*s.first.l+x.d*s.first.d;}
int get mealTotal=>days.where((x)=>today(x.date)).fold(0,(a,x)=>a+x.b+x.l+x.d+x.e);
double get revToday=>days.where((x)=>today(x.date)).fold(0.0,(a,x)=>a+rev(x));
double get stock=>items.fold(0.0,(a,x)=>a+x.q*x.cost);
void siteAdd(Site x){setState(()=>sites.add(x));save();}void dayAdd(Day x){setState(()=>days.add(x));save();}void itemAdd(Item x){setState(()=>items.add(x));save();}
@override Widget build(BuildContext c){if(!ready)return const Scaffold(body:Center(child:CircularProgressIndicator()));final views=[dashboard(),sitePage(),dayPage(),itemPage(),reportPage(),warehousePage()];return Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('StockPro | التغذية')),body:views[tab],bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[NavigationDestination(icon:Icon(Icons.home),label:'الرئيسية'),NavigationDestination(icon:Icon(Icons.apartment),label:'المواقع'),NavigationDestination(icon:Icon(Icons.restaurant),label:'الوجبات'),NavigationDestination(icon:Icon(Icons.inventory),label:'المخزون'),NavigationDestination(icon:Icon(Icons.analytics),label:'التقارير'),NavigationDestination(icon:Icon(Icons.warehouse),label:'المخازن')])));}
Widget metric(String title,String val,IconData icon)=>Card(child:ListTile(leading:Icon(icon,color:Colors.teal),title:Text(title),subtitle:Text(val)));
Widget dashboard()=>ListView(padding:const EdgeInsets.all(14),children:[Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Colors.teal.shade900,borderRadius:BorderRadius.circular(16)),child:const Text('إدارة مواقع التغذية والعقود\nالوجبات • المخزون • الإيرادات',style:TextStyle(color:Colors.white,fontSize:21))),metric('إيراد اليوم',cash(revToday),Icons.payments),metric('وجبات اليوم',mealTotal.toString(),Icons.restaurant),metric('عدد المواقع',sites.length.toString(),Icons.apartment),metric('عدد الخامات',items.length.toString(),Icons.inventory),metric('خامات وصلت حد التنبيه',items.where((x)=>x.q<=x.min).length.toString(),Icons.warning),metric('قيمة المخزون',cash(stock),Icons.warehouse),Wrap(spacing:8,children:[FilledButton(onPressed:()=>siteDialog(),child:const Text('إضافة موقع')),FilledButton(onPressed:()=>dayDialog(),child:const Text('تسجيل وجبات')),FilledButton(onPressed:()=>itemDialog(),child:const Text('إضافة خامة'))])]);

Widget warehousePage() => ListView(
  padding: const EdgeInsets.all(12),
  children: [
    Row(children: [
      const Expanded(child: Text('إدارة المخازن', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      FilledButton.icon(onPressed: warehouseDialog, icon: const Icon(Icons.add), label: const Text('مخزن جديد')),
    ]),
    const Card(child: ListTile(
      leading: Icon(Icons.info_outline),
      title: Text('رصيد الخامات الحالي يعتبر تابعًا للمخزن الرئيسي'),
      subtitle: Text('الخطوة القادمة: توزيع الأرصدة على المخازن وربط التحويلات بكل مخزن.'),
    )),
    ...warehouses.map((w) => Card(child: ListTile(
      leading: Icon(w.main ? Icons.warehouse : Icons.store, color: Colors.teal),
      title: Text(w.name),
      subtitle: Text((w.main ? 'مخزن رئيسي' : 'مخزن فرعي') + ' • ' + w.site + (w.manager.isEmpty ? '' : '\\nالمسؤول: ' + w.manager)),
      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => warehouseDialog(existing: w)),
    ))),
  ],
);
Widget sitePage()=>listPage('المواقع والعقود',sites.map((s)=>Card(child:ListTile(title:Text(s.name),subtitle:Text(s.client+'\nإفطار '+cash(s.b)+' / غداء '+cash(s.l)+' / عشاء '+cash(s.d))))).toList(),siteDialog,'إضافة موقع');
Widget dayPage()=>listPage('سجل الوجبات',days.reversed.map((x)=>Card(child:ListTile(title:Text(x.site),subtitle:Text(x.date.day.toString()+'/'+x.date.month.toString()+' | إفطار '+x.b.toString()+' غداء '+x.l.toString()+' عشاء '+x.d.toString()+' إضافي '+x.e.toString()),trailing:Text(cash(rev(x)))))).toList(),dayDialog,'تسجيل وجبات');
Widget itemPage()=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[const Expanded(child:Text('المخزون والخامات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton(onPressed:itemDialog,child:const Text('إضافة خامة'))]),Wrap(spacing:8,children:[OutlinedButton.icon(onPressed:()=>movementDialog('استلام'),icon:const Icon(Icons.add_box),label:const Text('استلام خامات')),OutlinedButton.icon(onPressed:()=>movementDialog('صرف'),icon:const Icon(Icons.remove_circle),label:const Text('صرف خامات')),OutlinedButton.icon(onPressed:recipeDialog,icon:const Icon(Icons.menu_book),label:const Text('وصفات الوجبات'))]),if(items.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('لا توجد خامات بعد'))),...items.map((x)=>Card(child:ListTile(title:Text(x.n),subtitle:Text(x.code+' | '+x.unit+' | حد التنبيه '+qtyText(x.min)),trailing:Text(qtyText(x.q)+' '+x.unit+'\\n'+cash(x.q*x.cost))))),const Padding(padding:EdgeInsets.only(top:12),child:Text('آخر حركات المخزون',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),if(movements.isEmpty)const Text('لا توجد حركات مسجلة'),...movements.reversed.take(30).map((m)=>Card(child:ListTile(leading:Icon(m.type=='استلام'?Icons.arrow_downward:Icons.arrow_upward,color:m.type=='استلام'?Colors.green:Colors.orange),title:Text(m.item+' — '+m.type+' '+qtyText(m.qty)),subtitle:Text(m.date.day.toString()+'/'+m.date.month.toString()+'/'+m.date.year.toString()+(m.note.isEmpty?'':'\\n'+m.note)))))]);
double mealCost(Day x){double total=0;for(final r in recipes){final count=r.meal=='إفطار'?x.b:r.meal=='غداء'?x.l:r.meal=='عشاء'?x.d:0;final found=items.where((i)=>i.n==r.item);if(found.isNotEmpty)total+=count*r.qty*found.first.cost;}return total;}
Widget reportPage(){
  final now=DateTime.now();
  final monthDays=days.where((x)=>x.date.year==now.year&&x.date.month==now.month).toList();
  int mealCount=0;
  double revenue=0;
  for(final entry in monthDays){mealCount+=entry.b+entry.l+entry.d+entry.e;revenue+=rev(entry);}
  final rows=<Widget>[
    const Text('تقرير الشهر الحالي',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
    metric('إجمالي الوجبات',mealCount.toString(),Icons.restaurant),
    metric('إيراد الشهر',cash(revenue),Icons.payments),metric('تكلفة الخامات حسب الوصفات',cash(monthDays.fold(0.0,(a,x)=>a+mealCost(x))),Icons.calculate),metric('هامش بعد تكلفة الخامات',cash(revenue-monthDays.fold(0.0,(a,x)=>a+mealCost(x))),Icons.trending_up),
  ];
  for(final site in sites){
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
Future<void> dayDialog()async{if(sites.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('سجل موقع وعقد أولاً')));return;}Site chosen=sites.first;final b=TextEditingController(text:'0'),l=TextEditingController(text:'0'),d=TextEditingController(text:'0'),e=TextEditingController(text:'0');await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:const Text('تسجيل الوجبات اليومية'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Site>(value:chosen,items:sites.map((s)=>DropdownMenuItem(value:s,child:Text(s.name))).toList(),onChanged:(v){if(v!=null)set(()=>chosen=v);}),field(b,'عدد الإفطار',numeric:true,decimal:false),field(l,'عدد الغداء',numeric:true,decimal:false),field(d,'عدد العشاء',numeric:true,decimal:false),field(e,'وجبات إضافية غير مسعرة',numeric:true,decimal:false),Text('أسعار العقد: '+cash(chosen.b)+' / '+cash(chosen.l)+' / '+cash(chosen.d))])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){final nb=int.tryParse(b.text)??0,nl=int.tryParse(l.text)??0,nd=int.tryParse(d.text)??0,ne=int.tryParse(e.text)??0;final need=<Item,double>{};for(final r in recipes){final count=r.meal=='إفطار'?nb:r.meal=='غداء'?nl:r.meal=='عشاء'?nd:0;final found=items.where((i)=>i.n==r.item);if(found.isNotEmpty)need[found.first]=(need[found.first]??0)+count*r.qty;}final shortage=need.entries.where((e)=>e.value>e.key.q).toList();if(shortage.isNotEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('رصيد غير كافٍ: '+shortage.map((e)=>e.key.n).join('، '))));return;}dayAdd(Day(chosen.name,DateTime.now(),nb,nl,nd,ne));for(final e in need.entries){e.key.q-=e.value;movements.add(Movement(e.key.n,'استهلاك وجبات',e.value,'موقع: '+chosen.name,DateTime.now()));}save();Navigator.pop(x);},child:const Text('حفظ'))])));}
Future<void> movementDialog(String type) async {
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف خامة أولاً')));
    return;
  }
  Item selected = items.first;
  final qty = TextEditingController();
  final note = TextEditingController();
  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text('$type خامات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Item>(
              value: selected,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.n))).toList(),
              onChanged: (value) { if (value != null) setDialogState(() => selected = value); },
            ),
            field(qty, 'الكمية بوحدة '+selected.unit,numeric:true),
            field(note, 'ملاحظات'),
            Text('الرصيد الحالي: '+qtyText(selected.q)+' '+selected.unit),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(qty.text.trim().replaceAll(',', '.'));
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل كمية صحيحة')));
                return;
              }
              if (type == 'صرف' && amount > selected.q) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رصيد غير كافٍ')));
                return;
              }
              selected.q += type == 'استلام' ? amount : -amount;
              movements.add(Movement(selected.n, type, amount, note.text.trim(), DateTime.now()));
              save();
              setState(() {});
              setDialogState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ),
  );
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
