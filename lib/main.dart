import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const StockProApp());

class StockProApp extends StatelessWidget {
  const StockProApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'StockPro',
    locale: const Locale('ar'),
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16856B)), scaffoldBackgroundColor: const Color(0xFFF5F7F8)),
    home: const MainShell(),
  );
}

class Product {
  Product({required this.name, required this.code, required this.buy, required this.sell, required this.qty, required this.minQty});
  String name, code;
  double buy, sell;
  int qty, minQty;
  Map<String, dynamic> toJson() => {'name': name, 'code': code, 'buy': buy, 'sell': sell, 'qty': qty, 'minQty': minQty};
  factory Product.fromJson(Map<String, dynamic> j) => Product(name: j['name'] ?? '', code: j['code'] ?? '', buy: (j['buy'] as num? ?? 0).toDouble(), sell: (j['sell'] as num? ?? 0).toDouble(), qty: (j['qty'] as num? ?? 0).toInt(), minQty: (j['minQty'] as num? ?? 0).toInt());
}

class SaleRecord {
  SaleRecord({required this.productName, required this.code, required this.quantity, required this.total, required this.profit, required this.date});
  final String productName, code;
  final int quantity;
  final double total, profit;
  final DateTime date;
  Map<String, dynamic> toJson() => {'productName': productName, 'code': code, 'quantity': quantity, 'total': total, 'profit': profit, 'date': date.toIso8601String()};
  factory SaleRecord.fromJson(Map<String, dynamic> j) => SaleRecord(productName: j['productName'] ?? '', code: j['code'] ?? '', quantity: (j['quantity'] as num? ?? 0).toInt(), total: (j['total'] as num? ?? 0).toDouble(), profit: (j['profit'] as num? ?? 0).toDouble(), date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now());
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int tab = 0;
  final products = <Product>[];
  final saleRecords = <SaleRecord>[];
  bool loading = true;
  double get salesToday => saleRecords.where((s) => s.date.year == DateTime.now().year && s.date.month == DateTime.now().month && s.date.day == DateTime.now().day).fold(0, (sum, s) => sum + s.total);
  double get profitToday => saleRecords.where((s) => s.date.year == DateTime.now().year && s.date.month == DateTime.now().month && s.date.day == DateTime.now().day).fold(0, (sum, s) => sum + s.profit);
  @override
  void initState() { super.initState(); loadData(); }
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pj = prefs.getString('stockpro_products'); final sj = prefs.getString('stockpro_sales');
      if (pj != null) products.addAll((jsonDecode(pj) as List).map((e) => Product.fromJson(Map<String, dynamic>.from(e))));
      if (sj != null) saleRecords.addAll((jsonDecode(sj) as List).map((e) => SaleRecord.fromJson(Map<String, dynamic>.from(e))));
    } catch (_) {}
    if (mounted) setState(() => loading = false);
  }
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stockpro_products', jsonEncode(products.map((p) => p.toJson()).toList()));
    await prefs.setString('stockpro_sales', jsonEncode(saleRecords.map((s) => s.toJson()).toList()));
  }
  void addProduct(Product p) { setState(() => products.add(p)); saveData(); }
  void recordSale(Product p, int qty) {
    if (qty <= 0 || qty > p.qty) return;
    setState(() { p.qty -= qty; saleRecords.add(SaleRecord(productName: p.name, code: p.code, quantity: qty, total: p.sell * qty, profit: (p.sell - p.buy) * qty, date: DateTime.now())); });
    saveData();
  }
  @override
  Widget build(BuildContext context) {
    if (loading) return const Directionality(textDirection: TextDirection.rtl, child: Scaffold(body: Center(child: CircularProgressIndicator())));
    final pages = [
      Dashboard(products: products, sales: salesToday, profit: profitToday, onAdd: () => showProductDialog(context, addProduct), onSale: () => showSaleDialog(context, products, recordSale)),
      ProductsPage(products: products, onAdd: () => showProductDialog(context, addProduct)),
      SalesPage(sales: salesToday, profit: profitToday, onSale: () => showSaleDialog(context, products, recordSale)),
      const ReportsPage(),
    ];
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      appBar: AppBar(title: const Text('StockPro', style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))]),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'الأصناف'),
        NavigationDestination(icon: Icon(Icons.point_of_sale_outlined), selectedIcon: Icon(Icons.point_of_sale), label: 'المبيعات'),
        NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'التقارير'),
      ]),
    ));
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.products, required this.sales, required this.profit, required this.onAdd, required this.onSale});
  final List<Product> products;
  final double sales, profit;
  final VoidCallback onAdd, onSale;
  String money(double x) => '${x.toStringAsFixed(2)} ج.م';
  @override
  Widget build(BuildContext context) {
    final stockValue = products.fold<double>(0, (s, p) => s + p.buy * p.qty);
    final low = products.where((p) => p.qty <= p.minQty).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF123B35), borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('أهلاً بك 👋', style: TextStyle(color: Colors.white70)), SizedBox(height: 6),
        Text('إدارة متجرك بذكاء', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 5),
        Text('تابع حركة البيع والمخزون من مكان واحد', style: TextStyle(color: Colors.white70)),
      ])),
      const SizedBox(height: 16),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4, children: [
        StatCard(title: 'مبيعات اليوم', value: money(sales), icon: Icons.payments_outlined, color: Colors.teal),
        StatCard(title: 'صافي الربح', value: money(profit), icon: Icons.trending_up, color: Colors.green),
        StatCard(title: 'عدد الأصناف', value: '${products.length}', icon: Icons.inventory_2_outlined, color: Colors.blue),
        StatCard(title: 'نواقص المخزون', value: '$low', icon: Icons.warning_amber_rounded, color: Colors.orange),
      ]),
      const SizedBox(height: 18), Text('عمليات سريعة', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 10),
      Row(children: [Expanded(child: FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('إضافة صنف'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: onSale, icon: const Icon(Icons.receipt_long), label: const Text('فاتورة بيع')))]),
      const SizedBox(height: 18),
      Card(child: ListTile(leading: const Icon(Icons.warehouse_outlined), title: const Text('قيمة المخزون بالتكلفة'), subtitle: Text(money(stockValue)))),
      Card(child: ListTile(leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange), title: const Text('تنبيه المخزون'), subtitle: Text(low == 0 ? 'لا توجد أصناف منخفضة حالياً' : '$low صنف وصل للحد الأدنى أو أقل'))),
      const SizedBox(height: 10), Text('آخر الأصناف', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      if (products.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('لسه مفيش أصناف — أضف أول صنف من زر إضافة صنف')))),
      ...products.take(5).map((p) => Card(child: ListTile(title: Text(p.name), subtitle: Text('كود: ${p.code} • الرصيد: ${p.qty}'), trailing: Text(money(p.sell))))),
    ]);
  }
}
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color});
  final String title, value; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: color, size: 25), Text(title, style: const TextStyle(color: Colors.black54)), FittedBox(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)))])));
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key, required this.products, required this.onAdd});
  final List<Product> products; final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => SimpleListPage(title: 'قائمة الأصناف', action: FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('إضافة')), empty: 'لم يتم إضافة أصناف بعد', children: products.map((p) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.inventory_2)), title: Text(p.name), subtitle: Text('كود ${p.code} | رصيد ${p.qty} | حد أدنى ${p.minQty}'), trailing: Text('${p.sell.toStringAsFixed(2)} ج.م')))).toList());
}
class SalesPage extends StatelessWidget {
  const SalesPage({super.key, required this.sales, required this.profit, required this.onSale});
  final double sales, profit; final VoidCallback onSale;
  @override
  Widget build(BuildContext context) => SimpleListPage(title: 'المبيعات', action: FilledButton.icon(onPressed: onSale, icon: const Icon(Icons.add), label: const Text('بيع جديد')), empty: 'ابدأ بتسجيل أول عملية بيع', children: [
    Card(child: ListTile(title: const Text('إجمالي مبيعات اليوم'), trailing: Text('${sales.toStringAsFixed(2)} ج.م'))),
    Card(child: ListTile(title: const Text('ربح اليوم التقديري'), trailing: Text('${profit.toStringAsFixed(2)} ج.م'))),
    const Padding(padding: EdgeInsets.all(12), child: Text('نسخة تجريبية: سجل البيع يخصم الرصيد ويحسب المبيعات والربح مباشرة.')),
  ]);
}
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) => const SimpleListPage(title: 'التقارير', empty: 'التقارير التفصيلية هتضاف في المرحلة القادمة', children: [
    Card(child: ListTile(leading: Icon(Icons.bar_chart), title: Text('تقرير المبيعات والأرباح'), subtitle: Text('قريباً'))),
    Card(child: ListTile(leading: Icon(Icons.inventory), title: Text('تقرير حركة المخزون'), subtitle: Text('قريباً'))),
    Card(child: ListTile(leading: Icon(Icons.file_download_outlined), title: Text('تصدير Excel وPDF'), subtitle: Text('قريباً'))),
  ]);
}
class SimpleListPage extends StatelessWidget {
  const SimpleListPage({super.key, required this.title, this.action, required this.empty, required this.children});
  final String title, empty; final Widget? action; final List<Widget> children;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), if (action != null) action!]),
    const SizedBox(height: 12), if (children.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(22), child: Center(child: Text(empty)))), ...children,
  ]);
}

