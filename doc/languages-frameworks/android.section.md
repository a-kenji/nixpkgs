# Android {#android}

The Android build environment provides three major features and a number of
supporting features.

## Using androidenv with Android Studio {#using-androidenv-with-android-studio}

Use the `android-studio-full` attribute for a very complete Android SDK, including system images:

```nix
{ buildInputs = [ android-studio-full ]; }
```

This is identical to:

```nix
{ buildInputs = [ androidStudioPackages.stable.full ]; }
```

Alternatively, you can pass composeAndroidPackages to the `withSdk` passthru:

```nix
{
  buildInputs = [
    (android-studio.withSdk (androidenv.composeAndroidPackages { includeNDK = true; }).androidsdk)
  ];
}
```

These will export `ANDROID_SDK_ROOT` and `ANDROID_NDK_ROOT` to the SDK and NDK directories
in the specified Android build environment.

## Deploying an Android SDK installation with plugins {#deploying-an-android-sdk-installation-with-plugins}

Alternatively, you can deploy the SDK separately with a desired set of plugins, or subsets of an SDK.

```nix
with import <nixpkgs> { };

let
  androidComposition = androidenv.composeAndroidPackages {
    platformVersions = [
      "34"
      "35"
      "latest"
    ];
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [
      "armeabi-v7a"
      "arm64-v8a"
    ];
    includeNDK = true;
    includeExtras = [ "extras;google;auto" ];
  };
in
androidComposition.androidsdk
```

The above function invocation states that we want an Android SDK with the above
specified plugin versions. By default, most plugins are disabled. Notable
exceptions are the tools, platform-tools and build-tools sub packages.

The following parameters are supported:

* `cmdLineToolsVersion` specifies the version of the `cmdline-tools` package to use.
  It defaults to the latest.
* `toolsVersion`, specifies the version of the `tools` package. Notice `tools` is
  obsolete, and currently only `26.1.1` is available, so there's not a lot of
  options here, however, you can set it as `null` if you don't want it. It defaults
  to the latest.
* `platformToolsVersion` specifies the version of the `platform-tools` plugin.
  It defaults to the latest.
* `buildToolsVersions` specifies the versions of the `build-tools` plugins to
  use. It defaults to the latest.
* `includeEmulator` specifies whether to deploy the emulator package (`false`
  by default). When enabled, the version of the emulator to deploy can be
  specified by setting the `emulatorVersion` parameter. If set to
  `"if-supported"`, it will deploy the emulator if it's supported by the system.
* `includeCmake` specifies whether CMake should be included. It defaults to true
  on x86-64 and Darwin platforms, and also supports `"if-supported"`.
* `cmakeVersions` specifies which CMake versions should be deployed.
  It defaults to the latest.
* `includeNDK` specifies that the Android NDK bundle should be included.
  Defaults to `false` though can be set to `true` or `"if-supported"`.
* `ndkVersions` specifies the NDK versions that we want to use. These are linked
  under the `ndk` directory of the SDK root, and the first is linked under the
  `ndk-bundle` directory. It defaults to the latest.
* `ndkVersion` is equivalent to specifying one entry in `ndkVersions`, and
  `ndkVersions` overrides this parameter if provided.
* `includeExtras` is an array of identifier strings referring to arbitrary
  add-on packages that should be installed. Note that extras may not be compatible
  with all platforms (for example, the Google TV head unit, which does not
  have an aarch64-linux compile).
* `platformVersions` specifies which platform SDK versions should be included.
  It defaults to including only the latest API level, though you can add more.
* `numLatestPlatformVersions` specifies how many of the latest API levels to include,
  if you are using the default for `platformVersions`. It defaults to 1, though you can
  increase this to, for example, 5 to get the last 5 years of Android API packages.
* `minPlatformVersion` and `maxPlatformVersion` take priority over `platformVersions`
  if both are provided. Note that `maxPlatformVersion` always defaults to the latest
  Android SDK platform version, allowing you to specify `minPlatformVersion` to describe
  the minimum SDK version your Android composition supports.

For each platform version that has been specified, we can apply the following
options:

* `includeSystemImages` specifies whether a system image for each platform SDK
  should be included.
* `includeSources` specifies whether the sources for each SDK version should be
  included.
* `useGoogleAPIs` specifies that for each selected platform version the
  Google API should be included.
