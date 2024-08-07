extern process, require

var $localFileRegex = /^(?:\.\.?(?:\/|$)|\/|([A-Za-z]:)?[\\\/])/

var $importExts = { # {{{
	data: {
		json: true
	}
	source: {
		coffee: true
		js: true
		ks: true
		ts: true
	}
} # }}}

func $listNPMModulePaths(mut start) { # {{{
	start = $fs.resolve(start)

	var prefix =
		if /^([A-Za-z]:)/.test(start) {
			set ''
		}
		else if /^\\\\/.test(start) {
			set '\\\\'
		}
		else {
			set '/'
		}

	var mut splitRe = if process.platform == 'win32' set /[\/\\]/ else /\/+/
	var mut parts = start.split(splitRe)
	var mut dirs = []

	for var i from parts.length - 1 to 0 step -1 {
		if parts[i] == 'node_modules' {
			continue
		}

		dirs.push(prefix + $path.join($path.join(...parts.slice(0, i + 1)!?), 'node_modules'))
	}

	if process.platform == 'win32' {
		dirs[dirs.length - 1] = dirs[dirs.length - 1].replace(':', ':\\')
	}

	return dirs
} # }}}

struct ImportedVariable {
	name: String
	sealed: Boolean		= false
	specter: Boolean	= false
	system: Boolean		= false
}

struct Arguments {
	values: Array					= []
	fromLocal: Object				= {}
	toImport: Object				= {}
}

enum ImportMode {
	Default

	Import
	ExternOrImport
	RequireOrImport
}

