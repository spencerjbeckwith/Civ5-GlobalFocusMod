MODS_PATH=$(HOME)/.steam/steam/steamapps/compatdata/8930/pfx/drive_c/users/steamuser/Documents/My\ Games/Sid\ Meier\'s\ Civilization\ 5/MODS
VERSION=$(shell cat VERSION.txt)
MOD_ID=d278de45-2e03-45e2-9d3a-34fafa5c9ef6

.PHONY: uninstall clean

output:
	mkdir -p ./output

output/GlobalFocus.lua: src/GlobalFocus.lua output
	cp ./src/GlobalFocus.lua ./output/GlobalFocus.lua

output/GlobalFocus.xml: src/GlobalFocus.xml output
	cp ./src/GlobalFocus.xml ./output/GlobalFocus.xml

output/GlobalFocusText.xml: src/GlobalFocusText.xml output
	cp ./src/GlobalFocusText.xml ./output/GlobalFocusText.xml

output/GlobalFocus.modinfo: src/modinfo.xml output/GlobalFocus.lua output/GlobalFocus.xml output/GlobalFocusText.xml
	cp ./src/modinfo.xml ./output/GlobalFocus.modinfo
	sed \
		-e 's/\$$VERSION\$$/$(VERSION)/g' \
		-e 's/\$$MOD_ID\$$/$(MOD_ID)/g' \
		-e 's/\$$GF_LUA_MD5\$$/$(shell cat ./src/GlobalFocus.lua | md5sum -z | cut -d' ' -f1 -z | tr '[:lower:]' '[:upper:]')/g' \
		-e 's/\$$GF_XML_MD5\$$/$(shell cat ./src/GlobalFocus.xml | md5sum -z | cut -d' ' -f1 -z | tr '[:lower:]' '[:upper:]')/g' \
		-e 's/\$$GF_TEXT_MD5\$$/$(shell cat ./src/GlobalFocusText.xml | md5sum -z | cut -d' ' -f1 -z | tr '[:lower:]' '[:upper:]')/g' \
		$< > $@

build: output/GlobalFocus.modinfo

install: build
	mkdir -p $(MODS_PATH)/GlobalFocus/
	cp ./output/* $(MODS_PATH)/GlobalFocus/

uninstall:
	rm -rf $(MODS_PATH)/GlobalFocus

clean:
	rm -rf ./output