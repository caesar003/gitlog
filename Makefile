# Makefile for the gitlog project

# === SINGLE SOURCE OF TRUTH ===
# Define the project version here. All build processes will use this variable.
VERSION := 2.0.2

# Define source and staging directories
SRC_DIR := usr
DEBIAN_STAGING_DIR := debian/gitlog

# Define template and target files
MANPAGE_TEMPLATE := $(SRC_DIR)/share/man/man1/gitlog.1.template
MANPAGE_TARGET := $(SRC_DIR)/share/man/man1/gitlog.1
CONTROL_TEMPLATE := $(DEBIAN_STAGING_DIR)/DEBIAN/control.template
CONTROL_TARGET := $(DEBIAN_STAGING_DIR)/DEBIAN/control
CONSTANT_TEMPLATE := $(SRC_DIR)/lib/gitlog/constant.template
CONSTANT_TARGET := $(SRC_DIR)/lib/gitlog/constant

# Phony targets don't represent actual files
.PHONY: all build update-version sync-files package clean

# Default target when you just run `make`
all: build

# Main build target
build: update-version sync-files package
	@echo "----------------------------------------------------"
	@echo "Gitlog package build complete!"
	@echo "New package: gitlog_$(VERSION)_amd64.deb"
	@echo "----------------------------------------------------"

# This target updates the version number in all necessary files.
update-version: generate-manpage generate-control generate-constant
	@echo "--> Version update complete."

# Generate the actual manual page from template
generate-manpage:
	@echo "--> Generating manual page from template..."
	@if [ ! -f "$(MANPAGE_TEMPLATE)" ]; then \
		echo "Error: Template file $(MANPAGE_TEMPLATE) not found!"; \
		exit 1; \
	fi
	@cp "$(MANPAGE_TEMPLATE)" "$(MANPAGE_TARGET)"
	@sed -i 's/^\(\.TH GITLOG\.SH 1 "[^"]*" "Version \)0\.0\.0\("\)/\1$(VERSION)\2/' "$(MANPAGE_TARGET)"
	@echo "--> Manual page generated: $(MANPAGE_TARGET)"

# Generate the actual control file from template
generate-control:
	@echo "--> Generating control file from template..."
	@if [ ! -f "$(CONTROL_TEMPLATE)" ]; then \
		echo "Error: Template file $(CONTROL_TEMPLATE) not found!"; \
		exit 1; \
	fi
	@cp "$(CONTROL_TEMPLATE)" "$(CONTROL_TARGET)"
	@sed -i 's/^\(Version: \)0\.0\.0/\1$(VERSION)/' "$(CONTROL_TARGET)"
	@echo "--> Control file generated: $(CONTROL_TARGET)"

# Generate the actual constant file from template
generate-constant:
	@echo "--> Generating constant file from template..."
	@if [ ! -f "$(CONSTANT_TEMPLATE)" ]; then \
		echo "Error: Template file $(CONSTANT_TEMPLATE) not found!"; \
		exit 1; \
	fi
	@cp "$(CONSTANT_TEMPLATE)" "$(CONSTANT_TARGET)"
	@sed -i 's/^\(readonly VERSION="\)0\.0\.0\("\)/\1$(VERSION)\2/' "$(CONSTANT_TARGET)"
	@echo "--> Constant file generated: $(CONSTANT_TARGET)"

# This target syncs the development files to the debian staging directory.
# Using rsync is efficient as it only copies changed files.
sync-files:
	@echo "--> Syncing files from '$(SRC_DIR)' to '$(DEBIAN_STAGING_DIR)'..."
	@rsync -a --delete --exclude='*.template' $(SRC_DIR)/ $(DEBIAN_STAGING_DIR)/usr/
	@echo "--> Sync complete."

# This target builds the final .deb package.
package:
	@echo "--> Building the Debian package..."
	@dpkg-deb --build $(DEBIAN_STAGING_DIR) .
	@echo "--> Package built."

# Clean up build artifacts
clean:
	@echo "--> Cleaning up..."
	@rm -f gitlog_*.deb
	@rm -f "$(MANPAGE_TARGET)"
	@rm -f "$(CONTROL_TARGET)"
	@rm -f "$(CONSTANT_TARGET)"
	@echo "--> Cleanup complete."
