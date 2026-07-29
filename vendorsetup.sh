#!/bin/bash

# Legacy device products that are maintained by YiuOS itself.
if [ -f vendor/yiuos/legacy/hinoki/yiuos_hinoki.mk ]; then
    add_lunch_combo yiuos_hinoki-userdebug
fi
