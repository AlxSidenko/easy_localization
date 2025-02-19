import 'dart:ui';

import 'package:easy_localization/src/asset_loader.dart';

class ImmutableJsonAssetLoader extends AssetLoader {
  const ImmutableJsonAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) {
    return Future.value(const {
      'test': 'test',
    });
  }
}

class JsonAssetLoader extends AssetLoader {
  const JsonAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) {
    return Future.value({
      'test': 'test',
      'test_empty': '',
      'test_replace_one': 'test replace {}',
      'test_replace_two': 'test replace {} {}',
      'test_replace_named': 'test named replace {arg1} {arg2}',
      'gender': {'male': 'Hi man ;)', 'female': 'Hello girl :)'},
      'gender_and_replace': {
        'male': 'Hi {} man ;)',
        'female': 'Hello {} girl :)'
      },
      'day': {
        'zero': '{} days',
        'one': '{} day',
        'two': '{} days',
        'few': '{} few days',
        'many': '{} many days',
        'other': '{} other days'
      },
      'hat': {
        'zero': 'no hats',
        'one': 'one hat',
        'two': 'two hats',
        'few': 'few hats',
        'many': 'many hats',
        'other': 'other hats'
      },
      'hat_other': {'other': 'other hats'},
      'money': {
        'zero': '{} has no money',
        'one': '{} has {} dollar',
        'other': '{} has {} dollars',
      },
      'money_named_args': {
        'zero': '{name} has no money',
        'one': '{name} has {money} dollar',
        'other': '{name} has {money} dollars',
      },
      'nested_periods': {
        'Processing': 'Processing',
        'Processing.': 'Processing.',
      },
      'nested.but.not.nested': 'nested but not nested',
      'linked': 'this @:isLinked',
      'isLinked': 'is linked',
      'linkAndModify': 'this is linked and @.upper:modified',
      'modified': 'modified',
      'linkMany': '@:many @.capitalize:locale @:messages',
      'many': 'many',
      'locale': 'locale',
      'messages': 'messages',
      'linkedWithBrackets': 'linked with @.lower:(brackets).',
      'brackets': 'Brackets',
      'nestedArguments': 'this is {} @.undefiend:nestedArg',
      'nestedArg': 'nested {}{}',
      'nestedNamedArguments': '{firstArg} is a @:nestedNamedArg',
      'nestedNamedArg': 'nested {secondArg}{thirdArg}',
      'nested': {
        'super': {
          'duper': {
            'nested': 'nested.super.duper.nested',
            'nested_with_arg': 'nested.super.duper.nested_with_arg {}',
            'nested_with_named_arg':
                'nested.super.duper.nested_with_named_arg {arg}'
          }
        }
      },
      'path': fullPath,
      'test_missing_fallback':
          (locale.languageCode == 'fb' ? 'fallback!' : null),
      'test_empty_fallback': (locale.languageCode == 'fb' ? 'fallback!' : ''),
      'test_fallback_plurals': (locale.languageCode == 'fb'
          ? {
              'zero': 'fallback zero',
              'one': 'fallback one',
              'two': 'fallback two',
              'few': 'fallback few',
              'many': 'fallback many',
              'other': 'fallback other',
            }
          : {
              'one': '{} second',
              'other': '{} seconds',
            }),
      'test_empty_fallback_plurals': (locale.languageCode == 'fb'
          ? {
              'zero': 'fallback zero',
              'one': 'fallback one',
              'two': 'fallback two',
              'few': 'fallback few',
              'many': 'fallback many',
              'other': 'fallback other',
            }
          : {
              'zero': '',
              'one': '',
              'two': '',
              'few': '',
              'many': '',
              'other': '',
            }),
      'test_empty_plurals': (locale.languageCode == 'fb'
          ? {
              'zero': '',
              'one': '',
              'two': '',
              'few': '',
              'many': '',
              'other': '',
            }
          : {
              'zero': '',
              'one': '',
              'two': '',
              'few': '',
              'many': '',
              'other': '',
            })
    });
  }
}

class ExternalAssetLoader extends AssetLoader {
  const ExternalAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) =>
      Future.value(const {
        'package_value_01': 'package_value_01',
        'package_value_02': 'package_value_02',
        'package_value_03': 'package_value_03',
      });
}

class NestedAssetLoader extends AssetLoader {
  const NestedAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) =>
      Future.value({
        'nested': {
          'super': {
            'duper': {'nested': 'nested.super.duper.nested'}
          }
        },
      });
}
