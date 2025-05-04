import 'package:flutter/material.dart';
import 'package:kosan_euy/screens/makanan/add_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFoodTab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
                      onPressed: () {
                        // Go back action
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddFoodScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _showFoodTab ? 'Cari Makanan Untukmu' : 'Cari Minuman Untukmu',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        'Cari Makan...',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showFoodTab = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showFoodTab ? const Color(0xFFE0BFFF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Makanan',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: _showFoodTab ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showFoodTab = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: !_showFoodTab ? const Color(0xFFE0BFFF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Minuman',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: !_showFoodTab ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _showFoodTab ? const FoodGridView() : const DrinkGridView(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D9DAB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () {
                      // Edit action
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodGridView extends StatelessWidget {
  const FoodGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> foodItems = [
      {
        'name': 'Indomie kuah/goreng Spesial',
        'price': 'RP 8.000',
        'image': 'assets/food6.png',
      },
      {
        'name': 'Nasi Goreng Telur',
        'price': 'RP 12.000',
        'image': 'assets/food5.png',
      },
      {
        'name': 'Telur Dadar',
        'price': 'RP 6.000',
        'image': 'assets/food4.png',
      },
      {
        'name': 'Telur Ceplok',
        'price': 'RP 7.000',
        'image': 'assets/food3.png',
      },
      {
        'name': 'Nasi Putih',
        'price': 'RP 5.000',
        'image': 'assets/food2.png',
      },
      {
        'name': 'Midog',
        'price': 'RP 5.000',
        'image': 'assets/food1.png',
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        return FoodItemCard(
          name: foodItems[index]['name'],
          price: foodItems[index]['price'],
          imagePath: foodItems[index]['image'],
        );
      },
    );
  }
}

class DrinkGridView extends StatelessWidget {
  const DrinkGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> drinkItems = [
      {
        'name': 'Es Teh/hangat',
        'price': 'RP 4.000',
        'image': 'assets/drink1.png',
      },
      {
        'name': 'Es Nutrisari',
        'price': 'RP 5.000',
        'image': 'assets/drink2.png',
      },
      {
        'name': 'Es Kopi Good Day',
        'price': 'RP 5.000',
        'image': 'assets/drink3.png',
      },
      {
        'name': 'Es Milo',
        'price': 'RP 7.000',
        'image': 'assets/drink4.png',
      },
      {
        'name': 'Es Sirsir',
        'price': 'RP 5.000',
        'image': 'assets/drink5.png',
      },
      {
        'name': 'Es Dancow',
        'price': 'RP 7.000',
        'image': 'assets/drink6.png',
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: drinkItems.length,
      itemBuilder: (context, index) {
        return FoodItemCard(
          name: drinkItems[index]['name'],
          price: drinkItems[index]['price'],
          imagePath: drinkItems[index]['image'],
        );
      },
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;

  const FoodItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          price,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4D9DAB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Tambah Menu"),
                          duration: Duration(seconds: 1),
                          showCloseIcon: true,
                        ),
                      );
                    },
                    child: const Text(
                      'Tambah',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



