MODS_PATH=$(HOME)/.steam/steam/steamapps/compatdata/8930/pfx/drive_c/users/steamuser/Documents/My\ Games/Sid\ Meier\'s\ Civilization\ 5/MODS
VERSION=$(shell cat VERSION.txt)
MOD_ID=d278de45-2e03-45e2-9d3a-34fafa5c9ef6

output:
	mkdir -p ./output

output/GlobalFocus.modinfo: src/modinfo.xml output
	cp ./src/modinfo.xml ./output/GlobalFocus.modinfo
	sed \
		-e 's/\$$VERSION\$$/$(VERSION)/g' \
		-e 's/\$$MOD_ID\$$/$(MOD_ID)/g' \
		$< > $@

build: output/GlobalFocus.modinfo

install: build
	mkdir -p $(MODS_PATH)/GlobalFocus/
	cp ./output/* $(MODS_PATH)/GlobalFocus/

uninstall:
	rm -rf $(MODS_PATH)/GlobalFocus

clean:
	rm -rf ./output