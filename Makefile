ns = app
dto_prefix = app
use_worker = true
locale = en
build_dir = build
autogen_dir = $(build_dir)/gen
i18n_dir = $(build_dir)/i18n/$(locale)
translation_file = $(i18n_dir)/translation.xlf
template_build_dir = $(build_dir)/tpl/$(locale)
css_file = $(build_dir)/$(ns).css
css_build_file = $(build_dir)/$(ns).build.css
css_min_file = $(build_dir)/$(ns).min.css
css_debug_file = $(build_dir)/$(ns).debug.css
js_min_file = $(build_dir)/$(ns).min.js
js_debug_file = $(build_dir)/$(ns).debug.js
manifest = $(build_dir)/$(ns).filelist.txt
modules_manifest = $(build_dir)/modulesfilelist.txt
pstj_lib_dir = ../pstj
smjs_lib_dir = ../smjs
schema_dir = schema
jssource_dir = js $(autogen_dir) $(template_build_dir)
debug = true

# Setup shell as it is not bash in Ubuntu...
SHELL=/bin/bash

# Used by depswriter
python = python2
closure_library_root = ../../library
closure_library_bin = $(closure_library_root)/closure/bin
calcdeps = $(closure_library_bin)/calcdeps.py
closure_depswriter = $(closure_library_bin)/build/depswriter.py
closure_depsfile = $(build_dir)/deps.js
modules_depsfile = $(build_dir)/moddeps.js
library_relative_path = ../../../
apps_dir = apps
this_dir = $(shell basename `pwd`)
sed_tokenizer = [^ ]*
sed_jsifier = &/*.js &/*/*.js
sed_unglob = 's+ [^ ]*\*[^ ]*++g'
sed_deps_subst = --root_with_prefix=&\\ $(library_relative_path)$(apps_dir)/$(this_dir)/&

# used by templates
java = java -jar
soy_source_dirs = templates $(pstj_lib_dir)/templates
soy_compiler = ../../templates/SoyToJsSrcCompiler.jar
soy_message_extractor = ../../templates/SoyMsgExtractor.jar
soy_compiler_options = \
	--locales $(locale) \
	--messageFilePathFormat "$(translation_file)" \
	--shouldProvideRequireSoyNamespaces \
	--shouldGenerateJsdoc \
	--outputPathFormat '$(template_build_dir)/{INPUT_FILE_NAME_NO_EXT}.soy.js'

#used by css/less/closure style sheet
gss_ini = $(shell if [ -f options/$(ns).css.ini ] ; then cat options/$(ns).css.ini ; else cat options/css.ini ; fi | tr '\n' ' ')
gss_compiler = ../../stylesheets/closure-stylesheets.jar

# used by jscompiler
js_compiler = ../../compiler/compiler.jar
pstj_public_source_dirs := \
animation \
app \
autogenerated \
cast \
color \
config \
control \
date \
debug \
ds \
element \
error \
fx \
graphics \
material \
math \
mvc \
ng \
object \
options \
resource \
sourcegen \
storage \
style \
themes \
ui \
worker
compiler_js_sources = \
		$(shell echo $(jssource_dir) | sed 's+$(sed_tokenizer)+--js="./&/**.js"+g') \
		$(shell echo $(pstj_public_source_dirs) | sed 's+$(sed_tokenizer)+--js="$(pstj_lib_dir)/&/**.js"+g') \
		--js="../../templates/soyutils_usegoog.js" \
		--js="$(closure_library_root)/closure/goog/**.js" \
		--js="$(closure_library_root)/third_party/closure/goog/mochikit/async/deferred.js" \
		--js="$(closure_library_root)/third_party/closure/goog/mochikit/async/deferredlist.js" \
		--js="!**_test.js"
build_js_compiler_option = \
		--charset=UTF-8 \
		--dependency_mode=STRICT \
		--entry_point=goog:$(ns) \
		--define='goog.LOCALE="$(locale)"' \
		--define='goog.DEBUG=$(debug)' \
		--process_closure_primitives \
		--use_types_for_optimization \
		--warning_level=VERBOSE
namespace_specific_flags = $(shell if [ -f options/$(ns).externs.ini ] ; then cat options/$(ns).externs.ini ; else cat options/externs.ini ; fi | tr '\n' ' ')
calcdeps_paths = \
$(shell echo $(jssource_dir) | sed 's+$(sed_tokenizer)+--path ./&+g') \
$(shell echo $(pstj_public_source_dirs) | sed 's+$(sed_tokenizer)+--path $(pstj_lib_dir)/&+g') \
--path ../../templates/ \
--path $(closure_library_root)/closure/goog \
--path $(closure_library_root)/third_party/closure/goog

# Recepies
all: builddirectories \
	soymessages soytemplates jsdependencies \
	lessc css cssmin \
	jsfilelist jsmin
	@if $(use_worker); then \
		make jsfilelist ns=worker; \
		make jsworker ns=worker; \
	fi

worker: builddirectories schemes
	make jsfilelist ns=worker
	make jsworker ns=worker

builddirectories:
	mkdir -p $(autogen_dir)
	mkdir -p $(i18n_dir)
	mkdir -p $(template_build_dir)

schemes:
	node $(pstj_lib_dir)/nodejs/dtogen.js $(dto_prefix).gen.dto $(schema_dir)/ $(autogen_dir)/

soymessages:
	$(java) $(soy_message_extractor) \
      --outputFile $(translation_file) \
      --targetLocaleString $(locale) \
      $(shell for dir in $(soy_source_dirs) ; do find $$dir -name *.soy ; done)

