# Other Experiments

This file contains some information about the other experiments performed in [our paper][ddio-atc-paper].

## Generating IP Filter Rules

We generated IP filter rules with two different methods. To do so, you can use [GenerateIPFlowDispatcher][gen-ip-flows] element from [metron][metron-repo]. After generating the rules, you can install them on the NIC via Fastclick's `FromDPDKDevice` element. You should set the `MODE` to `flow_disp`, see [here][fromdpdkdevice-wiki].

You can also use `gen-flow-dispatcher-rules.click` written by [Georgios Katsikas][georgios-github].

## Benchmarking NVMe

We used `fio` for benchmarking NVMe. For more information, you can check [here][nvme-benchmark]. Additionally, we used [Google cloud guidelines][google-ssd] to create a logical volume from multiple SSD partitions.

[nvme-benchmark]: https://wiki.mikejung.biz/Benchmarking
[google-ssd]: https://cloud.google.com/compute/docs/disks/local-ssd

## Benchmarking Memcached

We used [Seastar][seastar-page] guidelines to benchmark their [Memcached][seastar-memcached] implementation.

[seastar-page]: http://seastar.io/
[seastar-memcached]: https://github.com/scylladb/seastar/wiki/Memcached-Benchmark

[ddio-atc-paper]: https://www.usenix.org/conference/atc20/presentation/farshin
[metron-repo]: https://github.com/tbarbette/fastclick/tree/metron
[fromdpdkdevice-wiki]: https://github.com/tbarbette/fastclick/wiki/FromDPDKDevice
[gen-ip-flows]: https://github.com/tbarbette/fastclick/blob/metron/elements/ip/generateipflowdispatcher.hh
[georgios-github]: https://github.com/gkatsikas
