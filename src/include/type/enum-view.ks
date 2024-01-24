class EnumViewType extends Type {
	private late {
		@aliases: Object<EnumAliasType>			= {}
		@elements: String[]						= []
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
	override canBeRawCasted() => true
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
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
		return if ?#@elements

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
				var data = type.toASTData(name)

				auxiliary += `\(Generator.generate(data))\n`

				for var field in dynamics[name] {
					source += `var \(field): \(name) = eval(_\(field))\n`
				}
			}

			source += `return \(Generator.generate(data.typeSubtypes))\n`
			source += `}`

			var filter = $evaluate($compileTest(source, auxiliary)).__ks_0

			for var value of @root.values() {
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
			source += ` => \(Generator.generate(data.typeSubtypes))`

			var filter = $evaluate($compileTest(source)).__ks_0

			for var value of @root.values() {
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
	} # }}}
	getOnlyAliases() => @aliases
	getOriginalValueCount(...names: { name: String }): Number { # {{{
		var mut result = 0

		for var { name } in names {
			if var value ?= @aliases[name] {
				result += value.originals().length:!(Number)
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
	hashCode(): String { # {{{
		var mut hash = `^\(@master.hashCode())(`

		for var name, index in @elements {
			hash += ',' if index != 0
			hash += name
		}

		hash += ')'

		return hash
	} # }}}
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
	root() => @root
	setTestName(@testName)
	override toAwareTestFunctionFragments(varname, mut nullable, _, _, generics, subtypes, fragments, node) { # {{{
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
}

func $compileTest(source: String, auxiliary: String = ''): String { # {{{
	var compiler = Compiler.new('__ks__', {
		register: false
		target: $target
	})

	var data = `extern console, eval, JSON\n\(auxiliary)\nreturn \(source)`

	compiler.compile(data)

	return compiler.toSource()
} # }}}
