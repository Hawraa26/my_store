import 'package:flutter/material.dart';
import 'product.dart';
import 'network.dart';

void main() {
  runApp(const MyApp());
}

// =====================================================
// MyApp
// =====================================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  void changeTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // =================================================
      // Light Theme
      // =================================================

      theme: ThemeData(
        brightness: Brightness.light,

        scaffoldBackgroundColor:
        const Color(0xFFFFF8F8),

        cardColor: Colors.white,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB76E79),
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF8F8),
          foregroundColor: Color(0xFF2D2527),
          elevation: 0,
        ),

        navigationBarTheme:
        const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFF3D7DA),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // =================================================
      // Dark Theme
      // =================================================

      darkTheme: ThemeData(
        brightness: Brightness.dark,

        scaffoldBackgroundColor:
        const Color(0xFF121212),

        cardColor:
        const Color(0xFF1E1E1E),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB76E79),
          brightness: Brightness.dark,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        navigationBarTheme:
        const NavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          indicatorColor: Color(0xFF5A343B),
        ),
      ),

      themeMode: themeMode,

      home: HomePage(
        changeTheme: changeTheme,
      ),
    );
  }
}

// =====================================================
// HomePage
// =====================================================

class HomePage extends StatefulWidget {
  final VoidCallback changeTheme;

