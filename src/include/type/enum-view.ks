class EnumViewType extends Type {
	private late {
		@aliases: Object<EnumAliasType>		= {}
		@elements: String[]					= []
		@excludeds: String[]?
		@exclusion: Boolean					= false
		@master: Type
		@root: EnumType | EnumViewType
		// TODO move to alias
		@testName: String?
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): EnumViewType { # {{{
			var type = EnumViewType.new(scope)

			for var element in data.elements {
				type.addElement(element)
			}

			queue.push(() => {
				type.master(Type.import(data.master, metadata, references, alterations, queue, scope, node))
			})

			return type.flagComplete()
		} # }}}
	}
	addElement(name: String) { # {{{
		@elements.pushUniq(name)
	} # }}}
	override canBeNullable() => false
	override canBeRawCasted() => true
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	compareToRef(value: AnyType, equivalences: String[][]? = null) => 1
	compareToRef(value: NullType, equivalences: String[][]? = null) => -1
	explodeVarnames(...values: { name: String }): String[] { # {{{
		var result = []

		for var { name } in values {
			if var alias ?= @aliases[name] {
				result.pushUniq(name, ...alias.originals()!?)
			}
			else if @elements.contains(name) {
				result.pushUniq(name)
			}
		}

		return result
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		return {
			kind: TypeKind.EnumView
			master: @master.toReference(references, indexDelta, mode, module)
			@elements
		}
	} # }}}
	override finalize(data, generics, node) { # {{{
		if ?#@elements {
			return unless @exclusion

			var elements = []

			for var value in @root.values() {
				elements.push(value.name())
			}

			for var element in @elements {
				elements.remove(@root.getTopProperty(element))
			}

			@excludeds = @elements
			@elements = elements
		}
		else {
			var mut source = `func(`
			var mut comma = false
			var fields = ['index', 'name', 'value']
			var types: Type{} = {}
			var dynamics: String[]{} = {}

			for var field, name of @root.fields() {
				if comma {
					source += ', '
				}
				else {
					comma = true
				}

				var type = field.type()

				if type.isNative() {
					source += `\(name): \(type.name())`
				}
				else {
					source += `mut _\(name)`

					types[type.name()] = type.discard()

					dynamics[type.name()] ??= []
					dynamics[type.name()].push(name)
				}

				fields.pushUniq(name)
			}

			source += `): Boolean`

			if ?#types {
				source += ` {\n`

				var mut auxiliary = ''

				for var type, name of types {
					var ast = type.toASTData(name)

					auxiliary += `\(KSGeneration.generate(ast))\n`

					for var field in dynamics[name] {
						source += `var \(field): \(name) = eval(_\(field))!!\n`
					}
				}

				source += `return \(KSGeneration.generate(data.typeSubtypes))\n`
				source += `}`

				var filter = Syntime.evaluate($compileTest(@master.name(), source, auxiliary)).__ks_0

				for var value in @root.values() {
					var args = [value.index(), value.name(), value.value()]

					for var name in fields from 3 {
						args.push(value.argument(name))
					}

					if filter(...args) {
						@elements.push(value.name())
					}
				}
			}
			else {
				source += ` => \(KSGeneration.generate(data.typeSubtypes))`

				var filter = Syntime.evaluate($compileTest(@master.name(), source)).__ks_0

				for var value in @root.values() {
					var args = [value.index(), value.name(), value.value()]

					for var name in fields from 3 {
						args.push(value.argument(name))
					}

					if filter(...args) {
						@elements.push(value.name())
					}
				}
			}

			for var alias, name of @root.getOnlyAliases() {
				var mut matched = true

				for var original in alias.originals() {
					if !@elements.contains(original) {
						matched = false

						break
					}
				}

				if matched {
					@aliases[name] = alias
				}
			}

			unless ?#@elements {
				NotImplementedException.throw()
			}
		}
	} # }}}
	flagExclusion() { # {{{
		@exclusion = true
	} # }}}
	getOnlyAliases() => @aliases
	getOriginalValueCount(...names: { name: String }): Number { # {{{
		var mut result = 0

		for var { name } in names {
			if var value ?= @aliases[name] {
				result += value.originals().length:!!!(Number)
			}
			else {
				result += 1
			}
		}

		return result
	} # }}}
	getValue(name: String) { # {{{
		if @elements.contains(name) {
			return @root.getValue(name)
		}

		return null
	} # }}}
	getTestName() => @testName
	getTopProperty(name: String): String => @root.getTopProperty(name)
	hashCode(): String { # {{{
		var mut hash = `^\(@master.hashCode())(`

		for var name, index in @elements {
			hash += ',' if index != 0
			hash += name
		}

		hash += ')'

		return hash
	} # }}}
	override hasInvalidProperty(name) => @exclusion && @excludeds.contains(name)
	override hasProperty(name) => @elements.contains(name)
	hasValue(name: String) => @elements.contains(name)
	assist isAssignableToVariable(value: NamedType, anycast, nullcast, downcast, limited) { # {{{
		return false unless value.isEnum()
		return @isAssignableToVariable(value.type(), anycast, nullcast, downcast, limited)
	} # }}}
	assist isAssignableToVariable(value: EnumType, anycast, nullcast, downcast, limited) { # {{{
		return @root == value
	} # }}}
	override isComplex() => true
	override isEnum() => true
	override isExportable() => true
	override isExportable(module) => true
	assist isSubsetOf(value: EnumViewType, generics, subtypes, mode) { # {{{
		return this == value
	} # }}}
	override isSubsetOf(value, generics, subtypes, mode) { # {{{
		return @master.isSubsetOf(value, generics, subtypes, mode)
	} # }}}
	override isView() => true
	listVarnames(): String[] { # {{{
		var result = [...@elements]

		for var alias of @aliases {
			result.pushUniq(...alias.originals()!?)
		}

		return result
	} # }}}
	master() => @master
	master(@master) { # {{{
		var type = @master.discard()

		unless type is EnumType | EnumViewType {
			NotImplementedException.throw()
		}

		@root = type
	} # }}}
	path() => @master.path()
	root() => @root
	setTestName(@testName)
	override shallBeNamed() => true
	override toAwareTestFunctionFragments(varname, mut nullable, _, _, _, generics, subtypes, fragments, node) { # {{{
		fragments.code(`\(@testName)`)
	} # }}}
	override toBlindTestFragments(_, _, _, _, _, _, fragments, node) { # {{{
		fragments.code(`\(@testName)`)
	} # }}}
	override toBlindTestFunctionFragments(funcname, varname, _, testingType, generics, fragments, node) { # {{{
		fragments.code(`\(varname) => `)

		for var element, index in @elements {
			fragments
				.code(' || ') if index != 0
				.code(`\(varname) === `).compile(@master).code(`.\(element)`)
		}
	} # }}}
	override toFragments(fragments, node) { # {{{
		fragments.compile(@master)
	} # }}}
	override toQuote() { # {{{
		var mut fragments = `\(@master.toQuote())(`

		for var name, index in @elements {
			fragments += ', ' if index != 0
			fragments += name
		}

		fragments += ')'

		return fragments
	} # }}}
	override toPositiveTestFragments(parameters, subtypes, junction, fragments, node) { # {{{
		fragments.code(`\(@testName)(`).compile(node).code(')')
	} # }}}
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
	values() => @root.values().filter((value, ...) => @elements.contains(value.name()))
}

func $compileTest(name: String, source: String, auxiliary: String = ''): String { # {{{
	var compiler = Compiler.new(`_ks_view_\(name)`, {
		register: false
		target: Syntime.target
		libstd: {
			enable: false
		}
	})

	compiler.compile(```
		extern console, eval, JSON

		\(auxiliary)

		return \(source)
		```)

	return compiler.toSource()
} # }}}
