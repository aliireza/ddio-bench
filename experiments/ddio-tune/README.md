# DDIOTune Experiment

This experiment reproduces the results presented in Section 4.4 of [our paper][ddio-atc-paper]. The goal is to see the impact of tuning `IIO LLC WAYS` registers on the performance of DDIO (i.e., PCIe read/write hit rate).

`make run` runs these experiments. NPF automatically generates the output as CSVs and PDFs.

The output of the experiment should be similar to the following figure:

![sample](ddiotune-sample.png "DDIOTune Results")

[ddio-atc-paper]: https://people.kth.se/~farshin/documents/ddio-atc20.pdf
