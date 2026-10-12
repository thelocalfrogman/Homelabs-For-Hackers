#!/bin/bash
# reset-range-vbox.sh — restore VirtualBox lab VMs to a named snapshot, fail safe.
#
# Usage:  ./reset-range-vbox.sh [SNAPSHOT_NAME] [VM ...]
# Example:./reset-range-vbox.sh lab-ready range-kali range-target-01
#
# If no VMs are given, edit the DEFAULT_VMS array below.
# The script STOPS if a VM or its snapshot is missing — it never starts a VM in
# the wrong state and then claims success.
set -euo pipefail

SNAPSHOT="${1:-lab-ready}"; shift || true
DEFAULT_VMS=("range-kali" "range-target-01")
if [ "$#" -gt 0 ]; then VMS=("$@"); else VMS=("${DEFAULT_VMS[@]}"); fi

for vm in "${VMS[@]}"; do
    if ! VBoxManage showvminfo "$vm" >/dev/null 2>&1; then
        echo "ERROR: VM '$vm' not found. Aborting." >&2; exit 1
    fi
    if ! VBoxManage snapshot "$vm" list 2>/dev/null | grep -qF "Name: $SNAPSHOT"; then
        echo "ERROR: snapshot '$SNAPSHOT' not found on '$vm'. Aborting before any damage." >&2; exit 1
    fi
    echo "Restoring $vm to $SNAPSHOT..."
    VBoxManage controlvm "$vm" poweroff 2>/dev/null || true
    sleep 2
    VBoxManage snapshot "$vm" restore "$SNAPSHOT"
    VBoxManage startvm "$vm" --type headless
done
echo "Range reset complete."
