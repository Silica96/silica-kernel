## CachyOS Linux 7.3.5-1

Based on Linux 7.3.5
Previous release: `cachyos-7.3.4-1`

### Changes since `cachyos-7.3.4-1`

- Rebased to upstream: `7.3.4` → `7.3.5`

### Applied branches

#### 7.3/zram
- `e823a1bcdce3` zram: fix idle age_sec underflow in idle_store()
- `9be086eef442` zram: remove unreachable kernel_read_file_from_path() return check
- `b77fba3e5f56` zram: convert to SG-list zsmalloc object read API
- `5afe50dfe24c` zram: fix short reads from block_state
- `d30d52920a73` zram: prefix backends printk-s
- `d1b78bc5e357` zram: remove debugfs entry on init failure
- `88d502378e50` zram: zstd: do not allocate empty C/D-dictionaries
- `ba6f28d1807c` zram: lz4hc: pre-initialize dictionary stream in setup_params
- `1b1ac1e19e6c` zram: lz4: use LZ4_decompress_safe_usingDict()
- `bb5add5e24b5` zram: lz4hc: use LZ4_decompress_safe_usingDict()
- `04785e03d610` zram: zstd: do not use kvzalloc() for zstd allocations
- `5b89f7a2f606` zram: reset writeback state in zram_reset_device()
- `d01d096e7f0a` zram: split zcomp into separate R/W streams
- `4f639dd99e44` zram: use a singleton compression context for recompression
- `0e4911efd9f9` zram: use rw_semaphore for decompression streams

#### 7.3/vesa-dsc-bpp
- `0a5931ca6469` drm/edid: rename VESA block parsing functions to more generic name
- `fbe9642e3c5d` drm/edid: prepare for VESA vendor-specific data block extension
- `3fd9535e387d` drm/edid: MSO should only be used for non-eDP displays
- `05b31ff1e293` drm/edid: parse DSC DPP passthru support flag for mode VII timings
- `4feb8846971a` drm/edid: for consistency, use mask everywhere for block rev parsing
- `a31c55309200` drm/edid: parse DRM VESA dsc bpp target
- `fd92f73b6872` drm/amd: use fixed dsc bits-per-pixel from edid
- `cd17013dd190` drm/amdgpu: dsc: Fix max_qp limits to match VESA DSC 1.1 spec

