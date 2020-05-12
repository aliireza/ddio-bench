# Processing Time Experiment

This experiment reproduces the results presented in Section 5.2 of [our paper][ddio-atc-paper]. The goal is to measure the performance of DDIO (i.e., PCIe read/write hit rate) while processing packets. We use fastclick's `WorkPackage` element to vary the amount of computation per packet by calling the `std::mt1993` random number generator multiple times, see [here][workpackage-wiki].

`make run` runs these experiments. NPF automatically generates the output as CSVs and PDFs.

The output of the experiment should be similar to the following figure:

![sample](ddio-process-time-sample-1.png "Processing Time Results - PCIe Write Hit Rate")

**Note that this figure is a streched version of the figure used in paper, as the processor is running at a higher frequency.**

[ddio-atc-paper]: https://people.kth.se/~farshin/documents/ddio-atc20.pdf
[workpackage-wiki]: https://github.com/tbarbette/fastclick/wiki/WorkPackage
