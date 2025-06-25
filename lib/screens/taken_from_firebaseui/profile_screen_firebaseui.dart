// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart'
    hide OAuthProviderButtonBase;
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
// import 'package:first_project/model/audio_handler.dart';
// import 'package:first_project/model/player.dart';
import 'package:first_project/screens/now_playing_content.dart';
import 'package:first_project/screens/own_login_screen.dart';
import 'package:first_project/screens/taken_from_firebaseui/multi_provider_screen_firebaseui.dart';
import 'package:first_project/widgets/qawl_back_button_widget.dart';
import 'package:flutter/cupertino.dart' hide Title;
import 'package:flutter/material.dart' hide Title;
import 'package:flutter/services.dart';
import 'package:first_project/model/user.dart';
import 'package:firebase_ui_auth/src/widgets/internal/rebuild_scope.dart';
import 'package:firebase_ui_auth/src/widgets/internal/subtitle.dart';
import 'package:firebase_ui_auth/src/widgets/internal/universal_icon_button.dart';
import 'package:image_picker/image_picker.dart';

class _AvailableProvidersRow extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;
  final List<AuthProvider> providers;
  final VoidCallback onProviderLinked;
  // final MyAudioHandler audioHandler;


  const _AvailableProvidersRow({
    this.auth,
    required this.providers,
    required this.onProviderLinked, 
    // required this.audioHandler,
  });

  @override
  State<_AvailableProvidersRow> createState() => _AvailableProvidersRowState();
}

class _AvailableProvidersRowState extends State<_AvailableProvidersRow> {
  AuthFailed? error;

  Future<void> connectProvider({
    required BuildContext context,
    required AuthProvider provider,
  }) async {
    setState(() {
      error = null;
    });

    switch (provider.providerId) {
      case 'phone':
        await startPhoneVerification(
          context: context,
          action: AuthAction.link,
          auth: widget.auth,
        );
        break;
      case 'password':
        await showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          pageBuilder: (context, _, __) {
            return EmailSignUpDialog(
              provider: provider as EmailAuthProvider,
              auth: widget.auth,
              action: AuthAction.link,
            );
          },
        );
    }

    await (widget.auth ?? fba.FirebaseAuth.instance).currentUser!.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    final providers = widget.providers
        .where((provider) => provider is! EmailLinkAuthProvider)
        .toList();

    Widget child = Row(
      children: [
        for (var provider in providers)
          if (provider is! OAuthProvider)
            if (isCupertino)
              CupertinoButton(
                onPressed: () => connectProvider(
                  context: context,
                  provider: provider,
                ).then((_) => widget.onProviderLinked()),
                child: Icon(
                  providerIcon(context, provider.providerId),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  providerIcon(context, provider.providerId),
                ),
                onPressed: () => connectProvider(
                  context: context,
                  provider: provider,
                ).then((_) => widget.onProviderLinked()),
              )
          else
            AuthStateListener<OAuthController>(
              listener: (oldState, newState, controller) {
                if (newState is CredentialLinked) {
                  widget.onProviderLinked();
                } else if (newState is AuthFailed) {
                  setState(() => error = newState);
                }
                return null;
              },
              child: OAuthProviderButton(
                provider: provider,
                auth: widget.auth,
                action: AuthAction.link,
                variant: OAuthButtonVariant.icon,
              ),
            ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Subtitle(text: l.enableMoreSignInMethods),
        const SizedBox(height: 16),
        child,
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ErrorText(exception: error!.exception),
          ),
      ],
    );
  }
}

class _EditButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback? onPressed;

  const _EditButton({
    required this.isEditing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UniversalIconButton(
      materialIcon: isEditing ? Icons.check : Icons.edit,
      cupertinoIcon: isEditing ? CupertinoIcons.check_mark : CupertinoIcons.pen,
      color: Colors.green,
      onPressed: () {
        onPressed?.call();
      },
    );
  }
}

class _LinkedProvidersRow extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final fba.FirebaseAuth? auth;
  final List<AuthProvider> providers;
  final VoidCallback onProviderUnlinked;
  final bool showUnlinkConfirmationDialog;

  const _LinkedProvidersRow({
    this.auth,
    required this.providers,
    required this.onProviderUnlinked,
    required this.showUnlinkConfirmationDialog,
  });

  @override
  State<_LinkedProvidersRow> createState() => _LinkedProvidersRowState();
}

