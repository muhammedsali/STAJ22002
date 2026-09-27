import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart'; // HomeScreen'i import ediyoruz
import '../../providers/auth_provider.dart'; // API Provider'ımızı import ediyoruz
// import 'register_screen.dart'; // Kayıt ekranını oluşturunca yorum satırını kaldırırız

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TEDAŞ Kurumsal Lacivert
    const primaryColor = Color(0xFF002244); 

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo Alanı 
              Icon(
                Icons.electric_bolt,
                size: 64,
                color: primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'TEDAŞ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              
              const Text(
                'Sisteme Giriş',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // E-posta Alanı
              TextFormField(
                controller: _emailController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  hintText: 'ornek@tedas.gov.tr',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Şifre Alanı
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Şifremi Unuttum (Görseldeki gibi sağa dayalı)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Şifremi Unuttum?'),
                ),
              ),
              const SizedBox(height: 24),

              // Giriş Yap Butonu (API Entegrasyonlu)
              Consumer(
                builder: (context, ref, child) {
                  // Auth sağlayıcısını dinliyoruz
                  final authState = ref.watch(authProvider);
                  final isLoading = authState.isLoading;

                  // Hata varsa ekranda göster
                  ref.listen<AsyncValue>(authProvider, (_, state) {
                    if (state.hasError && !state.isLoading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });

                  return ElevatedButton(
                    onPressed: isLoading
                        ? null // Yükleniyorsa butonu pasif yap
                        : () async {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen tüm alanları doldurun.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Provider üzerinden login fonksiyonunu çağırıyoruz
                            final success = await ref
                                .read(authProvider.notifier)
                                .login(email, password);
                            
                            // Başarılıysa ana sayfaya yönlendir
                            if (success && context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Kayıt Ol Yönlendirmesi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hesabınız yok mu?'),
                  TextButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
}