#### 7.3/t2
- `8ca5749a781f` Add t2bce driver stack
- `81f0b75907f5` Integrate t2bce driver stack
- `371178af4612` i915: 4 lane quirk for mbp15,1
- `0c539c32df88` apple-gmux: allow switching to igpu at probe
- `606639f7c60a` treewide: add backend for macsmc
- `aeffbf4e59d4` platform/x86: add backend for macsmc in intel macs using ACPI
- `47682119bb9a` watchdog: add driver for apple smc
- `f8cc5cc3c706` iio/light: add new driver for macsmc
- `5d0829f0ff74` iio/accel: add driver for apple SMS
- `193e39ddb923` leds: add support for macsmc kbl
- `852a10500fc0` rtc: add support for x86 macs in macsmc-rtc
- `934e144d2914` treewide: Add a flag to detect the Apple T2 chip
- `baeabf76ccaa` treewide: disable other rtc's in t2 macs
- `86fa08e5741b` power/supply: add support for x86 macs in macsmc-power
- `56056e95d01c` acpi: disable battery and adapter for x86 apple machines
- `36fef00bc537` hwmon/macsmc: add more types
- `b5718fc7e5df` hwmon: add support for x86 macs in macsmc-hwmon
- `7c2091f18ce8` HID: add device IDs for Apple SPI HID devices
- `dbbb1340979b` HID: add HOST vendor/device IDs for Apple MTP devices
- `ac97f7d399cf` HID: core: Handle HOST bus type when announcing devices
- `4942a4d1f388` HID: Bump maximum report size to 16384
- `be9cc0a436bd` HID: apple: Bind Apple silicon SPI devices
- `de7089ee38af` HID: apple: Bind to HOST devices for MTP
- `74ef1b8ea938` DO NOT MERGE: HID: apple: Add fnmode which ignores function keys
- `31d31dcfa3c4` HID: magicmouse: use a define of the max number of touch contacts
- `2624a894e9c9` HID: magicmouse: use struct input_mt_pos for X/Y
- `a244f3c65b29` HID: magicmouse: use ops function pointers for input functionality
- `644d419cb8a4` HID: magicmouse: add support for Macbook trackpads
- `bb06a45b37cb` fixup! HID: magicmouse: add support for Macbook trackpads
- `94d2f4439f65` HID: magicmouse: Add MTP multi-touch device support
- `0df621073f73` HID: magicmouse: Add .reset_resume for SPI trackpads
- `f236a0ccce35` HID: magicmouse: Handle touch controller resets on SPI devices
- `faa5cab6ac27` HID: magicmouse: Query device dimensions via HID report
- `b3ccbe902efc` WIP: HID: transport: spi: add Apple SPI transport
- `d74661ee77f1` soc: apple: Add DockChannel driver
- `e140522193c1` HID: Add Apple DockChannel HID transport driver
- `2b34cb34f27f` soc: apple: Add RTKit helper driver
- `f5b03a02a346` HID: apple: ignore the trackpad on T2 Macs
- `ecdae0340ae0` HID: magicmouse: Add support for trackpads found on T2 Macs
- `35d48fe55d9b` HID: appletb-kbd: add option to switch default layer on double pressing fn key
- `fe96b1d49e23` The driver has no USB power management callbacks, so the USB core unbinds it before system suspend and binds it again on resume. The DRM device is unregistered and registered again on every suspend and resume cycle, userspace driving the Touch Bar through it (such as tiny-dfr) loses its device, and the Touch Bar stays dark after resume.
- `413015ca6ea4` drm/amd/pm: Fix boot problems in 5300
- `7a299f84e812` drm/i915/fbdev: Discard BIOS framebuffers with mismatched dimensions
- `ce52724a735e` amdgpu: add support for 5K
- `e6c2a1c2d7e9` ACPI: x86: Apple T2 systems need early CPU offlining
- `ecfe82782e43` Bluetooth: hci_event: strip Broadcom vendor bits from legacy adv report type
- `0a0274c84af2` wifi: brcmfmac: Improve D3 substate entering timeout handling
- `114613f2096d` fix
- `8ddc5b98fcc6` platform/x86: macsmc-acpi: fall back to polling on missed interrupt
- `f3954d2a164e` mfd/macsmc: add ioctl to access smc keys
- `a6fe0dcf579d` hwmon: macsmc: use descriptive names for power zone sensors
- `aee74afff4c3` vga_switcheroo: Defer probe of display devices on T2 Macs
- `b5b0300cdf3d` platform/x86: macsmc: restrict the ACPI SMC stack to T2 Macs

#### 7.3/snd-codecs
- `9d043d31363d` Sound support for the Samsung Galaxy Book 4
- `53e43a1b7c9f` Rename model number of Book4 360 and Book4 Pro
- `8c788eb17d5f` Added fixup model
- `18fb76946317` Typo: Book 4 360 was a Book 4 Pro 360
- `7b541b30743e` Added Galaxy Book 5 and removed duplicated line
- `8de4bf835cce` Added support for Book4 Pro 16-inch and Book4 Ultra
- `e3732ab14f2d` Put the new biquads from the official Samsung firmware in the firmware blob
- `eec9fb473ef7` hda/max98390: Remove unused variables

#### 7.3/sched
- `c0606860890d` sched/eevdf: Ensure that vprot will never go above a min slice
- `78c4ec7aa4e0` sched/eevdf: Align update_protect_slice to set_protect_slice
- `5901bea24460` sched/eevdf: Handle more short slice waking cases
- `7107dcbd03dc` sched/fair: Reset NUMA fault locality after scan period update
- `8ac89a7ed293` sched/cputime: Don't account idle time twice after dyntick-idle
- `1d1df75336dc` sched/cache: Avoid publishing partial LLC utilization

