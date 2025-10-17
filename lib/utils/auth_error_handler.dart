import 'package:flutter/material.dart';

/// Enhanced user-friendly error handler for authentication
class AuthErrorHandler {
  /// Convert technical Supabase errors to user-friendly messages
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Check for common authentication errors
    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid_credentials') ||
        errorString.contains('invalid email or password')) {
      return 'Incorrect email or password. Please try again.';
    }

    if (errorString.contains('email not confirmed')) {
      return 'Please check your email and confirm your account before logging in.';
    }

    if (errorString.contains('user already registered') ||
        errorString
            .contains('duplicate key value violates unique constraint')) {
      return 'This email is already registered. Please try logging in instead.';
    }

    if (errorString.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }

    if (errorString.contains('email_address_invalid') ||
        errorString.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (errorString.contains('too many requests') ||
        errorString.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Connection problem. Please check your internet and try again.';
    }

    if (errorString.contains('user not found')) {
      return 'No account found with this email. Please register first.';
    }

    if (errorString.contains('signup disabled')) {
      return 'New registrations are currently disabled. Please contact support.';
    }

    if (errorString.contains('database') ||
        errorString.contains('postgres') ||
        errorString.contains('row-level security policy')) {
      return 'System temporarily unavailable. Please try again in a moment.';
    }

    if (errorString.contains('authentication failed after user creation') ||
        errorString
            .contains('registration completed but automatic login failed')) {
      return 'Account created successfully! Please try logging in with your credentials.';
    }

    // Default for unknown errors
    return 'Something went wrong. Please try again or contact support.';
  }

  /// Get appropriate icon for error type
  static IconData getErrorIcon(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid_credentials')) {
      return Icons.lock_outline;
    }

    if (errorString.contains('email not confirmed')) {
      return Icons.email_outlined;
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return Icons.wifi_off;
    }

    if (errorString.contains('user not found')) {
      return Icons.person_search;
    }

    return Icons.error_outline;
  }

  /// Get color for error type
  static Color getErrorColor(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('invalid login credentials') ||
        errorString.contains('invalid_credentials')) {
      return Colors.amber; // Warning color for wrong credentials
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return Colors.blue; // Info color for network issues
    }

    return Colors.red; // Default error color
  }
}

/// Beautiful animated error widget
class AuthErrorWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onRetry;
  final VoidCallback? onForgotPassword;

  const AuthErrorWidget({
    Key? key,
    required this.message,
    required this.icon,
    required this.color,
    this.onRetry,
    this.onForgotPassword,
  }) : super(key: key);

  @override
  State<AuthErrorWidget> createState() => _AuthErrorWidgetState();
}

class _AuthErrorWidgetState extends State<AuthErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: widget.color.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.onRetry != null || widget.onForgotPassword != null)
                    const SizedBox(height: 12),
                  if (widget.onRetry != null || widget.onForgotPassword != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.onForgotPassword != null)
                          TextButton(
                            onPressed: widget.onForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: widget.color,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (widget.onRetry != null) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: widget.onRetry,
                            icon: Icon(Icons.refresh, size: 16),
                            label: Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Success feedback widget
class AuthSuccessWidget extends StatefulWidget {
  final String message;

  const AuthSuccessWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<AuthSuccessWidget> createState() => _AuthSuccessWidgetState();
}

class _AuthSuccessWidgetState extends State<AuthSuccessWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
