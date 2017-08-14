/**
 * compiler.ks
 * Version 0.9.0
 * September 15th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
extern console, global, Object, process, require

import {
	'../package.json'	as metadata
	'./compiler.ks'		for Compiler
	'commander'			as program
	'module'			as Module
	'path'
	'vm'
}

func rewire(option) {
	let files = []
	
	for item in option.split(',') {
		item = item.split('=')
		
		files.push({
			input: item[0]
			output: item[1]
		})
	}
	
	return files
}

program
	.version(metadata.version)
	.usage('[options] <file>')
	.option('-c, --compile', 'compile to JavaScript and save as .js files')
	.option('    --no-header', 'suppress the "Generated by" header')
	.option('-o, --output <path>', 'set the output directory for compiled JavaScript')
	.option('-p, --print', 'print out the compiled JavaScript')
	.option('    --no-register', 'suppress "require(kaoscript/register)"')
	.option('-r, --rewire <src-path=gen-path,...>', 'rewire the references to source files to generated files', rewire)
	.option('-t, --target <engine>', 'set the engine/runtime/browser to compile for')
	.parse(process.argv)

if program.args.length == 0 {
	program.outputHelp()
	process.exit(1)
}

const file = path.join(process.cwd(), program.args[0])

const options = {
	register: program.register
	config: {
		header: program.header
	}
}

if program.rewire? {
	options.rewire = []
	
	for item in program.rewire {
		options.rewire.push({
			input: path.join(process.cwd(), item.input)
			output: path.join(process.cwd(), item.output)
		})
	}
}

if program.target? {
	options.target = program.target
}

if program.compile {
	options.output = path.join(process.cwd(), program.output ?? '')
	
	const compiler = new Compiler(file, options)
	
	compiler.compile()
	
	if program.print {
		console.log(compiler.toSource())
	}
	
	compiler.writeOutput()
}
else if program.print {
	const compiler = new Compiler(file, options)
	
	compiler.compile()
	
	console.log(compiler.toSource())
}
else {
	const compiler = new Compiler(file, options)
	
	compiler.compile()
	
	const sandbox = {}
	for key of global {
		sandbox[key] = global[key]
	}
	
	_module = sandbox.module = new Module('eval')
	_require = sandbox.require = (path) => Module._load(path, _module, true)
	
	_module.filename = sandbox.__filename
	
	for r in Object.getOwnPropertyNames(require) {
		if r != 'paths' && r != 'arguments' && r != 'caller' {
			_require[r] = require[r]
		}
	}
	
	_require.paths = _module.paths = Module._nodeModulePaths(process.cwd()).concat(process.cwd())
	_require.resolve = (request) => Module._resolveFilename(request, _module)
	
	vm.runInNewContext(compiler.toSource(), sandbox, file)
}