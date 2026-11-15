# Local build & test with GnuCOBOL - no mainframe needed.
#
#   make test     compile + run the unit tests
#   make clean    remove build artifacts
#
# Install the compiler once:  brew install gnucobol

COBC   = cobc
BUILD  = build

.PHONY: test run clean

test: $(BUILD)/testprice
	./$(BUILD)/testprice

# Run the whole pipeline locally (price -> report -> SAP extract)
run:
	./run-local.sh

$(BUILD)/testprice: tests/TESTPRICE.cbl order-pricing/PRICECAL.cbl
	mkdir -p $(BUILD)
	$(COBC) -x -o $@ tests/TESTPRICE.cbl order-pricing/PRICECAL.cbl

clean:
	rm -rf $(BUILD)
