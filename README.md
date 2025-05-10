# 🎵 Bemol
![GitHub Workflow Status](https://github.com/ftchirou/Bemol/actions/workflows/run-tests.yml/badge.svg) <img src="https://img.shields.io/badge/coverage-75%25-yellow"> ![GitHub Workflow Status](https://github.com/ftchirou/Bemol/actions/workflows/upload-to-testflight.yml/badge.svg) ![GitHub release (latest SemVer)](https://img.shields.io/github/v/tag/ftchirou/Bemol)  <img src="https://img.shields.io/badge/beta-yellow"> <img src="https://img.shields.io/badge/iOS%2018.2%2B-red"> <img src="https://img.shields.io/badge/Swift%20%3E%3D%206-orange">

**Bemol** is a **free** and **open-source** ear training app that helps music hobbyists and music students train and develop [relative pitch](https://en.wikipedia.org/wiki/Relative_pitch), the ability to recognize a played musical note in a given [tonal context](https://en.wikipedia.org/wiki/Tonic_(music)).

<br />

![bemol-home](https://github.com/user-attachments/assets/6e89b255-3dab-4d7e-9b5a-9c9276450c68)

<br />

## Contents
- [Background](#background)
- [How it works](#how-it-works)
- [How to get it](#how-to-get-it)
- [For developers](#for-developers)
  - [How to build and run](#how-to-build-and-run)
  - [How to run the tests](#how-to-run-the-tests)
  - [How to ship](#how-to-ship)

# Background

**Bemol** helps people learn the character of each musical note by having them internalize how each note relates to its nearest [tonic](https://en.wikipedia.org/wiki/Tonic_(music)) in a given [key](https://en.wikipedia.org/wiki/Key_(music)). In each practice session, the user is prompted to identify a series of played notes. Before each note, Bemol plays a [I - IV - V - I cadence](https://en.wikipedia.org/wiki/Cadence) to establish the key. After the user has identified the note, a short melody is played to resolve the note to the nearest tonic. Listening to this final resolution helps cement the relationship between the note and the tonic in the ear and the mind.

As this process repeats, the user starts to internalize the character of each note in a given tonal context. This helps develop [relative pitch](https://en.wikipedia.org/wiki/Relative_pitch) and eventually they will have a much easier time recognizing any note as long as a tonal context is clearly established.

This ear training method was first described and implemented by [Alain Benbassat](https://www.miles.be) in his free [Functional Ear Trainer desktop app](https://www.miles.be/software/functional-ear-trainer-v2/). **Bemol** is simply a free and open-source implementation of the method for iOS.

# How it works

**Bemol** is organized in a series of progressive levels. The first level consists only of the **first 4 notes** in the key of **C major**. Once the user has at least 90% accuracy in this level, they can move to the next one, where they can practice the **next 4 notes**.

Once the entire scale is mastered, the next level will introduce **chromatic notes**. After this, a new key is introduced. This can go on until the user has practiced in all 12 major and 12 minor keys. Or they can choose just to practice in a random key after they have mastered the keys of C major and C minor.

# How to get it

**Bemol** is still in development but if you'd like to try it before it's released to the App Store, you can have access to the beta versions [here](https://testflight.apple.com/join/8vhsQVQQ).

1. First, install the [TestFlight app](https://testflight.apple.com) on your phone.
2. Then, follow the [link](https://testflight.apple.com/join/8vhsQVQQ) to join the beta testing group.
3. You will now be able to install new versions of the app as they become available.

<br/>

> [!IMPORTANT]
> The versions of the app in TestFlight are beta versions. Even though the basic mechanics are implemented and the app is usable, not everything is fully polished, and bugs and crashes will not be uncommon. You can help and contribute to the development of **Bemol** by reporting these bugs through TestFlight.

<br/>

Once released to the App Store, **Bemol** will be **free forever** (just like the original desktop app) and the code will remain available here.

# For developers

## How to build and run

1. Install [Xcode](https://developer.apple.com/xcode/). **Bemol** is built with [Swift 6](https://www.swift.org) and [Xcode 16.2](https://developer.apple.com/documentation/xcode-release-notes/xcode-16_2-release-notes).
2. Clone the repository and run `cd Bemol/`.
3. Run `touch ./Configurations/Signing.xcconfig` to create an empty signing config file.
4. Run `open Bemol.xcodeproj` to open it in Xcode.
5. Press `Run` in Xcode to launch the app in a simulator.
6. If running on a device, you have to provide the id of your development team in `./Configurations/Signing.xcconfig`. The contents of the file should look like this:
   
   ```
   // Signing.xcconfig

   CODE_SIGN_STYLE = Automatic
   DEVELOPMENT_TEAM = <your-development-team-id>
   ```

> [!TIP]
> To be able to hear piano sounds (and not sine waves), you'll need to download a [sound font](https://en.wikipedia.org/wiki/SoundFont) in the `sf2` format and save it under `Bemol/Resources/sound_font.sf2`. The TestFlight version of **Bemol** uses an excellent and open-source sound font from [MuseScore](https://musescore.org/en) that you can download [here](https://musescore.org/en/handbook/3/soundfonts-and-sfz-files#list) (look for `MuseScore_General`).


## How to run the tests

- **Product** -> **Test** in Xcode.
- Or run `./Scripts/test.sh` from the command line. The tests results bundle will then be available at `Artifacts/test-results.xcresult`.

## How to ship

Run `./Scripts/upload_to_testflight.sh <marketing_version> <build_version>` to archive and upload a new build to App Store Connect. `./Scripts/next_marketing_version.sh` and `./Scripts/next_build_version.sh` can be used to automatically generate the required arguments.

The script expects the following environment variables to be set:

- `APPLE_ID`
- `APP_STORE_CONNECT_API_KEY`
- `APP_STORE_CONNECT_API_ISSUER`

These are self-explanatory and their values can be found in App Store Connect. The script also expects a private key file to be available at `private_keys/AuthKey_<APP_STORE_CONNECT_API_KEY>.p8`.

# License

The code and data files in this repository are licensed under the terms of the version 3 of the GNU General Public License as published by the Free Software Foundation. See the [LICENSE](./LICENSE) file for a copy of the license.
