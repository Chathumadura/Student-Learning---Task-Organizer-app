
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/learnova_widgets.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final id = TextEditingController();
  final pw = TextEditingController();
  bool loading = false;

  bool _isValidIdentifier(String value) {
    final v = value.trim();
    final gmail = RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$', caseSensitive: false);
    final studentId = RegExp(r'^[A-Za-z]{2,12}-\d{4}\s\d{4}$');
    final horizon = RegExp(
      r'^[A-Za-z]{2,12}-\d{4}\s\d{4}@horizoncampus\.edu\.lk$',
      caseSensitive: false,
    );
    return gmail.hasMatch(v) || studentId.hasMatch(v) || horizon.hasMatch(v);
  }

  Future<void> _login() async {
    final identifier = id.text.trim();
    if (!_isValidIdentifier(identifier)) {
      showSnack(
        context,
        'Use valid Gmail or ITBNM-2313 0010 / ITBNM-2313 0010@horizoncampus.edu.lk',
      );
      return;
    }

    setState(() => loading = true);
    try { await ApiService.login(identifier, pw.text.trim()); if (!mounted) return; Navigator.pushReplacementNamed(context, '/dashboard'); }
    catch(e){ if(mounted) showSnack(context, e.toString().replaceFirst('Exception: ', '')); }
    finally { if(mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) {
    return LScaffold(child: Column(children: [
      const SizedBox(height: 48),
      const LearnovaLogo(size: 20, centered: true),
      const SizedBox(height: 58),
      Container(width: 92, height: 92, decoration: const BoxDecoration(color: Color(0xFFEAF1FF), shape: BoxShape.circle), child: const Icon(Icons.school_outlined, color: AppColors.blue, size: 42)),
      const SizedBox(height: 28),
      const Text('Welcome Back', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text)),
      const SizedBox(height: 12),
      const Text('Sign in to continue your learning journey', style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 28),
      LCard(padding: const EdgeInsets.all(22), child: Column(children: [
        LTextField(controller: id, label: 'Email Address / Student ID', hint: 'yourname@gmail.com or ITBNM-2313 0010', icon: Icons.mail_outline),
        const SizedBox(height: 16),
        LTextField(controller: pw, label: 'Password', hint: '••••••••', icon: Icons.lock_outline, obscure: true),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pushNamed(context, '/forgot'), child: const Text('Forgot Password?'))),
        LButton(text: loading ? 'Signing in...' : 'Log In', onPressed: loading ? null : _login),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Don’t have an account? ", style: TextStyle(color: AppColors.muted)),
          InkWell(onTap: () => Navigator.pushNamed(context, '/signup'), child: const Text('Create Account', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w700))),
        ])
      ])),
    ]));
  }
}

class SignUpScreen extends StatefulWidget { const SignUpScreen({super.key}); @override State<SignUpScreen> createState() => _SignUpScreenState(); }
class _SignUpScreenState extends State<SignUpScreen> {
  final name = TextEditingController(); final email = TextEditingController(); final pass = TextEditingController(); final confirm = TextEditingController(); final course = TextEditingController(text: 'Computer Science'); bool loading=false;
  Future<void> _signup() async {
    if(pass.text != confirm.text){ showSnack(context, 'Passwords do not match'); return; }
    setState(()=>loading=true);
    try { await ApiService.register(name: name.text.trim(), email: email.text.trim(), password: pass.text.trim(), course: course.text.trim()); if(!mounted)return; Navigator.pushReplacementNamed(context, '/login'); }
    catch(e){ if(mounted) showSnack(context, e.toString().replaceFirst('Exception: ', '')); }
    finally { if(mounted) setState(()=>loading=false); }
  }
  @override Widget build(BuildContext context) => LScaffold(child: Column(children: [
    const SizedBox(height: 26), const LearnovaLogo(size:20, centered:true), const SizedBox(height:36),
    Container(width:92,height:92,decoration: const BoxDecoration(color: Color(0xFFEAF1FF), shape: BoxShape.circle), child: const Icon(Icons.school_outlined, color: AppColors.blue, size: 42)),
    const SizedBox(height:24), const Text('Create Account', style: TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:AppColors.text)), const SizedBox(height:10),
    const Text('Join Learnova and start organizing better', style: TextStyle(color:AppColors.muted)), const SizedBox(height:22),
    LCard(padding: const EdgeInsets.all(22), child: Column(children: [
      LTextField(controller:name,label:'Full Name',hint:'John Doe',icon:Icons.person_outline), const SizedBox(height:14),
      LTextField(controller:email,label:'Email Address',hint:'ITBNM-0000-0000@horizoncampus.edu.lk',icon:Icons.mail_outline,keyboardType:TextInputType.emailAddress), const SizedBox(height:14),
      LTextField(controller:course,label:'Major / Course',hint:'Computer Science',icon:Icons.menu_book_outlined), const SizedBox(height:14),
      DropdownButtonFormField<String>(value:'Student', items: const [DropdownMenuItem(value:'Student',child:Text('Student'))], onChanged:(_){}, decoration: const InputDecoration(labelText:'Role', prefixIcon:Icon(Icons.school_outlined,color:AppColors.muted))), const SizedBox(height:14),
      LTextField(controller:pass,label:'Password',hint:'••••••••',icon:Icons.lock_outline,obscure:true), const SizedBox(height:14),
      LTextField(controller:confirm,label:'Confirm Password',hint:'••••••••',icon:Icons.lock_outline,obscure:true), const SizedBox(height:18),
      LButton(text: loading?'Creating...':'Create Account', onPressed: loading?null:_signup), const SizedBox(height:16),
      Row(mainAxisAlignment:MainAxisAlignment.center, children:[const Text('Already have an account? ', style:TextStyle(color:AppColors.muted)), InkWell(onTap:()=>Navigator.pop(context), child: const Text('Log In', style:TextStyle(color:AppColors.blue,fontWeight:FontWeight.w700)))])
    ]))
  ]));
}