* `useGoogleTVAddOns` specifies that for each selected platform version the
  Google TV add-on should be included.

For each requested system image we can specify the following options:

* `systemImageTypes` specifies what kind of system images should be included.
  Defaults to: `default`.
* `abiVersions` specifies what kind of ABI version of each system image should
  be included. Defaults to `armeabi-v7a` and `arm64-v8a`.

Most of the function arguments have reasonable default settings, preferring the latest
versions of tools when possible. You can additionally specify "latest" for any plugin version
that you do not care about, and just want the latest of.

You can specify license names:

* `extraLicenses` is a list of license names.
  You can get these names from repo.json or `querypackages.sh licenses`. The SDK
  license (`android-sdk-license`) is accepted for you if you set accept_license
  to true. If you are doing something like working with preview SDKs, you will
  want to add `android-sdk-preview-license` or whichever license applies here.

Additionally, you can override the repositories that composeAndroidPackages will
pull from:

* `repoJson` specifies a path to a generated repo.json file. You can generate this
  by running `generate.sh`, which in turn will call into `mkrepo.rb`.
* `repoXmls` is an attribute set containing paths to repo XML files. If specified,
  it takes priority over `repoJson`, and will trigger a local build writing out a
  repo.json to the Nix store based on the given repository XMLs. Note that this uses
  import-from-derivation.

```nix
{
  repoXmls = {
    packages = [ ./xml/repository2-1.xml ];
    images = [
      ./xml/android-sys-img2-1.xml
      ./xml/android-tv-sys-img2-1.xml
      ./xml/android-wear-sys-img2-1.xml
      ./xml/android-wear-cn-sys-img2-1.xml
      ./xml/google_apis-sys-img2-1.xml
      ./xml/google_apis_playstore-sys-img2-1.xml
    ];
    addons = [ ./xml/addon2-1.xml ];
  };
}
```

When building the above expression with:

```bash
$ nix-build
```

The Android SDK gets deployed with all desired plugin versions.

We can also deploy subsets of the Android SDK. For example, to only the
`platform-tools` package, you can evaluate the following expression:

```nix
with import <nixpkgs> { };

let
  androidComposition = androidenv.composeAndroidPackages {
    # ...
  };
in
androidComposition.platform-tools
```

## Using predefined Android package compositions {#using-predefined-android-package-compositions}

In addition to composing an Android package set manually, it is also possible
to use a predefined composition that contains a fairly complete set of Android packages:

The following Nix expression can be used to deploy the entire SDK:

```nix
with import <nixpkgs> { };

androidenv.androidPkgs.androidsdk
```

It is also possible to use one plugin only:

```nix
with import <nixpkgs> { };

androidenv.androidPkgs.platform-tools
```

## Spawning emulator instances {#spawning-emulator-instances}

For testing purposes, it can also be quite convenient to automatically generate
scripts that spawn emulator instances with all desired configuration settings.

An emulator spawn script can be configured by invoking the `emulateApp {}`
function:

```nix
with import <nixpkgs> { };

androidenv.emulateApp {
  name = "emulate-MyAndroidApp";
  platformVersion = "28";
  abiVersion = "x86"; # armeabi-v7a, mips, x86_64
  systemImageType = "google_apis_playstore";
}
```

Additional flags may be applied to the Android SDK's emulator through the runtime environment variable `$NIX_ANDROID_EMULATOR_FLAGS`.

It is also possible to specify an APK to deploy inside the emulator
and the package and activity names to launch it:

```nix
with import <nixpkgs> { };

androidenv.emulateApp {
  name = "emulate-MyAndroidApp";
  platformVersion = "24";
  abiVersion = "armeabi-v7a"; # mips, x86, x86_64
  systemImageType = "default";
  app = ./MyApp.apk;
  package = "MyApp";
  activity = "MainActivity";
}
```

In addition to prebuilt APKs, you can also bind the APK parameter to a
`buildApp {}` function invocation shown in the previous example.

## Notes on environment variables in Android projects {#notes-on-environment-variables-in-android-projects}

* `ANDROID_HOME` should point to the Android SDK. In your Nix expressions, this should be
  `${androidComposition.androidsdk}/libexec/android-sdk`. Note that `ANDROID_SDK_ROOT` is deprecated,
  but if you rely on tools that need it, you can export it too.
