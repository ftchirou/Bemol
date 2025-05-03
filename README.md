# 🎵 Bemol
![GitHub Workflow Status](https://github.com/ftchirou/Bemol/actions/workflows/run-tests.yml/badge.svg) <img src="https://img.shields.io/badge/coverage-84%25-green"> ![GitHub Workflow Status](https://github.com/ftchirou/Bemol/actions/workflows/upload-to-testflight.yml/badge.svg) ![GitHub release (latest SemVer)](https://img.shields.io/github/v/tag/ftchirou/Bemol)  <img src="https://img.shields.io/badge/beta-yellow"> <img src="https://img.shields.io/badge/iOS%2018.2%2B-red"> <img src="https://img.shields.io/badge/Swift%20%3E%3D%206-orange">

**Bemol** is a **free** and **open-source** ear training app that helps music hobbyists and music students train and develop [relative pitch](https://en.wikipedia.org/wiki/Relative_pitch), the ability to recognize a played musical note in a given [tonal context](https://en.wikipedia.org/wiki/Tonic_(music)).

<br />

![bemol-home](https://github.com/user-attachments/assets/cd712231-7350-454f-87e9-f63eb84471f0)

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

The goal of **Bemol** is to get you (if you're so inclined) to learn the character of each musical note by internalizing how the note relates to its nearest [tonic](https://en.wikipedia.org/wiki/Tonic_(music)). This is achieved through practice sessions in which you'll be prompted to identify a series of notes. For each note, Bemol will first play a [I - IV - V - I cadence](https://en.wikipedia.org/wiki/Cadence) to establish a [key](https://en.wikipedia.org/wiki/Key_(music)) in your ear and mind. Then the note is played and you identify it by playing it back on the keyboard. Once the note is successfully identified, a short sequence of notes from the note to its nearest tonic is played. 

At that point, your job is simply to listen and pay attention to how each note in the sequence moves towards the tonic (you can even sing along). This is what will cement the relationship between each note and the tonic in your ear. By repeating this process over and over again, you will begin to understand and internalize each note's unique qualities and will surprise yourself when you're suddenly able to clearly differentiate an F from an E in the key of C major, for example.

This ear training method was first described and implemented by [Alain Benbassat](https://www.miles.be) in his free [Functional Ear Trainer desktop app](https://www.miles.be/software/functional-ear-trainer-v2/). **Bemol** is simply a free and open-source implementation of the method for iOS.

# How it works

**Bemol** is organized in a series of progressive levels. First, you start in the key of **C major** and are limited to only the **first 4 notes** of the scale. Once you're able to consistently identify each of these 4 notes, you can move to the next level where you'll train with the **next 4 notes**. 

Once the entire scale is mastered, the next level will introduce **chromatic notes**. After you master these, you can move to the next level which will introduce a new key. This repeats until you go through all the 12 major and 12 minor keys. It's not really required to practice in all 12 keys but it's fun :). You can also just use the `Random Key` button to practice in a random key after you have mastered the keys of C major and C minor.

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
2. Clone the repository.
3. Double-click `Bemol.xcodeproj` to open it in Xcode.
4. **Bemol** has no third-party dependencies and requires no special tooling. So you can simply press `Run` in Xcode to launch the app in a simulator.
5. If running on a device, you have to provide the id of your development team in a file named `Signing.xcconfig` that you put under `Configurations/`. The contents of the file should look like this:
   
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

These are self-explanatory and their values can be found in App Store Connect. The script also expects a private key file to be available at `./private_keys/AuthKey_<APP_STORE_CONNECT_API_KEY>.p8`.

# License

The code and data files in this repository are licensed under the terms of the version 3 of the GNU General Public License as published by the Free Software Foundation. See the [LICENSE](./LICENSE) file for a copy of the license.