Future<void> showProductDialog(BuildContext context, Function(Product) onSave) async {
  final name = TextEditingController(), code = TextEditingController(), buy = TextEditingController(), sell = TextEditingController(), qty = TextEditingController(), min = TextEditingController(text: '5');
  await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('إضافة صنف جديد'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [field(name, 'اسم الصنف'), field(code, 'كود الصنف / الباركود'), field(buy, 'سعر الشراء', numeric: true), field(sell, 'سعر البيع', numeric: true), field(qty, 'الرصيد الحالي', numeric: true), field(min, 'حد التنبيه', numeric: true)])), actions: [
    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
    FilledButton(onPressed: () { if (name.text.trim().isEmpty || code.text.trim().isEmpty) return; onSave(Product(name: name.text.trim(), code: code.text.trim(), buy: double.tryParse(buy.text) ?? 0, sell: double.tryParse(sell.text) ?? 0, qty: int.tryParse(qty.text) ?? 0, minQty: int.tryParse(min.text) ?? 0)); Navigator.pop(ctx); }, child: const Text('حفظ')),
  ]));
}
Future<void> showSaleDialog(BuildContext context, List<Product> products, Function(Product, int) onSale) async {
  if (products.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أضف أصناف أولاً قبل تسجيل البيع'))); return; }
  Product selected = products.first; final quantity = TextEditingController(text: '1');
  await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(title: const Text('تسجيل عملية بيع'), content: Column(mainAxisSize: MainAxisSize.min, children: [
    DropdownButtonFormField<Product>(value: selected, items: products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (رصيد ${p.qty})'))).toList(), onChanged: (p) { if (p != null) setDialog(() => selected = p); }, decoration: const InputDecoration(labelText: 'الصنف')),
    field(quantity, 'الكمية', numeric: true), const SizedBox(height: 8), Text('الإجمالي: ${(selected.sell * (int.tryParse(quantity.text) ?? 0)).toStringAsFixed(2)} ج.م'),
  ]), actions: [
    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
    FilledButton(onPressed: () { final q = int.tryParse(quantity.text) ?? 0; if (q <= 0 || q > selected.qty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكمية غير صحيحة أو أكبر من الرصيد'))); return; } onSale(selected, q); Navigator.pop(ctx); }, child: const Text('تأكيد البيع')),
  ])));
}
Widget field(TextEditingController c, String label, {bool numeric = false}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true)));
