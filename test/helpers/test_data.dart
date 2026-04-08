import 'package:farmers_market/features/auth/data/models/user_model.dart';
import 'package:farmers_market/features/farmers/data/models/farmer_model.dart';
import 'package:farmers_market/features/products/data/models/product_model.dart';

UserModel testUser({String role = 'operator'}) => UserModel(
      id: 1,
      name: 'Alice Operator',
      email: 'alice@test.com',
      role: role,
    );

Farmer testFarmer({
  int id = 1,
  double creditLimit = 10000,
  List<Debt> debts = const [],
}) =>
    Farmer(
      id: id,
      firstname: 'Jean',
      lastname: 'Dupont',
      email: 'jean@farm.com',
      phoneNumber: '0600000001',
      identifier: 'F001',
      creditLimit: creditLimit,
      debts: debts,
    );

Product testProduct({int id = 1, String name = 'Tomato', double price = 500}) =>
    Product(
      id: id,
      name: name,
      description: '',
      priceFcfa: price,
      categoryId: 1,
    );

Category testCategory({List<Product>? products}) => Category(
      id: 1,
      name: 'Vegetables',
      children: [],
      products: products ?? [testProduct()],
    );
