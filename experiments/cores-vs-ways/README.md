# Cores vs. Ways Experiment

This experiment reproduces the results presented in Section 5.3 of [our paper][ddio-atc-paper]. The goal is to measure the performance of DDIO (i.e., PCIe read/write hit rate) while using different number of cores and/or different number of DDIO ways to forward packets.

`make run` runs these experiments. NPF automatically generates the output as CSVs and PDFs.

The output of the experiment should be similar to the following figure:

![sample](ddio-cores-vs-ways-sample.png "Cores vs. Ways Results")

[ddio-atc-paper]: https://www.usenix.org/conference/atc20/presentation/farshin