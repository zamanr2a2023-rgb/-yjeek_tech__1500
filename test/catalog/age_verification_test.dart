import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/browse/model/age_verification_repository.dart';
import 'package:yjeek_app/features/catalog/model/catalog_cart_payload.dart';
import 'package:yjeek_app/features/catalog/model/catalog_product.dart';

void main() {
  test('product CTA follows ageRestriction.cta and canPurchase', () {
    final verify = CatalogAgeRestriction.fromJson(<String, dynamic>{
      'required': true,
      'canPurchase': false,
      'cta': 'VERIFY_AGE',
    });
    expect(verify.requiresAgeVerification, isTrue);

    final allowed = CatalogAgeRestriction.fromJson(<String, dynamic>{
      'required': true,
      'canPurchase': true,
      'cta': null,
    });
    expect(allowed.requiresAgeVerification, isFalse);
    expect(allowed.canPurchase, isTrue);
  });

  test('age screen is taken from data.screen only', () {
    expect(
      ageVerificationScreenFromApi('verified'),
      AgeVerificationScreen.verified,
    );
    expect(
      ageVerificationScreenFromApi('under_18'),
      AgeVerificationScreen.under18,
    );
    expect(
      ageVerificationScreenFromApi('id_already_used'),
      AgeVerificationScreen.idAlreadyUsed,
    );
    expect(
      ageVerificationScreenFromApi('rejected'),
      AgeVerificationScreen.rejected,
    );
    expect(
      ageVerificationScreenFromApi('you are under 18'),
      AgeVerificationScreen.unknown,
    );
  });

  test('purchase flag is canPurchaseAgeRestricted', () {
    final verified = AgeVerificationStatus.fromJson(<String, dynamic>{
      'status': 'VERIFIED',
      'canPurchaseAgeRestricted': true,
    });
    expect(verified.canPurchaseAgeRestricted, isTrue);

    final under18 = AgeVerificationStatus.fromJson(<String, dynamic>{
      'status': 'REJECTED',
      'canPurchaseAgeRestricted': false,
      'rejectCode': 'UNDER_18',
    });
    expect(under18.canPurchaseAgeRestricted, isFalse);

    final notVerified = AgeVerificationStatus.fromJson(<String, dynamic>{
      'status': 'NOT_VERIFIED',
      'canPurchaseAgeRestricted': false,
    });
    expect(notVerified.canPurchaseAgeRestricted, isFalse);
  });

  test('vape variant add still sends variantId and omits optionIds', () {
    final body = catalogCartItemBody(
      productId: 'caliburn',
      quantity: 1,
      variantId: 'var-12mg',
      optionIds: const ['must-not-send'],
      addonIds: const ['coil'],
    );
    expect(body['productId'], 'caliburn');
    expect(body['variantId'], 'var-12mg');
    expect(body['options'], {
      'addonIds': ['coil'],
    });
    expect((body['options'] as Map).containsKey('optionIds'), isFalse);
  });
}
