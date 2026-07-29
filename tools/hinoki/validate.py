#!/usr/bin/env python3
"""Static validation for the legacy Xperia XA1 bring-up."""

from __future__ import annotations

import pathlib
import sys
import xml.etree.ElementTree as ET


ROOT = pathlib.Path(__file__).resolve().parents[2]

REQUIRED = (
    "manifests/hinoki-15.1.xml",
    "legacy/hinoki/yiuos_hinoki.mk",
    "legacy/hinoki/product.mk",
    "legacy/hinoki/apps/YiuHome/Android.mk",
    "legacy/hinoki/apps/YiuHome/AndroidManifest.xml",
    "legacy/hinoki/apps/YiuHome/src/org/yiuos/home/HomeActivity.java",
    "tools/hinoki/prepare-assets.sh",
    "tools/hinoki/build.sh",
    "tools/hinoki/ci-build.sh",
    "tools/hinoki/compile-launcher.sh",
)


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


for relative in REQUIRED:
    if not (ROOT / relative).is_file():
        fail(f"missing required file: {relative}")

manifest = ET.parse(ROOT / "manifests/hinoki-15.1.xml").getroot()
projects = {
    project.attrib.get("path"): project.attrib
    for project in manifest.findall("project")
}
expected_paths = {
    "device/sony/hinoki",
    "device/sony/mt6757-common",
    "kernel/sony/mt6757",
    "vendor/sony/mt6757-common",
}
if set(projects) != expected_paths:
    fail(f"unexpected manifest project paths: {sorted(projects)}")
if any(project.get("revision") != "lineage-15.1" for project in projects.values()):
    fail("all hinoki hardware projects must be pinned to lineage-15.1")

product = (ROOT / "legacy/hinoki/product.mk").read_text(encoding="utf-8")
for token in ("YiuHome", "bootanimation.zip", "ro.yiuos.device=hinoki"):
    if token not in product:
        fail(f"product.mk is missing {token}")

build_script = (ROOT / "tools/hinoki/build.sh").read_text(encoding="utf-8")
for token in (
    'KERNEL_ANDROID_MK="${ANDROID_ROOT}/kernel/sony/mt6757/Android.mk"',
    'mv -- "${KERNEL_ANDROID_MK}" "${KERNEL_ANDROID_MK_DISABLED}"',
    'mv -f -- "${KERNEL_ANDROID_MK_DISABLED}" "${KERNEL_ANDROID_MK}"',
    'find "${YIUOS_ROOT}/build/tasks" -maxdepth 1 -type f -name \'*.mk\' -print0',
    'mv -f -- "${task}.hinoki-disabled" "${task}"',
    "trap restore_build_inputs EXIT",
):
    if token not in build_script:
        fail("build.sh does not safely isolate the conflicting MT6757 Android.mk")

android_manifest = ET.parse(
    ROOT / "legacy/hinoki/apps/YiuHome/AndroidManifest.xml"
).getroot()
categories = {
    category.attrib.get("{http://schemas.android.com/apk/res/android}name")
    for category in android_manifest.findall(
        ".//category"
    )
}
if "android.intent.category.HOME" not in categories:
    fail("YiuHome does not declare the HOME category")

workflow = ROOT / ".github/workflows/hinoki.yml"
if workflow.exists():
    text = workflow.read_text(encoding="utf-8")
    if "self-hosted" not in text or "yiuos-builder" not in text:
        fail("the full ROM job must use the dedicated yiuos-builder runner")

print("hinoki bring-up validation passed")
