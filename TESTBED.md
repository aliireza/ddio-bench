# Testbed

All of the experiments require two servers interconnected via a 100-Gbps link. One of the servers (i.e., `client`) generates packets, while the other one (i.e., `dut`) acts as the device under test. Our testbed configuration is shown in the following table.

|      Server      |       Processor      |           NIC           |
|:----------------:|:--------------------:|:-----------------------:|
| Packet Generator | Intel Xeon Gold 6134 @ 3.2 GHz | Mellanox ConnectX-5 VPI |
| DUT              | Intel Xeon Gold 6140 @ 2.3 GHz | Mellanox ConnectX-5 VPI |

Our experiments require `npf`, `dpdk` (on both servers), `fastclick` (on both servers), `pcm` (on the dut), `intel-cmt-cat` (on the dut), and `Splash-3` (on the dut). You should setup your testbed based on the following guidelines.

## Network Performance Framework (NPF) Tool

We use [NPF][npf-repo] tool to run our experiments. However, it is possible to run them manually. To setup NPF, you can run the following commands:

```bash
git clone https://github.com/tbarbette/npf.git && cd npf
sudo apt install python3 python3-pip libssl-dev
pip3 install --user -r requirements.txt
```

You should also define your servers and NICs configuration in NPF. To do so, you can define `pkt-gen.node` and `dut.node` in the `npf/cluster` according to the example node files. For example, one of our servers is defined as follows:

```
path=/home/alireza/ddio-bench/npf/
addr=server0.kth.se
arch=skylake
nfs=0

0:mac=50:6b:4b:43:88:ca
0:ip=192.168.100.13
0:ifname=enp23s0f0
0:pci=0000:17:00.0

1:mac=50:6b:4b:43:88:cb
1:ip=192.168.101.13
1:ifname=enp23s0f1
1:pci=0000:17:00.1
```

- `path` is the path to NPF on a given machine. If you do not have Network File System (NFS) in your testbed, you should uncomment `nfs=0`.

- `addr` is the address of each machine. It can be either its URL or its IP address.

You should define 4 variables for every NIC port:

- `mac`: The MAC address of the interface
- `ip`: The IP address of the interface
- `ifname`: The interface name
- `pci`: The PCIe address of the interface

The first three variables can be set via `ifconfig`. To find the PCIe address of an interface, you can run `sudo lspci -v | grep Mellanox`. It is important to set these values carefuly, as NPF replaces these values in its scripts.

