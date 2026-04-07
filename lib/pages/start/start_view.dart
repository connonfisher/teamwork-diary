import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moodiary/l10n/l10n.dart';

import 'start_logic.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Bind.find<StartLogic>();

    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 320,
              padding: const EdgeInsets.all(10.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: context.l10n.startTitle1),
                    TextSpan(
                      text: context.l10n.startTitle2,
                      style: TextStyle(
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  ],
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 320,
              padding: const EdgeInsets.all(10.0),
              child: Text(
                context.l10n.startTitle3,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 320,
              padding: const EdgeInsets.all(10.0),
              child: FilledButton(
                onPressed: () {
                  logic.toHome();
                },
                child: Text(context.l10n.startChoice2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