class _LinkedProvidersRowState extends State<_LinkedProvidersRow> {
  bool isEditing = false;
  String? unlinkingProvider;
  fba.FirebaseAuthException? error;

  final size = 32.0;

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      error = null;
    });
  }

  void Function() pop(bool value) {
    return () {
      Navigator.of(context).pop(value);
    };
  }

  Future<void> _unlinkProvider(BuildContext context, String providerId) async {
    setState(() {
      unlinkingProvider = providerId;
      error = null;
    });

    bool? confirmed = !widget.showUnlinkConfirmationDialog;

    if (!confirmed) {
      final l = FirebaseUILocalizations.labelsOf(context);

      confirmed = await showAdaptiveDialog<bool?>(
        context: context,
        builder: (context) {
          return UniversalAlert(
            onConfirm: pop(true),
            onCancel: pop(false),
            title: l.ulinkProviderAlertTitle,
            confirmButtonText: l.confirmUnlinkButtonLabel,
            cancelButtonText: l.cancelButtonLabel,
            message: l.unlinkProviderAlertMessage,
          );
        },
      );
    }

    try {
      if (!(confirmed ?? false)) return;

      final user = widget.auth!.currentUser!;
      await user.unlink(providerId);
      await user.reload();

      setState(() {
        widget.onProviderUnlinked();
        isEditing = false;
      });
    } on fba.FirebaseAuthException catch (e) {
      setState(() {
        error = e;
      });
    } finally {
      setState(() {
        unlinkingProvider = null;
      });
    }
  }

  Widget buildProviderIcon(BuildContext context, String providerId) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    const animationDuration = Duration(milliseconds: 150);
    const curve = Curves.easeOut;

    VoidCallback? unlink;

    if (isEditing) {
      unlink = () => _unlinkProvider(context, providerId);
    }

    return Stack(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: unlinkingProvider == providerId
              ? LoadingIndicator(
                  size: size - (size / 4),
                  borderWidth: 1,
                )
              : Icon(providerIcon(context, providerId)),
        ),
        if (unlinkingProvider != providerId)
          AnimatedOpacity(
            duration: animationDuration,
            opacity: isEditing ? 1 : 0,
            curve: curve,
            child: SizedBox(
              width: size,
              height: size,
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: unlink,
                  child: Transform.translate(
                    offset: const Offset(6, -4),
                    child: Icon(
                      isCupertino
                          ? CupertinoIcons.minus_circle_fill
                          : Icons.remove_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    Widget child = Row(
      children: [
        for (var provider in widget.providers)
          buildProviderIcon(context, provider.providerId)
      ]
          .map((e) => [e, const SizedBox(width: 8)])
          .expand((element) => element)
          .toList(),
    );

    if (widget.providers.length > 1) {
      child = Row(
        children: [
          Expanded(child: child),
          const SizedBox(width: 8),
          _EditButton(
            isEditing: isEditing,
            onPressed: _toggleEdit,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Subtitle(text: l.signInMethods),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _EmailVerificationBadge extends StatefulWidget {
  final fba.FirebaseAuth auth;
  final fba.ActionCodeSettings? actionCodeSettings;
  const _EmailVerificationBadge({
    required this.auth,
    this.actionCodeSettings,
  });

  @override
  State<_EmailVerificationBadge> createState() =>
      _EmailVerificationBadgeState();
}

class _EmailVerificationBadgeState extends State<_EmailVerificationBadge> {
  late final service = EmailVerificationController(widget.auth)
    ..addListener(() {
      setState(() {});
    })
    ..reload();

  EmailVerificationState get state => service.state;

  fba.User get user {
    return widget.auth.currentUser!;
  }

  TargetPlatform get platform {
    return Theme.of(context).platform;
  }

  @override
  Widget build(BuildContext context) {
    if (state == EmailVerificationState.dismissed ||
        state == EmailVerificationState.unresolved ||
        state == EmailVerificationState.verified) {
      return const SizedBox.shrink();
    }

    final l = FirebaseUILocalizations.labelsOf(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Subtitle(
                    text: state == EmailVerificationState.sent ||
                            state == EmailVerificationState.pending
                        ? l.verificationEmailSentTextShort
                        : l.emailIsNotVerifiedText,
                    fontWeight: FontWeight.bold,
                  ),
                  if (state == EmailVerificationState.pending) ...[
                    const SizedBox(height: 8),
                    Text(l.checkEmailHintText),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state == EmailVerificationState.pending)
            // ignore: prefer_const_constructors
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingIndicator(size: 16, borderWidth: 0.5),
                const SizedBox(width: 16),
                Text(l.waitingForEmailVerificationText),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (state != EmailVerificationState.sent &&
                    state != EmailVerificationState.sending)
                  UniversalButton(
                    variant: ButtonVariant.text,
                    materialColor: Theme.of(context).colorScheme.error,
                    cupertinoColor: CupertinoColors.destructiveRed,
                    text: l.dismissButtonLabel,
                    onPressed: () {
                      setState(service.dismiss);
                    },
                  ),
                if (state != EmailVerificationState.sent)
                  LoadingButton(
                    isLoading: state == EmailVerificationState.sending,
                    label: 'Send verification email',
                    onTap: () {
                      service.sendVerificationEmail(
                        platform,
                        widget.actionCodeSettings,
                      );
                    },
                  )
                else
                  UniversalButton(
                    variant: ButtonVariant.text,
                    text: l.okButtonLabel,
                    onPressed: () {
                      setState(service.dismiss);
                    },
                  )
              ],
            )
        ],
      ),
    );
  }
}

class _MFABadge extends StatelessWidget {
  final bool enrolled;
  final fba.FirebaseAuth auth;
  final VoidCallback onToggled;
  final List<AuthProvider> providers;

  const _MFABadge({
    required this.enrolled,
    required this.auth,
    required this.onToggled,
    required this.providers,
  });

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Subtitle(text: l.mfaTitle),
          const SizedBox(height: 8),
          _MFAToggle(
            enrolled: enrolled,
            auth: auth,
            onToggled: onToggled,
            providers: providers,
          ),
        ],
      ),
    );
  }
}