abstract class Importer extends Statement {
	private late {
		@alias: String?								= null
		@arguments: Arguments						= Arguments.new()
		@autofill: Boolean							= false
		@count: Number								= 0
		@extAddendum: String						= ''
		@filename: String?							= null
		@hasArguments: Boolean						= true
		@imports									= {}
		@isKSFile: Boolean							= false
		@macro: Boolean								= false
		@metaExports
		@metaRequirements
		@moduleName: String
		@pathAddendum: String						= ''
		@reusable: Boolean							= false
		@reuseName: String
		@standardLibrary: Boolean					= false
		@variables: Object<ImportedVariable>		= {}
		@variationId: String
		@worker: ImportWorker
	}
	abstract mode(): ImportMode
	initiate() { # {{{
		var mut x = @data.source.value
		var mut y = @directory()

		if x.startsWith('node:') {
			unless @loadNodeModule(x) {
				IOException.throwNotFoundModule(x, y, this)
			}
		}
		else if x.startsWith('npm:') {
			unless @loadNPMModule(x, y) {
				IOException.throwNotFoundModule(x, y, this)
			}
		}
		else if $localFileRegex.test(x) {
			x = $fs.resolve(y, x)

			unless @loadFile(x, '', null) || @loadDirectory(x, null) {
				IOException.throwNotFoundModule(x, y, this)
			}
		}
		else {
			IOException.throwNotFoundModule(x, y, this)
		}

		var module = @module()

		if @isKSFile {
			@worker.prepare(@arguments)

			@scope.line(@line())

			for var argument in @arguments.values when argument.required {
				module.addRequirement(ImportingRequirement.new(argument.name, argument.type, this))

				if var variable ?= @scope.getVariable(argument.name) {
					variable.setDeclaredType(argument.type)
				}
				else {
					@scope.define(argument.name, true, argument.type, true, this)
				}
			}

			var matchables = []
			var types = []
			var workerScope = @worker.scope()

			for var def, name of @imports {
				workerScope.rename(name, def.internal, @scope)
			}

			for var def, name of @imports {
				var variable = @scope.getVariable(def.internal)

				if def.isAlias {
					var type = NamedContainerType.new(def.internal, NamespaceType.new(@scope:!!!(Scope)))

					for var i from 1 to~ @metaExports.exports.length step 2 {
						var exportName = @metaExports.exports[i]

						type.addProperty(exportName, @worker.getType(exportName))
					}

					variable.setDeclaredType(type.flagComplete())
				}
				else {
					if !@worker.hasType(name) {
						ReferenceException.throwNotDefinedInModule(name, @data.source.value, this)
					}

					var type = @worker.getType(name)

					if ?def.type && !type.isSubsetOf(def.type, MatchingMode.Signature) {
						TypeException.throwNotCompatibleDefinition(def.internal, name, @data.source.value, this)
					}

					if def.newVariable {
						var declType = type ?? def.type
							..setStandardLibrary(LibSTDMode.Yes + LibSTDMode.Closed) if variable.isStandardLibrary()

						variable.setDeclaredType(declType)
					}
					else if variable.isStandardLibrary(.Closed) && type?.isStandardLibrary(LibSTDMode.Opened) {
						variable.getDeclaredType().merge(type)
					}
					else if !variable.isPredefined() && !?@arguments.fromLocal[def.internal] {
						if variable.isStandardLibrary(.Closed) {
							variable.getDeclaredType().merge(type)
						}
						else if type.isAlias() && variable.getDeclaredType().isAlias() && variable.getDeclaredType().isSubsetOf(type, MatchingMode.Default) {
							pass
						}
						else {
							ReferenceException.throwNotPassed(def.internal, @data.source.value, this)
						}
					}
					else if type.isSubsetOf(variable.getDeclaredType(), MatchingMode.Signature + MatchingMode.Renamed) {
						var declType = type
							..setStandardLibrary(LibSTDMode.Yes + LibSTDMode.Closed) if variable.isStandardLibrary()
							..flagAlien() if variable.getDeclaredType().isAlien()

						variable.setDeclaredType(declType)
					}
					else {
						TypeException.throwNotCompatibleArgument(def.internal, name, @data.source.value, this)
					}

					if type.isNamed() {
						type.name(def.internal)

						type.scope().reassignReference(name, def.internal, @scope)

					}

					var var = ImportedVariable.new(
						name: def.internal
						sealed: type.isSealed() && !type.isSystem()
						system: type.isSystem()
					)

					if !@standardLibrary && type.isUsingAuxiliary() && !type.hasAuxiliary() {
						type.flagAuxiliary()
					}

					@variables[name] = var

					if var.sealed {
						@count += 2
					}
					else {
						@count += 1
					}

					if !@standardLibrary && type.isSystem() && def.internal == 'Object' {
						module.flag('Object')
					}
					else {
						module.import(def.internal)
					}

					if type.isAlias() {
						type.setTestName(def.internal)
					}
				}

				variable.setComplete(true)
			}

			if !@standardLibrary && !@macro && (@count != 0 || ?@alias) {
				module.flagRegister()
			}
		}
		else {
			for var import of @imports {
				module.import(import.internal)
			}
		}

		if @count != 0 && ?@alias {
			@reuseName = @alias
		}
	} # }}}
	analyse() { # {{{
		for var argument in @arguments.values when !argument.required {
			var variable = @scope.getVariable(argument.identifier)

			if !variable.isImmutable() || !variable.isComplete() {
				SyntaxException.throwOnlyStaticImport(variable.name(), @data.source.value, this)
			}
		}
	} # }}}
	override prepare(target, targetMode)
	translate()
	addArgument(data, autofill, arguments) { # {{{
		var argument = {
			auxiliary: false
			index: if @isKSFile set null else 0
			isApproved: true
			isAutofill: autofill
			isIdentifier: false
			isNamed: false
			required: false
			value: $compile.expression(data.value, this)
		}

		for var modifer in data.modifiers {
			if modifer.kind == ModifierKind.Required {
				argument.required = true

				break
			}
		}

		if argument.required {
			if var variable ?= @scope.getVariable(data.value.name) ;; !variable.getDeclaredType().isPredefined() {
				ReferenceException.throwDefined(data.value.name, this)
			}

			argument.isNamed = true
			argument.name = data.name?.name ?? data.value.name

			argument.isIdentifier = true
			argument.identifier = data.value.name

			arguments.fromLocal[data.value.name] = arguments.values.length
			arguments.toImport[argument.name] = arguments.values.length
		}
		else if data.value.kind == AstKind.Identifier {

			argument.isNamed = true
			argument.name = data.name?.name ?? data.value.name

			argument.isIdentifier = true
			argument.identifier = data.value.name

			arguments.fromLocal[data.value.name] = arguments.values.length
			arguments.toImport[argument.name] = arguments.values.length
		}
		else if ?data.name {
			argument.isNamed = true
			argument.name = data.name.name
			argument.identifier = data.name.name

			arguments.fromLocal[argument.name] = arguments.values.length
			arguments.toImport[argument.name] = arguments.values.length
		}
		else {
			SyntaxException.throwOnlyStaticImport(@data.source.value, this)
		}

		arguments.values.push(argument)
	} # }}}
	addImport(external: String, internal: String, isAlias: Boolean, type: Type? = null) { # {{{
		var mut variable = @scope.getVariable(internal)
		var newVariable = !?variable || variable.isPredefined()

		if newVariable {
			variable = @scope.define(internal, true, null, true, this)
		}
		else if @parent.includePath() != null {
			return
		}
		else if isAlias {
			SyntaxException.throwAlreadyDeclared(internal, this)
		}

		if @standardLibrary {
			variable.flagStandardLibrary()
		}

		@imports[external] = {
			external
			internal
			isAlias
			newVariable
			type
		}
	} # }}}
	addVariable(external: String, internal: String, isVariable: Boolean, type: Type?) { # {{{
		if var variable ?= @scope.getVariable(internal) ;; !variable.isPredefined() {
			if @parent.includePath() != null {
				// TODO check & merge type
				return
			}
			else if isVariable {
				if @arguments.fromLocal[internal] is not Number {
					ReferenceException.throwNotPassed(internal, @data.source.value, this)
				}
				else if variable.getDeclared().isMergeable(type) {
					variable.getDeclared().merge(type, null, null, false, this)
				}
				else {
					ReferenceException.throwNotMergeable(internal, @data.source.value, this)
				}
			}
			else {
				SyntaxException.throwAlreadyDeclared(internal, this)
			}

			if @standardLibrary {
				variable.flagStandardLibrary()
			}
		}
		else {
			var variable = @scope.define(internal, true, type, true, this)

			if @standardLibrary {
				variable.flagStandardLibrary()
			}
		}

		@module().import(internal)

		if isVariable && type is not AliasType {
			@variables[external] = ImportedVariable.new(internal)
			@count += 1
		}
	} # }}}
	buildArguments(metadata): Arguments { # {{{
		var arguments = Arguments.new()

		@scope.line(@line() - 1)

		if @data.arguments?.length != 0 {
			for var argument in @data.arguments {
				@addArgument(argument, false, arguments)
			}

			if @autofill {
				for var i from 0 to~ metadata.requirements.length step 3 {
					var name = metadata.requirements[i + 1]

					if !?arguments.toImport[name] {
						if @scope.hasVariable(name) {
							@addArgument({
								modifiers: []
								value: {
									kind: AstKind.Identifier
									name: name
								}
							}, true, arguments)
						}
						else {
							@validateRequirement(metadata.requirements[i + 2], name, metadata)
						}
					}
				}
			}
		}
		else if @autofill {
			for var i from 0 to~ metadata.requirements.length step 3 {
				var name = metadata.requirements[i + 1]

				if @scope.hasVariable(name) {
					@addArgument({
						modifiers: []
						value: {
							kind: AstKind.Identifier
							name: name
						}
					}, true, arguments)
				}
				else {
					@validateRequirement(metadata.requirements[i + 2], name, metadata)
				}
			}
		}
		else {
			for var i from 0 to~ metadata.requirements.length step 3 {
				@validateRequirement(metadata.requirements[i + 2], metadata.requirements[i + 1], metadata)
			}
		}

		if arguments.values.length != 0 {
			var unmatchedArguments = [0..<arguments.values.length]
			var requirements = []
			var queue = []

			var reqReferences = {}
			var alterations = {}

			for var i from 0 to~ metadata.aliens.length step 3 {
				var index = metadata.aliens[i]
				var name = metadata.aliens[i + 1]
				var late type

				if !?reqReferences[index] {
					type = Type.import(index, metadata.references, reqReferences, alterations, queue, @scope, this)
				}
				else {
					type = reqReferences[index]
				}

				reqReferences[index] = Type.toNamedType(name, type)
			}

			for var i from 0 to~ metadata.requirements.length step 3 {
				var index = metadata.requirements[i]
				var name = metadata.requirements[i + 1]

				if arguments.toImport[name] is Number {
					var argument = arguments.values[arguments.toImport[name]]

					argument.index = i / 3

					argument.type = Type.import(index, metadata.references, reqReferences, alterations, queue, @scope, this)
					argument.auxiliary = argument.type.hasAuxiliary()

					reqReferences[index] = Type.toNamedType(name, argument.type)

					unmatchedArguments.remove(arguments.toImport[name])
				}
				else {
					requirements.push(metadata.requirements.slice(i, i + 3))
				}
			}

			while queue.length > 0 {
				queue.shift()()
			}

			var len = arguments.values.length
			var mut nextArgument = 0
			for var requirement in requirements {
				while nextArgument < len && arguments.values[nextArgument].index != null {
					nextArgument += 1
				}

				if nextArgument == len {
					if requirement[2] {
						SyntaxException.throwMissingRequirement(requirement[1], this)
					}
				}
				else {
					arguments.values[nextArgument].index = requirement[0]
					arguments.values[nextArgument].name = requirement[1]

					unmatchedArguments.remove(nextArgument)
				}
			}

			if unmatchedArguments.length != 0 {
				SyntaxException.throwUnmatchedImportArguments([arguments.values[i].name for var i in unmatchedArguments], this)
			}
		}

		for var argument, index in [...arguments.values] when !argument.required {
			var variable = @scope.getVariable(argument.identifier)
			var type = variable.getRealType()

			if type.isSubsetOf(argument.type, MatchingMode.Signature + MatchingMode.Requirement) {
				argument.type = variable.getRealType()
				argument.auxiliary = argument.type.hasAuxiliary()
			}
			else if argument.isAutofill {
				pass
			}
			else {
				TypeException.throwNotCompatibleArgument(argument.identifier, argument.name, @data.source.value, this)
			}
		}

		return arguments
	} # }}}
	flagMacro() { # {{{
		@macro = true
	} # }}}
	flagStandardLibrary() { # {{{
		@standardLibrary = true
	} # }}}
	getModuleName() => @moduleName
	isStandardLibrary() => @standardLibrary
	loadDirectory(dir, moduleName? = null, fromPackage: Boolean = false) { # {{{
		var pkgfile = $path.join(dir, 'package.json')

		if $fs.isFile(pkgfile) {
			if var pkg ?= try JSON.parse($fs.readFile(pkgfile)) {
				if ?pkg.kaoscript {
					var metadata = if ?pkg.kaoscript.metadata set $path.join(dir, pkg.kaoscript.metadata) else null

					if ?pkg.kaoscript.main {
						if @loadKSFile($path.join(dir, pkg.kaoscript.main), pkg.kaoscript.main, null, moduleName, metadata) {
							return true
						}
					}
					else if ?metadata {
						if @loadKSFile(null, null, null, moduleName ?? dir, metadata) {
							return true
						}
					}
				}

				if pkg.main is String && (@loadFile($path.join(dir, pkg.main), pkg.main, moduleName, true) || @loadDirectory($path.join(dir, pkg.main), moduleName, true)) {
					return true
				}

				return @loadFile($path.join(dir, 'index'), 'index', moduleName, true)
			}
		}

		if fromPackage {
			return @loadFile($path.join(dir, 'index'), 'index', moduleName, true)
		}
		else {
			return false
		}
	} # }}}
	loadFile(filename, pathAddendum, moduleName? = null, fromPackage: Boolean = false) { # {{{
		if $fs.isFile(filename) {
			if filename.endsWith($extensions.source) {
				return @loadKSFile(filename, pathAddendum, null, moduleName)
			}
			else {
				return @loadNodeFile(filename, moduleName)
			}
		}

		if fromPackage {
			if $fs.isFile(filename + $extensions.source) {
				return @loadKSFile(filename + $extensions.source, pathAddendum, $extensions.source, moduleName)
			}
			else {
				for var _, ext of require.extensions {
					if $fs.isFile(filename + ext) {
						return @loadNodeFile(filename, moduleName)
					}
				}
			}
		}

		return false
	} # }}}
	loadKSFile(filename: String?, pathAddendum: String = '', extAddendum: String = '', mut moduleName: String? = null, metadataPath? = null) { # {{{
		var module = @module()

		if moduleName == null {
			moduleName = module.path(filename, @data.source.value):!!!(String)
		}

		if module.compiler().isInHierarchy(filename) {
			SyntaxException.throwLoopingImport(@data.source.value, this)
		}

		@isKSFile = true
		@filename = filename
		@pathAddendum = pathAddendum
		@extAddendum = extAddendum
		@moduleName = moduleName

		for var modifer in @data.modifiers until @autofill {
			if modifer.kind == ModifierKind.Autofill {
				@autofill = true
			}
		}

		@loadMetadata()

		@worker = ImportWorker.new(@metaRequirements, @metaExports, this)

		var macros = {}
		for var i from 0 to~ @metaExports.macros.length step 2 {
			macros[@metaExports.macros[i]] = [JSON.parse(Buffer.from(data, 'base64').toString('utf8')) for var data in @metaExports.macros[i + 1]]
		}

		@scope.line(@line())

		if !?#@data.specifiers {
			for var i from 1 to~ @metaExports.exports.length step 2 {
				var name = @metaExports.exports[i]

				@addImport(name, name, false)
			}

			for var datas, name of macros {
				for var data in datas {
					Syntime.SyntimeFunctionDeclaration.new(data, this, null, name, @standardLibrary)
				}
			}
		}
		else {
			for var data in @data.specifiers {
				match data.kind {
					AstKind.GroupSpecifier {
						var mut alias = false
						var mut exclusion = false

						for var modifier in data.modifiers {
							if modifier.kind == ModifierKind.Alias {
								alias = true
							}
							else if modifier.kind == ModifierKind.Exclusion {
								exclusion = true
							}
						}

						if alias {
							for var element in data.elements {
								match element.kind {
									AstKind.NamedSpecifier {
										match element.internal.kind {
											AstKind.Identifier {
												if ?@alias {
													throw NotSupportedException.new(this)
												}

												@alias = element.internal.name
											}
											AstKind.ObjectBinding {
												for var binding in element.internal.elements {
													var internal = binding.internal.name
													var external = binding.external?.name ?? internal

													@addImport(external, internal, false, null)
												}
											}
											else {
												throw NotImplementedException.new()
											}
										}
									}
									else {
										throw NotImplementedException.new()
									}
								}
							}
						}
						else if exclusion {
							var exclusions = []
							for var element in data.elements {
								exclusions.push(element.internal.name)
							}

							for var i from 1 to~ @metaExports.exports.length step 2 when exclusions.indexOf(@metaExports.exports[i]) == -1 {
								var name = @metaExports.exports[i]

								@addImport(name, name, false)
							}

							for var datas, name of macros when exclusions.indexOf(name) == -1 {
								for var d in datas {
									Syntime.SyntimeFunctionDeclaration.new(d, this, null, name, @standardLibrary)
								}
							}
						}
						else {
							for var element in data.elements {
								match element.kind {
									AstKind.NamedSpecifier {
										var internal = element.internal.name
										var external = element.external?.name ?? internal

										if ?macros[external] {
											for var macro in macros[external] {
												Syntime.SyntimeFunctionDeclaration.new(macro, this, null, internal, @standardLibrary)
											}
										}
										else {
											@addImport(external, internal, false)
										}
									}
									AstKind.TypedSpecifier {
										if element.type.kind == AstKind.TypeAliasDeclaration {
											var name = element.type.name.name
											var type = Type.fromAST(element.type.type, this)

											@addImport(name, name, false, type)
										}
									}
									else {
										throw NotImplementedException.new()
									}
								}
							}
						}
					}
					AstKind.NamedSpecifier {
						var internal = data.internal.name
						var external = if ?data.external set data.external.name else internal

						@addImport(external, internal, true, null)
					}
					else {
						throw NotImplementedException.new()
					}
				}
			}

			if @alias != null {
				@addImport(@alias, @alias, true)
			}
		}

