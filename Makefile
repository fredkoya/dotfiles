.PHONY: install
install:
	@sudo true
	./install.sh

MISE_MIN_VERSION := 2026.7.7

.PHONY: mise-gate
mise-gate:
	@command -v mise >/dev/null || brew install mise
	@cur="$$(mise --version | awk '{print $$1}')"; \
	if [ "$$(/usr/bin/printf '%s\n%s\n' "$(MISE_MIN_VERSION)" "$$cur" | /usr/bin/sort -V | /usr/bin/head -n1)" != "$(MISE_MIN_VERSION)" ]; then \
		echo "mise $$cur < $(MISE_MIN_VERSION); upgrading via brew..."; \
		PATH="/usr/bin:$$PATH" NONINTERACTIVE=1 brew update && PATH="/usr/bin:$$PATH" NONINTERACTIVE=1 brew upgrade mise; \
	fi
	@mise --version
	@mise -C "$(CURDIR)" trust

.PHONY: mise
mise: mise-gate
	mise -C "$(CURDIR)" bootstrap --yes
