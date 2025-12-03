import 'package:flutter/material.dart';

/// Call like:
/// final accepted = await showDialog<bool>(
///   context: context,
///   barrierDismissible: false,
///   builder: (_) => ConsentDialog(),
/// );
///
/// If accepted == true -> proceed with registration.

class ConsentDialog extends StatefulWidget {
  const ConsentDialog({super.key});

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _isAtBottom = false;

  // small tolerance in pixels so a tiny overscroll difference doesn't block enabling
  static const double _tolerance = 8.0;

  // The full policy text (use your exact text here). Kept as a getter for readability.
  String get _fullPolicy => '''
TERMS OF USE AND PRIVACY POLICY

This application Fetosense (“Application”) for mobile devices is created by CareNX Innovations Pvt. Ltd. (Developer) and is intended for Physicians/ Gynecologists/ Medical Professionals/ANMs/Skilled front-line health workers/Expectant mothers/Pregnant women (USER) with an aim to enable fetal heart assessment with evidence-based information and support to make informed decisions related to the fetus health during pregnancy. The application also aims to keep the doctor and User in constant contact. The information on her progress will be provided by the Physicians/Gynecologists/Medical Professionals/ ANMs/Skilled front-line health workers/ Hospital (hereinafter referred to as the Doctor) that the User is registered with.

INFORMATION PROVIDED BY THE USER AND THE DOCTOR:
The Application obtains the information when the User downloads and registers the Application on the smart phone. Registration is mandatory in order to be able to use the basic features of the application.
During registration, the User should provide (a) their name, email address, age, user name, password, mobile number, last menstrual date and any other registration information relevant to the use of the application; the name ID of the doctor assigned by Fetosense and hospital ID/ clinic ID that the doctor is attached to. Which can be obtained from the associated doctors.
Upon completion of the registration, the application requires the doctor to inquire and upload the basic medical information and data pertaining to the User.
All the medical related data is provided by the Doctor in compliance with the rules of the hospital and best to their knowledge.

AUTOMATICALLY COLLECTED INFORMATION:
In addition, the Application may collect certain information automatically, including, but not limited to, the type of mobile device the User uses, the mobile devices unique device ID, the IP address of the mobile device, the mobile operating system, the type of mobile Internet browsers being used, and information about the way the application is being used.

LOCATION INFORMATION:
This Application does not collect precise information about the location of the Users mobile device.

ACCESS BY THIRD PARTIES:
Only aggregated, anonymized data is periodically transmitted to external services to help the Developer improve the Application and their service. The Developer will share the Users information with third parties only in the ways that are described in this privacy statement.
The Developer may disclose User Provided and Automatically Collected Information, in the following circumstances:
• as required by law, such as to comply with any legal process;
• when the Developers believe in good faith that disclosure is necessary to protect their rights, protect the Users safety or the safety of others, including Doctors and Hospitals, investigate fraud, or respond to a government request;
• with the Developers trusted services providers who work on their behalf, do not have an independent use of the information disclosed to them, and have agreed to adhere to the rules set forth in this privacy statement.

OPT-OUT RIGHTS:
The User can stop all collection of information by the Application easily by uninstalling the Application. The User may use the standard uninstall processes as may be available as part of their mobile device or via the mobile application marketplace or network. The User can also request to opt-out via email, at info@Fetosense.in (the Developers email)

DATA RETENTION POLICY:
The Developer will retain User Provided data for as long as the User uses the Application and for a reasonable time thereafter. The Developer will retain Automatically Collected information for up to 24 months and thereafter may store it in aggregate. If the User wants the Developer to delete User Provided Data that has been provided via the Application, then the User may contact the Developer at info@carenx.com and the Developer will respond in a reasonable time. Please note that some or all of the User Provided Data may be required in order for the Application to function properly.

SECURITY:
The Developer is concerned about safeguarding the confidentiality of the Users information. The Developer provide physical, electronic, and procedural safeguards to protect information they process and maintain. For example, the Developer limits access to this information only to authorized employees and contractors who need to know that information in order to operate, develop or improve their Application. Please be aware that, although the Developer endeavours to provide reasonable security for information that they process and maintain, no security system can prevent all potential security breaches. SSL and Encryption techniques are used.

CHANGES:
This Privacy Policy may be updated from time to time for any reason. The Developer will notify the User of any changes to their Privacy Policy by posting the new Privacy Policy here and informing the User via email or text message. The User is advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.

YOUR CONSENT:
By using the Application, the User is consenting to the Developers processing of their information as set forth in this Privacy Policy now and as amended by them. "Processing,” means using cookies on a computer/hand held device or using or touching information in any way, including, but not limited to, collecting, storing, deleting, using, combining and disclosing information, all of which activities will take place in India. If the User resides outside the India, then the information will be transferred, processed and stored there under the Indian privacy standards.
''';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terms of Use & Privacy Consent',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 460, maxWidth: 520),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.metrics.axis == Axis.vertical) {
              final pixels = scrollNotification.metrics.pixels;
              final maxScroll = scrollNotification.metrics.maxScrollExtent;
              if (pixels + _tolerance >= maxScroll) {
                if (!_isAtBottom) setState(() => _isAtBottom = true);
              } else {
                if (_isAtBottom) setState(() => _isAtBottom = false);
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(_fullPolicy, style: const TextStyle(height: 1.4)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('DECLINE'),
        ),
        ElevatedButton(
          onPressed: _isAtBottom ? () => Navigator.of(context).pop(true) : null,
          child: const Text('ACCEPT'),
        ),
      ],
    );
  }
}