class ForgotPasswordScreen extends StatefulWidget { const ForgotPasswordScreen({super.key}); @override State<ForgotPasswordScreen> createState()=>_ForgotPasswordScreenState(); }
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>{
  final email=TextEditingController(); final np=TextEditingController(); final cp=TextEditingController(); bool reset=false; bool loading=false;
  Future<void> _send() async { setState(()=>loading=true); try{ await ApiService.forgotPassword(email.text.trim()); if(mounted) setState(()=>reset=true); } catch(e){ if(mounted) showSnack(context,e.toString().replaceFirst('Exception: ','')); } finally{ if(mounted)setState(()=>loading=false);} }
  Future<void> _reset() async { setState(()=>loading=true); try{ await ApiService.resetPassword(email.text.trim(), np.text.trim(), cp.text.trim()); if(!mounted)return; showSnack(context,'Password updated. Login again.'); Navigator.pushReplacementNamed(context,'/login'); } catch(e){ if(mounted) showSnack(context,e.toString().replaceFirst('Exception: ','')); } finally{ if(mounted)setState(()=>loading=false);} }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Forgot Password')), body:LScaffold(child:Column(children:[const SizedBox(height:60), Container(width:70,height:70,decoration:const BoxDecoration(color:Color(0xFFEAF1FF),shape:BoxShape.circle),child:const Icon(Icons.key_outlined,color:AppColors.blue,size:34)), const SizedBox(height:26), Text(reset?'Reset Password':'Forgot Password?',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)), const SizedBox(height:12), Text(reset?'Enter your new password':'Enter your email and continue reset flow',textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted)), const SizedBox(height:26), LCard(padding:const EdgeInsets.all(22),child:Column(children:[LTextField(controller:email,label:'Email Address',hint:'student@learnova.edu',icon:Icons.mail_outline), if(reset)...[const SizedBox(height:14),LTextField(controller:np,label:'New Password',icon:Icons.lock_outline,obscure:true), const SizedBox(height:14), LTextField(controller:cp,label:'Confirm New Password',icon:Icons.lock_outline,obscure:true)], const SizedBox(height:18), LButton(text:loading?'Please wait...':(reset?'Update Password':'Send Reset Link'),onPressed:loading?null:(reset?_reset:_send))]))]), padding:const EdgeInsets.fromLTRB(24,0,24,20)));
}

class ChangePasswordScreen extends StatefulWidget { const ChangePasswordScreen({super.key}); @override State<ChangePasswordScreen> createState()=>_ChangePasswordScreenState(); }
class _ChangePasswordScreenState extends State<ChangePasswordScreen>{
  final cur=TextEditingController(); final np=TextEditingController(); final cp=TextEditingController(); bool loading=false;
  Future<void> _save() async { setState(()=>loading=true); try{ await ApiService.changePassword(cur.text.trim(),np.text.trim(),cp.text.trim()); if(!mounted)return; showSnack(context,'Password changed'); Navigator.pop(context); } catch(e){ if(mounted) showSnack(context,e.toString().replaceFirst('Exception: ','')); } finally{ if(mounted)setState(()=>loading=false);} }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Change Password')), body:LScaffold(child:Column(children:[const SizedBox(height:40), LCard(padding:const EdgeInsets.all(22),child:Column(children:[LTextField(controller:cur,label:'Current Password',hint:'••••••••',obscure:true), const SizedBox(height:16), LTextField(controller:np,label:'New Password',hint:'••••••••',obscure:true), const SizedBox(height:16), LTextField(controller:cp,label:'Confirm New Password',hint:'••••••••',obscure:true), const SizedBox(height:20), LButton(text:loading?'Updating...':'Update Password',icon:Icons.check,onPressed:loading?null:_save)]))]), padding:const EdgeInsets.fromLTRB(24,0,24,20)));
}
