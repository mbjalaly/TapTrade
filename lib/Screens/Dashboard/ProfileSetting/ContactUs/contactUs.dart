import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode textFieldFocusNode1 = FocusNode();
  final TextEditingController textController1 = TextEditingController();
  final FocusNode textFieldFocusNode2 = FocusNode();
  final TextEditingController textController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textFieldFocusNode1.dispose();
    textController1.dispose();
    textFieldFocusNode2.dispose();
    textController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Image.asset(
            "assets/images/t.png",
            height: 30,
            width: 30,
          ),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: AppText(
                  text: "Contact US",
                  fontSize: size.width * 0.078,
                  textcolor: AppColors.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  Container(
                    width: size.width,
                    height: size.height * 0.76,
                    color: Colors.transparent,
                  ),
                  Center(
                    child: Material(
                      elevation: 4.5,
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.white,
                      child: Container(
                        width: size.width * 0.9,
                        height: size.height * 0.73,
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 20, bottom: 40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor
                                  .withOpacity(0.2), // #ecfcff
                              AppColors.secondaryColor
                                  .withOpacity(0.2), // #fff5db
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "We'd love to hear from you! Please fill out the form below to ask a question or share your thoughts, and our team will get back to you shortly.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.0,
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.04,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Subject",
                                  style: const TextStyle(
                                      color: AppColors.primaryTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 05,
                                ),
                                TextFormField(
                                  controller: textController1,
                                  readOnly: false,
                                  focusNode: textFieldFocusNode1,
                                  decoration: InputDecoration(
                                    filled: true,
                                    hintText: 'Your query...',
                                    fillColor: AppColors.secondaryColor
                                        .withOpacity(0.3), // Set the fill color
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          50.0), // Set the border radius
                                      borderSide: BorderSide
                                          .none, // Remove the default border
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 15.0,
                                        right:
                                            15.0), // Padding inside the text field
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Message",
                                  style: const TextStyle(
                                      color: AppColors.primaryTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 05,
                                ),
                                TextFormField(
                                  controller: textController2,
                                  readOnly: false,
                                  focusNode: textFieldFocusNode2,
                                  maxLines: 5,
                                  minLines: 5,
                                  decoration: InputDecoration(
                                    filled: true,
                                    hintText: 'Your message...',
                                    fillColor: AppColors.secondaryColor
                                        .withOpacity(0.3), // Set the fill color
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          50.0), // Set the border radius
                                      borderSide: BorderSide
                                          .none, // Remove the default border
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 15.0,
                                        top: 50.0,
                                        right:
                                            15.0), // Padding inside the text field
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: size.width / 4.5,
                    right: size.width / 4.5,
                    child: AppButton(
                      onPressed: () async {
                        if (textController1.text.isNotEmpty &&
                            textController2.text.isNotEmpty) {
                          await launchUrl(Uri(
                              scheme: 'mailto',
                              path: 'ceo@taptrade.app',
                              query: {
                                'subject': textController1.text,
                                'body': textController2.text,
                              }
                                  .entries
                                  .map((MapEntry<String, String> e) =>
                                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                  .join('&')));
                        } else {
                          ShowMessage.notify(
                              context, "Please fill in all fields");
                        }
                      },
                      text: 'Send Message',
                      width: double.infinity,
                      height: size.height * 0.065,
                      fontSize: size.width * 0.045,
                      buttonColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () => FocusScope.of(context).unfocus(),
  //     child: Scaffold(
  //       backgroundColor: Colors.white,
  //       appBar: AppBar(
  //         backgroundColor: Colors.white,
  //         automaticallyImplyLeading: false,
  //         centerTitle: false,
  //         title: Image.asset(
  //           "assets/images/t.png",
  //           height: 30,
  //           width: 30,
  //         ),),
  //       body: SafeArea(
  //         top: true,
  //         child: Padding(
  //           padding: const EdgeInsetsDirectional.fromSTEB(20.0, 50.0, 20.0, 0.0),
  //           child: Form(
  //             key: formKey,
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.max,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     'Contact Us',
  //                     style: TextStyle(
  //                       fontFamily: 'Roboto',
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: 0.0,
  //                     ),
  //                   ),
  //                   const Padding(
  //                     padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
  //                     child: Text(
  //                       "We'd love to hear from you! Please fill out the form below to ask a question or share your thoughts, and our team will get back to you shortly.",
  //                       style: TextStyle(
  //                         fontFamily: 'Lato',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w400,
  //                         letterSpacing: 0.0,
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
  //                     child: TextFormField(
  //                       controller: textController1,
  //                       focusNode: textFieldFocusNode1,
  //                       cursorColor: Colors.grey,
  //                       decoration: const InputDecoration(
  //                         border: InputBorder.none,
  //                         hintText: 'Subject',
  //                         focusedBorder: UnderlineInputBorder(
  //                           borderSide: BorderSide(
  //                               color: Colors.grey, width: 3),
  //                         ),
  //                         enabledBorder: UnderlineInputBorder(
  //                           borderSide: BorderSide(
  //                               color: Colors.grey, width: 3),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
  //                     child: TextFormField(
  //                       maxLines: 5,
  //                       minLines: 5,
  //                       controller: textController2,
  //                       focusNode: textFieldFocusNode2,
  //                       cursorColor: Colors.grey,
  //                       decoration: const InputDecoration(
  //                         border: InputBorder.none,
  //                         hintText: 'Your message...',
  //                         focusedBorder: UnderlineInputBorder(
  //                           borderSide: BorderSide(
  //                               color: Colors.grey, width: 3),
  //                         ),
  //                         enabledBorder: UnderlineInputBorder(
  //                           borderSide: BorderSide(
  //                               color: Colors.grey, width: 3),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsetsDirectional.fromSTEB(0.0, 25.0, 0.0, 0.0),
  //                     child: AppButton(
  //                       onPressed: () async {
  //                         if (textController1.text.isNotEmpty && textController2.text.isNotEmpty) {
  //                           await launchUrl(Uri(
  //                               scheme: 'mailto',
  //                               path: 'contact@taptrade.com',
  //                               query: {
  //                                 'subject': textController1.text,
  //                                 'body': textController2.text,
  //                               }
  //                                   .entries
  //                                   .map((MapEntry<String, String> e) =>
  //                               '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
  //                                   .join('&')));
  //                         } else {
  //                           ShowMessage.notify(context, "Please fill in all fields");
  //                         }
  //                       },
  //                       text: 'Send Message',
  //                       width: double.infinity,
  //                       height: 55.0,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
