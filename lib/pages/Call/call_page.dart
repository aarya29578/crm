import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/calls_history/calls_history_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CallPage extends StatefulWidget {
  final String leadId;
  const CallPage({super.key, required this.leadId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _wasCallMade = false;
  final callsHistoryController = Get.put(
    CallsHistoryController(),
    permanent: true,
  );
  //final callsHistoryController = Get.find<CallsHistoryController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Register lifecycle observer
    print("🐛 INIT STATE CALLED 🐛");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  // Handle app lifecycle changes (resume/pause)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _wasCallMade) {
      // App came back to foreground after call
      _onReturnFromCall();
      _wasCallMade = false; // Reset flag
    }
  }

  Future<void> callNumber() async {
    const number = '9137906337';

    setState(() {
      _wasCallMade = true;
    });

    //Show snackbar when call starts
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Calling $number...'),
    //     duration: Duration(seconds: 2),
    //   ),
    // );

    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    print("Call result: $res");
  }

  void _onReturnFromCall() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Returned from the call. Call ended'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: "Save in Logs",
          onPressed: () {
            callsHistoryController.checkLastCall(widget.leadId);
          },
        ),
        onVisible: () {
          // This will be called when the snackbar appears
          callsHistoryController.checkLastCall(widget.leadId);
        },
      ),
    );

    //print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    //await callsHistoryController.checkLastCall(widget.leadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Call Page", style: whiteHeading),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: callNumber,
                child: const Text("Make Call"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