* `ANDROID_NDK_ROOT` should point to the Android NDK, if you're doing NDK development.
  In your Nix expressions, this should be `${ANDROID_HOME}/ndk-bundle`.

If you are running the Android Gradle plugin, you need to export GRADLE_OPTS to override aapt2
to point to the aapt2 binary in the Nix store as well, or use a FHS environment so the packaged
aapt2 can run. If you don't want to use a FHS environment, something like this should work:

```nix
let
  buildToolsVersion = "30.0.3";

  # Use buildToolsVersion when you define androidComposition
  androidComposition = <...>;
in
pkgs.mkShell rec {
  ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
  ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";

  # Use the same buildToolsVersion here
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
}
```

If you are using cmake, you need to add it to PATH in a shell hook or FHS env profile.
The path is suffixed with a build number, but properly prefixed with the version.
So, something like this should suffice:

```nix
let
  cmakeVersion = "3.10.2";

  # Use cmakeVersion when you define androidComposition
  androidComposition = <...>;
in
pkgs.mkShell rec {
  ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
  ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";

  # Use the same cmakeVersion here
  shellHook = ''
    export PATH="$(echo "$ANDROID_HOME/cmake/${cmakeVersion}".*/bin):$PATH"
  '';
}
```

Note that running Android Studio with ANDROID_HOME set will automatically write a
`local.properties` file with `sdk.dir` set to $ANDROID_HOME if one does not already
exist. If you are using the NDK as well, you may have to add `ndk.dir` to this file.

An example shell.nix that does all this for you is provided in examples/shell.nix.
This shell.nix includes a shell hook that overwrites local.properties with the correct
sdk.dir and ndk.dir values. This will ensure that the SDK and NDK directories will
both be correct when you run Android Studio inside nix-shell.

## Notes on improving build.gradle compatibility {#notes-on-improving-build.gradle-compatibility}

Ensure that your buildToolsVersion and ndkVersion match what is declared in androidenv.
If you are using cmake, make sure its declared version is correct too.

Otherwise, you may get cryptic errors from aapt2 and the Android Gradle plugin warning
that it cannot install the build tools because the SDK directory is not writeable.

```gradle
android {
    buildToolsVersion "30.0.3"
    ndkVersion = "22.0.7026061"
    externalNativeBuild {
        cmake {
            version "3.10.2"
        }
    }
}

```

## Querying the available versions of each plugin {#querying-the-available-versions-of-each-plugin}

All androidenv packages are available on [search.nixos.org](https://search.nixos.org).
Note that `aarch64-linux` compatibility is currently spotty, though `x86_64-linux` and `aarch64-darwin`
are well supported. This is because Google's repository definitions mark some packages for "all" architectures
that are really only for `x86_64` or `aarch64`.

## Updating the generated expressions {#updating-the-generated-expressions}

repo.json is generated from XML files that the Android Studio package manager uses.
To update the expressions run the `update.sh` script that is stored in the
`pkgs/development/mobile/androidenv/` subdirectory:

```bash
./update.sh
```

This is run automatically by the nixpkgs update script.

## Building an Android application with Ant {#building-an-android-application-with-ant}

In addition to the SDK, it is also possible to build an Ant-based Android
project and automatically deploy all the Android plugins that a project
requires. Most newer Android projects use Gradle, and this is included for historical
purposes.

```nix
with import <nixpkgs> { };

androidenv.buildApp {
  name = "MyAndroidApp";
  src = ./myappsources;
  release = true;

  # If release is set to true, you need to specify the following parameters
  keyStore = ./keystore;
  keyAlias = "myfirstapp";
  keyStorePassword = "mykeystore";
  keyAliasPassword = "myfirstapp";

  # Any Android SDK parameters that install all the relevant plugins that a
  # build requires
  platformVersions = [ "24" ];

  # When we include the NDK, then ndk-build is invoked before Ant gets invoked
  includeNDK = true;
}
```

Aside from the app-specific build parameters (`name`, `src`, `release` and
keystore parameters), the `buildApp {}` function supports all the function
parameters that the SDK composition function (the function shown in the
previous section) supports.

This build function is particularly useful when it is desired to use
[Hydra](https://nixos.org/hydra): the Nix-based continuous integration solution
to build Android apps. An Android APK gets exposed as a build product and can be
installed on any Android device with a web browser by navigating to the build
result page.
