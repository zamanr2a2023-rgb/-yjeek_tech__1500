import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/core/utils/responsive.dart';
import 'package:yjeek_app/features/cart/view/widgets/cart_flow_widgets.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Place booking label is fully visible', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppDesign.size,
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: CartStickyFooter(
                  total: 'BHD 8.044',
                  buttonLabel: 'Place booking',
                  onPressed: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Place booking'),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(paragraph.text.toPlainText(), 'Place booking');
  });
}
