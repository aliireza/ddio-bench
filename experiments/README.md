# Experiments

This folder contains the following experiments:

- `splash`: Finds the LLC ways used by DDIO and measures the contention caused by overlapping an application with DDIO ways.
- `ddio-tune`: Measures the impact of tuning `IIO LLC WAYS` register on the performance of DDIO.

- `pktsize-desc`: Measures the impact of different packet sizes and different number of RX descriptors on the performance of DDIO.

- `pkt-rate`: Measures the impact of changing the packet rate on the performance of DDIO.

- `process-time`: Measures the impact of changing the processing time on the performance of DDIO.

- `cores`: Measures the impact of using different number of cores on the performance of DDIO.

- `cores-vs-ways`: Compares the performance of DDIO while tuning DDIO ways and using different number of cores.

- `freq`: Compares the performance of DDIO while changing the uncore frequency.

- `others`: Contains information for reproducing other experiments done in our paper.

**Before running any experiment, you should define variables in `includes/Makefile.includes` according to your testbed.**

We assume that you are using one NIC to receive and transmit packets (i.e., `RCV_NIC=0` and `SND_NIC=0`). You can change this in the testie files.

Check the `README` inside each folder for more details.

- `make run` runs the experiment in the quiet mode.
- `make force-run` ignores the current results and runs the experiment. It also prints the output of every script. If you want to re-run an experiment, but not ignoring the current results, you can modify the `Makefile`. To do so, you can change `--force-retest` to `--no-test` in the `NPF_FLAGS`.
- NPF automatically generates the output as CSVs and PDFs. However, you can use your favorite plotting tool to replot the results. You can add `--pandas [PATH]` flag to `NPF_FLAGS` to get a Pandas dataframe for an experiment, see [here][npf-output].

You can measure different metrics and design your custom experiments by changing the `testie` files inside each folder. To measure new variables (e.g., `new-var`), you have to print them as `RESULTS-new-var`.

**Note that the available results for each experiment are a bit different from the results provided in our paper, due to the change in our processor's frequency. The DUT's processor is running at 3 GHz rather than 2.3 GHz. However, they are still conveying the same message, as described in [our paper][ddio-atc-paper]. To change/check the processors' frequency, see [here](../TESTBED.md)**

[ddio-atc-paper]: https://www.usenix.org/conference/atc20/presentation/farshin
[npf-output]: https://github.com/tbarbette/npf#output
