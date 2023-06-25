/**
 * compiler.ks
 * Version 0.9.1
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![runtime(prefix='KS')]

#![error(off)]
#![rules(ignore-misfit)]

import {
	'../package.json' => metadata
	'./fs.js'
	'node:path' {
		var sep: String
		func basename(path: String): String
		func dirname(path: String): String
		func join(...paths: String): String
		func relative(from: String, to: String): String
	}
}

include {
	'@kaoscript/ast'
	'@kaoscript/parser'
	'@kaoscript/util'
	'./include/error.ks'
	'./include/global.ks'
	'./include/node.ks'
	'./include/astmap.ks'

	'../registry/std/index.ks'
}

export class Compiler {
	private late {
		@module: Module
	}
	private {
		@file: String
		@fragments
		@hashes: Object
		@hierarchy: Array
		@options: Object
		@standardLibrary: Boolean	= false
	}
	static {
		registerTarget(target: String, fn: Function) { # {{{
			$targets[target] = fn
		} # }}}
		registerTarget(mut target: String, options: Object) { # {{{
			if target !?= $targetRegex.exec(target) {
				throw Error.new(`Invalid target syntax: \(target)`)
			}

			$targets[target[1]] ??= {}
			$targets[target[1]][target[2]] = options
		} # }}}
		registerTargets(targets) { # {{{
			for var data, name of targets {
				if data is String {
					Compiler.registerTargetAlias(name, data)
				}
				else {
					Compiler.registerTarget(name, data)
				}
			}
		} # }}}
		registerTargetAlias(mut target: String, mut alias: String) { # {{{
			if alias !?= $targetRegex.exec(alias) {
				if !?$targets[alias] || $targets[alias] is not Function {
					throw Error.new(`Invalid target syntax: \(alias)`)
				}

				$targets[target] = $targets[alias]
			}
			else {
				if target !?= $targetRegex.exec(target) {
					throw Error.new(`Invalid target syntax: \(target)`)
				}

				if !?$targets[alias[1]] {
					throw Error.new(`Undefined target '\(alias[1])'`)
				}
				else if !?$targets[alias[1]][alias[2]] {
					throw Error.new(`Undefined target's version '\(alias[2])'`)
				}

				$targets[target[1]] ??= {}
				$targets[target[1]][target[2]] = $targets[alias[1]][alias[2]]
			}
		} # }}}
	}
	constructor(@file, options? = null, @hashes = {}, @hierarchy = [@file]) { # {{{
		@options = Object.merge({
			target: 'ecma-v6'
			register: true
			header: true
			error: {
				level: 'fatal'
				ignore: []
				raise: []
			}
			parse: {
				parameters: 'kaoscript'
			}
			format: {}
			parameters: {
				retain: false
			}
			rules: {
				assertNewStruct: true
				assertNewTuple: true
				assertOverride: true
				assertParameter: true
				assertParameterType: true
				noUndefined: false
				ignoreError: false
				ignoreMisfit: false
			}
			runtime: {
				helper: {
					alias: 'Helper'
					member: 'Helper'
					package: '@kaoscript/runtime'
				}
				initFlag: {
					alias: 'initFlag'
					member: 'initFlag'
					package: '@kaoscript/runtime'
				}
				object: {
					alias: 'OBJ'
					member: 'OBJ'
					package: '@kaoscript/runtime'
				}
				operator: {
					alias: 'Operator'
					member: 'Operator'
					package: '@kaoscript/runtime'
				}
				type: {
					alias: 'Type'
					member: 'Type'
					package: '@kaoscript/runtime'
				}
			}
		}, options)

		if @options.target is String {
			if target !?= $targetRegex.exec(@options.target) {
				throw Error.new(`Invalid target syntax: \(@options.target)`)
			}

			@options.target = {
				name: target[1]
				version: target[2]
			}
		}
		else if @options.target is not Object || !$targetRegex.test(`\(@options.target.name)-v\(@options.target.version)`) {
			throw Error.new(`Undefined target`)
		}

		@options = $expandOptions(@options)
	} # }}}
	initiate(data: String? = null) { # {{{
		@module = Module.new(data ?? fs.readFile(@file), this, @file)

		if @standardLibrary {
			@module.flagStandardLibrary()
		}

		@module.initiate()

		return this
	} # }}}
	compile(data: String? = null) { # {{{
		return @initiate(data).finish()
	} # }}}
	createServant(file) { # {{{
		return Compiler.new(file, Object.defaults(@options, {
			register: false
		}), @hashes, [...@hierarchy, file])
	} # }}}
	finish() { # {{{
		@module.finish()

		@fragments = @module.toFragments()

		return this
	} # }}}
	private flagStandardLibrary() { # {{{
		@standardLibrary = true
	} # }}}
	isInHierarchy(file) => @hierarchy.contains(file)
	module(): @module
	readFile() => fs.readFile(@file)
	setArguments(arguments: Array, module: String? = null, node: AbstractNode? = null) => @module.setArguments(arguments, module, node)
	sha256(file, data? = null) { # {{{
		return @hashes[file] ?? (@hashes[file] <- fs.sha256(data ?? fs.readFile(file)))
	} # }}}
	toExports() => @module.toExports()
	toHashes() => @module.toHashes()
	toRequirements() => @module.toRequirements()
	toSource() { # {{{
		var mut source = ''

		for fragment in @fragments {
			source += fragment.code
		}

		if source.length != 0 {
			return source.substr(0, source.length - 1)
		}
		else {
			return source
		}
	} # }}}
	toSourceMap() => @module.toSourceMap()
	toVariationId() => @module.toVariationId()
	writeFiles() { # {{{
		fs.mkdir(path.dirname(@file))

		if @module.isBinary() {
			@writeBinaryFiles()
		}
		else {
			@writeModuleFiles()
		}
	} # }}}
	private writeBinaryFiles() { # {{{
		var variationId = @module.toVariationId()

		fs.writeFile(getBinaryPath(@file, variationId), @toSource())

		@writeHashFile(variationId)
	} # }}}
	private writeHashFile(variationId: String) { # {{{
		var hashPath = getHashPath(@file)

		var dyn data

		try {
			data = JSON.parse(fs.readFile(hashPath))
		}
		catch {
			data = {
				hashes: {}
			}
		}

		if @module.isUpToDate(data.hashes) {
			data.variations.push(variationId)
		}
		else {
			data = {
				hashes: @module.toHashes()
				variations: [variationId]
			}
		}

		fs.writeFile(hashPath, JSON.stringify(data))
	} # }}}
	private writeModuleFiles() { # {{{
		var variationId = @module.toVariationId()

		fs.writeFile(getBinaryPath(@file, variationId), @toSource())

		fs.writeFile(getRequirementsPath(@file), JSON.stringify(@toRequirements(), fs.escapeJSON))

		fs.writeFile(getExportsPath(@file, variationId), JSON.stringify(@toExports(), fs.escapeJSON))

		@writeHashFile(variationId)
	} # }}}
	writeOutput() { # {{{
		if @options.output is not String {
			throw Error.new('Undefined option: output')
		}

		fs.mkdir(@options.output)

		var filename = path.join(@options.output, path.basename(@file)).slice(0, -3) + '.js'

		fs.writeFile(filename, @toSource())

		return this
	} # }}}
}

export func compileFile(file, options? = null) { # {{{
	var compiler = Compiler.new(file, options)

	return compiler.compile().toSource()
} # }}}

export func getBinaryPath(file, variationId? = null) => fs.hidden(file, variationId, $extensions.binary)

export func getExportsPath(file, variationId) => fs.hidden(file, variationId, $extensions.exports)

export func getHashPath(file) => fs.hidden(file, null, $extensions.hash)

export func getRequirementsPath(file) => fs.hidden(file, null, $extensions.requirements)

export func isUpToDate(file, variationId, source) { # {{{
	var late data
	try {
		data = JSON.parse(fs.readFile(getHashPath(file)))
	}
	catch {
		return false
	}

	if !data.variations:Array.contains(variationId) {
		return false
	}

	var root = path.dirname(file)

	for var hash, name of data.hashes {
		if name == '.' {
			return null if fs.sha256(source) != hash
		}
		else {
			return null if fs.sha256(fs.readFile(path.join(root, name))) != hash
		}
	}

	return true
} # }}}

export $extensions => extensions

export AssignmentOperatorKind, BinaryOperatorKind, MacroElementKind, ModifierKind, NodeKind, ReificationKind, ScopeKind, UnaryOperatorKind, FragmentBuilder
