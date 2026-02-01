# OpenWork Local Installation Makefile
# Usage: make install / make uninstall / make update

PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
APPDIR = $(PREFIX)/share/applications
ICONDIR = $(PREFIX)/share/icons/hicolor/256x256/apps

.PHONY: all build build-openwrk install uninstall update clean deps

all: build

build: build-openwrk
	@echo ">>> Building OpenWork desktop (release)..."
	cd packages/desktop && pnpm tauri build --no-bundle
	@echo ">>> Build complete!"

build-openwrk:
	@echo ">>> Building openwrk orchestrator..."
	cd packages/headless && pnpm build:bin
	@echo ">>> openwrk build complete!"

install: build
	@echo ">>> Installing OpenWork to $(PREFIX)..."
	@mkdir -p $(BINDIR) $(APPDIR) $(ICONDIR)
	
	# Install openwork wrapper with WEBKIT fix
	@echo '#!/bin/bash' > $(BINDIR)/openwork
	@echo 'export WEBKIT_DISABLE_DMABUF_RENDERER=1' >> $(BINDIR)/openwork
	@echo 'exec "$(BINDIR)/openwork-bin" "$$@"' >> $(BINDIR)/openwork
	@chmod +x $(BINDIR)/openwork
	
	# Install openwork binary
	@cp packages/desktop/src-tauri/target/release/openwork $(BINDIR)/openwork-bin
	@chmod +x $(BINDIR)/openwork-bin
	
	# Install openwrk orchestrator
	@cp packages/headless/dist/openwrk $(BINDIR)/openwrk
	@chmod +x $(BINDIR)/openwrk
	
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
	
	@echo ""
	@echo ">>> OpenWork installed!"
	@echo "    - openwork  (desktop app)"
	@echo "    - openwrk   (orchestrator CLI)"
	@echo ""
	@echo "Run 'openwork' to start."

uninstall:
	@echo ">>> Uninstalling OpenWork..."
	@rm -f $(BINDIR)/openwork $(BINDIR)/openwork-bin $(BINDIR)/openwrk
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
	rm -rf packages/headless/dist
	rm -rf packages/server/dist
	rm -rf packages/owpenbot/dist
	@echo ">>> Clean complete."

deps:
	@echo ">>> Installing dependencies..."
	pnpm install
	@echo ">>> Dependencies installed."
