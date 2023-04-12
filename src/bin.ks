/**
 * compiler.ks
 * Version 0.9.0
 * September 15th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
extern console, global, process, require, Object

import {
	'../package.json'	=> metadata
	'./compiler.ks'		for Compiler
	'child_process'		for execSync
	'commander'			=> program
	'module'			=> Module
	'path'
	'vm'
}

func rewire(option, defaultValue?) { # {{{
	var files = []

	for item in option.split(',') {
		item = item.split('=')

		files.push({
			input: item[0]
			output: item[1]
		})
	}

	return files
} # }}}

program
	.version(metadata.version)
	.usage('[options] <file>')
	.option('-k, --clean', 'remove compiler\'s cache files')
	.option('-c, --compile', 'compile to JavaScript and save as .js files')
	.option('    --no-header', 'suppress the "Generated by" header')
	.option('-m, --metadata', 'write the metadata file')
	.option('-o, --output <path>', 'set the output directory for compiled JavaScript')
	.option('-p, --print', 'print out the compiled JavaScript')
	.option('    --no-register', 'suppress "require(kaoscript/register)"')
	.option('-r, --rewire <src-path=gen-path,...>', 'rewire the references to source files to generated files', rewire)
	.option('-t, --target <engine>', 'set the engine/runtime/browser to compile for')
	.parse(process.argv)

if program.clean {
	execSync(`find -L \(process.cwd()) -type f \\( -name "*.ksb" -o -name "*.ksh" -o -name "*.ksr" -o -name "*.kse" \\) -exec rm {} \\;`)

	if program.args.length == 0 {
		echo('all clean!')
		process.exit(0)
	}
}
else if program.args.length == 0 {
	program.outputHelp()
	process.exit(1)
}

var file = path.join(process.cwd(), program.args[0])

var options = {
	header: program.header
	register: program.register
}

if ?program.rewire {
	options.rewire = []

	for item in program.rewire {
		options.rewire.push({
			input: path.join(process.cwd(), item.input)
			output: path.join(process.cwd(), item.output)
		})
	}
}

if ?program.target {
	options.target = program.target
}

if program.compile {
	options.output = path.join(process.cwd(), program.output ?? '')

	var compiler = Compiler.new(file, options)

	compiler.compile()

	if program.print {
		echo(compiler.toSource())
	}

	compiler.writeOutput()
}
else if program.print {
	var compiler = Compiler.new(file, options)

	compiler.compile()

	echo(compiler.toSource())
}
else {
	var compiler = Compiler.new(file, options)

	compiler.compile()

	var sandbox = {}
	for var _, key of global {
		sandbox[key] = global[key]
	}

	sandbox.console = console
	sandbox.__dirname = path.dirname(file)
	sandbox.__filename = file

	var _module = sandbox.module <- Module.new('eval')
	var _require = sandbox.require <- (path) => Module._load(path, _module, true)

	_module.filename = file

	#[rules(ignore-misfit)]
	for var r in Object.getOwnPropertyNames(require) {
		if r != 'paths' && r != 'arguments' && r != 'caller' {
			_require[r] = require[r]
		}
	}

	_require.paths = _module.paths = Module._nodeModulePaths(process.cwd()).concat(process.cwd())
	_require.resolve = (request) => Module._resolveFilename(request, _module)

	vm.runInNewContext(compiler.toSource(), sandbox, file)
}
