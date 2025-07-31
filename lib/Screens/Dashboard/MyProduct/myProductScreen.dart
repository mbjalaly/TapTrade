import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/TradeRequest/tradeRequest.dart';
import 'package:taptrade/Screens/Dashboard/ContactTrader/contactTrader.dart';
import 'package:taptrade/Screens/UserDetail/Product/addProduct.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/Screens/Dashboard/MyProduct/likedDealsForProductScreen.dart';

class MyProductScreen extends StatefulWidget {
  const MyProductScreen({Key? key}) : super(key: key);

  @override
  _MyProductScreenState createState() => _MyProductScreenState();
}

class _MyProductScreenState extends State<MyProductScreen> with SingleTickerProviderStateMixin {
  var userController = Get.find<UserController>();
  var productController = Get.find<ProductController>();
  bool isLoading = false;
  bool isDeleting = false;
  int selectedIndex = -1;
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<Color> cardColors = const [
    Color(0xfffff585),
    Color(0xff61ffdd),
    Color(0xffc3f8be),
    Color(0xfffee598),
    Color(0xff9feefe),
    Color(0xff61fddd),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    getData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getData() async {
    try {
      setState(() {
        isLoading = true;
      });

      String id = userController.userProfile.value.data?.id ?? '';
      if (id.isNotEmpty) {
        await ProductService.instance.getMyProduct(context, id);
        await ProductService.instance.getTradeRequestProduct(context, id);
        await ProductService.instance.getLikeProduct(context, id); // Added to fetch liked products
      }
    } catch (e) {
      print("Error occurred while fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: _selectedTabIndex == 0 ? Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () async {
            await Get.to(() => AddProductScreen(
                  isDirect: true,
                ));
            getData();
          },
          child: Icon(
            Icons.add,
            color: AppColors.darkBlue, // Dark blue color
            size: 45,
          ),
        ),
      ) : null,
      backgroundColor: Colors.white,
      body: Container(
        height: size.height * 0.95,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFecfcff), // #ecfcff
              Color(0xFFfff5db), // #fff5db
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: AppText(
                  text: "My Products",
                  fontSize: size.width * 0.078,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 3.0,
                      color: AppColors.primaryColor,
                    ),
                    insets: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: AppColors.darkBlue,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: "Products I Like"),
                    Tab(text: "Completed Deals"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLikedProductsTab(size),
                    _buildCompletedDealsTab(size),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New Products I Like tab implementation
  Widget _buildLikedProductsTab(Size size) {
    final myProductList = productController.myProduct.value.data ?? [];
    final likedProductList = productController.likeProduct.value.data ?? [];
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryTextColor,
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: myProductList.length,
            itemBuilder: (context, index) {
              final product = myProductList[index];
              // Count unique products that liked this product
              final uniqueLikes = likedProductList
                  .where((like) => like.userProduct?.id == product.id)
                  .map((like) => like.otherProduct?.id)
                  .where((id) => id != null)
                  .toSet()
                  .length;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), // slightly larger radius
                  side: BorderSide(color: AppColors.darkBlue, width: 1.5),
                ),
                margin: const EdgeInsets.only(bottom: 16), // more space between cards
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LikedDealsForProductScreen(
                          product: product,
                          likedDeals: likedProductList.where((like) => like.userProduct?.id == product.id).toList(),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // more padding
                    child: Row(
                      children: [
                        Container(
                          width: 64, // bigger image
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.darkBlue, width: 2),
                            color: Colors.grey[100],
                          ),
                          child: ClipOval(
                            child: (product.image != null && product.image!.isNotEmpty)
                                ? Image.network(
                                    KeyConstants.imageUrl + product.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image,
                                          size: 32,
                                          color: Colors.grey[400],
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      size: 32,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 24), // more space between image and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), // bigger font
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkBlue.withAlpha((0.1 * 255).toInt()),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                                        const SizedBox(width: 6),
                                        Text('$uniqueLikes likes', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildCompletedDealsTab(Size size) {
    final tradeList = (productController.tradeRequestProduct.value.data ?? [])
        .where((e) => e.paymentStatus == 'paid')
        .toList();
    
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryTextColor,
            ),
          )
        : SingleChildScrollView(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: tradeList.length,
              itemBuilder: (context, index) {
                TradeRequestUserProduct otherProduct =
                    tradeList[index].otherProduct ?? TradeRequestUserProduct();
                TradeRequestUserProduct userProduct =
                    tradeList[index].userProduct ?? TradeRequestUserProduct();
                return GestureDetector(
                  onTap: () {
                    ProfileService.instance.traderProfile(
                        context, (otherProduct.user ?? '').toString());
                    Get.to(() => ContactTrader());
                  },
                  child: Container(
                    height: size.height * 0.26,
                    width: size.width * 0.37,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: cardColors[index % cardColors.length],
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff99f2e2).withAlpha((0.10 * 255).toInt()),
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.favorite,
                                color: Color(0xfff2b721),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.16,
                          width: size.width,
                          child: Stack(
                            children: [
                              // First image (user product)
                              Container(
                                margin: EdgeInsets.only(left: 15),
                                height: size.height * 0.16,
                                width: size.width * 0.22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.green,
                                  image: DecorationImage(
                                    image: NetworkImage(KeyConstants.imageUrl +
                                        (userProduct.image ?? '')),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              // Second image (other product)
                              Positioned(
                                left: size.width * 0.21,
                                child: Container(
                                  height: size.height * 0.16,
                                  width: size.width * 0.22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.green,
                                    image: DecorationImage(
                                      image: NetworkImage(KeyConstants.imageUrl +
                                          (otherProduct.image ?? '')),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3.5),
                        // Product description
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: size.width * 0.2,
                              child: Text(
                                "${(userProduct.title ?? '').capitalize}",
                                maxLines: 2,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.2,
                              child: Text(
                                "${(otherProduct.title ?? '').capitalize}",
                                maxLines: 2,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget returnTexts(String key, String value) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.5,
      child: RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: key,
            style: TextStyle(
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.035),
            children: [
              TextSpan(
                  text: value.capitalize,
                  style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: size.width * 0.04))
            ],
          )),
    );
  }
}
