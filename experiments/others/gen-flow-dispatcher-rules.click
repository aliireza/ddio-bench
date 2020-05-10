/**
 * Generate DPDK Flow API rules out of a trace.
 * Before dumping the rules, the script changes the packets' Ethernet addresses
 * according to the respective variables in order to fit your needs.
 *
 * Copyright (c) 2020, Georgios Katsikas, KTH Royal Institute of Technology - All Rights Reserved
 */

// sudo bin/click --dpdk -l 0-0  --socket-mem 62,2 --huge-dir /mnt/hugepages -v -- gen-flow-dispatcher-rules.click queuesNb=16 rulesNb=3800 allocPolicy=load_aware

////////////////////////////////////////////////////////////
// Testbed configuration
////////////////////////////////////////////////////////////
define(
	$trace     /mnt/traces/INfull_64.pcap,
	$inSrcMac  ae:aa:aa:65:dd:2b,
	$inDstMac  ae:aa:aa:02:27:a6,

	$inPort    0,
	$ignore    0,
	$rulesNb   5000,
	$queuesNb  16
);

d :: DPDKInfo(NB_SOCKET_MBUF 14008256, NB_SOCKET_MBUF 8192);

fdIN :: FromDump($trace, STOP true, TIMING false);

fdIN
	-> rwIN :: EtherRewrite($inSrcMac, $inDstMac)
	-> avgSIN :: AverageCounter(IGNORE $ignore)
	-> Strip(14)
	-> CheckIPHeader
	-> ruleGen :: GenerateIPFlowDispatcher(PORT $inPort, NB_QUEUES $queuesNb, NB_RULES $rulesNb, KEEP_SPORT false, KEEP_DPORT false)
	-> Discard;

DriverManager(
	pause,
	print "Finished with $(avgSIN.count) input packets",
	print "",
	print "Rules from trace:",
	print $(ruleGen.dump),
	print $(ruleGen.stats),

	stop
);
