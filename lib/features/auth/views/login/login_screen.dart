import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_cubit_event.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/app_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocPresentationListener<AuthCubit, AuthCubitEvent>(
      listener: (context, event) {
        switch (event) {
          case AuthErrorEvent():
            Navigator.of(context)
                .popUntil((route) => route is! ModalBottomSheetRoute);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(event.reason)));
          case AuthenticatedEvent(:final user):
            Navigator.of(context)
                .popUntil((route) => route is! ModalBottomSheetRoute);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Zalogowano jako ${user.email}')),
              );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryVeryDark,
                    ],
                  ),
                ),
              ),
            ),

            // Background decorative elements
            const Positioned(
              top: -50,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: -100,
              left: -50,
              child: Opacity(
                opacity: 0.08,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          const ResellioLogoWithTitle(size: 120),
                          _buildAppDescription(),
                          const SizedBox(height: 120),
                          _buildLoginButton(
                            context,
                            title: 'Chcę kupować bilety',
                            icon: Icons.person,
                            isCustomer: true,
                          ),
                          const SizedBox(height: 16),
                          _buildLoginButton(
                            context,
                            title: 'Chcę sprzedawać bilety',
                            icon: Icons.business,
                            isCustomer: false,
                            isOutlined: true,
                          ),
                          const SizedBox(height: 32),
                          TextButton(
                            onPressed: () => context
                                .read<AuthCubit>()
                                .adminSignInWithGoogle(),
                            child: const Text(
                              'Zaloguj się jako administrator',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: const Text(
        'Kupuj i sprzedawaj bilety na wydarzenia',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isCustomer,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLoginBottomSheet(
          context,
          title: isCustomer
              ? 'Zaloguj/zarejestruj się jako kupujący'
              : 'Zaloguj/zarejestruj się jako sprzedawca',
          icon: icon,
          onSignInWithGoogle: isCustomer
              ? context.read<AuthCubit>().customerSignInWithGoogle
              : context.read<AuthCubit>().organizerSignInWithGoogle,
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: isOutlined ? Colors.white : const Color(0xFF1E88E5),
          backgroundColor: isOutlined ? Colors.transparent : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isOutlined ? Colors.white : const Color(0xFF1E88E5),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isOutlined ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginBottomSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Future<void> Function() onSignInWithGoogle,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return LoginBottomSheet(
              title: title,
              icon: icon,
              onSignInWithGoogle: onSignInWithGoogle,
            );
          },
        );
      },
    );
  }
}

class SignInWithGoogleButton extends StatefulWidget {
  const SignInWithGoogleButton({
    super.key,
    required this.onSignInWithGoogle,
  });

  final Future<void> Function() onSignInWithGoogle;

  @override
  _SignInWithGoogleButtonState createState() => _SignInWithGoogleButtonState();
}

class _SignInWithGoogleButtonState extends State<SignInWithGoogleButton> {
  bool _isLoading = false;

  Future<void> _onClick() async {
    setState(() {
      _isLoading = true;
    });

    await widget.onSignInWithGoogle();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _onClick,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                  ),
                )
              : Image.asset(
                  'assets/icon/google.png',
                  width: 24,
                  height: 24,
                ),
        ),
        label: Text(
          _isLoading ? 'Logowanie...' : 'Zaloguj się przez Google',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.onSignInWithGoogle,
  });

  final String title;
  final IconData icon;
  final Future<void> Function() onSignInWithGoogle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _buildDragHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Icon(icon, size: 64, color: const Color(0xFF1E88E5)),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SignInWithGoogleButton(onSignInWithGoogle: onSignInWithGoogle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