		@scope.line(@line() - 1)

		return true
	} # }}}
	loadMetadata() { # {{{
		var module = @module()
		var source = $fs.readFile(@filename)
		var target = @options.target

		if var upto ?= module.isUpToDate(@filename, source) {
			if var metadata ?= @readMetadata(getRequirementsPath(@filename)) {
				var variations = [module._options.target.name, module._options.target.version]
				var arguments = @buildArguments(metadata)

				var mut next = 0
				for var argument in [...arguments.values].sort((a, b) => a.index - b.index) {
					while next != argument.index {
						variations.push(null)

						next += 1
					}

					argument.type.toVariations(variations)

					next += 1
				}

				var length = metadata.requirements.length / 3
				while next != length {
					variations.push(null)

					next += 1
				}

				var variationId = $fs.djb2a(variations.join())

				if upto.variations:!!!(Array).contains(variationId) {
					@metaRequirements = metadata
					@arguments = arguments
					@variationId = variationId

					if var data ?= @readMetadata(getExportsPath(@filename, variationId)) {
						@metaExports = data

						module.addHashes(@filename, upto.hashes)

						return
					}
				}
			}
		}

		var compiler = module.compiler().createServant(@filename)

		if @macro {
			compiler._options.libstd.enable = false
		}

		compiler.initiate(source)

		@metaRequirements = compiler.toRequirements()

		@arguments = @buildArguments(@metaRequirements)

		var arguments: Any[] = [false for var i from 0 to~ @metaRequirements.requirements.length / 3]

		for var argument in @arguments.values {
			arguments[argument.index] = {
				name: argument.identifier
				type: argument.type
			}
		}

		@scope.line(@line())

		for var argument in @arguments.values when argument.required {
			if !@scope.hasVariable(argument.name) {
				@scope.define(argument.name, true, argument.type, true, this)
			}
		}

		compiler.setArguments(arguments, @data.source.value, this)

		compiler.finish()

		compiler.writeFiles()

		@metaExports = compiler.toExports()

		module.addHashes(@filename, compiler.toHashes())

		@variationId = compiler.toVariationId()
	} # }}}
	loadNodeFile(filename: String? = null, mut moduleName: String? = null, alias: String? = null) { # {{{
		var module = @module()

		var mut file: String? = null
		if moduleName == null {
			file = moduleName = module.path(filename, @data.source.value)
		}

		if ?@data.arguments {
			for var argument in @data.arguments {
				if ?argument.name {
					SyntaxException.throwInvalidImportAliasArgument(this)
				}
				else {
					@addArgument(argument, false, @arguments)
				}
			}
		}
		else {
			@hasArguments = false
		}

		@isKSFile = false
		@moduleName = moduleName!?

		var type = Type.fromAST(@data.type, this).flagAlien()
		var container = type is ObjectType | NamespaceType

		if container {
			for var property of type.properties() {
				property.flagAlien().flagComplete()
			}
		}

		if !?#@data.specifiers {
			if ?alias {
				@alias = alias
			}
			else {
				var source =
					if var match ?= /^[A-Za-z]+:(.*)$/.exec(@data.source.value) {
						set match[1]
					}
					else {
						set @data.source.value
					}

				var parts = source.split('/')

				for var part in parts down while @alias == null when !/(?:^\.+$|^@)/.test(part) {
					var dots = part.split('.')
					var last = dots.length - 1

					if last == 0 {
						@alias = dots[0].replace(/[-_]+(.)/g, (m, l, ...) => l.toUpperCase())
					}
					else if $importExts.data[dots[last]] {
						@alias = dots.slice(0, last).join('.').replace(/[-_.]+(.)/g, (m, l, ...) => l.toUpperCase())
					}
					else if $importExts.source[dots[last]] {
						@alias = dots[last - 1].replace(/[-_]+(.)/g, (m, l, ...) => l.toUpperCase())
					}
					else {
						@alias = dots[last].replace(/[-_]+(.)/g, (m, l, ...) => l.toUpperCase())
					}
				}
			}

			unless ?@alias {
				SyntaxException.throwUnnamedWildcardImport(this)
			}

			@addVariable(@alias, @alias, false, type)
		}
		else {
			for var data in @data.specifiers {
				match data.kind {
					AstKind.GroupSpecifier {
						var mut aliasing = false

						for var modifier in data.modifiers {
							if modifier.kind == ModifierKind.Alias {
								aliasing = true
							}
							else if modifier.kind == ModifierKind.Exclusion {
								NotSupportedException.throw(`JavaScript import doesn't support exclusions`, this)
							}
						}

						if ?#data.elements {
							for var element in data.elements {
								match element.kind {
									AstKind.NamedSpecifier {
										match element.internal.kind {
											AstKind.Identifier {
												var internal = element.internal.name
												var external = element.external?.name ?? internal

												if aliasing {
													@addVariable(external, internal, false, type)

													@alias = internal
												}
												else {
													@addVariable(external, internal, true, null)
												}
											}
											AstKind.ObjectBinding {
												for var binding in element.internal.elements {
													var internal = binding.internal.name
													var external = binding.external?.name ?? internal

													@addVariable(external, internal, true, null)
												}
											}
											else {
												throw NotImplementedException.new()
											}
										}
									}
									else {
										throw NotImplementedException.new()
									}
								}
							}
						}
						else if container {
							for var property, name of type.properties() {
								@addVariable(name, name, true, property.type())
							}
						}
						else {
							throw NotImplementedException.new()
						}
					}
					AstKind.NamedSpecifier {
						var internal = data.internal.name
						var external = data.external?.name ?? internal

						var mut aliasing = false

						for var modifier in data.modifiers {
							if modifier.kind == ModifierKind.Alias {
								aliasing = true
							}
						}

						if aliasing {
							@addVariable(external, internal, false, type)

							@alias = internal
						}
						else {
							@addVariable(external, internal, true, type.getProperty(external))
						}
					}
					else {
						throw NotImplementedException.new()
					}
				}
			}
		}

		return true
	} # }}}
	loadNodeModule(moduleName) { # {{{
		var name = moduleName.substr(5)

		return @loadNodeFile(null, name, name)
	} # }}}
	loadNPMModule(moduleName, start) { # {{{
		var name = moduleName.substr(4)
		var dirs = $listNPMModulePaths(start)

		for var dir in dirs {
			var file = $path.join(dir, name)

			if @loadFile(file, '', name) || @loadDirectory(file, name) {
				return true
			}
		}

		return false
	} # }}}
	readMetadata(file) { # {{{
		try {
			return JSON.parse($fs.readFile(file), $fs.unescapeJSON)
		}
		catch {
			return null
		}
	} # }}}
	registerSyntimeFunction(name, macro) { # {{{
		@parent.registerSyntimeFunction(name, macro)
	} # }}}
	toImportFragments(fragments, destructuring: Boolean = true) { # {{{
		if @isKSFile {
			@toKSFileFragments(fragments, destructuring)
		}
		else {
			@toNodeFileFragments(fragments, destructuring)
		}
	} # }}}
	toKSFileFragments(fragments, destructuring: Boolean) { # {{{
		if @count == 0 {
			if ?@alias {
				var line = fragments
					.newLine()
					.code('var ', @alias, ' = ')

				@toRequireFragments(line)

				line.done()
			}
			else if @arguments.values.length != 0 {
				var line = fragments.newLine()

				@toRequireFragments(line)

				line.done()
			}
		}
		else {
			if ?@alias {
				var line = fragments
					.newLine()
					.code('var ', @reuseName, ' = ')

				@toRequireFragments(line)

				line.done()
			}

			if @count == 1 {
				var dyn variable, name

				// TODO remove loop to get first element
				for variable, name of @variables {
				}

				if variable.system || variable.specter {
					var line = fragments
						.newLine()
						.code(`var __ks_\(variable.name) = `)

					@toRequireFragments(line)

					line.code(`.__ks_\(name)`).done()
				}
				else {
					var line = fragments
						.newLine()
						.code(`var \(variable.name) = `)

					@toRequireFragments(line)

					line.code(`.\(name)`).done()
				}
			}
			else if destructuring {
				@toVariablesFragments((fragments) => @toRequireFragments(fragments), fragments)
			}
			else {
				var late varname

				if @reusable {
					varname = @reuseName
				}
				else {
					var line = fragments.newLine().code('var __ks__ = ')

					@toRequireFragments(line)

					line.done()

					varname = @reuseName = '__ks__'
				}
			}
		}
	} # }}}
	toLibSTDFragments(type: Boolean, usages: String[], fragments) { # {{{
		var line = fragments.newLine().code('const {')

		for var name, index in usages {
			line
				..code(', ') if index > 0
				..code(`__ksStd_\(name.substr(0, 1).toLowerCase())`)
		}

		if type {
			line
				..code(', ') if ?#usages
				..code(`__ksStd_types`)
		}

		line.code('} = ')

		@toRequireFragments(line)

		line.done()
	} # }}}
	toNodeFileFragments(fragments, destructuring: Boolean) { # {{{
		if @count == 0 {
			if @alias != null {
				var line = fragments
					.newLine()
					.code('var ', @alias, ' = ')

				@toRequireFragments(line)

				line.done()
			}
		}
		else {
			if @alias != null {
				var line = fragments
					.newLine()
					.code('var ', @reuseName, ' = ')

				@toRequireFragments(line)

				line.done()
			}

			if @count == 1 {
				var dyn variable, name

				for variable, name of @variables {
				}

				var line = fragments
					.newLine()
					.code(`var \(variable.name) = `)

				@toRequireFragments(line)

				line.code(`.\(name)`).done()
			}
			else if @count > 0 {
				if destructuring {
					var mut line = fragments.newLine().code('var {')

					var mut nf = false
					for var variable, name of @variables {
						if nf {
							line.code(', ')
						}
						else {
							nf = true
						}

						if variable.name == name {
							line.code(name)
						}
						else {
							line.code(name, ': ', variable.name)
						}
					}

					line.code(`} = `)

					@toRequireFragments(line)

					line.done()
				}
				else {
					var mut line = fragments
						.newLine()
						.code(`var __ks__ = `)

					@toRequireFragments(line)

					line.done()
				}
			}
		}
	} # }}}
	toRequireFragments(fragments) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else {
			if @isKSFile {
				var mut modulePath = ''

				if @pathAddendum.length > 0 {
					var dirname = $path.dirname(@pathAddendum)
					var basename = $path.basename(@pathAddendum)

					modulePath = `\(@moduleName)\($path.sep)\(dirname)\($path.sep).\(basename)\(@extAddendum).\(@variationId).ksb`
				}
				else if $localFileRegex.test(@moduleName) {
					var basename = $path.basename(@moduleName)

					if basename.endsWith($extensions.source) {
						var late dirname

						if @parent.includePath() == null {
							dirname = $path.dirname(@moduleName)
						}
						else {
							dirname = $path.dirname(@parent.includePath())
						}

						modulePath = `\(dirname)\($path.sep).\(basename).\(@variationId).ksb`
					}
					else {
						modulePath = @moduleName
					}
				}
				else {
					var dirname = $path.dirname(@moduleName)
					var basename = $path.basename(@moduleName)

					modulePath = `\(dirname)\($path.sep).\(basename)\(@extAddendum).\(@variationId).ksb`
				}

				fragments.code(`require(\($quote(modulePath)))`)
			}
			else {
				fragments.code(`require(\($quote(@moduleName)))`)
			}

			if @hasArguments {
				fragments.code(`(`)

				for var argument, index in @arguments.values when argument.isApproved && argument.index != null {
					fragments.code($comma) if index > 0

					if argument.isIdentifier && argument.type.isSystem() {
						if argument.auxiliary {
							fragments.code(`__ks_\(argument.identifier)`)
						}
						else if argument.required {
							fragments.code(`__ks_\(argument.identifier) || {}`)
						}
						else if argument.type.isRequirement() {
							fragments.code(`__ks_\(argument.identifier)`)
						}
						else {
							fragments.code(`{}`)
						}
					}
					else {
						fragments.compile(argument.value)

						 if argument.isIdentifier && argument.type.isSealed() {
						 	if argument.auxiliary {
								fragments.code(`, __ks_\(argument.identifier)`)
							}
							else if argument.required {
								fragments.code(`, __ks_\(argument.identifier) || {}`)
							}
							else if argument.type.isRequirement() {
								fragments.code(`, __ks_\(argument.identifier)`)
							}
							else {
								fragments.code(`, {}`)
							}
						}
					}
				}

				fragments.code(`)`)
			}

			@reusable = true
		}
	} # }}}
	toVariablesFragments(callback, fragments) { # {{{
		var line = fragments.newLine().code('var {')

		var mut nf = false
		for var variable, name of @variables {
			if nf {
				line.code(', ')
			}
			else {
				nf = true
			}

			if variable.name == name {
				if $virtuals[name] {
					line.code(`__ks_\(name)`)
				}
				else {
					if variable.system || variable.specter {
						line.code(`__ks_\(name)`)
					}
					else {
						line.code(name)

						if variable.sealed {
							line.code(`, __ks_\(name)`)
						}
					}
				}
			}
			else {
				if variable.system || variable.specter {
					line.code(`__ks_\(name): __ks_\(variable.name)`)
				}
				else {
					line.code(`\(name): \(variable.name)`)

					if variable.sealed {
						line.code(`, __ks_\(name): __ks_\(variable.name)`)
					}
				}
			}
		}

		line.code('} = ')

		callback(line)

		line.done()
	} # }}}
	private validateRequirement(required: Boolean | Number, name: String, metadata) { # {{{
		if required {
			SyntaxException.throwMissingRequirement(name, this)
		}
		else if @mode() == ImportMode.Import && required is Number {
			for var i from 0 to~ metadata.aliens.length step 3 {
				if metadata.aliens[i] == required {
					metadata.aliens[i + 2] = true
					break
				}
			}
		}
	} # }}}
}

