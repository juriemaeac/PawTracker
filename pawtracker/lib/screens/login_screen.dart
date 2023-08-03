import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pawtracker/providers/auth_methods.dart';
import 'package:pawtracker/screens/forgotPass.dart';
import 'package:pawtracker/screens/signup_screen.dart';
import 'package:pawtracker/utils/constants.dart';
import 'package:pawtracker/utils/navigation.dart';
import 'package:pawtracker/widgets/snackbar.dart';
import 'package:pawtracker/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isObscure = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_emailController.text == "" || _passwordController.text == "") {
      showSnackBar(context, "Please fill all the fields");
      _isLoading = false;
      return;
    } else {
      String res = await AuthMethods().loginUser(
          email: _emailController.text,
          password: _passwordController.text,
          context: context);
      if (res == 'success') {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Navigation()),
            (route) => false);

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, res);
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
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
                    'Login to your account',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    'To access your account',
                    style: AppTextStyles.subHeadings,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldInput(
                    textEditingController: _emailController,
                    hintText: 'Enter Email',
                    labelText: 'Email',
                    textInputType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isObscure,
                    style: AppTextStyles.textFields,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.greyAccent,
                      hintText: 'Enter Password',
                      labelText: 'Password',
                      labelStyle: AppTextStyles.subHeadings,
                      hintStyle: AppTextStyles.subHeadings,
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
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.darkGrey,
                          ),
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
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ForgotPassword();
                          }));
                        },
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text('Forgot Password?',
                              style: AppTextStyles.subHeadings),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: loginUser,
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
                                'Login',
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
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Doesn't have an account? ",
                        style: AppTextStyles.subHeadings,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  duration: const Duration(milliseconds: 500),
                                  child: const SignupScreen()));
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.subHeadings.copyWith(
                            color: AppColors.blue,
                          ),
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
                  const SizedBox(
                    height: 30,
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
