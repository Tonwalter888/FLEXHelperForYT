# FLEXHelperForYT
A simple tweak to activate a FLEX explorer window in YouTube and YouTube Music app.

## How to use this tweak?
- **YouTube** - Go to **You** tab -> Tap on the settings icon -> Tap on the **FLEXHelperForYT** section
- **YouTube Music** - Tap on your Google logo account (on the top right) -> Tap on the **Settings** section -> Tap on the **FLEXHelperForYT** section

## Building
1. Clone [Theos](https://github.com/theos/theos) along with its submodules and set your theos path in ``$THEOS`` value.
2. Clone and copy [iOS 18.6 SDK](https://github.com/Tonwalter888/iOS-18.6-SDK) to ``$THEOS/sdks``.
3. Clone [YouTubeHeader](https://github.com/PoomSmart/YouTubeHeader), [YouTubeMusicHeader](https://github.com/PoomSmart/YouTubeMusicHeader), and [PSHeader](https://github.com/PoomSmart/PSHeader) into ``$THEOS/include``.
4. Clone this repo, cd into it and run
- ``make clean package DEBUG=0 FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless`` For rootless jailbroken iOS (iOS 15+ - palera1n, Sileo, Zebra, Dolpamine, bakera1n, TrollStore) and Sideloaded enviroment (eg. SideStore, AltStore, LiveContainer, Sideloadly, PlumeImpactor, iloader etc.)
- ``make clean package DEBUG=0 FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=roothide`` For roothide jailbroken iOS (iOS 15 - Dolpamine, Bootstrap)