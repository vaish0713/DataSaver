import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:printing/printing.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/details': (context) => OtherPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _login(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login',
          style: TextStyle(color: Colors.black),
        ),

      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () {
                  _login(context);
                },
              ),
              SizedBox(height: 8.0),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool click = true;
  bool click2 = true;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  late String? _selectedItem;
  PickedFile? _image;

  TextEditingController _textEditingController = TextEditingController();
  List<String> _items = [
    '2001',
    '2002',
    '2003',
    '2004',
    '2005',
  ];
  String _name = '';
  String _phonenumber = '';

  Future<void> _selectImage() async {
    final pickedImage =
    await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = PickedFile(pickedImage.path);
      });
    }
  }



  void _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(
          context, '/', (Route<dynamic> route) => false);
    } catch (e) {
      print('Logout failed:Check youre connection');
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedItem = _items[0]; // Initialize with the first item in the list
  }

  void _submitForm() {
    setState(() {
      _name = nameController.text.trim();
      _phonenumber= phoneController.text.trim();


    });
    Navigator.pushNamed(
      context as BuildContext,
      '/details',
      arguments: OtherPageArguments(
        name: _name,
        phoneNumber: _phonenumber,
        image: _image,
        selectedItem: _selectedItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VITAP'),
        actions: [
          ElevatedButton(
            child: Text('Logout'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.black,
            ),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
              [
                TextField(

                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter your name',
                  ),

                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Enter your phone number',
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: Text('Select Image'),
                  onPressed: _selectImage,
                ),


                DropdownButton<String>(
                  value: _selectedItem,
                  items: _items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? selectedItem) {
                    setState(() {
                      _selectedItem = selectedItem;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                Text('Selected Item: $_selectedItem'),
                ElevatedButton(
                  child: Text('Next'),
                  onPressed: _submitForm,
                ),
                ElevatedButton(
                  onPressed: (){
                    _submitForm;
                    CollectionReference colRef = FirebaseFirestore.instance.collection('Client');
                    colRef.add({
                      'name':nameController.text,
                      'phone number':phoneController.text,
                    });

                  }, child: const Text('Submit'),
                )

              ],
            )
        ),
      ),
    );
  }
}

class OtherPage extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    final OtherPageArguments arguments =
    ModalRoute.of(context)!.settings.arguments as OtherPageArguments;
    String name = arguments.name;
    String phoneNumber = arguments.phoneNumber;
    bool isNameEmpty = arguments.name.isEmpty;
    bool isPhoneNumberEmpty = arguments.phoneNumber.isEmpty;
    bool hasImage = arguments.image != null;
    bool isselectedItemEmpty = arguments.selectedItem!.isEmpty;
    bool hasDateOfBirth = arguments.dateOfBirth != null;
    String? imageName;
    if (hasImage) {
      imageName = arguments.image!.path.split('/').last;
    }

    List<DataRow> rows = [
      DataRow(
        cells: [
          DataCell(Icon(
            isNameEmpty ? Icons.close : Icons.check,
            color: isNameEmpty ? Colors.red : Colors.green,
          )),
          DataCell(Text(
            'Name:',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataCell(Text(isNameEmpty ? 'Not provided' : arguments.name)),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Icon(
            isPhoneNumberEmpty ? Icons.close : Icons.check,
            color: isPhoneNumberEmpty ? Colors.red : Colors.green,
          )),
          DataCell(Text(
            'Phone Number:',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataCell(Text(isPhoneNumberEmpty ? 'Not provided' : arguments.phoneNumber)),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Icon(
            hasImage ? Icons.check : Icons.close,
            color: hasImage ? Colors.green : Colors.red,
          )),
          DataCell(Text(
            'Image:',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataCell(Text(hasImage ? imageName! : 'Not provided')),
        ],
      ),
      DataRow(
        cells: [
          DataCell(Icon(
            isselectedItemEmpty ? Icons.close : Icons.check,
            color: isselectedItemEmpty ? Colors.red : Colors.green,
          )),
          DataCell(Text(
            'Year of Birth:',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataCell(Text(isselectedItemEmpty ? 'Not provided' : arguments.selectedItem!)),
        ],
      ),
    ];

    if (hasDateOfBirth) {
      rows.add(
        DataRow(
          cells: [
            DataCell(Icon(
              Icons.check,
              color: Colors.green,
            )),
            DataCell(Text(
              'Date of Birth:',
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Text(arguments.dateOfBirth!)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(16.0),
          children: [
            Text(
              'User Details:',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16.0,
                columns: [
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Field')),
                  DataColumn(label: Text('Value')),
                ],
                rows: rows,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                generatePDF(context);
              },
              child: Text('Print as PDF'),
            ),

            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Client').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  int userCount = documents.length;

                  return Column(
                    children: [
                      Text(
                        'Number of Users: $userCount',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          String name = documents[index]['name'];
                          String phoneNumber = documents[index]['phone number'];

                          return ListTile(
                            title: Text('Name: $name'),
                            subtitle: Text('Phone Number: $phoneNumber'),
                          );
                        },
                      ),
                    ],);
                }
            )
          ],
        ),
      );
  }
  Future<void> generatePDF(BuildContext context) async {
    final OtherPageArguments arguments =
    ModalRoute.of(context)!.settings.arguments as OtherPageArguments;
    String name = arguments.name;
    String phoneNumber = arguments.phoneNumber;
    String? dOB=arguments.selectedItem!;
    final pdf = pw.Document();
    // Create the content of the PDF
    final content = pw.ListView(
      children: [
        pw.Text('User Details', style: pw.TextStyle(fontSize: 20)),
        pw.SizedBox(height: 8),
        pw.Text('Name: $name'),
        pw.Text('Phone Number: $phoneNumber'),
        pw.Text('Date Of Birth:$dOB'),
      ],
    );

    // Add the content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return content;
        },
      ),
    );

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/other_page.pdf');
    await file.writeAsBytes(await pdf.save());

    // Print the PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

}

class OtherPageArguments {
  final String name;
  final String phoneNumber;
  final String? selectedItem;
  final String? dateOfBirth;
  final PickedFile? image;


  OtherPageArguments({
    required this.name,
    required this.phoneNumber,
    required this.selectedItem,
    this.dateOfBirth,
    required this.image,

  });
}