#### 7.3/hdmi
- `bfd02102c6db` drm/amd/display: Add 2.1 FreeSync support for AMD VSDB EDID Block
- `6667afd57f77` drm/edid: parse HDMI 2.1 gaming (ALLM/VRR) capabilities from HF-VSDB
- `9ad5475bc364` drm/amd/display: Add HDMI 2.1 VRR support from HF-VSDB
- `a0596ba19d53` drm/amd/display: Enable HDMI ALLM for Gaming-VRR
- `6f11071b4a1a` drm: Add passive_vrr properties for passive/desktop VRR
- `5a42488d82a8` drm/amd/display: Use passive_vrr properties in amdgpu
- `96f023bb8c13` drm/amd/display: Keep FreeSync for HF-VSDB VRR sinks in MCCS fallback

#### 7.3/fixes
- `c90c777f9f7c` x86/cpu/amd: Don't clear RDSEED32 bit on znver5
- `df68eb7bafa0` drm/i915/rc6: Disable RC6 for InfinityBook Pro Gen8
- `13805bdf27ca` drm/i915/rc6: Add another Boardname to "Disable RC6 for InfinityBook Pro Gen8"
- `eb155ccbd456` Add BT support for PRIME B650M-A AX6 II motherboard
- `a82b45662d41` bluetooth: btusb: Add VID/PID 13d3:3625
- `3abc003bf2a4` sched/fair: do not scan twice in detach_tasks()
- `f38c1aede384` sched/core: Make finish_task_switch() and its subfunctions always inline
- `929056a37f56` USB: core: sanitize string descriptors against C0 control characters
- `99d4f73dbc9c` i2c: Force ASUE140D touchpad i2c freq to 100khz
- `3ae3d192fabb` wifi: iwlwifi: mld: skip TX when firmware is dead
- `18a890878b51` sof: Add quirk for Dell XPS 13 DX13260
- `d10310a163ce` Revert "drm/gud: validate TV mode names before creating enum property"
- `68f054f6774b` mm/slub: refill prefilled sheaves from the barn
- `2d0a9e75fe41` wireguard: queueing: preserve tstamp_type when encapsulating packet
- `6ac9c0cb071f` drm/i915/dp: On DPCD init wake the DPRx for eDP
- `84967922853d` cpufreq/amd-pstate: Skip auto_sel write when it already matches the mode
- `e93468e0030d` HID: logitech-hidpp: read G920 force feedback config before hid_connect()
- `a558a2bbbfc3` usb: pci-quirks: always assert xHCI OS ownership
- `06697f5e15b6` apparmor: convert duplicated dfa transitions to match_char()
- `1236df3b85d0` PCI: vmd: Flush DMA writes before handling MSI on Meteor Lake
- `5f35c1ed9a38` PCI: vmd: Flush DMA writes before handling MSI on Arrow Lake
- `3f1d6b739afe` wifi: brcmfmac: map msgbuf RX packet IDs bidirectional