class ImportDeclaration extends Statement {
	private {
		@declarators = []
		@macro: Boolean						= false
		@standardLibrary: Boolean			= false
	}
	initiate() { # {{{
		for var data in @data.declarations {
			var declarator = ImportDeclarator.new(data, this)
				..flagMacro() if @macro
				..flagStandardLibrary() if @standardLibrary
				..initiate()

			@declarators.push(declarator)
		}
	} # }}}
	analyse() { # {{{
		for var declarator in @declarators {
			declarator.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var declarator in @declarators {
			declarator.prepare()
		}
	} # }}}
	translate()
	flagMacro() { # {{{
		@macro = true
	} # }}}
	flagStandardLibrary() { # {{{
		@standardLibrary = true
	} # }}}
	registerSyntimeFunction(name, macro) { # {{{
		@parent.registerSyntimeFunction(name, macro)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		return if @standardLibrary

		for var declarator in @declarators {
			declarator.toFragments(fragments, mode)
		}
	} # }}}
}

class ImportDeclarator extends Importer {
	flagForcefullyRebinded()
	override mode() => ImportMode.Import
	toStatementFragments(fragments, mode) { # {{{
		@toImportFragments(fragments)
	} # }}}
}

class ImportWorker {
	private {
		@metaExports
		@metaRequirements
		@node
		@scope: Scope
	}
	constructor(@metaRequirements, @metaExports, @node) { # {{{
		@scope = ImportScope.new(node.scope())
	} # }}}
	hasType(name: String) => @scope.hasDefinedVariable(name)
	getType(name: String) => @scope.getDefinedVariable(name).getDeclaredType()
	prepare(arguments) { # {{{
		var module = @node.module()
		var references = {}
		var queue = []
		var variables = {}

		var metadata = [...@metaRequirements.references!?, ...@metaExports.references!?]

		var alterations = {mode: @node.mode()}

		var newAliens = {}
		var oldAliens = []

		for var i from 0 to~ @metaRequirements.aliens.length step 3 {
			var index = @metaRequirements.aliens[i]
			var name = @metaRequirements.aliens[i + 1]
			var mut type = null

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)

				if var origin ?= type.origin() {
					type.origin(origin:!!!(TypeOrigin) + TypeOrigin.Extern + TypeOrigin.Import)
				}
				else {
					type.origin(TypeOrigin.Extern + TypeOrigin.Import)
				}
			}
			else {
				type = references[index]
			}

