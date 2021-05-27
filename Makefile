#!make

# Copyright (c) 2021 Romullo @hiukky.

# This file is part of FlateOS
# (see https://github.com/flateos).

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

include .env
export

# @name: exec
# @desc: Executes a command in the defined environment.
define exec
	docker exec -it flateos $(1)
endef

# @name: get_manifest_url
# @desc: Obtains project URL for the specified protocol.
define get_manifest_url
    $(shell [[ $(OPT__USE_SSH) == true ]] \
	&& echo "git@github.com:flateos/manifest.git" \
	|| echo "https://github.com/flateos/manifest.git")
endef

# @name: up
# @desc: Sets up the building environment.
up:
	@docker-compose up -d

# @name: sync
# @desc: Synchronizes all source code needed for construction.
sync:
	repo init -u $(call get_manifest_url) -b main && repo sync

# @name: up
# @desc: Provides development environment.
provision:
	@$(call exec, ansible-playbook flate.yml)

# @name: build
# @desc: Build ISO for FlateOS.
build:
	@$(call exec, sudo mkarchiso -v -w $(ISO__TMPDIR) -g ${GPG__KEY_ID} \
	-P '${GPG__NAME} ${GPG__MAIL}' -o $(ISO__DIST) ./platform)

# @name: clean
# @desc: Clean the work directory.
clean:
	@$(call exec, sudo rm -rf $(ISO__TMPDIR) $(ISO__DIST))

# @name: space
# @desc: Compile and update local packages.
space:
	@$(call exec, sudo -u flate ./space/space.sh $(PKGS))

.PHONY: up sync provision build clean space
