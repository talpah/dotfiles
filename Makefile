.PHONY: help install goodies uninstall update test clean

help:
	@echo "Dotfiles Management"
	@echo ""
	@echo "Usage:"
	@echo "  make install    - Install dotfiles and essentials"
	@echo "  make goodies    - Install optional packages (Docker, gh, glab, etc.)"
	@echo "  make uninstall  - Uninstall dotfiles"
	@echo "  make update     - Update oh-my-zsh and powerlevel10k"
	@echo "  make test       - Run shellcheck on all scripts"
	@echo "  make clean      - Clean up backup files"

install:
	@./install.sh

goodies:
	@./bin/install_goodies.sh

uninstall:
	@./uninstall.sh

update:
	@echo "Updating oh-my-zsh..."
	@cd ~/.oh-my-zsh && git pull --quiet
	@echo "Updating powerlevel10k..."
	@cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull --quiet
	@echo "Update complete!"

test:
	@./test.sh

clean:
	@echo "Cleaning backup directory..."
	@rm -rf backup/*
	@touch backup/.keep
	@echo "Clean complete!"
