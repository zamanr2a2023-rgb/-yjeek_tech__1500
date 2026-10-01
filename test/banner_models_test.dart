import 'package:flutter_test/flutter_test.dart';
import 'package:yjeek_app/features/ui_content/model/banner_models.dart';

UiBanner _parentScroll() => UiBanner.fromJson({
      'id': 'banner1',
      'title': 'Parent title',
      'subtitle': 'Parent sub',
      'imageUrl': 'https://example.com/parent.jpg',
      'bannerType': 'SCROLL',
      'placementKey': 'home_top',
      'tapAction': 'NONE',
      'sortOrder': 0,
    });

void main() {
  test('parseBannerSlides preserves order by sortOrder', () {
    final slides = UiBanner.parseBannerSlides([
      {'id': 's2', 'sortOrder': 2, 'imageUrl': 'b.jpg'},
      {'id': 's1', 'sortOrder': 1, 'imageUrl': 'a.jpg'},
    ]);
    expect(slides.length, 2);
    expect(slides.first.id, 's1');
    expect(slides.last.id, 's2');
  });

  test('SCROLL banner with slides expands to carousel pages', () {
    final banner = UiBanner.fromJson({
      'id': 'b1',
      'title': 'Carousel',
      'bannerType': 'SCROLL',
      'placementKey': 'home_mid',
      'slides': [
        {
          'id': 'slide-a',
          'imageUrl': 'https://example.com/a.jpg',
          'tapAction': 'OPEN_STORE',
          'targetId': 'vendor-1',
          'sortOrder': 0,
        },
        {
          'id': 'slide-b',
          'imageUrl': 'https://example.com/b.jpg',
          'tapAction': 'OPEN_CATEGORY',
          'targetId': 'food',
          'sortOrder': 1,
        },
      ],
    });
    final pages = UiBanner.expandCarouselPages([banner]);
    expect(pages.length, 2);
    expect(pages[0].imageUrl, 'https://example.com/a.jpg');
    expect(pages[0].tapAction, 'OPEN_STORE');
    expect(pages[0].targetId, 'vendor-1');
    expect(pages[1].tapAction, 'OPEN_CATEGORY');
    expect(pages[1].targetId, 'food');
  });

  test('empty slides keeps single parent page', () {
    final banner = UiBanner.fromJson({
      'id': 'b2',
      'title': 'Empty scroll',
      'bannerType': 'SCROLL',
      'placementKey': 'home_top',
      'slides': [],
    });
    final pages = UiBanner.expandCarouselPages([banner]);
    expect(pages.length, 1);
    expect(pages.first.id, 'b2');
  });

  test('multiple banner rows are not duplicated with slides', () {
    final scroll = UiBanner.fromJson({
      'id': 'scroll1',
      'title': 'S',
      'bannerType': 'SCROLL',
      'placementKey': 'home_top',
      'slides': [
        {'id': 'x', 'sortOrder': 0, 'imageUrl': 'x.jpg'},
      ],
    });
    final static = UiBanner.fromJson({
      'id': 'static1',
      'title': 'Static',
      'bannerType': 'STATIC',
      'placementKey': 'home_top',
    });
    final pages = UiBanner.expandCarouselPages([static, scroll]);
    expect(pages.length, 2);
    expect(pages[0].id, 'static1');
    expect(pages[1].imageUrl, 'x.jpg');
  });

  test('slide OPEN_URL uses ctaUrl as target', () {
    final slide = UiBannerSlide.fromJson({
      'id': 'u1',
      'tapAction': 'OPEN_URL',
      'ctaUrl': 'https://yjeek.example/promo',
      'sortOrder': 0,
    });
    final page = slide.toCarouselPage(_parentScroll());
    expect(page.tapAction, 'OPEN_URL');
    expect(page.targetId, 'https://yjeek.example/promo');
  });
}
