# File: /main.mk
# Project: mkpm-dotenv
# File Created: 06-01-2022 03:18:08
# Author: Clay Risser
# -----
# Last Modified: 31-05-2022 11:25:48
# Modified By: Clay Risser
# -----
# Risser Labs LLC (c) Copyright 2021 - 2022
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

-include $(MKPM_TMP)/mkenv

DOTENV ?= $(CURDIR)/.env
DEFAULT_ENV ?= $(subst /.env,,$(DOTENV))/default.env

$(MKPM_TMP)/env: $(DOTENV)
	@$(MKDIR) -p $(@D)
	@$(CAT) $< | \
		$(SED) 's|^#.*||g' | \
		$(SED) '/^$$/d' | \
		$(SED) 's|^|export |' > $@
$(MKPM_TMP)/mkenv: $(MKPM_TMP)/env
	@$(MKDIR) -p $(@D)
	@. $(MKPM_TMP)/env && \
		for e in $$($(CAT) $< | $(SED) 's|^export \+\([^ =]\+\).*$$|\1|g'); do \
			eval "echo export $$e ?= \$$$$e"; \
		done > $@
ifneq (,$(wildcard $(DEFAULT_ENV)))
$(DOTENV): $(DEFAULT_ENV)
	@$(CP) $< $@
else
$(DOTENV):
	@$(TOUCH) -m $@
endif
