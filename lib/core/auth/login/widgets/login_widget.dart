import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/config/themes/tb_text_styles.dart';
import 'package:thingsboard_app/core/auth/login/provider/login_provider.dart';
import 'package:thingsboard_app/core/auth/login/provider/oauth_provider.dart';
import 'package:thingsboard_app/core/auth/login/widgets/footer/login_footer.dart';
import 'package:thingsboard_app/core/auth/login/widgets/full_screen_loader.dart';
import 'package:thingsboard_app/core/auth/login/widgets/header/login_header.dart';
import 'package:thingsboard_app/core/auth/login/widgets/text_field.dart';
import 'package:thingsboard_app/core/logger/tb_logger.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/ui/visibility_widget.dart';

class LoginWidget extends HookConsumerWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(true);
    final providers = ref.watch(oauthProvider);
    final form = useMemoized(
      () => FormGroup({
        "email": FormControl(
          validators: [Validators.required, Validators.email],
        ),
        "password": FormControl(validators: [Validators.required]),
      }),
    );
    useEffect(() {
      if (providers is! AsyncLoading) {
        loading.value = false;
      }
      return null;
    }, [providers]);
    final mediaQuery = MediaQuery.of(context);
    return Stack(
      children: [
        ReactiveForm(
          formGroup: form,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SingleChildScrollView(
                child: SizedBox(
                  height:
                      mediaQuery.size.height -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom -
                      kToolbarHeight,
                  child: Column(
                    spacing: 16,
                    children: [
                      const LoginHeader(),
                      Text(
                        S.of(context).loginToYourAccount,
                        style: TbTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: AutofillGroup(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(46),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  spacing: 24,
                                  children: [
                                    TbTextField(
                                      formControlName: "email",
                                      label: S.of(context).email,
                                      hint: S.of(context).email,
                                      autoFillHints: const [
                                        AutofillHints.email,
                                      ],
                                    ),
                                    TbTextField(
                                      formControlName: "password",
                                      label: S.of(context).password,
                                      hint: S.of(context).password,
                                      obscureText: true,
                                      autoFillHints: const [
                                        AutofillHints.password,
                                      ],
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => onForgotPassword(context),
                                    child: Text(
                                      S.of(context).passwordForgotText,
                                      style: TbTextStyles.labelSmall.copyWith(
                                        color: AgriPulseBrand.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ReactiveFormConsumer(
                          builder: (context, formGroup, child) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AgriPulseBrand.green,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: AgriPulseBrand
                                          .green
                                          .withAlpha(110),
                                      disabledForegroundColor: Colors.white70,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed:
                                        formGroup.invalid && formGroup.touched
                                            ? null
                                            : () async {
                                              await onLoginPressed(
                                                context,
                                                form,
                                                ref,
                                                loading
                                              );
                                            },
                                    child: Text(
                                      S.of(context).login,
                                      style: TbTextStyles.labelMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const LoginFooter(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        AnimatedVisibilityWidget(
          show: loading.value || providers is AsyncLoading,
          child: const FullScreenLoader(),
        ),
      ],
    );
  }
}

Future<void> onLoginPressed(
  BuildContext context,
  FormGroup form,
  WidgetRef ref,
  ValueNotifier<bool> loading,
) async {
  FocusScope.of(context).unfocus();
  form.markAllAsTouched();
  if (form.invalid) {
    return;
  }
  final String username = form.control('email').value.toString();
  final String password = form.control('password').value.toString();
  try {
    loading.value = true;
  final res =   await ref.read(loginProvider.notifier).login(username, password);

    loading.value = res;
  } catch (e) {
    // Silent-login-failure fix: stop the loader and show the real error.
    loading.value = false;
    form.setErrors({"err": {}});
    if (context.mounted) {
      final message =
          e is ThingsboardError ? (e.message ?? e.toString()) : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $message'),
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

Future<void> onLoginWithBarcode(BuildContext context) async {
  try {
    final Barcode? barcode = await getIt<ThingsboardAppRouter>().navigateTo(
      '/qrCodeScan',
      transition: TransitionType.nativeModal,
    );

    if (barcode != null && barcode.rawValue != null) {
      getIt<ThingsboardAppRouter>().navigateByAppLink(barcode.rawValue);
    }
  } catch (e) {
    getIt<TbLogger>().error('Login with qr code error', e);
  }
}

Future<void> onOauth2ButtonPressed(
  OAuth2ClientInfo client,
  BuildContext context,
  ValueNotifier<bool> loading,
  WidgetRef ref,
) async {
  FocusScope.of(context).unfocus();
  if (client.name == 'qr') {
    await onLoginWithBarcode(context);
    return;
  }
  loading.value = true;
final res =  await  ref.read(loginProvider.notifier).oauthLogin(client.url);
  loading.value = res;
}

Future<void> onForgotPassword(BuildContext context) async {
  context.push('/login/resetPasswordRequest');
}
