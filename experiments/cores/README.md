# Cores Experiment

This experiment reproduces the results presented in Section 5.3 of [our paper][ddio-atc-paper]. The goal is to measure the performance of DDIO (i.e., PCIe read/write hit rate) while using different number of cores to forward packets.

`make run` runs these experiments. NPF automatically generates the output as CSVs and PDFs.

The output of the experiment should be similar to the following figure:

![sample](ddio-cores-sample.png "Cores Results")

[ddio-atc-paper]: https://people.kth.se/~farshin/documents/ddio-atc20.pdf