class _MFAToggle extends StatefulWidget {
  final bool enrolled;
  final fba.FirebaseAuth auth;
  final VoidCallback? onToggled;
  final List<AuthProvider> providers;

  const _MFAToggle({
    required this.enrolled,
    required this.auth,
    required this.onToggled,
    required this.providers,
  });

  @override
  State<_MFAToggle> createState() => _MFAToggleState();
}

class _MFAToggleState extends State<_MFAToggle> {
  bool isLoading = false;
  Exception? exception;

  IconData getCupertinoIcon() {
    if (widget.enrolled) {
      return CupertinoIcons.check_mark_circled;
    } else {
      return CupertinoIcons.circle;
    }
  }

  IconData getMaterialIcon() {
    if (widget.enrolled) {
      return Icons.check_circle;
    } else {
      return Icons.remove_circle_sharp;
    }
  }

  Color getColor() {
    if (widget.enrolled) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  Future<bool> _reauthenticate() async {
    return await showReauthenticateDialog(
      context: context,
      providers: widget.providers,
      auth: widget.auth,
      onSignedIn: () {
        Navigator.of(context).pop(true);
      },
    );
  }

  Future<void> _disable() async {
    setState(() {
      exception = null;
      isLoading = true;
    });

    final mfa = widget.auth.currentUser!.multiFactor;
    final factors = await mfa.getEnrolledFactors();

    if (factors.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await mfa.unenroll(multiFactorInfo: factors.first);
      widget.onToggled?.call();
    } on PlatformException catch (e) {
      if (e.code == 'FirebaseAuthRecentLoginRequiredException') {
        if (await _reauthenticate()) {
          await _disable();
        }
      } else {
        rethrow;
      }
    } on Exception catch (e) {
      setState(() {
        exception = e;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _enable() async {
    setState(() {
      exception = null;
      isLoading = true;
    });

    final currentRoute = ModalRoute.of(context);

    final mfa = widget.auth.currentUser!.multiFactor;
    final session = await mfa.getSession();

    await startPhoneVerification(
      context: context,
      action: AuthAction.none,
      multiFactorSession: session,
      auth: widget.auth,
      actions: [
        AuthStateChangeAction<CredentialReceived>((context, state) async {
          final cred = state.credential as fba.PhoneAuthCredential;
          final assertion = fba.PhoneMultiFactorGenerator.getAssertion(cred);

          try {
            await mfa.enroll(assertion);
            widget.onToggled?.call();
          } on Exception catch (e) {
            setState(() {
              exception = e;
            });
          } finally {
            setState(() {
              isLoading = false;
            });

            Navigator.of(context).popUntil((route) => route == currentRoute);
          }
        })
      ],
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            UniversalIcon(
              cupertinoIcon: getCupertinoIcon(),
              materialIcon: getMaterialIcon(),
              color: getColor(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.enrolled ? l.on : l.off),
            ),
            LoadingButton(
              variant: ButtonVariant.text,
              label: widget.enrolled ? l.disable : l.enable,
              onTap: widget.enrolled ? _disable : _enable,
              isLoading: isLoading,
            )
          ],
        ),
        if (exception != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ErrorText(exception: exception!),
          )
      ],
    );
  }
}

/// {@template ui.auth.screens.profile_screen}
/// A pre-built profile screen that allows to link more auth providers,
/// unlink auth providers, edit user name and delete the account. Could also
/// contain a user-defined content.
/// {@endtemplate}
class MyProfileScreen extends MultiProviderScreen {
  /// A user-defined content of the screen.
  final List<Widget> children;

  /// {@macro ui.auth.widgets.user_avatar.placeholder_color}
  final Color? avatarPlaceholderColor;

  /// {@macro ui.auth.widgets.user_avatar.shape}
  final ShapeBorder? avatarShape;

  /// {@macro ui.auth.widgets.user_avatar.size}
  final double? avatarSize;

  /// Possible actions that could be triggered:
  ///
  /// - [SignedOutAction]
  /// - [AuthStateChangeAction]
  ///
  /// ```dart
  /// ProfileScreen(
  ///   actions: [
  ///     SignedOutAction((context) {
  ///       Navigator.of(context).pushReplacementNamed('/sign-in');
  ///     }),
  ///     AuthStateChangeAction<CredentialLinked>((context, state) {
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(
  ///           content: Text("Provider sucessfully linked!"),
  ///         ),
  ///       );
  ///     }),
  ///   ]
  /// )
  /// ```
  final List<FirebaseUIAction>? actions;

  /// See [Scaffold.appBar].
  final AppBar? appBar;

  /// See [CupertinoPageScaffold.navigationBar].
  final CupertinoNavigationBar? cupertinoNavigationBar;

  /// A configuration object used to construct a dynamic link for email
  /// verification.
  final fba.ActionCodeSettings? actionCodeSettings;

  /// Indicates whether MFA tile should be shown.
  final bool showMFATile;

  /// A custom avatar widget that is used instead of the default one.
  /// If provided, [avatarPlaceholderColor], [avatarShape] and [avatarSize]
  /// are ignored.
  final Widget? avatar;

  /// Indicates wether a confirmation dialog should be shown when the user
  /// tries to unlink a provider.
  final bool showUnlinkConfirmationDialog;

  const MyProfileScreen({
    super.key,
    super.auth,
    super.providers,
    this.avatar,
    this.avatarPlaceholderColor,
    this.avatarShape,
    this.avatarSize,
    this.children = const [],
    this.actions,
    this.appBar,
    this.cupertinoNavigationBar,
    this.actionCodeSettings,
    this.showMFATile = false,
    this.showUnlinkConfirmationDialog = false,
  });

  Future<bool> _reauthenticate(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return showReauthenticateDialog(
      context: context,
      providers: providers,
      auth: auth,
      onSignedIn: () => Navigator.of(context).pop(true),
      actionButtonLabelOverride: l.deleteAccount,
    );
  }

  List<AuthProvider> getLinkedProviders(fba.User user) {
    return providers
        .where((provider) => user.isProviderLinked(provider.providerId))
        .toList();
  }

  List<AuthProvider> getAvailableProviders(
    BuildContext context,
    fba.User user,
  ) {
    final platform = Theme.of(context).platform;

    return providers
        .where(
          (provider) =>
              !user.isProviderLinked(provider.providerId) &&
              provider.supportsPlatform(platform),
        )
        .toList();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    print("clicked picker");

    if (pickedFile != null) {
      String? uid = QawlUser.getCurrentUserUid();
      if (uid != null) {
        debugPrint("HERE");
        String imagePath = pickedFile.path;
        QawlUser? currUser = await QawlUser.getQawlUser(uid);

        await currUser!.updateImagePath(uid, imagePath);
      } else {
        print("No signed-in user found.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseUITheme(
      styles: const {},
      child: Builder(builder: buildPage),
    );
  }

  Widget buildPage(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final providersScopeKey = RebuildScopeKey();
    final mfaScopeKey = RebuildScopeKey();
    final emailVerificationScopeKey = RebuildScopeKey();

    final user = auth.currentUser!;
    const snackBar = SnackBar(
      content: Text('Changes will take effect after refereshing the app'),
    );

    void _showConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text(
                'Are you sure you want to delete your account? This cannot be undone.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Dismiss the dialog without doing anything
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Dismiss the dialog
                  fba.User? user = fba.FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    final String uid = user.uid;
                    // print("USER ID IS: " + uid);

                    try {
                      print("now going back to login");
                    //  await Navigator.of(context).pushAndRemoveUntil(
                    //     MaterialPageRoute(builder: (context) => LoginPage()),
                    //     (Route<dynamic> route) => false,
                    //   );
                      // First, delete the Firestore data
                      await FirebaseFirestore.instance
                          .collection('QawlUsers')
                          .doc(uid)
                          .delete();

                      // Then delete the user from Firebase Authentication
                       await user.delete();

                      // Optionally sign out the user, though delete should handle this
                     // await fba.FirebaseAuth.instance.signOut();
                      print("going back to login page");
                      // Finally, navigate to the login page

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Account successfully deleted")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Failed to delete account: ${e.toString()}")),
                      );
                    }
                  }
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    }

    // final avatarWidget = avatar ??
    //     Align(
    //       child: UserAvatar(
    //         auth: auth,
    //         placeholderColor: Colors.green,
    //         shape: avatarShape,
    //         size: avatarSize,
    //       ),
    //     );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QawlBackButton(),
        // avatarWidget,
        Align(child: EditableUserDisplayName(auth: auth)),
        //This is for changing your email provider. Save for later
        // if (!user.emailVerified) ...[
        //   RebuildScope(
        //     builder: (context) {
        //       if (user.emailVerified) {
        //         return const SizedBox.shrink();
        //       }

        //       return _EmailVerificationBadge(
        //         auth: auth,
        //         actionCodeSettings: actionCodeSettings,
        //       );
        //     },
        //     scopeKey: emailVerificationScopeKey,
        //   ),
        // ],
        // RebuildScope(
        //   builder: (context) {
        //     final user = auth.currentUser!;
        //     final linkedProviders = getLinkedProviders(user);

        //     if (linkedProviders.isEmpty) {
        //       return const SizedBox.shrink();
        //     }

        //     return Padding(
        //       padding: const EdgeInsets.only(top: 32),
        //       child: _LinkedProvidersRow(
        //         auth: auth,
        //         providers: linkedProviders,
        //         onProviderUnlinked: providersScopeKey.rebuild,
        //         showUnlinkConfirmationDialog: showUnlinkConfirmationDialog,
        //       ),
        //     );
        //   },
        //   scopeKey: providersScopeKey,
        // ),
        // RebuildScope(
        //   builder: (context) {
        //     final user = auth.currentUser!;
        //     final availableProviders = getAvailableProviders(context, user);

        //     if (availableProviders.isEmpty) {
        //       return const SizedBox.shrink();
        //     }

        //     return Padding(
        //       padding: const EdgeInsets.only(top: 32),
        //       child: _AvailableProvidersRow(
        //         auth: auth,
        //         providers: availableProviders,
        //         onProviderLinked: providersScopeKey.rebuild,
        //       ),
        //     );
        //   },
        //   scopeKey: providersScopeKey,
        // ),
        // if (showMFATile)
        //   RebuildScope(
        //     builder: (context) {
        //       final user = auth.currentUser!;
        //       final mfa = user.multiFactor;

        //       return FutureBuilder<List<fba.MultiFactorInfo>>(
        //         future: mfa.getEnrolledFactors(),
        //         builder: (context, snapshot) {
        //           if (!snapshot.hasData) {
        //             return const SizedBox.shrink();
        //           }

        //           final enrolledFactors = snapshot.requireData;

        //           return Padding(
        //             padding: const EdgeInsets.only(top: 8.0),
        //             child: _MFABadge(
        //               providers: providers,
        //               enrolled: enrolledFactors.isNotEmpty,
        //               auth: auth,
        //               onToggled: mfaScopeKey.rebuild,
        //             ),
        //           );
        //         },
        //       );
        //     },
        //     scopeKey: mfaScopeKey,
        //   ),
        // ...children,
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 50.0, right: 50.0),
          child: GestureDetector(
            onTap: () {
              _pickImage();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: <Color>[
                    Color.fromARGB(255, 13, 161, 99),
                    Color.fromARGB(255, 22, 181, 93),
                    Color.fromARGB(255, 32, 220, 85),
                  ],
                ),
              ),
              width: 120,
              height: 40,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5), // Adjust the spacing as needed
                  Text(
                    "New Profile Photo",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 50.0,right: 50.0),
          child: ElevatedButton(
            onPressed: () async {
              // audioHandler.pause;
              
              await fba.FirebaseAuth.instance.signOut();
              print("clicked sign out");

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Text color
            ),
          ),
        ),
        // SignOutButton(
        //   auth: auth,
        //   variant: ButtonVariant.outlined,
        // ),
        // steps for delete: get current user, navigate back to login, delete the user

        const SizedBox(height: 8),
         Padding(
           padding: const EdgeInsets.only(left: 50.0, right: 50.0),
           child: ElevatedButton(
            onPressed: () async {
              // Sign out the user
              // await auth?.signOut();
              print("clicked Delete");
              fba.User? user = fba.FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final String uid = user.uid;
                      // print("USER ID IS: " + uid);
           
                      try {
                        print("now going back to login");
                      //  await Navigator.of(context).pushAndRemoveUntil(
                      //     MaterialPageRoute(builder: (context) => LoginPage()),
                      //     (Route<dynamic> route) => false,
                      //   );
                        
           
                        // First delete the user from Firebase Authentication
                        await user.delete();
                        print("going back to login page");
                        // Finally, navigate to the login page
                        
                        // then, delete the Firestore data
                       await FirebaseFirestore.instance
                           .collection('QawlUsers')
                           .doc(uid)
                           .delete();
           
                       await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (Route<dynamic> route) => false,
                        );
           
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Account successfully deleted")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Failed to delete account: ${e.toString()}")),
                        );
                      }
                    }
            },
            child: Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Text color
            ),
                   ),
         ),
        // ElevatedButton(
        //   onPressed: () => _showConfirmationDialog(context),
        //   child: Text('Delete Account'),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.red, // Background color
        //   ),
        // ),
        // const SizedBox(height: 8),
        // ElevatedButton(
        //   onPressed: () async {
        //     fba.User? user = fba.FirebaseAuth.instance.currentUser;

        //     if (user != null) {
        //       final String uid = user.uid;
        //       print("USER ID IS: " + uid);

        //       // delete firebase authentication
        //       user.delete();
        //       // delete from firestore collection
        //       await FirebaseFirestore.instance
        //           .collection('QawlUsers')
        //           .doc(uid)
        //           .delete();
        //       //navigate back to login page
        //       Navigator.of(context).pushAndRemoveUntil(
        //         MaterialPageRoute(builder: (context) => LoginPage()),
        //         (Route<dynamic> route) => false,
        //       );
        //     }
        //     // Sign out the user
        //     print("clicked delete");
        //   },
        //   child: Text('Delete Account'),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.red, // Text color
        //   ),
        // ),

        // DeleteAccountButton(
        //   auth: auth,
        //   onSignInRequired: () {
        //     return _reauthenticate(context);
        //   },
        // ),
      ],
    );

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: content,
              );
            } else {
              return content;
            }
          },
        ),
      ),
    );

    Widget child = SafeArea(child: SingleChildScrollView(child: body));

    if (isCupertino) {
      child = CupertinoPageScaffold(
        navigationBar: cupertinoNavigationBar,
        child: SafeArea(
          child: SingleChildScrollView(child: child),
        ),
      );
    } else {
      child = Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: SingleChildScrollView(child: body),
        ),
      );
    }

    return FirebaseUIActions(
      actions: actions ?? const [],
      child: child,
    );
  }
}
