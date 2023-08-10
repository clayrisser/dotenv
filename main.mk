# File: /main.mk
# Project: mkpm-dotenv
# File Created: 06-01-2022 03:18:08
# Author: Clay Risser
# -----
# Last Modified: 10-08-2023 14:47:45
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

DOTENV ?= $(CURDIR)/.env
DEFAULT_ENV ?= $(subst /.env,,$(DOTENV))/default.env
_DOTENV_SUBPATH := dotenv$(subst $(PROJECT_ROOT),,$(CURDIR))

ifneq (dotenv,$(_DOTENV_SUBPATH))
ifeq (,$(wildcard $(DEFAULT_ENV)))
ifeq (,$(wildcard $(DOTENV)))
DOTENV := $(PROJECT_ROOT)/.env
DEFAULT_ENV := $(subst /.env,,$(DOTENV))/default.env
_DOTENV_SUBPATH := dotenv
endif
endif
endif

$(MKPM_TMP)/$(_DOTENV_SUBPATH)/env: $(DOTENV)
	@$(MKDIR) -p $(@D)
	@$(AWK) -F= ' \
		BEGIN { inMultiline=0; quoteType="" } \
		/^[[:space:]]*#/ || /^[[:space:]]*$$/ { print; next } \
		inMultiline && $$0 ~ quoteType "$$" { print; inMultiline=0; next } \
		inMultiline { print; next } \
		($$2 ~ /^"[^"]*$$/) || ($$2 ~ /^'\''[^'\'']*$$/) { \
			print "export " $$0; \
			inMultiline=1; \
			quoteType = substr($$2, 1, 1); \
			next \
		} \
		{ print "export " $$0 }' $< > $@

$(MKPM_TMP)/$(_DOTENV_SUBPATH)/mkenv: $(MKPM_TMP)/$(_DOTENV_SUBPATH)/env
	@$(MKDIR) -p $(@D)
	@$(RM) $@
	@. $< && \
		for e in $$($(CAT) $< | $(GREP) -oE '^export +[^=]+' | sed 's|^export \+||g'); do \
			echo "define $$e" && \
			eval "echo \"\$$$$e\"" && \
			echo endef && echo; \
		done > $@

ifneq (,$(wildcard $(DEFAULT_ENV)))
$(DOTENV): $(DEFAULT_ENV)
	@if [ ! -f "$@" ] || [ "$<" -nt "$@" ]; then \
		$(CP) $< $@; \
	fi
else
$(DOTENV):
	@$(TOUCH) -m $@
endif

-include $(MKPM_TMP)/$(_DOTENV_SUBPATH)/mkenv
