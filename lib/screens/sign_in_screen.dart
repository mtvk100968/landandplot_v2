import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  appBar: AppBar(title: const Text('Sign In')),
	  body: Center(
		child: Column(
		  mainAxisAlignment: MainAxisAlignment.center,
		  children: [
			ElevatedButton(
			  onPressed: () async {
				User? user = await signInWithGoogle();
				if (user != null) {
				  Navigator.pushReplacementNamed(context, '/home');
				}
			  },
			  child: const Text('Sign in with Google'),
			),
			ElevatedButton(
			  onPressed: () {
				_showPhoneNumberDialog(context);
			  },
			  child: const Text('Sign in with Phone Number'),
			),
		  ],
		),
	  ),
	);
  }

  void _showPhoneNumberDialog(BuildContext context) {
	final TextEditingController phoneController = TextEditingController();
	final TextEditingController codeController = TextEditingController();
	String verificationId = '';

	showDialog(
	  context: context,
	  builder: (BuildContext context) {
		return AlertDialog(
		  title: const Text('Enter Phone Number'),
		  content: Column(
			mainAxisSize: MainAxisSize.min,
			children: [
			  TextField(
				controller: phoneController,
				decoration: const InputDecoration(labelText: 'Phone Number'),
			  ),
			  TextField(
				controller: codeController,
				decoration: const InputDecoration(labelText: 'Verification Code'),
			  ),
			],
		  ),
		  actions: [
			TextButton(
			  onPressed: () async {
				await signInWithPhoneNumber(
				  phoneController.text,
				  (String verId) {
					verificationId = verId;
				  },
				  (FirebaseAuthException e) {
					ScaffoldMessenger.of(context).showSnackBar(
					  SnackBar(content: Text('Failed to verify phone number: ${e.message}')),
					);
				  },
				);
			  },
			  child: const Text('Send Code'),
			),
			TextButton(
			  onPressed: () async {
				final PhoneAuthCredential credential = PhoneAuthProvider.credential(
				  verificationId: verificationId,
				  smsCode: codeController.text,
				);
				User? user = await signInWithPhoneAuthCredential(credential);
				if (user != null) {
				  Navigator.pushReplacementNamed(context, '/home');
				}
			  },
			  child: const Text('Sign In'),
			),
		  ],
		);
	  },
	);
  }
}