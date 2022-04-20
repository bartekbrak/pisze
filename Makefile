.PHONY: help mount umount install show stats save decode

help:
	@echo "encfs stores the files in .encrypted"
	@echo "don't put anything in .encrypted"
	@echo "put temp files in ."
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

mount: ## make "secret" folder available
	encfs --extpass='from_file_or_input /tmp/encfs.key' ~/pisze/.encrypted ~/pisze/secret -- -o nonempty

umount: ## finish working with files
	sudo umount ~/pisze/secret

install: ## get debian dependencies
	sudo apt-get install encfs tree pdfgrep
	mkdir -p secret .encrypted

show: ## display tree of files
	tree secret

stats: ## display stats
	@du -sh .encrypted .git
	@echo $$(git log | wc -l) commits

save: ## git commit and push
	git add .encrypted
	git commit -m "$$(date +%Y.%m.%d)"
	git push

decode: ## show what files were modified
# decode only accepts <100 args, https://github.com/vgough/encfs/issues/574
	@git status -s | grep .encrypted | sed -En 's,.*.encrypted/,,p' | xargs -n 90 encfsctl decode .encrypted --extpass='from_file_or_input /tmp/encfs.key' --
