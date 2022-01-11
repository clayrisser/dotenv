# File: /Makefile
# Project: mkpm-dotenv
# File Created: 06-01-2022 03:18:08
# Author: Clay Risser
# -----
# Last Modified: 11-01-2022 03:39:07
# Modified By: Clay Risser
# -----
# BitSpur Inc (c) Copyright 2021 - 2022
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include mkpm.mk
ifneq (,$(MKPM_READY))
include $(MKPM)/gnu
include main.mk

PACK_DIR := $(MKPM_TMP)/pack

.PHONY: info
info:
	@$(ECHO) DOTENV: $(DOTENV)
	@$(ECHO) DEFAULT_ENV: $(DEFAULT_ENV)

.PHONY: pack
pack:
	@rm -rf $(PACK_DIR) $(NOFAIL) && mkdir -p $(PACK_DIR)
	@cp main.mk $(PACK_DIR)
	@cp mkpm.mk $(PACK_DIR)
	@cp LICENSE $(PACK_DIR) $(NOFAIL)
	@for f in $(shell [ "$(MKPM_FILES_REGEX)" = "" ] || \
		$(FIND) . -type f -not -path './.git/*' | $(SED) 's|^\.\/||g' | \
		$(GREP) -E "$(MKPM_FILES_REGEX)") \
		$(shell $(GIT) ls-files | $(GREP) -E "^README[^\/]*$$"); do \
			PARENT_DIR=$$(echo $$f | $(SED) 's|[^\/]\+$$||g' | $(SED) 's|\/$$||g') && \
			([ "$$PARENT_DIR" != "" ] && mkdir -p $(PACK_DIR)/$$PARENT_DIR || true) && \
			cp $$f $(PACK_DIR)/$$f; \
		done
	@tar -cvzf $(MKPM_PKG_NAME).tar.gz -C $(PACK_DIR) .

.PHONY: publish
publish: pack

.PHONY: clean
clean:
	@$(MKCHAIN_CLEAN)
	@$(GIT) clean -fXd \
		$(MKPM_GIT_CLEAN_FLAGS)

.PHONY: purge
purge: clean
	@$(GIT) clean -fXd

endif
