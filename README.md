# YiuOS

A clean AOSP-based Android OS. Version 1.0 "Origin" — stock AOSP, rebranded.

## What this repo is

This is the `vendor/yiuos` overlay. It doesn't contain AOSP itself (that's ~150 GB);
it sits on top of an AOSP checkout and turns the build into YiuOS:

```
vendor/yiuos/
├── config/common.mk                  # Version, branding props, overlays
├── products/
│   ├── AndroidProducts.mk            # Registers lunch targets
│   ├── yiuos_sdk_phone64_x86_64.mk   # Emulator target (start here)
│   └── yiuos_gsi_arm64.mk            # GSI for real Treble devices
├── overlay/common/                   # Framework string rebranding
└── prebuilt/common/bootanimation/    # Drop bootanimation.zip here later
```

## Build requirements

- Linux (Ubuntu 22.04+ recommended) or macOS
- 16 GB RAM minimum (32+ GB recommended), 64 GB+ swap helps
- 400 GB free disk (source + build output)
- Packages: `git`, `repo`, `python3`, and AOSP build deps
  (https://source.android.com/docs/setup/start/requirements)

## Build steps

```bash
# 1. Get the repo tool
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH

# 2. Init and sync AOSP (pick a recent android-15 tag; this takes hours)
mkdir yiuos && cd yiuos
repo init -u https://android.googlesource.com/platform/manifest -b android-15.0.0_r1
repo sync -c -j8

# 3. Drop this overlay in
cp -r /path/to/this/repo/vendor/yiuos vendor/

# 4. Build (emulator target first)
source build/envsetup.sh
lunch yiuos_sdk_phone64_x86_64-userdebug
m -j$(nproc)

# 5. Boot it
emulator
```

For real hardware, build `yiuos_gsi_arm64-userdebug` and flash the resulting
`system.img` to any Treble-compatible device with an unlocked bootloader:

```bash
fastboot reboot fastboot
fastboot flash system out/target/product/generic_arm64/system.img
fastboot -w reboot
```

## Verifying the rebrand

After boot: **Settings → About phone**. Build number should read
`YiuOS 1.0 (Origin)`, and `adb shell getprop ro.yiuos.version` returns `1.0`.

## Roadmap ideas

- Custom bootanimation.zip (1080p, part0/part1 + desc.txt)
- Signature spoofing / custom keys (`vendor/yiuos-priv/keys`)
- Device trees for specific phones
- OTA update infrastructure
