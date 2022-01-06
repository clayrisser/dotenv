# File: /main.mk
# Project: mkpm-dotenv
# File Created: 06-01-2022 03:18:08
# Author: Clay Risser
# -----
# Last Modified: 06-01-2022 03:21:39
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

-include $(MKPM_TMP)/env

EXAMPLE_ENV ?= $(PROJECT_ROOT)/example.env
DOTENV ?= $(PROJECT_ROOT)/.env

$(MKPM_TMP)/env: .env
	@$(MKDIR) -p $(@D)
	@$(CAT) $< | $(SED) 's|^#.*||g' | $(SED) '/^$$/d' | $(SED) 's|^|export |' > $@
$(DOTENV): $(EXAMPLE_ENV)
	@$(CP) $< $@