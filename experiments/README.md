# Experiments

This folder contains the following experiments:

- `splash`: Finds the LLC ways used by DDIO and measures the contention caused by overlapping an application with DDIO ways.
- `ddio-tune`: Measures the impact of tuning `IIO LLC WAYS` register on the performance of DDIO.

- `pktsize-desc`: Measures the impact of different packet sizes and different number of RX descriptros on the performance of DDIO.

- `pkt-rate`: Measures the impact of changing the packet rate on the performance of DDIO.

- `process-time`: Measures the impact of changing the processing time on the performance of DDIO.

- `cores`: Measures the impact of using different number of cores on the performance of DDIO.

- `cores-vs-ddio-ways`: Compares the performance of DDIO while tuning DDIO ways and using different number of cores.

- `others`: Contains information for reproducing other experiments done in our paper.

**Before running any experiment, you should define variables in `includes/Makefile.includes` according to your testbed.**

Check the `README` inside each folder for more details.

You can measure different metrics and design your custom experiments by changeing the `testie` files inside each folder. To measure new variables (e.g., `new-var`), you have to print them as `RESULTS-new-var`.

[ddio-atc-paper]: https://people.kth.se/~farshin/documents/ddio-atc20.pdf
