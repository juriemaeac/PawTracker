import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pawtracker/screens/home_screen.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/global_variable.dart';
import 'package:pawtracker/utils/navigation.dart';
import 'package:pawtracker/widgets/snackbar.dart';
import 'package:pawtracker/widgets/text_field_input.dart';
import 'package:latlong2/latlong.dart';

class EditPet extends StatefulWidget {
  const EditPet({super.key});

  @override
  State<EditPet> createState() => _EditPetState();
}

class _EditPetState extends State<EditPet> {
  //get current user id
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  String uid = '';
  String petId = '';
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _petOwnerNameController = TextEditingController();
  final TextEditingController _petBreedController = TextEditingController();
  final TextEditingController _petAgeController = TextEditingController();
  final TextEditingController _petBirthdateController = TextEditingController();

  final List<String> _petType = [
    'Cat',
    'Dog',
  ];
  String? _selectedType;

  final List<String> _petGender = [
    'Male',
    'Female',
  ];
  String? _selectedGender;

  Future<void> getPetDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('pets')
        .where('uid', isEqualTo: user!.uid)
        .get()
        .then(
          (QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach(
              (doc) {
                setState(
                  () {
                    uid = doc['uid'];
                    petId = doc['petId'];
                    _petNameController.text = doc['petName'];
                    _petOwnerNameController.text = doc['ownerName'];
                    _selectedType = doc['petType'];
                    _petBreedController.text = doc['petBreed'];
                    _petAgeController.text = doc['petAge'];
                    _selectedGender = doc['petGender'];
                    _petBirthdateController.text = doc['petBirthdate'];
                  },
                );
              },
            )
          },
        );
  }

  //update pet details
  Future<void> updatePetDetails() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('pets')
        .doc(petId)
        .update({
          'petName': _petNameController.text,
          'ownerName': _petOwnerNameController.text,
          'petType': _selectedType,
          'petBreed': _petBreedController.text,
          'petAge': _petAgeController.text,
          'petGender': _selectedGender,
          'petBirthdate': _petBirthdateController.text,
          'petHome': petHomeAddressGlobal,
          'petHomeLatitude': homeLatitudeGlobal,
          'petHomeLongitude': homeLongitudeGlobal,
          'fencePerimeter': geofenceRadiusGlobal,
        })
        .then(
          (value) => {
            setState(
              () {
                isLoading = false;
              },
            ),
            showSnackBar(
              context,
              'Pet details updated successfully',
            ),
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const Navigation(),
              ),
            ),
          },
        )
        .catchError(
          (error) => {
            setState(
              () {
                isLoading = false;
              },
            ),
            showSnackBar(
              context,
              error.toString(),
            ),
          },
        );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPetDetails();
  }

  @override
  Widget build(BuildContext context) {
    // final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.pinkAccent,
          //title: Text('Add Pet', style: AppTextStyles.title1),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: SafeArea(
        child: Container(
          color: AppColors.pinkAccent,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              isCat
                  ? Image(
                      image: AssetImage('assets/images/cat_hi.png'),
                      height: MediaQuery.of(context).size.height / 2.8,
                    )
                  : Image(
                      image: AssetImage('assets/images/dog_hi.png'),
                      height: MediaQuery.of(context).size.height / 2.8,
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  height: MediaQuery.of(context).size.height / 1.5,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              color: AppColors.black,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Edit Pet Information',
                              style: AppTextStyles.title1,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFieldInput(
                          textEditingController: _petOwnerNameController,
                          hintText: 'Owner Name',
                          labelText: 'Owner Name',
                          textInputType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 40,
                              child: TextFieldInput(
                                textEditingController: _petNameController,
                                hintText: 'Pet Name',
                                labelText: 'Pet Name',
                                textInputType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              width: MediaQuery.of(context).size.width / 2 - 40,
                              decoration: BoxDecoration(
                                color: AppColors.greyAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  hint: Text(
                                    'Pet Type  ',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  items: _petType
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item,
                                                style:
                                                    AppTextStyles.textFields),
                                          ))
                                      .toList(),
                                  value: _selectedType,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedType = value as String;
                                      if (_selectedType == 'Cat') {
                                        isCat = true;
                                      } else {
                                        isCat = false;
                                      }
                                    });
                                  },
                                  buttonHeight: 48,
                                  buttonWidth: 340,
                                  itemHeight: 48,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFieldInput(
                          textEditingController: _petBreedController,
                          hintText: 'Pet Breed',
                          labelText: 'Pet Breed',
                          textInputType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 40,
                              child: TextFieldInput(
                                textEditingController: _petAgeController,
                                hintText: 'Pet Age',
                                labelText: 'Pet Age',
                                textInputType: TextInputType.number,
                                textCapitalization: TextCapitalization.none,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              width: MediaQuery.of(context).size.width / 2 - 40,
                              decoration: BoxDecoration(
                                color: AppColors.greyAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  hint: Text('Pet Gender',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w500,
                                      )),
                                  items: _petGender
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item,
                                                style:
                                                    AppTextStyles.textFields),
                                          ))
                                      .toList(),
                                  value: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value as String;
                                    });
                                  },
                                  buttonHeight: 48,
                                  buttonWidth: 20,
                                  itemHeight: 48,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(1900, 1, 1),
                                maxTime: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day), onChanged: (date) {
                              print('change $date');
                            }, onConfirm: (date) {
                              print('confirm $date');
                              setState(() {
                                var dateTime = DateTime.parse(date.toString());
                                var formate1 =
                                    "${dateTime.day}-${dateTime.month}-${dateTime.year}";
                                _petBirthdateController.text = formate1;
                                //textBirthdate = formate1;
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                          controller: _petBirthdateController,
                          style: AppTextStyles.textFields,
                          decoration: const InputDecoration(
                            fillColor: AppColors.greyAccent,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            hintText: 'Pet Birthdate',
                            hintStyle: AppTextStyles.subHeadings,
                            labelText: 'Pet Birthdate',
                            labelStyle: AppTextStyles.subHeadings,
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            suffixIcon: Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFF848484),
                            ),
                          ),
                          validator: (var value) {
                            if (value!.isEmpty) {
                              return 'Enter Birthdate';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            if (_petOwnerNameController.text.isEmpty ||
                                _petNameController.text.isEmpty ||
                                _petBreedController.text.isEmpty ||
                                _petAgeController.text.isEmpty ||
                                _petBirthdateController.text.isEmpty ||
                                _selectedGender!.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Please fill all fields'),
                              ));
                              return;
                            }
                            updatePetDetails();
                          },
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 15.0)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            shadowColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Save',
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