#### 7.3/cachy
- `e4cd5992b0de` add sysctl to allow disabling unprivileged CLONE_NEWUSER
- `ad9d051f344c` Kconfig: Add CONFIG_CACHY
- `fca30f3a1818` Kconfig.hz: Add additional timer frequency options
- `96164dfbed0f` mm: Increase VM_READAHEAD_PAGES to 256K
- `4aeb2fc3ebf7` CACHY: mm/vmscan: Increase vm_swappiness to 100
- `20b5544262ae` CACHY: sched/fair: Tweak EEVDF for interactivity
- `12d17b523d3a` Kconfig: Restore CONFIG_OPTIMIZE_FOR_PERFORMANCE_O3
- `6f2b05b719d8` kbuild: Add GCC SMS-based modulo scheduling
- `16acc33ed004` drivers/pci: Add ACS override support
- `1e648d759270` Input: evdev - use call_rcu when detaching client
- `ab9b9962958a` CACHY: Enable background reclaim of hugepages
- `c5f1297f1c0e` CACHY: Disable watermark boosting by default
- `798ce5a82e1a` CACHY: Disable proactive compaction by default
- `b194f335960a` drm/amd: Move AMD_PRIVATE_COLOR to Kconfig
- `930f739a0202` CACHY: v4l2-core: add v4l2loopback
- `85b1ee1995bd` intel-pstate: Implement "enable" parameter
- `805e4301cae0` scsi: Add VHBA driver
- `ec5a84851c81` Kconfig.preempt: Remove CONFIG_EXPERT dependency from PREEMPT_RT
- `71e9c134e71f` arch/x86: Add x86_64 ISA and Zen4 compiler optimizations
- `78df04208d2b` CACHY: Disable split lock mitigation by default
- `1c3acc6c8c74` linux7.1-rc1-ADIOS-3.2.0
- `e8ab2c2dba61` CACHY: Use BFQ for SQ devices and mq-deadline for MQ devices
- `84c961d30741` ACPI: processor: Disable bus master check for AMD
- `5424f3c6cb14` tag-release: Add script to easier create a release and tag
- `fca1898e05b7` tag-release: Update script to include commits from branches
- `da24f26ca8ee` tag-release: Move tarball to pkgbuilds dir for naim
- `ad38870256bc` CACHY: mm: lru-gen: Protect the working set of the last 100 jiffies
- `c9c787be66d0` kbuild: add resolve_btfids to pacman PKGBUILD
- `3e74873bddcf` tag-release: Update script
- `8f28aedefce3` Kbuild: Enable LLVM machine pipeliner
- `1f1f7071f51d` tag-release: Update script
- `2ced65838b77` readdir: add unlikely hint on len check
- `5f3e9d4f9a4c` sched/core: add some branch hints based on gcov analysis
- `74bf4e66d0c4` tag-release.sh: GPG-sign release tarballs before upload
- `d99eae941015` tag-release: Update to include .0
- `6eaae2635d39` list: Mark some functions as __always_inline
- `661ebafdadd7` 7.2-rc1-poc-selector-v2.6.3
- `6936583cfc28` mm/swap_state: Disable swap-in readahead
- `d77c58de7881` x86: implement tsc=directsync for systems without IA32_TSC_ADJUST
- `dd199fccf526` x86: touch clocksource watchdog after syncing TSCs
- `63239e08d7ef` x86: save/restore TSC counter value during sleep/wake
- `9d04311179f0` x86: only restore TSC if we have IA32_TSC_ADJUST or directsync enabled
- `e5c2a5fd8c3a` x86: don't check for random warps if using direct sync
- `f9012d5b1220` x86: revert extra time added to check for tsc wraps
- `10aa506a7d0f` iosched-7.3: update ADIOS to 3.3.0
- `52dc9bb47a1b` fixup! iosched-7.3: update ADIOS to 3.3.0
- `db7c39dabd6e` PCI: Add Intel remapped NVMe device support
- `962bee17a9d7` rust: Allow BTF generation with Rust + LTO
- `f2bd287ff236` fixup! drivers/pci: Add ACS override support
- `852ded6b31ba` Revert "7.2-rc1-poc-selector-v2.6.3"

#### 7.3/bbr3
- `5b121d2f9e4f` tcp/bbr3: add BBRv3 congestion control
- `a52f724cc56d` bbr: Fix bbr name to bbr3

#### 7.3/amd-iommu
- `f5ec5d9476c4` iommu/amd: Do not request ACS when IOMMU is not going to be initialized
- `f6e14328620e` iommu/amd: Disallow implicit START_STATE => IVRS_DETECTED transition
- `567e74ce4dfd` iommu/amd: Remove ad-hoc checks that are never true
- `bf5bdfd1f8d4` iommu/amd: Force identity mode for selected GPUs only
- `15d5b3027d9f` iommu/amd: Refactor device probe and capability initialization
- `5b33c19a31c0` iommu/amd: Remove iommu_ignore_device()
- `622384f54a84` iommu/amd: Fail probe on ATS configuration failure
- `f4eab1f88f79` iommu/amd: Move GA log allocation to init
- `108657f24706` iommu/amd: Fix leak of data->entry in irq_remapping_alloc() error path
- `6e87850d1a8f` iommu/amd: Add PerfOpt IOMMU performance optimization support
- `e74db71a3530` drm/amdgpu: Enable PerfOpt IOMMU perf optimization when GPU in identity domain
- `cf18d488df9d` Revert "iommu/amd: Force identity mode for selected GPUs only"

