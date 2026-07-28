# YiuOS for Sony Xperia XA1 (hinoki)

This is the first bootable-device bring-up for the YiuOS prototype. It targets
the Xperia XA1 hardware family represented by the community `hinoki` tree,
using LineageOS 15.1 / Android 8.1 and the Linux 4.4-era MT6757 kernel source.

## Why Android 8.1?

The available hinoki device tree, MT6757 common tree, kernel and proprietary
vendor repository were authored for `lineage-15.1`. YiuOS main targets
LineageOS 23.2 / Android 16. Mixing those generations would fail at build time
and would not produce a bootable phone. This compatibility product keeps the
current YiuOS work intact while putting the prototype on the hardware base that
the Xperia XA1 can actually use.

The result is an early, unofficial port. A successful compile is not proof that
radio, camera, audio, encryption or suspend are reliable on every XA1 variant.
Hardware validation requires a real phone and serial/`adb` logs.

## What is implemented

- `yiuos_hinoki-userdebug`, inheriting the community hinoki product.
- Yiu Home, a platform-signed launcher implementing the prototype's home,
  cards, dock and privacy/control surface with Android 8.1 APIs.
- YiuOS properties, wallpaper and boot animation.
- Reproducible source pinning through `manifests/hinoki-15.1.xml`.
- GitHub Actions validation and a maintainer-dispatched full ROM build.

## Manual build

Use a Linux machine with Java 8, the Android build dependencies, at least
32 GB RAM and 180 GB free disk. A constrained build can run with less by
setting `USE_CCACHE=0` and reducing `BUILD_JOBS`, but it will be substantially
slower and may still run out of space.

```bash
mkdir -p ~/android/yiuos-hinoki
cd ~/android/yiuos-hinoki
repo init -u https://github.com/LineageOS/android.git -b lineage-15.1 \
  --depth=1 --no-clone-bundle

mkdir -p .repo/local_manifests
curl -L \
  https://raw.githubusercontent.com/Ellosan/YiuOS/main/manifests/hinoki-15.1.xml \
  -o .repo/local_manifests/yiuos-hinoki.xml
repo sync -c --no-tags --optimized-fetch --prune -j8

git clone https://github.com/Ellosan/YiuOS.git vendor/yiuos
ANDROID_ROOT="$PWD" bash vendor/yiuos/tools/hinoki/build.sh
```

Outputs are written to `out/target/product/hinoki/`. The build script retains
the upstream-named OTA and creates a `YiuOS-0.3-...-hinoki.zip` copy.

## GitHub Actions builder

The validation job uses a standard GitHub-hosted runner. The full ROM job runs
only after a maintainer manually dispatches **YiuOS Xperia XA1** and requires a
Linux x64 self-hosted runner with Docker, at least 32 GB RAM and 180 GB free
disk. Give that runner the custom label `yiuos-builder`.

Keeping the heavyweight job manual prevents code from untrusted pull requests
from reaching the self-hosted builder. GitHub uploads the OTA, `boot.img`,
`recovery.img` and `SHA256SUMS` for 14 days.

## Flashing and safety

Do not flash this build until the workflow has completed successfully and the
first boot has been reviewed by someone with a recoverable XA1.

Before touching the device:

1. Confirm the service menu reports **Bootloader unlock allowed: Yes**.
2. Back up every file and record the exact XA1 model/stock firmware.
3. Keep Sony's stock flashing tool and firmware available for recovery.
4. Verify the downloaded files against `SHA256SUMS`.

Unlocking the Sony bootloader factory-resets the phone and permanently removes
device DRM keys. Flashing an image for the wrong partition layout can leave the
phone unbootable. The initial bring-up should boot recovery first and collect
logs before installing the OTA.

This project does not ship Google apps or production signing keys.
