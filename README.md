# ddio-bench: Understanding Intel Data Direct I/O Technology

This repositoy contains information/source code to perform the experiments done in [DDIO paper][ddio-atc-paper] published at ATC'20.

## Testbed

All of the experiments require two servers interconnected via a 100-Gbps link. One of the servers (i.e., `client`) generates packets, while the other one (i.e., `dut`) acts as the device under test. Our testbed configuration is shown in the following table.

|      Server      |       Processor      |           NIC           |
|:----------------:|:--------------------:|:-----------------------:|
| Packet Generator | Intel Xeon Gold 6134 | Mellanox ConnectX-5 VPI |
| DUT              | Intel Xeon Gold 6140 | Mellanox ConnectX-5 VPI |

Our experiments requires `npf`, `dpdk` (on both servers), `fastclick` (on both servers), `pcm` (on the dut), `intel-cmt-cat` (on the dut), and `Splash-3` (on the dut). You should setup your testbed based on the following guidelines.

### Network Performance Framework (NPF) Tool

We use [NPF][npf-repo] tool to run our experiments. However, it is possible to run them manually. To setup NPF, you can run the following commands:

```bash
git clone https://github.com/tbarbette/npf.git && cd npf
sudo apt install python3 python3-pip
pip3 install --user -r requirements.txt
```

You should also define your servers and NICs configuration in NPF. To do so, you can define `pkt-gen.node` and `dut.node` in the `npf/cluster` according to the example node files. For example, one of our servers is define as follows:

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

- `mac`: the MAC address of the interface
- `ip`: the IP address of the interface
- `ifname`: the interface name
- `pci`: the PCIe address of the interface

The first three variables can be set via `ifconfig`. To find the PCIe address of an interface, you can run `sudo lspci -v | grep Mellanox`. It is important to set these values carefuly, as NPF replaces these values in its scripts.

