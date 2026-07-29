# Roadmap

Verification plan for a clean bare-metal run, plus the known gaps.

Written after a session that added the `tablet` role and brought the repo to a
clean `ansible-lint` production profile. Several changes touch `arch_install`,
which cannot be exercised without wiping a disk — so they are **lint-clean and
render-verified, but never executed**. That is what this fresh install is for.

## Status of the current tree

| Area | State | How it was verified |
|------|-------|---------------------|
| `tablet` role | Working | Ran live on `south`; Huion HS610 detected, idempotent re-run |
| `common` yay variable rename | Working | Ran live via `--tags yay` |
| `common` yay check-mode guards | Working | `--check` reports `none`/`none`, real run reports real versions |
| `ollama` enable-gate fix | Working | Full `--check` of `site.yml` passes on `south` |
| Lint tooling (`mise run test`) | Working | Green from an empty `~/.ansible/collections` |
| `arch_install` line wrapping | **Unverified** | Jinja rendered + shell `sh -n`, never executed |
| `arch_install` handler rename | **Unverified** | grep of `notify:` sites only |
| `gaming` variable rename | **Unverified** | Syntax + lint only |

## Stage 0: bare metal install

The risk concentrates here. Four files in `arch_install` had long lines
rewrapped to satisfy `yamllint`. The wrapping was chosen so the rendered output
is byte-identical, but only a real run proves it.

### What to watch

1. **`partitioning.yml` — UEFI partition creation.**
   Three `parted` calls now use shell backslash continuation inside a `|`
   literal block. Rendering was checked with `parted` stubbed out:

   ```
   parted -s /dev/sda mkpart primary linux-swap 512MiB 8704MiB
   parted -s /dev/sda mkpart primary ext4 8704MiB 100%
   ```

   If the continuation is mis-parsed, partitions come out the wrong size or
   `parted` errors on a stray argument. Check with `lsblk` before the reboot.
   The BIOS path was not touched.

2. **`pacstrap.yml` — package list.**
   The 296-character `{{ ... }}` expression is now split across six physical
   lines. Jinja consumes the newlines, so it renders to one line. A failure
   here is loud: pacstrap refuses an argument or installs the wrong set.
   Verify the installed set matches CPU/GPU/boot-mode/wifi selections.

3. **`bootloader.yml` — syslinux `INITRD` line (BIOS only).**
   Renders to `INITRD ../amd-ucode.img,../initramfs-linux-lts.img`. If the
   split leaked whitespace into the config, syslinux fails to find the initramfs
   and the machine does not boot. **This is the one that bricks a boot rather
   than failing loudly** — check `/boot/syslinux/syslinux.cfg` in the installed
   system before rebooting out of the ISO.

4. **`arch_install` handler rename.**
   `install syslinux mbr` → `Install syslinux mbr`, with the single `notify:`
   at `bootloader.yml:64` updated. If a reference was missed, the handler
   silently never runs and the MBR is not written — BIOS systems will not boot.
   Ansible does not warn on an unmatched `notify:`; it errors, so a missed
   rename fails the play rather than passing quietly.

5. **`finalize.yml` — reboot task.**
   `ignore_errors: true` became `failed_when: false`. Both let the play
   continue when the host drops mid-command; `failed_when` additionally keeps
   the run from being reported as failed.

### Suggested sequence

```bash
mise run install            # collections into ~/.ansible/collections
mise run test               # syntax + lint, expect 0 failures
./run.sh install            # DESTRUCTIVE
```

Before letting it reboot, from the ISO:

```bash
lsblk /dev/<disk>                        # partition sizes match config
cat /mnt/boot/syslinux/syslinux.cfg      # BIOS: INITRD line on one line
arch-chroot /mnt pacman -Q | wc -l       # package set looks sane
```

## Stage 1: provisioning

Lower risk — most of this has run live.

```bash
./run.sh                          # full site.yml
./run.sh site --tags tablet       # or per-role
```

`mise run check` (dry run) now completes against a reachable host. It still
fails if any host in `inventories/provision/hosts.ini` is powered off — that is
an SSH `UNREACHABLE`, not a playbook error. Use `--limit <host>` to scope it.

One behaviour change to be aware of on the first full run: `ollama_enabled` is
now the master switch for that role, and `ollama_cuda_enabled` only selects
which build. Previously the CUDA install and the service start were gated on
`ollama_cuda_enabled` alone, so a host with `ollama_enabled: false` and a
leftover `ollama_cuda_enabled: true` would install `ollama-cuda` from the AUR
and start the service anyway. If you actually want ollama on a machine, both
`ollama_enabled: true` and your build choice must be set.

The `gaming` role's `multilib_result` → `gaming_multilib_result` rename is
contained in one file but has not been executed. First run with
`gaming_steam_enabled: true` will prove it: if the rename broke, the multilib
cache refresh is skipped and the Steam install fails on missing `lib32-*`
packages.

## Known issues

- **`arch_install` has no automated test.** Everything in that role is verified
  by reading and rendering. A VM run against a scratch disk would close this;
  `qemu` is already available via `common_virt_enabled`.

## Things deliberately not done

- **Per-device OpenTabletDriver config is not managed.** Key bindings, dial
  mapping and tablet area live in `~/.config/OpenTabletDriver/` and are written
  by the `otd` CLI or the GUI. That is dotfile territory (chezmoi), not Ansible.
  The role installs the driver and enables the daemon; it does not opine on
  bindings.

- **`mock_modules` must stay empty in `.ansible-lint`.** ansible-lint
  materialises each entry as a stub `.py` inside the collections path. Because
  `ansible.cfg` points `collections_path` at `~/.ansible/collections`, mocking a
  real module overwrites it, and every later playbook run fails with
  `Unsupported parameters ... Supported parameters include: .` Install the
  collection instead.
