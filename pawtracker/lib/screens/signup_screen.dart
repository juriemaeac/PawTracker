import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pawtracker/providers/auth_methods.dart';
import 'package:pawtracker/screens/login_screen.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/widgets/snackbar.dart';
import 'package:pawtracker/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confpassController = TextEditingController();
  bool _isLoading = false;
  //bool? checkedValue = false;
  bool _isObscure = false;
  bool _isObscure1 = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    // signup user using our authmethodds
    if (_emailController.text == "" ||
        _firstnameController.text == "" ||
        _lastnameController.text == "" ||
        _passwordController.text == "") {
      showSnackBar(context, "Please fill all the fields");
      _isLoading = false;
      return;
    } else {
      if (_passwordController.text != _confpassController.text) {
        showSnackBar(context, "Password doesn't match");
        _isLoading = false;
        return;
      } else if (_confpassController.text == "") {
        showSnackBar(context, "Please confirm your password");
        _isLoading = false;
        return;
      } else {
        String res = await AuthMethods().signUpUser(
          email: _emailController.text,
          firstName: _firstnameController.text,
          lastName: _lastnameController.text,
          password: _passwordController.text,
          context: context,
        );
        // if string returned is sucess, user has been created
        if (res == "success") {
          setState(() {
            _isLoading = false;
          });
          // navigate to the login screen
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 500),
              child: const LoginScreen(),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          // show the error
          showSnackBar(context, res);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 100,
                    color: AppColors.pinkAccent,
                  ),
                  Text(
                    'PawTracker',
                    style: AppTextStyles.title1.copyWith(
                      color: AppColors.pinkAccent,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    'Create new account',
                    style: AppTextStyles.title,
                  ),
                  const Text(
                    'Please fill in the form to create an account',
                    style: AppTextStyles.subHeadings,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFieldInput(
                    hintText: 'Enter Email',
                    labelText: 'Email',
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                    textCapitalization: TextCapitalization.none,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 39,
                        child: TextFieldInput(
                          hintText: 'Firstname',
                          labelText: 'Firstname',
                          textInputType: TextInputType.text,
                          textEditingController: _firstnameController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 39,
                        child: TextFieldInput(
                          hintText: 'Lastname',
                          labelText: 'Lastname',
                          textInputType: TextInputType.text,
                          textEditingController: _lastnameController,
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isObscure,
                    style: AppTextStyles.textFields,
                    decoration: InputDecoration(
                      fillColor: AppColors.greyAccent,
                      filled: true,
                      hintText: 'Enter Password',
                      hintStyle: AppTextStyles.subHeadings,
                      labelText: 'Password',
                      labelStyle: AppTextStyles.subHeadings,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2),
                      ),
                      suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          icon: Icon(_isObscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          }),
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _confpassController,
                    obscureText: !_isObscure1,
                    style: AppTextStyles.textFields,
                    decoration: InputDecoration(
                      fillColor: AppColors.greyAccent,
                      filled: true,
                      hintText: 'Confirm Password',
                      hintStyle: AppTextStyles.subHeadings,
                      labelText: 'Confirm Password',
                      labelStyle: AppTextStyles.subHeadings,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 2),
                      ),
                      suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          icon: Icon(_isObscure1
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscure1 = !_isObscure1;
                            });
                          }),
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Required!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                          "By Signing up you agree to PawTracker's Terms and Conditions",
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.grey,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signUpUser();
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 30.0)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(AppColors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      shadowColor:
                          MaterialStateProperty.all<Color>(Colors.transparent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !_isLoading
                            ? Text(
                                'Sign up',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.white,
                                ),
                              )
                            : const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text('Already have an account?',
                            style: AppTextStyles.subHeadings),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            duration: const Duration(milliseconds: 500),
                            child: const LoginScreen(),
                          ),
                        ),
                        child: Container(
                          child: Text(
                            ' Login.',
                            style: AppTextStyles.subHeadings.copyWith(
                              color: AppColors.blue,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    //color: Colors.amber,
                    height: 20,
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Powered by   ",
                            style: AppTextStyles.body3.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          Image.asset('assets/images/artemis.png',
                              width: 70,
                              //height: 100,
                              fit: BoxFit.fill),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
