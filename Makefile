# Makefile for X-Plane MFD and Flight Calculators
# Supports both JSF-compliant and non-compliant versions

CXX = g++
# JSF-compliant flags: strict warnings, optimization, C++20
CXXFLAGS_COMPLIANT = -std=c++20 -O3 -Wall -Wextra -Wpedantic -Werror=return-type -Icompliant
# Non-compliant flags: standard C++20, less strict
CXXFLAGS_NON_COMPLIANT = -std=c++20 -O3 -Wall -Wextra

# Default to compliant version
CXXFLAGS = $(CXXFLAGS_COMPLIANT)
SRC_DIR = compliant

# Calculator names (built in root directory)
TARGETS = wind_calculator flight_calculator turn_calculator vnav_calculator density_altitude_calculator

.PHONY: all compliant non-compliant clean test run install-fonts jsf-check help switch-compliant switch-non-compliant

# Default target: build compliant version
all: compliant

# Build JSF-compliant version
compliant:
	@echo "========================================"
	@echo "Building JSF-COMPLIANT calculators"
	@echo "Source: compliant/"
	@echo "========================================"
	@$(MAKE) switch-compliant
	@$(MAKE) build-all SRC_DIR=compliant CXXFLAGS="$(CXXFLAGS_COMPLIANT)"
	@echo ""
	@echo "JSF-compliant calculators built successfully!"
	@echo "Run with: ./run_mfd.sh"

# Build non-compliant version
non-compliant:
	@echo "========================================"
	@echo "Building NON-COMPLIANT calculators"
	@echo "Source: non-compliant/"
	@echo "========================================"
	@$(MAKE) switch-non-compliant
	@$(MAKE) build-all SRC_DIR=non-compliant CXXFLAGS="$(CXXFLAGS_NON_COMPLIANT)"
	@echo ""
	@echo "Non-compliant calculators built successfully!"
	@echo "Run with: ./run_mfd.sh"

# Internal target to build all calculators from specified directory
build-all: wind_calculator flight_calculator turn_calculator vnav_calculator density_altitude_calculator

wind_calculator:
	@echo "Compiling wind calculator from $(SRC_DIR)..."
	$(CXX) $(CXXFLAGS) -o wind_calculator $(SRC_DIR)/wind_calculator.cpp
	@echo "✓ Wind calculator built!"

flight_calculator:
	@echo "Compiling flight calculator from $(SRC_DIR)..."
	$(CXX) $(CXXFLAGS) -o flight_calculator $(SRC_DIR)/flight_calculator.cpp
	@echo "✓ Flight calculator built!"

turn_calculator:
	@echo "Compiling turn calculator from $(SRC_DIR)..."
	$(CXX) $(CXXFLAGS) -o turn_calculator $(SRC_DIR)/turn_calculator.cpp
	@echo "✓ Turn calculator built!"

vnav_calculator:
	@echo "Compiling VNAV calculator from $(SRC_DIR)..."
	$(CXX) $(CXXFLAGS) -o vnav_calculator $(SRC_DIR)/vnav_calculator.cpp
	@echo "✓ VNAV calculator built!"

density_altitude_calculator:
	@echo "Compiling density altitude calculator from $(SRC_DIR)..."
	$(CXX) $(CXXFLAGS) -o density_altitude_calculator $(SRC_DIR)/density_altitude_calculator.cpp
	@echo "✓ Density altitude calculator built!"

# Create marker file to indicate which version is active
switch-compliant:
	@echo "compliant" > .active_version
	@echo "Switched to JSF-COMPLIANT version"

switch-non-compliant:
	@echo "non-compliant" > .active_version
	@echo "Switched to NON-COMPLIANT version"

clean:
	@echo "Cleaning build artifacts..."
	rm -f $(TARGETS)
	rm -f .active_version
	rm -rf __pycache__
	rm -f *.pyc
	@echo "Clean complete!"

test: $(TARGETS)
	@echo "Running calculator tests..."
	@./test_calculators.sh

install-fonts:
	@echo "Installing B612 Mono fonts..."
	@cp fonts/B612Mono-Regular.ttf ~/Library/Fonts/ 2>/dev/null || true
	@cp fonts/B612Mono-Bold.ttf ~/Library/Fonts/ 2>/dev/null || true
	@echo "Fonts installed!"

run: $(TARGETS)
	@echo "Launching X-Plane MFD..."
	@./run_mfd.sh

jsf-check:
	@echo "Checking JSF AV C++ Coding Standard compliance..."
	@if [ -f .active_version ] && [ "$$(cat .active_version)" = "compliant" ]; then \
		echo "✓ Currently using JSF-COMPLIANT version"; \
		echo "✓ AV Rule 208: No exceptions (throw/catch/try) used"; \
		echo "✓ AV Rule 209: Fixed-width types via jsf_types.h"; \
		echo "✓ AV Rule 206: No dynamic memory allocation"; \
		echo "✓ AV Rule 119: No recursion (binomial_coefficient is iterative)"; \
		echo "✓ AV Rule 113: Single exit points"; \
		echo "✓ AV Rule 157/204: No side effects in boolean operators"; \
		echo "All calculators are JSF-compliant!"; \
	else \
		echo "Currently using NON-COMPLIANT version"; \
		echo "To build compliant version: make compliant"; \
	fi

status:
	@echo "========================================"
	@echo "X-Plane Calculator Build Status"
	@echo "========================================"
	@if [ -f .active_version ]; then \
		VERSION=$$(cat .active_version); \
		echo "Active version: $$VERSION"; \
		echo "Source directory: $$VERSION/"; \
	else \
		echo "Active version: unknown (run 'make compliant' or 'make non-compliant')"; \
	fi
	@echo ""
	@echo "Built executables:"
	@for calc in $(TARGETS); do \
		if [ -f $$calc ]; then \
			echo "  ✓ $$calc"; \
		else \
			echo "  ✗ $$calc (not built)"; \
		fi \
	done

help:
	@echo "========================================"
	@echo "X-Plane MFD Makefile"
	@echo "JSF AV C++ Coding Standard Support"
	@echo "========================================"
	@echo ""
	@echo "Build Targets:"
	@echo "  make                    - Build JSF-compliant version (default)"
	@echo "  make compliant          - Build JSF-compliant calculators from compliant/"
	@echo "  make non-compliant      - Build non-compliant calculators from non-compliant/"
	@echo "  make clean              - Remove build artifacts"
	@echo ""
	@echo "Run Targets:"
	@echo "  make test               - Run calculator tests"
	@echo "  make run                - Build and launch MFD"
	@echo "  make status             - Show current build status"
	@echo ""
	@echo "Utility Targets:"
	@echo "  make install-fonts      - Install B612 Mono fonts"
	@echo "  make jsf-check          - Verify JSF compliance status"
	@echo "  make help               - Show this help"
	@echo ""
	@echo "Built executables (in root directory):"
	@echo "  • flight_calculator          - Comprehensive flight calculations"
	@echo "  • turn_calculator            - Turn performance calculations"
	@echo "  • vnav_calculator            - VNAV helpers (TOD, required VS)"
	@echo "  • density_altitude_calculator - Density altitude & performance"
	@echo "  • wind_calculator            - Wind vector calculations"
	@echo ""
	@echo "Source directories:"
	@echo "  • compliant/            - JSF AV C++ Standard compliant code"
	@echo "  • non-compliant/        - Original non-compliant code"
	@echo ""
	@echo "Examples:"
	@echo "  make compliant && make run    - Build compliant and run MFD"
	@echo "  make non-compliant && make test - Build non-compliant and test"
	@echo "========================================"

