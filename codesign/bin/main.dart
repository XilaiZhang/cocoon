// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:codesign/codesign.dart';
import 'package:platform/platform.dart';

const String filepathFlag = 'filepath';
const String helpFlag = 'help';

const String kCommit = 'commit';
const String kProduction = 'production';
const String kCodesignCertName = 'codesign-cert-name';
const String kCodesignPrimaryBundleId = 'codesign-primary-bundle-id';
const String kCodesignUserName = 'codesign-username';
const String kAppSpecificPassword = 'app-specific-password';
const String kCodesignAppStoreId = 'codesign-appstore-id';
const String kCodesignTeamId = 'codesign-team-id';
const String kCodesignFilepath = 'filepath';

/// Perform Mac code signing based on file paths.
///
/// If `--production` is set to true, code signed artifacts will be uploaded
/// back to google cloud storage.
/// Otherwise, nothing will be uploaded back for production. default value is
/// false.
///
/// For `--commit`, asks for the engine commit to be code signed.
///
/// For `--filepath`, provides the artifacts zip paths to be code signed.
///
/// Usage:
/// dart run bin/main.dart --commit=a5967ed309ef2beb9625f128571f7060597b5eda
/// --filepath=darwin-x64/FlutterMacOS.framework.zip --filepath=ios/artifacts.zip
/// --filepath=dart-sdk-darwin-arm64.zip
/// ( add `--production` if this is intended for production)
Future<void> main(List<String> args) async {
  final ArgParser parser = ArgParser();
  parser
    ..addFlag(helpFlag, help: 'Prints usage info.', callback: (bool value) {
      if (value) {
        stdout.write('${parser.usage}\n');
        exit(1);
      }
    })
    ..addOption(
      kCodesignCertName,
      help: 'The name of the codesign certificate to be used when codesigning.',
    )
    ..addOption(kCodesignPrimaryBundleId,
        help: 'Identifier for the application you are codesigning. This is only used '
            'for disambiguating codesign jobs in the notary service logging.',
        defaultsTo: 'dev.flutter.sdk')
    ..addOption(
      kCodesignUserName,
      help: 'Apple developer account email used for authentication with notary service.',
    )
    ..addOption(
      kAppSpecificPassword,
      help: 'Unique password specifically for codesigning the given application.',
    )
    ..addOption(
      kCodesignAppStoreId,
      help: 'Apple-id for connecting to app store. Used by notary service for xcode version 13+.',
    )
    ..addOption(
      kCodesignTeamId,
      help: 'Team-id is used by notary service for xcode version 13+.',
    )
    ..addMultiOption(
      kCodesignFilepath,
      help:
          'the zip file paths to be codesigned. e.g. --filepath=darwin-x64/font-subset.zip'
          ' --filepath=darwin-x64-release/gen_snapshot.zip --filepath=dart-sdk-darwin-arm64.zip',
    )
    ..addOption(
      kCommit,
      help: 'the commit hash of flutter/engine github pr used for google cloud storage bucket indexing',
    )
    ..addFlag(
      kProduction,
      help: 'whether we are going to upload the artifacts back to GCS for production',
    );

  final ArgResults argResults = parser.parse(args);

  final Platform platform = LocalPlatform();

  final String commit = getValueFromEnvOrArgs(kCommit, argResults, platform.environment)!;
  final String codesignCertName = getValueFromEnvOrArgs(kCodesignCertName, argResults, platform.environment)!;
  final String codesignPrimaryBundleId =
      getValueFromEnvOrArgs(kCodesignPrimaryBundleId, argResults, platform.environment)!;
  final String codesignUserName = getValueFromEnvOrArgs(kCodesignUserName, argResults, platform.environment)!;
  final String appSpecificPassword = getValueFromEnvOrArgs(kAppSpecificPassword, argResults, platform.environment)!;
  final String codesignAppstoreId = getValueFromEnvOrArgs(kCodesignAppStoreId, argResults, platform.environment)!;
  final String codesignTeamId = getValueFromEnvOrArgs(kCodesignTeamId, argResults, platform.environment)!;
  
  final List<String> codesignFilepaths = argResults[kCodesignFilepath]!;
  final bool production = argResults[kProduction] as bool;

  if (!platform.isMacOS) {
    throw ConductorException(
      'Error! Expected operating system "macos", actual operating system is: '
      '"${platform.operatingSystem}"',
    );
  }

  return CodesignContext(
    codesignCertName: codesignCertName,
    codesignPrimaryBundleId: codesignPrimaryBundleId,
    codesignUserName: codesignUserName,
    commitHash: commit,
    appSpecificPassword: appSpecificPassword,
    codesignAppstoreId: codesignAppstoreId,
    codesignTeamId: codesignTeamId,
    codesignFilepaths: codesignFilepaths,
    production: production,
  ).run();
}