import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const YjeekApp());
    await tester.pump();

    expect(find.text('Lifestyle'), findsOneWidget);
    expect(find.text('Yjeek'), findsOneWidget);
  });
}