NPF use ssh to connect to the servers. Please make sure that you have setup passwordless ssh on your system. If you want to use your current key (e.g., `ida_rsa`) on a different server, you can run the following commands:

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/ida_rsa
```

You can check [NPF README][npf-readme] file for more information.

### Data Plane Development Kit (DPDK)

We use [DPDK][dpdk-page] to bypass kernel network stack in order achieve line rate in our tests. To build DPDK, you can run the following commands. Note that Mellanox drivers (e.g., MLX5) is not enabled by default and you should enable them in `dpdk/config/common_base` file if you have Mellanox cards.

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

### Fastclick

We use [Fastclick][fastclick-repo] to generate and process packets. To build Fastclick, you can run the following commands. We have implemented a new element for Fastclick, called [DDIOTune][ddiotune-element], to enable/disable/tune DDIO. To use this element, you have to compile fastclick with `--enable-research` flag and install `libpci`.

```bash
git clone git@github.com:tbarbette/fastclick.git
cd fastclick
sudo apt-get install libpci-dev
./configure RTE_SDK=/home/alireza/ddio-bench/dpdk RTE_TARGET=x86_64-native-linux-gcc --enable-multithread --disable-linuxmodule --enable-intel-cpu --enable-user-multithread --verbose CFLAGS="-std=gnu11 -O3" CXXFLAGS="-std=gnu++14 -O3" --disable-dynamic-linking --enable-poll --enable-dpdk --disable-dpdk-pool --disable-dpdk-packet --enable-research
make
```

Note that you should change `RTE_SDK` and `RTE_TARGET` in the `configure` command.

### Intel Performance Counter Monitor (PCM) Tool

We use [PCM][pcm-page] tool to monitor the Intel performance counters introduced for PCIe. Specifially, we measure the `ItoM` and `PCIeRdCur` events via `pcm/pcm-pcie.x`, which shows the performance of DDIO. You can find more information about these events either in our paper or [here][pcie-events].

To build PCM tool, you can run the following commands.

```bash
git clone https://github.com/opcm/pcm.git
cd pcm
make
sudo make install
```

To check your installation, run `sudo pcm-pcie`.

### Intel Resource Director Technology (RDT) Software Package (intel-cmt-cat)

We use Intel [RDT][rdt-page] software package to configure Cache Allocation Technology (CAT), Memory Bandwidth Allocation (MBA), and measure per-core Last Level Cache (LLC) misses via `pqos` command. To setup `pqos`, you can run the following commands.

```bash
git clone https://github.com/intel/intel-cmt-cat.git
cd intel-cmt-cat
make
sudo make install
```

To check your installation, run `sudo pqos`. You can find more information about CAT and pqos in [intel-cmt-cat wiki][pqos-wiki].

### Other Configurations

Below, you can find some useful hints for optimizing your testbed.

- Isolating a CPU Socket: To have a more accurate measurement, we recommend you to isolate one CPU socket. By doing so, you ensure that operating system is not polluting your cache. To do so, you can add the following commands to the `GRUB` commandline in `/etc/default/grub`. To find the cores located on a CPU socket, you can use `lscpu` command.

```bash
GRUB_CMDLINE_LINUX="isolcpus=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17"
```

- Other commandlines: There are more options for the `GRUB_CMDLINE` to optimize your system. We used the followings:

```bash
GRUB_CMDLINE_LINUX="isolcpus=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 iommu=pt intel_iommu=on default_hugepagesz=1GB hugepagesz=1G hugepages=128 acpi=on selinux=0 audit=0 nosoftlockup processor.max_cstate=1 intel_idle.max_cstate=0 intel_pstate=on nopti nospec_store_bypass_disable nospectre_v2 nospectre_v1 nospec l1tf=off netcfg/do_not_use_netplan=true mitigations=off"
```

Note that you need to run `sudo update-grub` and reboot your system after changing `/etc/default/grub`.

- Disabling PAUSE frames: We disable PAUSE frames in our experiments, which will be done automatically by Fastclick. However, you can also enable/disable/check the status of PAUSE frames for every interface via `ethtool`.

```bash
ethtool -a enp23s0f0
sudo ethtool -A enp23s0f0 rx off tx off
```

It is possible to measure the number of PAUSE frames via `ethtool` and `dpdk`.

*ethtool: `sudo ethtool -S enp23s0f0 | grep pause_ctrl`. For more info, check [here][mlx5-counters].

*dpdk: You can read ethtool statistics in DPDK via `xstats` API. However, some of the Mellanox counters (e.g., `rx_pause_ctrl` and `tx_pause_ctrl`) are not available by default. To measure PAUSE frames via dpdk, you should add the counters to `static const struct mlx5_counter_ctrl mlx5_counters_init[]` located in `dpdk/drivers/net/mlx5/mlx5_stats.c`, as follows:

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

- Configuring Mellanox Cards: We set `CQE_COMPRESSION` to aggressive mode in order to save PCIe bandwidth in our experiments. To check the status of `CQE_COMPRESSION`, you can run the following commands.

```bash
sudo mst start
sudo mlxconfig -d /dev/mst/mt4119_pciconf0 q | grep CQE
```

To change its status, you can run `sudo mlxconfig -d /dev/mst/mt4119_pciconf0 set CQE_COMPRESSION=1`.

Note that you need to install Mellanox `OFED` and `MFT` before being able to run the mentioned commands. For more info, check the Mellanox manual for your NIC.

## Experiments

This repo is mainly focuses on the experiments performed in Section 4 and 5 of [DDIO paper][ddio-atc-paper].

The experiments are located at `experiments/`. Every folder has a `Makefile` and `README.md` that can be used to run the experiment.

For more information, please check [README](experiments/README.md).

## Tuning DDIO

You can use [DDIOTune][ddiotune-element] element in fastclick to enable/disable/tune DDIO. If you want to tune DDIO in a different context you can use the following guidelines.

- Tuning: Our experiments show that changing the values of `IIO LLC WAYS` register, located at `0xC8B`, could improve the performance of DDIO. The default value of this register in our testbed is `0x600`, which has 2 set bits. You can read the current value and write new values to this register via `msr-tools`, as follows:

```bash
sudo modprobe msr
sudo rdmsr 0xc8b
sudo wrmsr 0xc8b 0x7f0
```

- Disabling/Enabling DDIO: DDIO is enabled by default on Intel Xeon processors. DDIO can be disabled globally (i.e.,  by setting the `Disable_All_Allocating_Flows` bit in `iiomiscctrl` register) or per-root PCIe port (i.e., setting bit `NoSnoopOpWrEn` and unsetting bit `Use_Allocating_Flow_Wr` in `perfctrlsts_0` register).

`alter-ddio.c` provides a simple C program to change the state of DDIO for a PCIe port. To use `alter-ddio`, run the following commands:

```bash
sudo apt-get install libpci-dev
gcc alter-ddio.c -o alter-ddio -lpci
sudo ./alter-ddio
```

You can also check the implementation of [DDIOTune][ddiotune-cc] element in fastclick.

## Dynamic Burst Size Reduction

We have investigated the impact of dynamically reducing the number of RX descriptors in case of congestion in the TX path. Our implementation can be found at [DMAdynamic][dynamic-dma-branch] branch of fastclick.

If you want to try it, you have to compile fastclick with `--enable_dynamic_rxburst` flag.

## Citing our paper

If you use ddio-bench in any context, please cite our [paper][ddio-atc-paper]:

```bibtex
@inproceedings {farshin-ddio,
author = {Farshin, Alireza and Roozbeh, Amir and {Maguire Jr.}, Gerald Q. and Kosti\'{c}, Dejan},
title = {{Reexamining Direct Cache Access to Optimize I/O Intensive Applications for Multi-hundred-gigabit Networks}},
booktitle = {2020 {USENIX} Annual Technical Conference ({USENIX} {ATC} 20)},
year = {2020},
isbn = {},
address = {Boston, MA},
pages = {1--17},
url = {https://www.usenix.org/conference/atc20/presentation/farshin},
publisher = {{USENIX} Association},
month = jul,
}
```

## Getting Help

If you have any questions regarding our code or the paper, you can contact Alireza Farshin (farshin at kth.se) and/or Amir Roozbeh (amirrsk at kth.se).

[ddio-atc-paper]: https://people.kth.se/~farshin/documents/ddio-atc20.pdf
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
[mlx5-counters]: https://community.mellanox.com/s/article/understanding-mlx5-ethtool-counters
[dynamic-dma-branch]: https://github.com/tbarbette/fastclick/tree/DMAdynamic
