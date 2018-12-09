include .vars
export

define check_state
echo -e $(STATE_OK) || echo -e $(STATE_FAIL);\
cat $(ERR_FILE); \
rm -rf errors
endef

.PHONY: modules head

all: modules
	@echo "Добавляем основной код..."
	@echo -en "main.sh --> $(DIST_DIR)/$(END_SCRIPT)\t\t"
	@cat main.sh >> $(DIST_DIR)/$(END_SCRIPT) 2> $(ERR_FILE) && $(call check_state)
	@echo $(END_OF_TARGET)

modules: head
	@echo "Добавляем остальные модули"
	@for module in $(MODULES); do \
		echo -en "$$module --> $(DIST_DIR)/$(END_SCRIPT)\t"; \
		cat $$module >> $(DIST_DIR)/$(END_SCRIPT) 2> errors && $(call check_state);\
	done
	@echo $(END_OF_TARGET)	

head: clean 
	@echo "Добавляем заглавные модули"
	@for module in $(HEAD_FILES); do \
		echo -en "$$module --> $(DIST_DIR)/$(END_SCRIPT)\t";\
		cat $$module >> $(DIST_DIR)/$(END_SCRIPT) 2> errors && $(call check_state);\
	done
	@echo $(END_OF_TARGET)
clean:
	rm -rf $(DIST_DIR)/*
