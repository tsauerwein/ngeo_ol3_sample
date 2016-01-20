OL_JS_FILES = $(shell find node_modules/openlayers/src/ol -type f -name '*.js' 2> /dev/null)
NGEO_JS_FILES = $(shell find node_modules/ngeo/src -type f -name '*.js' 2> /dev/null)
APP_JS_FILES = $(shell find src -type f -name '*.js')

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo
	@echo "Main targets:"
	@echo
	@echo "- build               Compile the application"
	@echo "- clean               Remove generated files"
	@echo "- cleanall            Remove all the build artefacts"
	@echo "- install             Install and build the project"
	@echo "- serve               Run the development server"
	@echo "- update-node-modules Update node modules (using --force)"
	@echo

.PHONY: build
build: .build/dist/app.js .build/dist/index.html

.PHONY: clean
clean:
	rm -f .build/node_modules.timestamp
	rm -rf .build/dist

.PHONY: cleanall
cleanall: clean
	rm -rf .build
	rm -rf node_modules

.PHONY: install
install: build .build/node_modules.timestamp

.PHONY: serve
serve: install build
	./node_modules/.bin/closure-util serve app.json

.PHONY: update-node-modules
update-node-modules:
	npm install --force

.build/dist/app.js: app.json $(OL_JS_FILES) $(NGEO_JS_FILES) $(APP_JS_FILES) .build/externs/angular-1.4.js .build/externs/angular-1.4-q_templated.js .build/externs/angular-1.4-http-promise_templated.js .build/externs/jquery-1.9.js .build/node_modules.timestamp
	mkdir -p $(dir $@)
	./node_modules/.bin/closure-util build $< $@

.build/dist/index.html: index.html
	mkdir -p $(dir $@)
	sed -e 's|node_modules/openlayers/css/ol.css|../../node_modules/openlayers/css/ol.css|' \
		-e 's|node_modules/angular/angular.js|../../node_modules/angular/angular.min.js|' \
		-e 's|@?main=.*.js|app.js|'  $< > $@

.build/externs/angular-1.4.js:
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/angular-1.4.js
	touch $@

.build/externs/angular-1.4-q_templated.js:
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/angular-1.4-q_templated.js
	touch $@

.build/externs/angular-1.4-http-promise_templated.js:
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/angular-1.4-http-promise_templated.js
	touch $@

.build/externs/jquery-1.9.js:
	mkdir -p $(dir $@)
	wget -O $@ https://raw.githubusercontent.com/google/closure-compiler/master/contrib/externs/jquery-1.9.js
	touch $@

.build/node_modules.timestamp: package.json
	mkdir -p $(dir $@)
	npm install
	touch $@
