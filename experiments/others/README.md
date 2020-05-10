# Other Experiment

This file contains some information about the other experiments performed in [our paper][ddio-atc-paper].

## Generating IP Filter Rules

We generated IP filter rules with two different methods. To do so, you can use [GenerateIPFlowDispatcher][gen-ip-flows] element from [metron][metron-repo].

You can also use `gen-flow-dispatcher-rules.click` written by [Georgios Katsikas][georgios-github].

## Benchmarking NVMe

We used `fio` for benchmarking NVMe. For more information, you can check [here][nvme-benchmark]

[nvme-benchmark]: https://wiki.mikejung.biz/Benchmarking

## Benchmarking Memcached

We used [Seastar][seastar-page] guidelines to benchmark their [Memcached][seastar-memcached] implementation.

[seastar-page]: http://seastar.io/
[seastar-memcached]: https://github.com/scylladb/seastar/wiki/Memcached-Benchmark

[ddio-atc-paper]: https://people.kth.se/~farshin/documents/ddio-atc20.pdf
[metron-repo]: https://github.com/tbarbette/fastclick/tree/metron
[gen-ip-flows]: https://github.com/tbarbette/fastclick/blob/metron/elements/ip/generateipflowdispatcher.hh
[georgios-github]: https://github.com/gkatsikas

