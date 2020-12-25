# ddio-bench: Understanding Intel Data Direct I/O Technology

This repository contains information/source code to perform the experiments done in [DDIO paper][ddio-atc-paper] published at [ATC'20][atc20-page].

## Experiments

This repositoy mainly focuses on the experiments performed in Section 4 and 5 of [DDIO paper][ddio-atc-paper].

The experiments are located at `experiments/`. Every folder has a `Makefile` and `README.md` that can be used to run the experiment.

For more information, please check [README](experiments/README.md).

**Note that you have to setup your testbed based on [our guidelines](TESTBED.md) before running any experiment.**

## Tuning DDIO

You can use [DDIOTune][ddiotune-element] element in Fastclick to enable/disable/tune DDIO. If you want to tune DDIO in a different context, you can use the following guidelines.

- **Tuning**: Our experiments show that changing the values of `IIO LLC WAYS` register, located at `0xC8B`, could improve the performance of DDIO. The default value of this register in our testbed is `0x600`, which has 2 set bits. You can read the current value and write new values to this register via `msr-tools`, as follows:

```bash
sudo apt-get install msr-tools
sudo modprobe msr
sudo rdmsr 0xc8b
sudo wrmsr 0xc8b 0x7f0
```

- **Disabling/Enabling DDIO**: DDIO is enabled by default on Intel Xeon processors. DDIO can be disabled globally (i.e.,  by setting the `Disable_All_Allocating_Flows` bit in `iiomiscctrl` register) or per-root PCIe port (i.e., setting bit `NoSnoopOpWrEn` and unsetting bit `Use_Allocating_Flow_Wr` in `perfctrlsts_0` register). You can find more information about these registers in the second volume of your processor's datasheet. For instance, you can check [Haswell][haswell-datasheet] and [Cascade Lake][cascade-datasheet] datasheets.

`change-ddio.c` is a simple C program to change the state of DDIO for a PCIe port. To use `change-ddio`, run the following commands:

```bash
sudo apt-get install libpci-dev
gcc change-ddio.c -o change-ddio -lpci
sudo ./change-ddio
```

You need to define the proper value for **nic_bus** and **ddio_state** in the code. For example, if you have a NIC that is mounted on `03:00.0`, you should change **nic_bus** to `0x03`. **ddio_state=0** will disable the DDIO for the PCIe root responsible for that specific NIC.

You can find the PCIe BDF (Bus Device Function) of your NIC via `lspci`, e.g., try `lspci -vvv | grep Mellanox` if you have a Mellanox card. 

You can also check the implementation of [DDIOTune][ddiotune-cc] element in Fastclick.

## Dynamic Burst Size Reduction

We have investigated the impact of dynamically reducing the number of RX descriptors in case of congestion in the TX path. Our implementation can be found at [DMAdynamic][dynamic-dma-branch] branch of Fastclick.

If you want to try it, you have to compile Fastclick with `--enable_dynamic_rxburst` flag.

## Citing our paper

If you use ddio-bench in any context, please cite our [paper][ddio-atc-paper]:

```bibtex
@inproceedings {farshin-ddio,
author = {Farshin, Alireza and Roozbeh, Amir and {Maguire Jr.}, Gerald Q. and Kosti\'{c}, Dejan},
title = {{Reexamining Direct Cache Access to Optimize I/O Intensive Applications for Multi-hundred-gigabit Networks}},
booktitle = {2020 {USENIX} Annual Technical Conference ({USENIX} {ATC} 20)},
year = {2020},
isbn = {978-1-939133-14-4},
pages = {673--689},
url = {https://www.usenix.org/conference/atc20/presentation/farshin},
publisher = {{USENIX} Association},
month = jul,
}
```

## Getting Help

If you have any questions regarding our code or the paper, you can contact [Alireza Farshin][alireza-page] (farshin at kth.se) and/or [Amir Roozbeh][amir-page] (amirrsk at kth.se).

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
[mlx5-counters]: https://community.mellanox.com/s/article/understanding-mlx5-ethtool-counters
[haswell-datasheet]: https://www.intel.com/content/dam/www/public/us/en/documents/datasheets/xeon-e5-v2-datasheet-vol-2.pdf
[cascade-datasheet]: https://www.intel.com/content/www/us/en/products/docs/processors/xeon/2nd-gen-xeon-scalable-datasheet-vol-2.html
[dynamic-dma-branch]: https://github.com/tbarbette/fastclick/tree/DMAdynamic
[alireza-page]: https://www.kth.se/profile/farshin
[amir-page]: https://www.kth.se/profile/amirrsk