soytemplates:
	$(java) $(soy_compiler) $(soy_compiler_options) \
			$(shell for dir in $(soy_source_dirs) ; do find $$dir -name *.soy ; done)

# Also includes the dto generation if we are building that namespace
jsdependencies:
	@if [ "$(ns)" == "$(dto_prefix)" ]; then \
		make schemes; \
	fi
	$(python) $(closure_depswriter) \
			$(shell echo $(jssource_dir) | sed 's+$(sed_tokenizer)+$(sed_deps_subst)+g') \
			--output_file=$(closure_depsfile)

lessc:
	lessc --no-ie-compat less/$(ns).less > $(css_file)

css:
	$(java) $(gss_compiler) \
			--output-renaming-map-format CLOSURE_UNCOMPILED \
			--rename NONE \
		 	--pretty-print \
			--output-file $(css_build_file) \
			$(gss_ini) \
		  --output-renaming-map $(build_dir)/$(ns)-cssmap.js \
		  $(css_file)

cssmin:
	$(java) $(gss_compiler) \
			--output-renaming-map-format CLOSURE_COMPILED \
			--rename CLOSURE \
			--output-file $(css_min_file) \
			--output-renaming-map $(build_dir)/$(ns)-cssmap.min.js \
			$(gss_ini) \
			$(css_file)

cssdebug:
	$(java) $(gss_compiler) \
			--output-renaming-map-format CLOSURE_COMPILED \
			--rename NONE \
			--pretty-print \
			--output-file $(css_debug_file) \
			--output-renaming-map $(build_dir)/$(ns)-cssmap.debug.js \
			$(gss_ini) \
			$(css_file)

jsfilelist:
	$(java) $(js_compiler) \
			--dependency_mode=STRICT \
			--entry_point=goog:$(ns) \
			--output_manifest $(manifest) \
			--js_output_file /tmp/closure_compiler_build \
			$(compiler_js_sources)

jsmin:
	$(java) $(js_compiler) \
			$(build_js_compiler_option) \
			$(namespace_specific_flags) \
			--compilation_level=ADVANCED \
			--flagfile=options/compile.ini \
			--js_output_file=$(js_min_file) \
			--js=build/$(ns)-cssmap.min.js \
			$(shell cat $(manifest) | tr '\n' ' ')

jsworker:
	$(java) $(js_compiler) \
			$(build_js_compiler_option) \
			$(namespace_specific_flags) \
			--compilation_level=ADVANCED \
			--flagfile=options/compile.ini \
			--js_output_file=$(js_min_file) \
			$(shell cat $(manifest) | tr '\n' ' ')

jsdebug:
	$(java) $(js_compiler) \
			$(build_js_compiler_option) \
			$(namespace_specific_flags) \
			--compilation_level=ADVANCED \
			--flagfile=options/compile.ini \
			--debug \
			--formatting=PRETTY_PRINT \
			--js_output_file=$(js_debug_file) \
			$(shell cat $(manifest) | tr '\n' ' ')

modulelist:
	echo "build/$(ns)-cssmap.min.js" > $(modules_manifest)
	$(python) $(calcdeps) $(calcdeps_paths) \
			-o list \
			-e ../../templates/src/ \
			-e ../pstj/tpl/ \
			-e ../smjs/tpl/ \
			$(shell for item in `find js -name '*init.js' -print0 | xargs -0 ls | sort`; do echo $$item | sed 's+[^ ]*+-i &+'; done) >> $(modules_manifest)

# $(shell for item in `grep -n _init $(modules_manifest) | grep -Eo '^[^:]+'`; do echo $$item; done)

modulebuild: modulelist
	$(java) $(js_compiler) \
			--charset=UTF-8 \
			--define='goog.LOCALE="$(locale)"' \
			--define='goog.DEBUG=$(debug)' \
			--process_closure_primitives \
			--generate_exports \
			--export_local_property_definitions \
			--use_types_for_optimization \
			--warning_level=VERBOSE \
			$(namespace_specific_flags) \
			--compilation_level=ADVANCED \
			--flagfile=options/compile.ini \
			--output_module_dependencies="$(modules_depsfile)" \
			$(shell ARR=(); for item in `grep -n _init $(modules_manifest) | grep -Eo '^[^:]+'`; do ARR=($${ARR[@]} $$item); done; COUNT=0; LAST=-1; cat options/modules.ini | while read line; do echo $$line | sed "s+%+`expr $${ARR[$$COUNT]} - $$LAST`+"; LAST=$${ARR[$$COUNT]}; COUNT=`expr $$COUNT + 1`; done) \
			--module_output_path_prefix build/module_ \
			--module_wrapper="a:var pns={};(function(__){%s})(pns);" \
			--module_wrapper="b:(function(__){%s})(pns);" \
			--module_wrapper="c:(function(__){%s})(pns);" \
			--rename_prefix_namespace="__" \
			$(shell cat $(modules_manifest) | tr '\n' ' ')
	node bin/main.js


distribution:
	mkdir -p dist/
	make ns=$(ns) debug=false
	@if [ "$(ns)" == "app" ]; then \
		cat libs/CustomElements.min.js $(js_min_file) > dist/svg-glyph.min.js; \
	elif [ "$(ns)" == "ios" ]; then \
		cat libs/CustomElements.min.js $(js_min_file) > dist/$(ns).min.js; \
	fi