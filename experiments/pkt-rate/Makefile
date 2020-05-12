include ../includes/Makefile.includes

NPF_FLAGS := --force-retest --show-full


generate:
	${NPF_PATH}/npf-run.py local --testie ./ddio-pcap-gen.testie --cluster ${NPF_CLUSTER} --variable ${TOOLS_PATH} ${NPF_FLAGS}

run:
	${NPF_PATH}/npf-run.py local --testie ./ddio-pkt-rate.testie --cluster ${NPF_CLUSTER} --config graph_type=boxplot graph_y_group={result:all} --output --output-columns x all --max-results --graph-filename ddio-pkt-rate-results.pdf --graph-size 10 5 --variable ${TOOLS_PATH}

force-run:
	${NPF_PATH}/npf-run.py local --testie ./ddio-pkt-rate.testie --cluster ${NPF_CLUSTER} --config graph_type=boxplot graph_y_group={result:all} --output --output-columns x all --max-results --graph-filename ddio-pkt-rate-results.pdf --graph-size 10 5 --variable ${TOOLS_PATH} ${NPF_FLAGS}

clean:
	rm -fr *.pdf ddio-pkt-rate-results/ testie*/ 
	rm -fr results/