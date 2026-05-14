#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
# USB "effect off" sequence from pobrn/ite8291r3-ctl (8291 rev 0.03). Same wire format is
# attempted on 048d:7001 (ITE 8233) on some MECHREVO units for lid / second RGB zone.

import sys

import usb.core
import usb.util

VENDOR_ID = 0x048D
# 600b = ITE 8291 (light bar / chassis); 7001 = ITE 8233 (lid logo / extra zone on many units)
PRODUCT_IDS = (0x600B, 0x7001)
SET_EFFECT = 8
RGB_OFF_IFACE = 1


def _send_ctrl(dev, payload: tuple[int, ...]) -> None:
    if len(payload) < 8:
        payload = payload + (0,) * (8 - len(payload))
    dev.ctrl_transfer(
        usb.util.build_request_type(
            usb.util.CTRL_OUT,
            usb.util.CTRL_TYPE_CLASS,
            usb.util.CTRL_RECIPIENT_INTERFACE,
        ),
        0x009,
        0x300,
        0x001,
        payload,
    )


def _turn_off(dev) -> None:
    _send_ctrl(dev, (SET_EFFECT, 0x01, 0, 0, 0, 0, 0))


def _poke_device(pid: int) -> tuple[bool, str]:
    dev = usb.core.find(idVendor=VENDOR_ID, idProduct=pid)
    if dev is None:
        return False, "no device"
    detached = False
    try:
        if dev.is_kernel_driver_active(RGB_OFF_IFACE):
            dev.detach_kernel_driver(RGB_OFF_IFACE)
            detached = True
        _turn_off(dev)
    except usb.core.USBError as e:
        return False, str(e)
    finally:
        if detached:
            try:
                dev.attach_kernel_driver(RGB_OFF_IFACE)
            except usb.core.USBError:
                pass
    return True, "ok"


def main() -> int:
    ok_any = False
    for pid in PRODUCT_IDS:
        label = "8291 (chassis/bar)" if pid == 0x600B else "8233 (lid/extra)"
        ok, detail = _poke_device(pid)
        if ok:
            print("048d:%04x (%s): sent RGB-off." % (pid, label))
            ok_any = True
        else:
            if detail != "no device":
                print("048d:%04x: %s" % (pid, detail), file=sys.stderr)
    if not ok_any:
        print(
            "No ITE RGB USB (%s). Laptop on? Cable? Try: lsusb -d 048d:"
            % ", ".join("%04x" % p for p in PRODUCT_IDS),
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