  const HomePage({
    super.key,
    required this.changeTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  List<Product> products = [];

  List<Map<String, dynamic>> cart = [];

  List<Product> favorites = [];

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

  String selectedCategory = 'All';

  // =====================================================
  // Add To Cart
  // =====================================================

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere(
            (item) => item['product'].id == product.id,
      );

      if (index != -1) {
        cart[index]['quantity']++;
      } else {
        cart.add({
          'product': product,
          'quantity': 1,
        });
      }
    });
  }

  // =====================================================
  // Remove From Cart
  // =====================================================

  void removeFromCart(Product product) {
    setState(() {
      cart.removeWhere(
            (item) => item['product'].id == product.id,
      );
    });
  }

  // =====================================================
  // Increase Quantity
  // =====================================================

  void increaseQuantity(Product product) {
    setState(() {
      final index = cart.indexWhere(
            (item) => item['product'].id == product.id,
      );

      if (index != -1) {
        cart[index]['quantity']++;
      }
    });
  }

  // =====================================================
  // Decrease Quantity
  // =====================================================

  void decreaseQuantity(Product product) {
    setState(() {
      final index = cart.indexWhere(
            (item) => item['product'].id == product.id,
      );

      if (index != -1) {
        if (cart[index]['quantity'] > 1) {
          cart[index]['quantity']--;
        }
      }
    });
  }

  // =====================================================
  // Favorites
  // =====================================================

  void toggleFavorite(Product product) {
    setState(() {
      if (favorites.any(
            (item) => item.id == product.id,
      )) {
        favorites.removeWhere(
              (item) => item.id == product.id,
        );
      } else {
        favorites.add(product);
      }
    });
  }

  // =====================================================
  // Category Button
  // =====================================================

  Widget _categoryButton(String category) {
    final bool isSelected =
        selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        label: Text(category),

        selected: isSelected,

        onSelected: (selected) {
          setState(() {
            selectedCategory = category;
          });
        },

        selectedColor:
        const Color(0xFFB76E79),

        backgroundColor:
        Theme.of(context).cardColor,

        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context)
              .colorScheme
              .onSurface,

          fontWeight: FontWeight.w600,
        ),

        side: BorderSide(
          color: isSelected
              ? const Color(0xFFB76E79)
              : const Color(0xFFE4D9DB),
        ),

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),
      ),
    );
  }

  // =====================================================
  // Get Products From API
  // =====================================================

  Future<void> getProducts() async {
    try {
      final response = await Network().get(
        'https://dummyjson.com/products',
      );

      final List data =
      response.data['products'];

      setState(() {
        products = data
            .map(
              (item) => Product.fromJson(item),
        )
            .toList();
      });
    } catch (e) {
      debugPrint(
        'Error loading products: $e',
      );
    }
  }

  // =====================================================
  // Init State
  // =====================================================

  @override
  void initState() {
    super.initState();

    getProducts();
  }

  // =====================================================
  // Dispose
  // =====================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // Build
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final filteredProducts =
    products.where((product) {
      final bool matchesSearch =
      product.title
          .toLowerCase()
          .contains(
        searchText.toLowerCase(),
      );

      final String productCategory =
      product.category
          .toLowerCase()
          .replaceAll('-', ' ');

      final String chosenCategory =
      selectedCategory
          .toLowerCase();

      final bool matchesCategory =
          selectedCategory == 'All' ||
              productCategory ==
                  chosenCategory;

      return matchesSearch &&
          matchesCategory;
    }).toList();

    return Scaffold(

      // =================================================
      // AppBar
      // =================================================

      appBar: AppBar(
        title: const Text(
          'My Store',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: false,
      ),

      // =================================================
      // Body
      // =================================================

      body: selectedIndex == 0

      // =================================================
      // HOME
      // =================================================

          ? Padding(
        padding:
        const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          0,
        ),

        child: Column(
          children: [

            // =================================================
            // Search Bar
            // =================================================

            TextField(
              controller:
              searchController,

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },

              decoration:
              InputDecoration(
                hintText:
                'Search products...',

                hintStyle:
                const TextStyle(
                  color:
                  Color(0xFF9B8D90),
                ),

                prefixIcon:
                const Icon(
                  Icons.search,
                  color:
                  Color(0xFFB76E79),
                ),

                suffixIcon:
                searchText.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController
                        .clear();

                    setState(() {
                      searchText =
                      '';
                    });
                  },

                  icon:
                  const Icon(
                    Icons.clear,
                  ),
                )
                    : null,

                filled: true,

                fillColor:
                Theme.of(context)
                    .cardColor,

                contentPadding:
                const EdgeInsets
                    .symmetric(
                  vertical: 16,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(18),

                  borderSide:
                  BorderSide.none,
                ),

                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(18),

                  borderSide:
                  const BorderSide(
                    color:
                    Color(0xFFB76E79),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            // =================================================
            // Categories Title
            // =================================================

            Align(
              alignment:
              Alignment.centerLeft,

              child: Text(
                'Categories',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================
            // Categories
            // =================================================

            SizedBox(
              height: 42,

              child: ListView(
                scrollDirection:
                Axis.horizontal,

                children: [
                  _categoryButton(
                    'All',
                  ),

                  _categoryButton(
                    'Beauty',
                  ),

                  _categoryButton(
                    'Fragrances',
                  ),

                  _categoryButton(
                    'Skin Care',
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =================================================
            // Products Grid
            // =================================================

            Expanded(
              child:
              filteredProducts.isEmpty
                  ? const Center(
                child: Text(
                  'No products found',
                  style:
                  TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),
              )
                  : GridView.builder(
                padding:
                const EdgeInsets
                    .only(
                  bottom: 16,
                ),

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                  2,

                  crossAxisSpacing:
                  12,

                  mainAxisSpacing:
                  12,

                  // Increased height
                  // to avoid overflow.
                  childAspectRatio:
                  0.55,
                ),

                itemCount:
                filteredProducts
                    .length,

                itemBuilder:
                    (context,
                    index) {
                  final product =
                  filteredProducts[
                  index];

                  final bool
                  isFavorite =
                  favorites.any(
                        (item) =>
                    item.id ==
                        product.id,
                  );

                  return Card(
                    elevation:
                    2,

                    color:
                    Theme.of(
                        context)
                        .cardColor,

                    shadowColor:
                    Colors
                        .black12,

                    clipBehavior:
                    Clip.antiAlias,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                    ),

                    child:
                    InkWell(
                      onTap: () {
                        Navigator
                            .push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                ProductDetailsPage(
                                  product:
                                  product,
                                  addToCart:
                                  addToCart,
                                ),
                          ),
                        );
                      },

                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [

                          // =================================================
                          // Product Image
                          // =================================================

                          Expanded(
                            flex:
                            4,

                            child:
                            Stack(
                              children: [

                                // Image background

                                Positioned
                                    .fill(
                                  child:
                                  Container(
                                    margin:
                                    const EdgeInsets.all(
                                      8,
                                    ),

                                    decoration:
                                    BoxDecoration(
                                      color:
                                      const Color(0xFFFFF3F4),

                                      borderRadius:
                                      BorderRadius.circular(
                                        16,
                                      ),
                                    ),

                                    child:
                                    Padding(
                                      padding:
                                      const EdgeInsets.all(
                                        10,
                                      ),

                                      child:
                                      Image.network(
                                        product.thumbnail,

                                        fit:
                                        BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                // =================================================
                                // Favorite Button
                                // =================================================

                                Positioned(
                                  top:
                                  12,

                                  right:
                                  12,

                                  child:
                                  Material(
                                    color:
                                    Colors.transparent,

                                    child:
                                    Ink(
                                      decoration:
                                      BoxDecoration(
                                        color:
                                        Theme.of(context)
                                            .cardColor,

                                        shape:
                                        BoxShape.circle,

                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius:
                                            8,

                                            offset:
                                            Offset(
                                              0,
                                              2,
                                            ),

                                            color:
                                            Colors.black12,
                                          ),
                                        ],
                                      ),

                                      child:
                                      IconButton(
                                        onPressed:
                                            () {
                                          toggleFavorite(
                                              product);
                                        },

                                        icon:
                                        Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,

                                          color:
                                          isFavorite
                                              ? const Color(
                                            0xFFB76E79,
                                          )
                                              : const Color(
                                            0xFF8A7A7D,
                                          ),
                                        ),

                                        iconSize:
                                        21,

                                        splashRadius:
                                        22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // =================================================
                          // Product Information
                          // =================================================

                          Expanded(
                            flex:
                            3,

                            child:
                            Padding(
                              padding:
                              const EdgeInsets.fromLTRB(
                                10,
                                6,
                                10,
                                10,
                              ),

                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  // Product Name

                                  Text(
                                    product.title,

                                    maxLines:
                                    2,

                                    overflow:
                                    TextOverflow.ellipsis,

                                    style:
                                    TextStyle(
                                      fontSize:
                                      14.5,

                                      fontWeight:
                                      FontWeight.w600,

                                      color:
                                      Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                    5,
                                  ),

                                  // Price

                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',

                                    style:
                                    const TextStyle(
                                      fontSize:
                                      17,

                                      fontWeight:
                                      FontWeight.bold,

                                      color:
                                      Color(0xFFB76E79),
                                    ),
                                  ),

                                  const Spacer(),

                                  // =================================================
                                  // Add To Cart
                                  // =================================================

                                  SizedBox(
                                    width:
                                    double.infinity,

                                    height:
                                    40,

                                    child:
                                    ElevatedButton.icon(
                                      onPressed:
                                          () {
                                        addToCart(
                                            product);
                                      },

                                      icon:
                                      const Icon(
                                        Icons.shopping_bag_outlined,
                                        size:
                                        17,
                                      ),

                                      label:
                                      const Text(
                                        'Add to Cart',
                                        style:
                                        TextStyle(
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),

                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFFB76E79),

                                        foregroundColor:
                                        Colors.white,

                                        elevation:
                                        0,

                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal:
                                          8,
                                        ),

                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )

      // =================================================
      // FAVORITES
      // =================================================

          : selectedIndex == 1
          ? FavoritesPage(
        favorites: favorites,
      )

      // =================================================
      // CART
      // =================================================

          : selectedIndex == 2
          ? CartPage(
        cart: cart,
        removeFromCart:
        removeFromCart,
        increaseQuantity:
        increaseQuantity,
        decreaseQuantity:
        decreaseQuantity,
      )

      // =================================================
      // SETTINGS
      // =================================================

          : SettingsPage(
        changeTheme:
        widget.changeTheme,
      ),

      // =================================================
      // Navigation Bar
      // =================================================

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        selectedIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),

            selectedIcon: Icon(
              Icons.home,
            ),

            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
            ),

            selectedIcon: Icon(
              Icons.favorite,
            ),

            label: 'Favorites',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.shopping_cart_outlined,
            ),

            selectedIcon: Icon(
              Icons.shopping_cart,
            ),

            label: 'Cart',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),

            selectedIcon: Icon(
              Icons.settings,
            ),

            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Product Details Page
// =====================================================

class ProductDetailsPage
    extends StatelessWidget {
  final Product product;

  final void Function(Product)
  addToCart;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
        ),
      ),

      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =================================================
            // Product Image
            // =================================================

            Container(
              width:
              double.infinity,

              height: 300,

              decoration:
              BoxDecoration(
                color:
                const Color(0xFFFFF3F4),

                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),

                child:
                Image.network(
                  product.thumbnail,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // Product Name
            // =================================================

            Text(
              product.title,

              style:
              const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // =================================================
            // Price
            // =================================================

            Text(
              '\$${product.price.toStringAsFixed(2)}',

              style:
              const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
                color:
                Color(0xFFB76E79),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // =================================================
            // Description
            // =================================================

            const Text(
              'Description',

              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              product.description,

              style:
              const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // =================================================
            // Add To Cart
            // =================================================

            SizedBox(
              width:
              double.infinity,

              height: 50,

              child:
              ElevatedButton.icon(
                onPressed: () {
                  addToCart(
                    product,
                  );
                },

                icon:
                const Icon(
                  Icons.shopping_cart,
                ),

                label:
                const Text(
                  'Add to Cart',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFFB76E79,
                  ),

                  foregroundColor:
                  Colors.white,

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// Cart Page
// =====================================================

class CartPage
    extends StatelessWidget {
  final List<Map<String, dynamic>>
  cart;

  final void Function(Product)
  removeFromCart;

  final void Function(Product)
  increaseQuantity;

  final void Function(Product)
  decreaseQuantity;

  const CartPage({
    super.key,
    required this.cart,
    required this.removeFromCart,
    required this.increaseQuantity,
    required this.decreaseQuantity,
  });

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;

    for (final item in cart) {
      final product =
      item['product'] as Product;

      final quantity =
      item['quantity'] as int;

      totalPrice +=
          product.price * quantity;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
        ),
      ),

      body: cart.isEmpty

      // =================================================
      // Empty Cart
      // =================================================

          ? const Center(
        child: Text(
          'Your cart is empty',

          style: TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      )

      // =================================================
      // Cart Products
      // =================================================

          : Column(
        children: [

          Expanded(
            child:
            ListView.builder(
              padding:
              const EdgeInsets
                  .all(16),

              itemCount:
              cart.length,

              itemBuilder:
                  (context, index) {
                final product =
                cart[index]
                ['product']
                as Product;

                final quantity =
                cart[index]
                ['quantity']
                as int;

                return Card(
                  margin:
                  const EdgeInsets
                      .only(
                    bottom: 12,
                  ),

                  child:
                  ListTile(
                    leading:
                    ClipRRect(
                      borderRadius:
                      BorderRadius
                          .circular(
                        10,
                      ),

                      child:
                      Image.network(
                        product
                            .thumbnail,

                        width: 60,
                        height: 60,

                        fit: BoxFit.cover,
                      ),
                    ),

                    title:
                    Text(
                      product.title,

                      maxLines: 1,

                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),

                    subtitle:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          '\$${product.price.toStringAsFixed(2)}',

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,

                            color:
                            Color(0xFFB76E79),
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
                          children: [

                            IconButton(
                              onPressed:
                                  () {
                                decreaseQuantity(
                                  product,
                                );
                              },

                              icon:
                              const Icon(
                                Icons.remove,
                              ),
                            ),

                            Text(
                              '$quantity',

                              style:
                              const TextStyle(
                                fontSize:
                                16,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              onPressed:
                                  () {
                                increaseQuantity(
                                  product,
                                );
                              },

                              icon:
                              const Icon(
                                Icons.add,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    trailing:
                    IconButton(
                      onPressed: () {
                        removeFromCart(
                          product,
                        );
                      },

                      icon:
                      const Icon(
                        Icons.delete_outline,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // =================================================
          // Total Price
          // =================================================

          Container(
            padding:
            const EdgeInsets
                .fromLTRB(
              20,
              16,
              20,
              20,
            ),

            decoration:
            BoxDecoration(
              color:
              Theme.of(context)
                  .cardColor,

              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset:
                  Offset(0, -2),
                  color:
                  Colors.black12,
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

              children: [

                const Text(
                  'Total Price',

                  style:
                  TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',

                  style:
                  const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,

                    color:
                    Color(0xFFB76E79),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Favorites Page
// =====================================================

class FavoritesPage
    extends StatelessWidget {
  final List<Product> favorites;

  const FavoritesPage({
    super.key,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
        ),
      ),

      body: favorites.isEmpty

      // =================================================
      // Empty Favorites
      // =================================================

          ? const Center(
        child: Text(
          'No favorite products',

          style: TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      )

      // =================================================
      // Favorite Products
      // =================================================

          : ListView.builder(
        padding:
        const EdgeInsets.all(
          16,
        ),

        itemCount:
        favorites.length,

        itemBuilder:
            (context, index) {
          final product =
          favorites[index];

          return Card(
            margin:
            const EdgeInsets
                .only(
              bottom: 12,
            ),

            child: ListTile(
              leading:
              ClipRRect(
                borderRadius:
                BorderRadius
                    .circular(
                  10,
                ),

                child:
                Image.network(
                  product.thumbnail,

                  width: 60,
                  height: 60,

                  fit: BoxFit.cover,
                ),
              ),

              title: Text(
                product.title,

                maxLines: 1,

                overflow:
                TextOverflow
                    .ellipsis,
              ),

              subtitle: Text(
                '\$${product.price.toStringAsFixed(2)}',

                style:
                const TextStyle(
                  color:
                  Color(0xFFB76E79),

                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              trailing:
              const Icon(
                Icons.favorite,
                color:
                Color(0xFFB76E79),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// Settings Page
// =====================================================

class SettingsPage
    extends StatelessWidget {
  final VoidCallback changeTheme;

  const SettingsPage({
    super.key,
    required this.changeTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(
            'Settings',

            style:
            TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          const Text(
            'Appearance',

            style:
            TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Card(
            child:
            ListTile(
              leading:
              const Icon(
                Icons.dark_mode,
                color:
                Color(0xFFB76E79),
              ),

              title:
              const Text(
                'Dark Mode',

                style:
                TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),

              trailing:
              Switch(
                value:
                Theme.of(context)
                    .brightness ==
                    Brightness.dark,

                onChanged:
                    (value) {
                  changeTheme();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}