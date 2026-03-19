import 'package:flutter_test/flutter_test.dart';
import 'package:my_portfolio/core/constants/app_spacing.dart';
import 'package:my_portfolio/core/constants/app_strings.dart';

void main() {
  group('AppStrings Tests', () {
    group('Hero Content', () {
      test('name is non-empty', () => expect(AppStrings.name.isNotEmpty, isTrue));
      test('title is non-empty', () => expect(AppStrings.title.isNotEmpty, isTrue));
      test('tagline is non-empty', () => expect(AppStrings.tagline.isNotEmpty, isTrue));
    });

    group('Section Titles', () {
      test('sectionAbout is non-empty', () => expect(AppStrings.sectionAbout.isNotEmpty, isTrue));
      test('sectionProjects is non-empty', () => expect(AppStrings.sectionProjects.isNotEmpty, isTrue));
      test('sectionSkills is non-empty', () => expect(AppStrings.sectionSkills.isNotEmpty, isTrue));
      test('sectionContact is non-empty', () => expect(AppStrings.sectionContact.isNotEmpty, isTrue));
    });

    group('About Page', () {
      test('aboutHeading is non-empty', () => expect(AppStrings.aboutHeading.isNotEmpty, isTrue));
      test('aboutBio is non-empty', () => expect(AppStrings.aboutBio.isNotEmpty, isTrue));
      test('whatIValue is non-empty', () => expect(AppStrings.whatIValue.isNotEmpty, isTrue));

      test('aboutValues has exactly 5 entries', () {
        expect(AppStrings.aboutValues.length, equals(5));
      });

      test('all aboutValues entries are non-empty', () {
        for (final value in AppStrings.aboutValues) {
          expect(value.isNotEmpty, isTrue, reason: 'Found empty value string');
        }
      });

      test('aboutValues has no duplicates', () {
        final unique = AppStrings.aboutValues.toSet();
        expect(unique.length, equals(AppStrings.aboutValues.length));
      });
    });

    group('Projects Page', () {
      test('techStack label is non-empty', () => expect(AppStrings.techStack.isNotEmpty, isTrue));
      test('viewOnGitHub label is non-empty', () => expect(AppStrings.viewOnGitHub.isNotEmpty, isTrue));
      test('liveDemo label is non-empty', () => expect(AppStrings.liveDemo.isNotEmpty, isTrue));
    });

    group('Contact Strings', () {
      test('contactEmail is non-empty', () => expect(AppStrings.contactEmail.isNotEmpty, isTrue));
      test('contactGitHub is non-empty', () => expect(AppStrings.contactGitHub.isNotEmpty, isTrue));
      test('contactLinkedIn is non-empty', () => expect(AppStrings.contactLinkedIn.isNotEmpty, isTrue));
      test('contactErrorMessage is non-empty', () => expect(AppStrings.contactErrorMessage.isNotEmpty, isTrue));

      test('contactEmailUri starts with mailto:', () {
        expect(AppStrings.contactEmailUri.startsWith('mailto:'), isTrue);
      });

      test('contactGitHubUri starts with https://', () {
        expect(AppStrings.contactGitHubUri.startsWith('https://'), isTrue);
      });

      test('contactLinkedInUri starts with https://', () {
        expect(AppStrings.contactLinkedInUri.startsWith('https://'), isTrue);
      });

      test('contactEmailUri contains contactEmail address', () {
        expect(
          AppStrings.contactEmailUri.contains(AppStrings.contactEmail),
          isTrue,
        );
      });

      test('contactGitHubUri contains contactGitHub handle', () {
        expect(
          AppStrings.contactGitHubUri.contains(AppStrings.contactGitHub),
          isTrue,
        );
      });

      test('contactLinkedInUri contains contactLinkedIn handle', () {
        expect(
          AppStrings.contactLinkedInUri.contains(AppStrings.contactLinkedIn),
          isTrue,
        );
      });
    });
  });

  group('AppSpacing Tests', () {
    group('Base Spacing Scale', () {
      test('xs is positive', () => expect(AppSpacing.xs, greaterThan(0)));
      test('sm is positive', () => expect(AppSpacing.sm, greaterThan(0)));
      test('md is positive', () => expect(AppSpacing.md, greaterThan(0)));
      test('lg is positive', () => expect(AppSpacing.lg, greaterThan(0)));
      test('xl is positive', () => expect(AppSpacing.xl, greaterThan(0)));
      test('xxl is positive', () => expect(AppSpacing.xxl, greaterThan(0)));
    });

    group('Monotonic Scale', () {
      test('xs < sm', () => expect(AppSpacing.xs, lessThan(AppSpacing.sm)));
      test('sm < md', () => expect(AppSpacing.sm, lessThan(AppSpacing.md)));
      test('md < lg', () => expect(AppSpacing.md, lessThan(AppSpacing.lg)));
      test('lg < xl', () => expect(AppSpacing.lg, lessThan(AppSpacing.xl)));
      test('xl < xxl', () => expect(AppSpacing.xl, lessThan(AppSpacing.xxl)));
    });

    group('Page Padding Aliases', () {
      test('pagePaddingMobile equals lg', () {
        expect(AppSpacing.pagePaddingMobile, equals(AppSpacing.lg));
      });

      test('pagePaddingDesktop equals xxl', () {
        expect(AppSpacing.pagePaddingDesktop, equals(AppSpacing.xxl));
      });

      test('pagePaddingDesktop > pagePaddingMobile', () {
        expect(AppSpacing.pagePaddingDesktop, greaterThan(AppSpacing.pagePaddingMobile));
      });
    });
  });
}
