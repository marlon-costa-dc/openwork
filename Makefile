# OpenWork Local Installation Makefile
# Usage: make install / make uninstall / make update

PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
APPDIR = $(PREFIX)/share/applications
ICONDIR = $(PREFIX)/share/icons/hicolor/256x256/apps

.PHONY: all build install uninstall update clean

all: build

build:
	@echo ">>> Building OpenWork (release)..."
	cd packages/desktop && pnpm tauri build --no-bundle
	@echo ">>> Build complete!"

install: build
	@echo ">>> Installing OpenWork to $(PREFIX)..."
	@mkdir -p $(BINDIR) $(APPDIR) $(ICONDIR)
	
	# Install binary wrapper with WEBKIT fix
	@echo '#!/bin/bash' > $(BINDIR)/openwork
	@echo 'export WEBKIT_DISABLE_DMABUF_RENDERER=1' >> $(BINDIR)/openwork
	@echo 'exec "$(BINDIR)/openwork-bin" "$$@"' >> $(BINDIR)/openwork
	@chmod +x $(BINDIR)/openwork
	
	# Install actual binary
	@cp packages/desktop/src-tauri/target/release/openwork $(BINDIR)/openwork-bin
	@chmod +x $(BINDIR)/openwork-bin
	
	# Install icon
	@cp packages/app/public/icon.png $(ICONDIR)/openwork.png 2>/dev/null || \
		cp packages/desktop/src-tauri/icons/icon.png $(ICONDIR)/openwork.png 2>/dev/null || \
		echo "Warning: icon not found"
	
	# Install desktop entry
	@echo '[Desktop Entry]' > $(APPDIR)/openwork.desktop
	@echo 'Name=OpenWork' >> $(APPDIR)/openwork.desktop
	@echo 'Comment=Open-source alternative to Claude Cowork' >> $(APPDIR)/openwork.desktop
	@echo 'Exec=$(BINDIR)/openwork' >> $(APPDIR)/openwork.desktop
	@echo 'Icon=openwork' >> $(APPDIR)/openwork.desktop
	@echo 'Terminal=false' >> $(APPDIR)/openwork.desktop
	@echo 'Type=Application' >> $(APPDIR)/openwork.desktop
	@echo 'Categories=Development;IDE;' >> $(APPDIR)/openwork.desktop
	
	@echo ">>> OpenWork installed! Run 'openwork' to start."

uninstall:
	@echo ">>> Uninstalling OpenWork..."
	@rm -f $(BINDIR)/openwork $(BINDIR)/openwork-bin
	@rm -f $(APPDIR)/openwork.desktop
	@rm -f $(ICONDIR)/openwork.png
	@echo ">>> OpenWork uninstalled."

update:
	@echo ">>> Updating OpenWork..."
	git fetch origin dev
	git rebase origin/dev
	$(MAKE) install

clean:
	@echo ">>> Cleaning build artifacts..."
	cd packages/desktop/src-tauri && cargo clean
	@echo ">>> Clean complete."

deps:
	@echo ">>> Installing dependencies..."
	pnpm install
	@echo ">>> Dependencies installed."
