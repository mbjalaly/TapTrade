import 'package:flutter/material.dart';
import 'package:taptrade/l10n/app_localizations.dart';
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
        backgroundColor: AppColors.backgroundColor(context),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: false,
          title: Text(AppLocalizations.of(context)?.contactUs ?? 'Contact us', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    width: size.width,
                    height: size.height * 0.76,
                    color: Colors.transparent,
                  ),
                  Center(
                    child: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.contentBg(context),
                      child: Container(
                        width: size.width * 0.9,
                        height: size.height * 0.73,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.surfaceColor(context),
                          border: Border.all(color: AppColors.outlineColor(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.weLoveToHear ?? "We'd love to hear from you! Please fill out the form below to ask a question or share your thoughts.",
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(
                              height: size.height * 0.04,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)?.subject ?? "Subject",
                                  style: TextStyle(
                                      color: AppColors.primaryText(context),
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
                                    hintText: AppLocalizations.of(context)?.yourQuery ?? 'Your query...',
                                    filled: true,
                                    fillColor: AppColors.fieldBg(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(color: AppColors.outlineColor(context)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(color: AppColors.outlineColor(context)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
                                Text(
                                  AppLocalizations.of(context)?.message ?? "Message",
                                  style: TextStyle(
                                      color: AppColors.primaryText(context),
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
                                    hintText: AppLocalizations.of(context)?.yourMessage ?? 'Your message...',
                                    filled: true,
                                    fillColor: AppColors.fieldBg(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(color: AppColors.outlineColor(context)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide(color: AppColors.outlineColor(context)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                              context, AppLocalizations.of(context)?.pleaseFillAllFields ?? "Please fill in all fields");
                        }
                      },
                      text: AppLocalizations.of(context)?.sendMessageAction ?? 'Send Message',
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