NPF uses ssh to connect to the servers. Please make sure that you have setup passwordless ssh on your system. If you want to use your current key (e.g., `ida_rsa`) on a different server, you can run the following commands:

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/ida_rsa
```

You can check [NPF README][npf-readme] file for more information.

## Data Plane Development Kit (DPDK)

We use [DPDK][dpdk-page] to bypass kernel network stack in order to achieve line rate in our tests. To build DPDK, you can run the following commands. Note that Mellanox drivers (e.g., `MLX5`) is not enabled by default and you should enable them in `dpdk/config/common_base` if you have Mellanox cards.

```bash
git clone https://github.com/DPDK/dpdk.git
cd dpdk
git checkout v20.02
make install T=x86_64-native-linux-gcc
```

To build DPDK, you can also use `dpdk/usertools/dpdk-setup.sh`.

After building DPDK, you have to define `RTE_SDK` and `RTE_TARGET`. To do so, run:

```bash
export RTE_SDK=/home/alireza/ddio-bench/dpdk/
export RTE_TARGET=x86_64-native-linux-gcc
```

You can try running [testpmd][testpmd-doc] to check whether DPDK is working properly on your system or not.

## Fastclick

We use [Fastclick][fastclick-repo] to generate and process packets. To build Fastclick, you can run the following commands. We have implemented a new element for Fastclick, called [DDIOTune][ddiotune-element], to enable/disable/tune DDIO. To use this element, you have to compile Fastclick with `--enable-research` and `--enable-dpdk` flags and install `libpci-dev` and `cpuid` libraries. Note that DDIOTune requires **at least gcc 6.0** to be built successfully. 

```bash
git clone git@github.com:tbarbette/fastclick.git
cd fastclick
sudo apt-get install libpci-dev
./configure RTE_SDK=/home/alireza/ddio-bench/dpdk RTE_TARGET=x86_64-native-linux-gcc --enable-multithread --disable-linuxmodule --enable-intel-cpu --enable-user-multithread --verbose CFLAGS="-std=gnu11 -O3" CXXFLAGS="-std=gnu++14 -O3" --disable-dynamic-linking --enable-poll --enable-dpdk --disable-dpdk-pool --disable-dpdk-packet --enable-research
make
```

Note that you should change `RTE_SDK` and `RTE_TARGET` in the `configure` command.

## Intel Performance Counter Monitor (PCM) Tool

We use [PCM][pcm-page] tool to monitor the Intel performance counters introduced for PCIe. Specifially, we measure the `ItoM` and `PCIeRdCur` events via `pcm/pcm-pcie.x`, which shows the performance of DDIO. You can find more information about these events either in our paper or [here][pcie-events].

To build PCM tool, you can run the following commands.

```bash
git clone https://github.com/opcm/pcm.git
cd pcm
make
sudo make install
```

To check your installation, run `sudo pcm-pcie`.

## Intel Resource Director Technology (RDT) Software Package (intel-cmt-cat)

We use Intel [RDT][rdt-page] software package to configure Cache Allocation Technology (CAT), Memory Bandwidth Allocation (MBA), and measure per-core Last Level Cache (LLC) misses via `pqos` command. To setup `pqos`, you can run the following commands.

```bash
git clone https://github.com/intel/intel-cmt-cat.git
cd intel-cmt-cat
make
sudo make install
```

To check your installation, run `sudo pqos`. You can find more information about CAT and pqos in [intel-cmt-cat wiki][pqos-wiki].

## Other Configurations

Below, you can find some useful hints for optimizing your testbed.

### Isolating a CPU Socket

To have a more accurate measurement, we recommend you to isolate one CPU socket. By doing so, you ensure that operating system is not polluting your cache. To do so, you can add the following commands to the `GRUB` commandline in `/etc/default/grub`. To find the cores located on a CPU socket, you can use `lscpu` command.

```bash
GRUB_CMDLINE_LINUX="isolcpus=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17"
```

### Other Commandlines

There are more options for the `GRUB_CMDLINE` to optimize your system. We used the followings:

```bash
GRUB_CMDLINE_LINUX="isolcpus=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 iommu=pt intel_iommu=on default_hugepagesz=1GB hugepagesz=1G hugepages=128 acpi=on selinux=0 audit=0 nosoftlockup processor.max_cstate=1 intel_idle.max_cstate=0 intel_pstate=on nopti nospec_store_bypass_disable nospectre_v2 nospectre_v1 nospec l1tf=off netcfg/do_not_use_netplan=true mitigations=off"
```

Note that you need to run `sudo update-grub` and reboot your system after changing `/etc/default/grub`.

### Changing Frequency

It is essential to check the processor's frequency before running any experiment so that you could reproduce them later.

- **Checking**: To check the processor's frequency you can use one of the following methods:
    1. `lscpu | grep "CPU" | grep "MHz"`
    2. `cat /proc/cpuinfo | grep "processor\|MHz"`
    3. `sudo lshw -c cpu | grep "*-cpu\|MHz"`
    4. `sudo dmidecode -t processor | grep Speed`
    5. `sudo watch -n 1  cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq`

    The last method prints the frequency of each core every second. Note that instead of using `cpu*`, you can print the frequency of a subset of cores (e.g., `cpu[0-7]`).

- **Changing**: To change the frequency of the processors, you can use `cpupower` tool, as follows:

    ```bash
    sudo cpupower frequency-set -u 2.3G -d 2.3G
    ```

  - `-u` specifies the maximum frequency, while `-d` shows the minimum frequency for each core. To have a fixed frequency, you can set both of them to a single frequency (e.g., `2.3G`).
  - `sudo cpupower frequency-info | grep "hardware limits"` or `lscpu | grep "CPU" | grep "MHz"` print the minimum/maximum frequencies for the processor.
  - You can get the nominal frequency of the processor via: `cat /proc/cpuinfo | grep model | grep -o "[0-9.]\+G" | head -n 1`

For more information, check [here][cpu-freq-link].

### Disabling PAUSE Frames

We disable PAUSE frames in our experiments, which will be done automatically by Fastclick. However, you can also enable/disable/check the status of PAUSE frames for every interface via `ethtool`.

```bash
ethtool -a enp23s0f0
sudo ethtool -A enp23s0f0 rx off tx off
```

It is possible to measure the number of PAUSE frames via `ethtool` and `dpdk`.

- **ethtool**: `sudo ethtool -S enp23s0f0 | grep pause_ctrl`. For more info, check [here][mlx5-counters].

- **dpdk**: You can read ethtool statistics in DPDK via `xstats` API. However, some of the Mellanox counters (e.g., `rx_pause_ctrl` and `tx_pause_ctrl`) are not available by default. To measure PAUSE frames via dpdk, you should add the counters to `static const struct mlx5_counter_ctrl mlx5_counters_init[]` located in `dpdk/drivers/net/mlx5/mlx5_stats.c`, as follows:

```c
static const struct mlx5_counter_ctrl mlx5_counters_init[] = {
    {
        .dpdk_name = "rx_port_unicast_bytes",
        .ctr_name = "rx_vport_unicast_bytes",
    },

    ...

    + {
    +     .dpdk_name = "rx_pause_ctrl_phy",
    +     .ctr_name = "rx_pause_ctrl_phy",
    + },
    + {
    +     .dpdk_name = "tx_pause_ctrl_phy",
    +     .ctr_name = "tx_pause_ctrl_phy",
    + },
};
```

### Configuring Mellanox Cards

We set `CQE_COMPRESSION` to aggressive mode in order to save PCIe bandwidth in our experiments. To check the status of `CQE_COMPRESSION`, you can run the following commands.

```bash
sudo mst start
sudo mlxconfig -d /dev/mst/mt4119_pciconf0 q | grep CQE
```

To change its status, you can run `sudo mlxconfig -d /dev/mst/mt4119_pciconf0 set CQE_COMPRESSION=1`.

Note that you need to install Mellanox `OFED` and `MFT` before being able to run the mentioned commands. For more info, check the Mellanox manual for your NIC.

[ddio-atc-paper]: https://www.usenix.org/conference/atc20/presentation/farshin
[atc20-page]: https://www.usenix.org/conference/atc20
[npf-repo]: https://github.com/tbarbette/npf
[npf-readme]: https://github.com/tbarbette/npf#network-performance-framework
[dpdk-page]:https://www.dpdk.org/
[testpmd-doc]: https://doc.dpdk.org/guides/testpmd_app_ug/intro.html
[fastclick-repo]: https://github.com/tbarbette/fastclick
[ddiotune-element]: https://github.com/tbarbette/fastclick/wiki/DDIOTune
[ddiotune-cc]: https://github.com/tbarbette/fastclick/blob/master/elements/research/ddiotune.cc
[pcm-page]: https://software.intel.com/content/www/us/en/develop/articles/intel-performance-counter-monitor.html
[rdt-page]: https://www.intel.com/content/www/us/en/architecture-and-technology/resource-director-technology.html
[pqos-wiki]: https://github.com/intel/intel-cmt-cat/wiki
[pcie-events]: https://software.intel.com/en-us/forums/software-tuning-performance-optimization-platform-monitoring/topic/543883
[cpu-freq-link]: https://wiki.archlinux.org/index.php/CPU_frequency_scaling
[mlx5-counters]: https://community.mellanox.com/s/article/understanding-mlx5-ethtool-counters
[haswell-datasheet]: https://www.intel.com/content/dam/www/public/us/en/documents/datasheets/xeon-e5-v2-datasheet-vol-2.pdf
[cascade-datasheet]: https://www.intel.com/content/www/us/en/products/docs/processors/xeon/2nd-gen-xeon-scalable-datasheet-vol-2.html
[dynamic-dma-branch]: https://github.com/tbarbette/fastclick/tree/DMAdynamic
[alireza-page]: https://www.kth.se/profile/farshin
[amir-page]: https://www.kth.se/profile/amirrsk