			type = Type.toNamedType(name, type)

			if @metaRequirements.aliens[i + 2] {
				type = type.flagRequired()
			}

			if var alien ?= module.getAlien(name) {
				oldAliens.push(name, type, alien)

				references[index] = alien
			}
			else {
				newAliens[name] = index

				references[index] = type
			}
		}

		while queue.length > 0 {
			queue.shift()()
		}

		for var name, index in oldAliens step 3 {
			var newType = oldAliens[index + 1]
			var oldType = oldAliens[index + 1]

			if !oldType.isSubsetOf(newType, MatchingMode.Signature) {
				TypeException.throwNotCompatibleAlien(name, @node.data().source.value, @node)
			}
		}

		if @metaRequirements.requirements.length > 0 {
			var reqReferences = {...references}

			for var i from 0 to~ @metaRequirements.requirements.length step 3 {
				var index = @metaRequirements.requirements[i]
				var name = @metaRequirements.requirements[i + 1]
				var type = references[index] ?? Type.import(index, metadata, reqReferences, alterations, queue, @scope, @node)

				reqReferences[index] = Type.toNamedType(name, type)
			}

			while queue.length > 0 {
				queue.shift()()
			}

			for var i from 0 to~ @metaRequirements.requirements.length step 3 {
				var name = @metaRequirements.requirements[i + 1]
				var type = reqReferences[@metaRequirements.requirements[i]]

				if var index ?= arguments.toImport[name] {
					var argument = arguments.values[index]

					if !argument.required && !type.isAny() && !argument.type.isSubsetOf(type, MatchingMode.Signature) {
						if argument.isAutofill {
							argument.isApproved = false
						}
						else {
							TypeException.throwNotCompatibleArgument(argument.name, name, @node.data().source.value, @node)
						}
					}
				}
			}

			for var i from 0 to~ @metaRequirements.requirements.length step 3 {
				var reqIndex = @metaRequirements.requirements[i]
				var name = @metaRequirements.requirements[i + 1]

				if var index ?= arguments.toImport[name] {
					var argument = arguments.values[index]

					if argument.isApproved {
						if argument.required {
							argument.type = reqReferences[reqIndex]
							argument.auxiliary = argument.type.hasAuxiliary()
						}

						if var type ?= references[reqIndex] {
							if !argument.type.isSubsetOf(type, MatchingMode.Signature) {
								TypeException.throwNotCompatibleAlien(name, @node.data().source.value, @node)
							}
						}

						references[reqIndex] = argument.type
					}
				}
				else if var type ?= references[reqIndex] {
					references[reqIndex] = type.flagRequired()
				}
			}
		}

