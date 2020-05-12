include ../includes/Makefile.includes

NPF_FLAGS := --force-retest --show-full


run:
	${NPF_PATH}/npf-run.py local --testie ./ddio-process-time.testie --cluster ${NPF_CLUSTER} --config graph_type=boxplot graph_y_group={result:all} --output --output-columns x all --max-results --graph-filename ddio-process-time-results.pdf --graph-size 10 5 --variable ${TOOLS_PATH}

force-run:
	${NPF_PATH}/npf-run.py local --testie ./ddio-process-time.testie --cluster ${NPF_CLUSTER} --config graph_type=boxplot graph_y_group={result:all} --output --output-columns x all --max-results --graph-filename ddio-process-time-results.pdf --graph-size 10 5 --variable ${TOOLS_PATH} ${NPF_FLAGS}

clean:
	rm -fr *.pdf ddio-process-time-results/ testie*/ 
	rm -fr results/