# YiuOS

<img src="branding/yiuos-logo-192.png" alt="YiuOS logo" width="96" align="right"/>

YiuOS is a custom Android distribution based on **LineageOS 23.2** (Android 16).
This repository is the YiuOS vendor tree — a fully rebranded fork of
[`LineageOS/android_vendor_lineage`](https://github.com/LineageOS/android_vendor_lineage)
(branch `lineage-23.2`). It sits at `vendor/yiuos` in a LineageOS source
checkout and turns the build into YiuOS.

## What's rebranded

- **Name**: every user-visible `LineageOS` / `Lineage` string is now `YiuOS`
  (build display, Settings, recovery, setup wizard overlays, translations).
- **Logo**: new YiuOS mark — orange rounded square with the white `Yiu`
  wordmark (see `branding/`). Used in the boot animation.
- **Boot animation**: regenerated from scratch with the YiuOS logo
  (`bootanimation/bootanimation.tar`, 1620x540 @ 60fps, fade-in / pulse loop /
  fade-out).
- **Default wallpapers**: new dark-orange gradient wallpapers at every density
  (`overlay/common/.../default_wallpaper.png`).
- **Charger UI**: offline-charging battery graphics recolored from Lineage
  teal to YiuOS orange (`charger/`).
- **Build system identity**: products are `yiuos_*` (e.g. `yiuos_gsi_arm64`),
  version vars are `YIUOS_*`, and props are `ro.yiuos.*`
  (`ro.yiuos.version`, `ro.yiuos.build.version`, `ro.yiuos.releasetype`).

Deliberately **not** renamed (these identifiers belong to other LineageOS
repos that are synced at build time; renaming them here would break the build):
`org.lineageos.*` package/feature IDs, the `lineage-sdk` overlay paths, app
module names such as `LineageParts` / `LineageSettingsProvider`, and the
`github.com/LineageOS` device-tree URLs used by roomservice. Fully renaming
those means forking `lineage-sdk`, `build/make`, and the Lineage apps — see
roadmap.

## Repo layout

```
branding/          YiuOS logo (SVG + PNG) and wordmark
bootanimation/     YiuOS boot animation source frames (tar) + generator
charger/           Offline-charging UI assets (YiuOS orange)
config/            Common product configs (common.mk, version.mk, BoardConfigYiuOS.mk, ...)
build/             envsetup extensions (breakfast/brunch), roomservice, yiuos_* targets
overlay/           Resource overlays: branding strings, wallpapers, lineage-sdk config
prebuilt/          Ringtones/alarms/notifications, init rc files, etc.
manifests/         Local manifest to drop into .repo/local_manifests/
tools/             apply-yiuos-buildsystem.sh (points build/make at vendor/yiuos)
```

## Building

Requirements: Linux, 32 GB+ RAM, ~400 GB disk, AOSP build deps and the
`repo` tool (https://wiki.lineageos.org/build_guides).

```bash
# 1. Init LineageOS 23.2 and add the YiuOS manifest
mkdir yiuos && cd yiuos
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
mkdir -p .repo/local_manifests
curl -o .repo/local_manifests/yiuos.xml \
    https://raw.githubusercontent.com/Ellosan/YiuOS/main/manifests/yiuos.xml
repo sync -c -j8

# 2. Point the build system at vendor/yiuos (one-time, re-run after build/make syncs)
bash vendor/yiuos/tools/apply-yiuos-buildsystem.sh

# 3. Build — GSI for any Treble device:
source build/envsetup.sh
lunch yiuos_gsi_arm64-bp4a-userdebug
m

# ...or a specific device with a LineageOS device tree (roomservice fetches it):
breakfast <device>
brunch <device>
```

### Building on Crave

With a [foss.crave.io](https://foss.crave.io) account, the whole build runs
on Crave's farm instead of your machine. Put your `crave.conf` (downloaded
from the Crave web console) next to the `crave` binary or at `~/crave.conf`,
create a project from the **LineageOS** template, then:

```bash
./crave-0.2-7220-linux-amd64.bin run --no-patch -- \
    "curl -s https://raw.githubusercontent.com/Ellosan/YiuOS/main/tools/crave-build.sh | bash"

# when it finishes:
./crave-0.2-7220-linux-amd64.bin pull out/target/product/gsi_arm64/system.img
```

`tools/crave-build.sh` does the repo init/sync, drops in the YiuOS manifest,
applies the build-system patch, and builds `yiuos_gsi_arm64-bp4a-userdebug`.
Override with env vars: `YIUOS_LUNCH_TARGET`, `YIUOS_RELEASE`, `YIUOS_VARIANT`.

Flash the GSI to a Treble device with an unlocked bootloader:

```bash
fastboot reboot fastboot
fastboot flash system out/target/product/gsi_arm64/system.img
fastboot -w reboot
```

## Verifying the rebrand

After boot: **Settings → About phone** shows a YiuOS build, and:

```bash
adb shell getprop ro.yiuos.version
adb shell getprop ro.yiuos.releasetype   # UNOFFICIAL
```

The boot animation and default wallpaper carry the new logo.

## Branding assets

`branding/yiuos-logo.svg` is the master mark: `#FF6900` rounded square,
white DejaVu Sans Bold wordmark. PNG exports at 512/192 px plus a horizontal
wordmark. The boot animation and wallpapers are generated from the same
geometry. (The mark is an original design in the MiOS visual style — it does
not reuse any third-party logo.)

## Roadmap

- Fork `lineage-sdk` and the Lineage apps to finish the deep rename
  (`org.lineageos.*` → `org.yiuos.*`)
- Signing keys under `vendor/yiuos-priv/keys`
- OTA/updater endpoint (`ro.yiuos.updater.uri`)
- Official device roster

## License

Apache License 2.0, same as upstream. This tree contains code
Copyright The CyanogenMod Project and The LineageOS Project; their
copyright notices are retained. YiuOS is not affiliated with LineageOS,
Xiaomi, or MiOS.

## Sony Xperia XA1 (hinoki)

The first device port lives under [`legacy/hinoki`](legacy/hinoki). The Xperia
XA1 hardware trees available from the Sony MTK community target LineageOS 15.1
(Android 8.1), not the Android 16 base used by the main YiuOS vendor tree. The
port therefore uses a dedicated compatibility product instead of presenting an
unbootable Android 16 image as device support.

The hinoki edition includes:

- the `yiuos_hinoki-userdebug` product;
- the MT6757 device, common, kernel and proprietary-vendor projects pinned by
  [`manifests/hinoki-15.1.xml`](manifests/hinoki-15.1.xml);
- **Yiu Home**, a real system launcher derived from the interactive prototype,
  with the YiuOS home cards, app dock, status surface and privacy/control panel;
- the orange YiuOS wallpaper and a 720-pixel boot animation generated from the
  same branding source as the Android 16 edition; and
- a manual GitHub Actions ROM build that publishes the OTA, boot image,
  recovery image and SHA-256 checksums as an Actions artifact.

See [`legacy/hinoki/README.md`](legacy/hinoki/README.md) for the build, device
and flashing notes. The full ROM job intentionally targets a maintainer-run
Linux builder labelled `yiuos-builder`: an Android source checkout and its
outputs need substantially more disk and memory than a standard GitHub-hosted
runner provides.
