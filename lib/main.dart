import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main()=>runApp(const App());
class App extends StatelessWidget{const App({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:Colors.teal)),home:const Hub());}
class Site{String name,client;double b,l,d;Site(this.name,this.client,this.b,this.l,this.d);Map j()=>{'n':name,'c':client,'b':b,'l':l,'d':d};}
class Day{String site;DateTime date;int b,l,d,e;Day(this.site,this.date,this.b,this.l,this.d,this.e);Map j()=>{'s':site,'t':date.toIso8601String(),'b':b,'l':l,'d':d,'e':e};}
class Item{String n,code,unit;double cost,q,min;Item(this.n,this.code,this.unit,this.cost,this.q,this.min);Map j()=>{'n':n,'c':code,'u':unit,'cost':cost,'q':q,'min':min};}
class Movement{String item,type,note;double qty;DateTime date;Movement(this.item,this.type,this.qty,this.note,this.date);Map j()=>{'i':item,'t':type,'q':qty,'n':note,'d':date.toIso8601String()};}
class Recipe{String item,meal;double qty;Recipe(this.item,this.meal,this.qty);Map j()=>{'i':item,'m':meal,'q':qty};}
class Hub extends StatefulWidget{const Hub({super.key});@override State<Hub> createState()=>HState();}
class HState extends State<Hub>{int tab=0;bool ready=false;final sites=<Site>[];final days=<Day>[];final items=<Item>[];final movements=<Movement>[];final recipes=<Recipe>[];
Future<void> load()async{final p=await SharedPreferences.getInstance();try{sites.addAll((jsonDecode(p.getString('sites')??'[]') as List).map((x)=>Site(x['n'],x['c'],(x['b'] as num).toDouble(),(x['l'] as num).toDouble(),(x['d'] as num).toDouble())));days.addAll((jsonDecode(p.getString('days')??'[]') as List).map((x)=>Day(x['s'],DateTime.parse(x['t']),x['b'],x['l'],x['d'],x['e'])));items.addAll((jsonDecode(p.getString('items')??'[]') as List).map((x)=>Item(x['n'],x['c'],x['u'],(x['cost'] as num).toDouble(),(x['q'] as num).toDouble(),(x['min'] as num).toDouble())));movements.addAll((jsonDecode(p.getString('movements')??'[]') as List).map((x)=>Movement(x['i'],x['t'],(x['q'] as num).toDouble(),x['n'],DateTime.parse(x['d']))));recipes.addAll((jsonDecode(p.getString('recipes')??'[]') as List).map((x)=>Recipe(x['i'],x['m'],(x['q'] as num).toDouble())));}catch(_){}setState(()=>ready=true);}
Future<void> save()async{final p=await SharedPreferences.getInstance();await p.setString('sites',jsonEncode(sites.map((x)=>x.j()).toList()));await p.setString('days',jsonEncode(days.map((x)=>x.j()).toList()));await p.setString('items',jsonEncode(items.map((x)=>x.j()).toList()));await p.setString('movements',jsonEncode(movements.map((x)=>x.j()).toList()));await p.setString('recipes',jsonEncode(recipes.map((x)=>x.j()).toList()));}
@override void initState(){super.initState();load();}
bool today(DateTime d){final n=DateTime.now();return d.year==n.year&&d.month==n.month&&d.day==n.day;}
double rev(Day x){final s=sites.where((z)=>z.name==x.site);return s.isEmpty?0:x.b*s.first.b+x.l*s.first.l+x.d*s.first.d;}
int get mealTotal=>days.where((x)=>today(x.date)).fold(0,(a,x)=>a+x.b+x.l+x.d+x.e);
double get revToday=>days.where((x)=>today(x.date)).fold(0.0,(a,x)=>a+rev(x));
double get stock=>items.fold(0.0,(a,x)=>a+x.q*x.cost);
void siteAdd(Site x){setState(()=>sites.add(x));save();}void dayAdd(Day x){setState(()=>days.add(x));save();}void itemAdd(Item x){setState(()=>items.add(x));save();}
@override Widget build(BuildContext c){if(!ready)return const Scaffold(body:Center(child:CircularProgressIndicator()));final views=[dashboard(),sitePage(),dayPage(),itemPage(),reportPage()];return Directionality(textDirection:TextDirection.rtl,child:Scaffold(appBar:AppBar(title:const Text('StockPro | التغذية')),body:views[tab],bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[NavigationDestination(icon:Icon(Icons.home),label:'الرئيسية'),NavigationDestination(icon:Icon(Icons.apartment),label:'المواقع'),NavigationDestination(icon:Icon(Icons.restaurant),label:'الوجبات'),NavigationDestination(icon:Icon(Icons.inventory),label:'المخزون'),NavigationDestination(icon:Icon(Icons.analytics),label:'التقارير')])));}
Widget metric(String title,String val,IconData icon)=>Card(child:ListTile(leading:Icon(icon,color:Colors.teal),title:Text(title),subtitle:Text(val)));
Widget dashboard()=>ListView(padding:const EdgeInsets.all(14),children:[Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Colors.teal.shade900,borderRadius:BorderRadius.circular(16)),child:const Text('إدارة مواقع التغذية والعقود\nالوجبات • المخزون • الإيرادات',style:TextStyle(color:Colors.white,fontSize:21))),metric('إيراد اليوم',cash(revToday),Icons.payments),metric('وجبات اليوم',mealTotal.toString(),Icons.restaurant),metric('عدد المواقع',sites.length.toString(),Icons.apartment),metric('عدد الخامات',items.length.toString(),Icons.inventory),metric('خامات وصلت حد التنبيه',items.where((x)=>x.q<=x.min).length.toString(),Icons.warning),metric('قيمة المخزون',cash(stock),Icons.warehouse),Wrap(spacing:8,children:[FilledButton(onPressed:()=>siteDialog(),child:const Text('إضافة موقع')),FilledButton(onPressed:()=>dayDialog(),child:const Text('تسجيل وجبات')),FilledButton(onPressed:()=>itemDialog(),child:const Text('إضافة خامة'))])]);
Widget sitePage()=>listPage('المواقع والعقود',sites.map((s)=>Card(child:ListTile(title:Text(s.name),subtitle:Text(s.client+'\nإفطار '+cash(s.b)+' / غداء '+cash(s.l)+' / عشاء '+cash(s.d)),trailing:IconButton(icon:const Icon(Icons.edit),tooltip:'تعديل',onPressed:()=>siteDialog(s))))).toList(),siteDialog,'إضافة موقع');
Widget dayPage()=>listPage('سجل الوجبات',days.reversed.map<Widget>((x)=>Card(child:ListTile(title:Text(x.site),subtitle:Text(x.date.day.toString()+'/'+x.date.month.toString()+' | إفطار '+x.b.toString()+' غداء '+x.l.toString()+' عشاء '+x.d.toString()+' إضافي '+x.e.toString()),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(cash(rev(x))),IconButton(icon:const Icon(Icons.edit),tooltip:'تعديل',onPressed:()=>dayDialog(x))])))).toList(),dayDialog,'تسجيل وجبات');
Widget itemPage()=>ListView(padding:const EdgeInsets.all(12),children:[Row(children:[const Expanded(child:Text('المخزون والخامات',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold))),FilledButton(onPressed:itemDialog,child:const Text('إضافة خامة'))]),Wrap(spacing:8,children:[OutlinedButton.icon(onPressed:()=>movementDialog('استلام'),icon:const Icon(Icons.add_box),label:const Text('استلام خامات')),OutlinedButton.icon(onPressed:()=>movementDialog('صرف'),icon:const Icon(Icons.remove_circle),label:const Text('صرف خامات')),OutlinedButton.icon(onPressed:recipeDialog,icon:const Icon(Icons.menu_book),label:const Text('وصفات الوجبات'))]),const Padding(padding:EdgeInsets.only(top:12),child:Text('الوصفات الحالية',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),if(recipes.isEmpty)const Text('لم تُحدد وصفات بعد'),...recipes.map<Widget>((r)=>Card(child:ListTile(title:Text(r.item+' — '+r.meal),subtitle:Text('استهلاك '+qtyText(r.qty)+' لكل وجبة'),trailing:IconButton(icon:const Icon(Icons.edit),tooltip:'تعديل',onPressed:()=>recipeDialog(r))))).toList(),if(items.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('لا توجد خامات بعد'))),...items.map<Widget>((x)=>Card(child:ListTile(title:Text(x.n),subtitle:Text(x.code+' | '+x.unit+' | حد التنبيه '+qtyText(x.min)),trailing:Row(mainAxisSize:MainAxisSize.min,children:[Text(qtyText(x.q)+' '+x.unit+'\\n'+cash(x.q*x.cost)),IconButton(icon:const Icon(Icons.edit),tooltip:'تعديل',onPressed:()=>itemDialog(x))])))).toList(),const Padding(padding:EdgeInsets.only(top:12),child:Text('آخر حركات المخزون',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))),if(movements.isEmpty)const Text('لا توجد حركات مسجلة'),...movements.reversed.take(30).map<Widget>((m)=>Card(child:ListTile(leading:Icon(m.type=='استلام'?Icons.arrow_downward:Icons.arrow_upward,color:m.type=='استلام'?Colors.green:Colors.orange),title:Text(m.item+' — '+m.type+' '+qtyText(m.qty)),subtitle:Text(m.date.day.toString()+'/'+m.date.month.toString()+'/'+m.date.year.toString()+(m.note.isEmpty?'':'\\n'+m.note)),trailing:IconButton(icon:const Icon(Icons.edit),tooltip:'تعديل',onPressed:()=>movementEditDialog(m))))).toList()]);
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
Future<void> siteDialog([Site? existing])async{final n=TextEditingController(text:existing?.name??''),c=TextEditingController(text:existing?.client??''),b=TextEditingController(text:existing?.b.toString()??'0'),l=TextEditingController(text:existing?.l.toString()??'0'),d=TextEditingController(text:existing?.d.toString()??'0');await showDialog(context:context,builder:(x)=>AlertDialog(title:Text(existing==null?'عقد الموقع':'تعديل عقد الموقع'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n,'اسم الموقع'),field(c,'العميل'),field(b,'سعر الإفطار',numeric:true),field(l,'سعر الغداء',numeric:true),field(d,'سعر العشاء',numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){if(n.text.trim().isEmpty)return;final updated=Site(n.text.trim(),c.text.trim(),double.tryParse(b.text)??0,double.tryParse(l.text)??0,double.tryParse(d.text)??0);if(existing==null){siteAdd(updated);}else{final oldName=existing.name;existing.name=updated.name;existing.client=updated.client;existing.b=updated.b;existing.l=updated.l;existing.d=updated.d;for(final day in days){if(day.site==oldName)day.site=updated.name;}save();setState((){});}Navigator.pop(x);},child:const Text('حفظ'))]));}
Future<void> dayDialog([Day? existing])async{if(sites.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('سجل موقع وعقد أولاً')));return;}Site chosen=sites.firstWhere((s)=>s.name==existing?.site,orElse:()=>sites.first);final b=TextEditingController(text:existing?.b.toString()??'0'),l=TextEditingController(text:existing?.l.toString()??'0'),d=TextEditingController(text:existing?.d.toString()??'0'),e=TextEditingController(text:existing?.e.toString()??'0');await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:Text(existing==null?'تسجيل الوجبات اليومية':'تعديل تسجيل الوجبات'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Site>(value:chosen,items:sites.map((s)=>DropdownMenuItem(value:s,child:Text(s.name))).toList(),onChanged:(v){if(v!=null)set(()=>chosen=v);}),field(b,'عدد الإفطار',numeric:true,decimal:false),field(l,'عدد الغداء',numeric:true,decimal:false),field(d,'عدد العشاء',numeric:true,decimal:false),field(e,'وجبات إضافية غير مسعرة',numeric:true,decimal:false),Text('أسعار العقد: '+cash(chosen.b)+' / '+cash(chosen.l)+' / '+cash(chosen.d))])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){final nb=int.tryParse(b.text)??0,nl=int.tryParse(l.text)??0,nd=int.tryParse(d.text)??0,ne=int.tryParse(e.text)??0;final need=<Item,double>{};for(final r in recipes){final count=r.meal=='إفطار'?nb:r.meal=='غداء'?nl:r.meal=='عشاء'?nd:0;final found=items.where((i)=>i.n==r.item);if(found.isNotEmpty)need[found.first]=(need[found.first]??0)+count*r.qty;}if(existing==null){final shortage=need.entries.where((e)=>e.value>e.key.q).toList();if(shortage.isNotEmpty){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('رصيد غير كافٍ: '+shortage.map((e)=>e.key.n).join('، '))));return;}}if(existing==null){dayAdd(Day(chosen.name,DateTime.now(),nb,nl,nd,ne));for(final entry in need.entries){entry.key.q-=entry.value;movements.add(Movement(entry.key.n,'استهلاك وجبات',entry.value,'موقع: '+chosen.name,DateTime.now()));}}else{final oldNeed=<Item,double>{};for(final r in recipes){final count=r.meal=='إفطار'?existing.b:r.meal=='غداء'?existing.l:r.meal=='عشاء'?existing.d:0;final found=items.where((i)=>i.n==r.item);if(found.isNotEmpty)oldNeed[found.first]=(oldNeed[found.first]??0)+count*r.qty;}for(final item in items){final delta=(oldNeed[item]??0)-(need[item]??0);if(delta<0&&-delta>item.q){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('رصيد غير كافٍ لتعديل الوجبات: '+item.n)));return;}}for(final item in items){final delta=(oldNeed[item]??0)-(need[item]??0);if(delta!=0){item.q+=delta;movements.add(Movement(item.n,'تسوية تعديل وجبات',delta.abs(),'تعديل سجل موقع: '+existing.site+' إلى '+chosen.name,DateTime.now()));}}existing.site=chosen.name;existing.b=nb;existing.l=nl;existing.d=nd;existing.e=ne;save();setState((){});}save();Navigator.pop(x);},child:const Text('حفظ'))])));}
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
Future<void> movementEditDialog(Movement existing)async{
if(existing.type=='استهلاك وجبات'||existing.type=='تسوية تعديل وجبات'){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('حركات استهلاك الوجبات تُعدّل من سجل الوجبات لتجنب اختلاف الأرصدة.')));return;}
Item? oldItem;for(final i in items){if(i.n==existing.item){oldItem=i;break;}}if(oldItem==null)return;
Item selected=oldItem;String type=existing.type;final qty=TextEditingController(text:existing.qty.toString()),note=TextEditingController(text:existing.note);
await showDialog(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,setD)=>AlertDialog(title:const Text('تعديل حركة مخزون'),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)setD(()=>selected=v);}),DropdownButtonFormField<String>(value:type,items:['استلام','صرف'].map((t)=>DropdownMenuItem(value:t,child:Text(t))).toList(),onChanged:(v){if(v!=null)setD(()=>type=v);}),field(qty,'الكمية',numeric:true),field(note,'ملاحظات')]),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('إلغاء')),FilledButton(onPressed:(){final amount=double.tryParse(qty.text.trim().replaceAll(',','.'));if(amount==null||amount<=0)return;final reversed=existing.type=='استلام'?-existing.qty:existing.qty;oldItem!.q+=reversed;final delta=type=='استلام'?amount:-amount;if(selected.q+delta<0){oldItem!.q-=reversed;ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('الرصيد لا يسمح بهذا التعديل')));return;}selected.q+=delta;existing.item=selected.n;existing.type=type;existing.qty=amount;existing.note=note.text.trim();save();setState((){});Navigator.pop(ctx);},child:const Text('حفظ التعديل'))])));
}
Future<void> recipeDialog([Recipe? existing])async{if(items.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('أضف خامات أولاً')));return;}Item selected=items.firstWhere((i)=>i.n==existing?.item,orElse:()=>items.first);String meal=existing?.meal??'إفطار';final q=TextEditingController(text:existing?.qty.toString()??'1');await showDialog(context:context,builder:(x)=>StatefulBuilder(builder:(x,set)=>AlertDialog(title:Text(existing==null?'تحديد استهلاك الخامة لكل وجبة':'تعديل الوصفة'),content:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<Item>(value:selected,items:items.map((i)=>DropdownMenuItem(value:i,child:Text(i.n))).toList(),onChanged:(v){if(v!=null)set(()=>selected=v);}),DropdownButtonFormField<String>(value:meal,items:['إفطار','غداء','عشاء'].map((m)=>DropdownMenuItem(value:m,child:Text(m))).toList(),onChanged:(v){if(v!=null)set(()=>meal=v);}),field(q,'الكمية لكل وجبة بوحدة المخزون',numeric:true),const Text('عند تسجيل الوجبات سيتم خصم الاستهلاك تلقائيًا.')]),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){final qty=double.tryParse(q.text.trim().replaceAll(',', '.'));if(qty==null||qty<=0)return;if(existing!=null){existing.item=selected.n;existing.meal=meal;existing.qty=qty;}else{final old=recipes.where((r)=>r.item==selected.n&&r.meal==meal);if(old.isNotEmpty){old.first.qty=qty;}else{recipes.add(Recipe(selected.n,meal,qty));}}save();setState(()=>{});Navigator.pop(x);},child:const Text('حفظ الوصفة'))])));}
Future<void> itemDialog([Item? existing])async{final n=TextEditingController(text:existing?.n??''),code=TextEditingController(text:existing?.code??''),u=TextEditingController(text:existing?.unit??'كجم'),cost=TextEditingController(text:existing?.cost.toString()??'0'),q=TextEditingController(text:existing?.q.toString()??'0'),min=TextEditingController(text:existing?.min.toString()??'0');await showDialog(context:context,builder:(x)=>AlertDialog(title:Text(existing==null?'بيانات الخامة':'تعديل بيانات الخامة'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[field(n,'اسم المادة'),field(code,'كود/باركود'),field(u,'وحدة القياس'),field(cost,'تكلفة الوحدة',numeric:true),field(q,'الرصيد الحالي',numeric:true),field(min,'حد التنبيه',numeric:true)])),actions:[TextButton(onPressed:()=>Navigator.pop(x),child:const Text('إلغاء')),FilledButton(onPressed:(){if(n.text.trim().isEmpty)return;final updated=Item(n.text.trim(),code.text.trim(),u.text.trim(),double.tryParse(cost.text.trim().replaceAll(',', '.'))??0,double.tryParse(q.text.trim().replaceAll(',', '.'))??0,double.tryParse(min.text.trim().replaceAll(',', '.'))??0);if(existing==null){itemAdd(updated);}else{final oldName=existing.n;existing.n=updated.n;existing.code=updated.code;existing.unit=updated.unit;existing.cost=updated.cost;existing.q=updated.q;existing.min=updated.min;for(final r in recipes){if(r.item==oldName)r.item=updated.n;}for(final m in movements){if(m.item==oldName)m.item=updated.n;}save();setState((){});}Navigator.pop(x);},child:const Text('حفظ'))]));}
}
String cash(double n)=>n.toStringAsFixed(2)+' ج.م';
String qtyText(double n){
  var value=n.toStringAsFixed(3);
  while(value.contains('.')&&value.endsWith('0')){value=value.substring(0,value.length-1);}
  if(value.endsWith('.')){value=value.substring(0,value.length-1);}
  return value;
}
Widget field(TextEditingController x,String label,{bool numeric=false,bool decimal=true})=>Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:x,keyboardType:numeric?TextInputType.numberWithOptions(decimal:decimal):TextInputType.text,decoration:InputDecoration(labelText:label,border:const OutlineInputBorder())));
