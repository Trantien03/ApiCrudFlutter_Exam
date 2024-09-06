import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD API Flutter ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://t2210m-flutter.onrender.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    } else {
      showErrorSnackBar('Failed to load products');
    }
  }

  Future<void> createProduct(String name, String description, int price) async {
    final response = await http.post(
      Uri.parse('https://t2210m-flutter.onrender.com/products'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      fetchProducts();
      showSuccessSnackBar('Product added successfully!');
    } else {
      showErrorSnackBar('Failed to create product');
    }
  }

  Future<void> updateProduct(String id, String name, String description, int price) async {
    final response = await http.put(
      Uri.parse('https://t2210m-flutter.onrender.com/products/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'description': description,
        'price': price,
      }),
    );

    if (response.statusCode == 200) {
      fetchProducts();
      showSuccessSnackBar('Product updated successfully!');
    } else {
      showErrorSnackBar('Failed to update product');
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('https://t2210m-flutter.onrender.com/products/$id'),
    );

    if (response.statusCode == 200) {
      fetchProducts();
      showSuccessSnackBar('Product deleted successfully!');
    } else {
      showErrorSnackBar('Failed to delete product');
    }
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['name']),
            subtitle: Text('Price: \$${product['price']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showUpdateProductDialog(product),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteProduct(product['_id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProductDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCreateProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                final name = nameController.text;
                final description = descriptionController.text;
                final price = int.tryParse(priceController.text) ?? 0;

                if (name.isNotEmpty && description.isNotEmpty && price > 0) {
                  createProduct(name, description, price);
                  Navigator.of(context).pop();
                } else {
                  showErrorSnackBar('Please enter valid data');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateProductDialog(Map<String, dynamic> product) {
    final nameController = TextEditingController(text: product['name']);
    final descriptionController = TextEditingController(text: product['description']);
    final priceController = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                final name = nameController.text;
                final description = descriptionController.text;
                final price = int.tryParse(priceController.text) ?? 0;

                if (name.isNotEmpty && description.isNotEmpty && price > 0) {
                  updateProduct(product['_id'], name, description, price);
                  Navigator.of(context).pop();
                } else {
                  showErrorSnackBar('Please enter valid data');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
