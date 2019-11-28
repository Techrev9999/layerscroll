SUBDIRS := src

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