		if !@node.isStandardLibrary() {
			for var index, name of newAliens {
				module.addAlien(name, references[index])
			}
		}

		for var i from 0 to~ @metaRequirements.requirements.length step 3 {
			var index = @metaRequirements.requirements[i]
			var name = @metaRequirements.requirements[i + 1]
			var late type

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)

				type.origin(TypeOrigin.Require)
			}
			else {
				type = references[index]

				var origin = type.origin()
				if ?origin {
					type.origin(origin:!!!(TypeOrigin) + TypeOrigin.Require)
				}
				else {
					type.origin(TypeOrigin.Require + TypeOrigin.Import)
				}
			}

			references[index] = Type.toNamedType(name, type)
		}

		var enums = []

		for var i from 0 to~ @metaExports.exports.length step 2 {
			var index = @metaExports.exports[i]
			var name = @metaExports.exports[i + 1]
			var mut type = null

			if !?references[index] {
				type = Type.import(index, metadata, references, alterations, queue, @scope, @node)
			}
			else {
				type = references[index]
			}

			if type is EnumType {
				enums.push({ type, name })
			}

			type = Type.toNamedType(name, type)

			if var variable ?= @scope.getDefinedVariable(name) {
				variable.setDeclaredType(type)
			}
			else {
				@scope.addVariable(name, Variable.new(name, false, false, type), @node)

				variables[index] = true
			}

			references[index] = type
		}

		for var i from 0 to~ @metaRequirements.aliens.length step 3 {
			var index = @metaRequirements.aliens[i]
			var name = @metaRequirements.aliens[i + 1]

			if !@scope.hasVariable(name) {
				@scope.addVariable(name, Variable.new(name, false, false, references[index]), @node)

				variables[index] = true
			}
		}

		for var _, index in metadata {
			if !?references[index] {
				var type = Type.toNamedType(
					Type.import(index, metadata, references, alterations, queue, @scope, @node)
					true
					@scope
					@node
				)

				references[index] = type
			}
			else if !variables[index] {
				var type = references[index]

				if type is NamedType && !@scope.hasVariable(type.name()) {
					@scope.define(type.name(), true, type, @node)
				}
			}
		}

		while ?#queue {
			queue.shift()()
		}

		for var { type, name } in enums {
			type.fillProperties(name, @node)
		}
	} # }}}
	scope() => @scope
}
