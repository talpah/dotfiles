.PHONY: help install goodies uninstall update completions test lint clean

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make install      - Install dotfiles and essentials"
	@echo "  make goodies      - Install optional packages (Docker, gh, glab, brew tools)"
	@echo "  make uninstall    - Uninstall dotfiles"
	@echo "  make update       - Update oh-my-zsh, powerlevel10k and zsh plugins"
	@echo "  make completions  - Regenerate static zsh completions into zfunc/"
	@echo "  make test         - Run the full test suite"
	@echo "  make lint         - Run shellcheck only"
	@echo "  make clean        - Clean up backup files (destroys originals)"

install:
	@./install.sh

goodies:
	@./bin/install_goodies.sh

uninstall:
	@./uninstall.sh

update:
	@echo "Updating oh-my-zsh..."
	@git -C ~/.oh-my-zsh pull --quiet
	@echo "Updating powerlevel10k..."
	@git -C ~/.oh-my-zsh/custom/themes/powerlevel10k pull --quiet
	@for plugin in ~/.oh-my-zsh/custom/plugins/*/; do \
		if [ -d "$$plugin/.git" ]; then \
			echo "Updating $$(basename $$plugin)..."; \
			git -C "$$plugin" pull --quiet; \
		fi; \
	done
	@if command -v brew >/dev/null 2>&1; then \
		echo "Updating Homebrew tools..."; \
		brew update --quiet && brew upgrade --quiet; \
	fi
	@echo "Update complete!"

# Tools whose completions are static enough to cache on disk. Dynamic ones
# (uv, gh, glab) are evaluated at shell startup in zsh/30-tools.zsh instead.
completions:
	@mkdir -p zfunc
	@command -v ruff    >/dev/null 2>&1 && ruff generate-shell-completion zsh > zfunc/_ruff && echo "  ruff" || true
	@command -v rustup  >/dev/null 2>&1 && rustup completions zsh > zfunc/_rustup && echo "  rustup" || true
	@command -v docker  >/dev/null 2>&1 && docker completion zsh > zfunc/_docker 2>/dev/null && echo "  docker" || true
	@command -v k9s     >/dev/null 2>&1 && k9s completion zsh > zfunc/_k9s && echo "  k9s" || true
	@command -v kubectl >/dev/null 2>&1 && kubectl completion zsh > zfunc/_kubectl && echo "  kubectl" || true
	@echo "Completions written to zfunc/ (restart your shell to load them)"

test:
	@./test.sh

lint:
	@shellcheck -x install.sh uninstall.sh test.sh bin/*.sh

clean:
	@echo "This permanently deletes pre-install originals in backup/."
	@printf "Continue? (yes/no): " && read ans && [ "$$ans" = "yes" ] || exit 1
	@rm -rf backup/*
	@touch backup/.keep
	@echo "Clean complete!"
