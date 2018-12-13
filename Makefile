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
		cat $$module | grep -v "# \|#!" >> $(DIST_DIR)/$(END_SCRIPT) 2> errors && $(call check_state);\
	done
	@echo $(END_OF_TARGET)	

head: test clean
	@echo "Добавляем заглавные модули"
	@echo "#!$(WRAPPER)" >> $(DIST_DIR)/$(END_SCRIPT)
	@for module in $(HEAD_FILES); do \
		echo -en "$$module --> $(DIST_DIR)/$(END_SCRIPT)\t";\
		cat $$module | grep -v "# \|#!" >> $(DIST_DIR)/$(END_SCRIPT) 2> errors && $(call check_state);\
	done
	@echo $(END_OF_TARGET)

test:
	@bats -v &>/dev/null; \
	if [ $$? -eq 0 ]; then \
		echo -e "\e[32mЗапускаем тесты...\e[0m"; \
		bats $(MOD_DIR); \
	else \
		echo -e "\e[32mУстанавливаем bats. Может потребоваться ввод пароля.\e[0m"; \
		git clone https://github.com/sstephenson/bats.git; \
		sudo bats/install.sh /usr/local; \
		rm -rf bats; \
		$(MAKE) test; \
	fi;
	
clean:
	rm -rf $(DIST_DIR)/*
