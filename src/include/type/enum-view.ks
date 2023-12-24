class EnumViewType extends Type {
	private late {
		@elements: String[]		= []
		@master: EnumType
		// TODO NamedType
		@name: String
		// TODO move to alias
		@testName: String?
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): EnumViewType { # {{{
			var type = EnumViewType.new(scope, data.name)

			for var element in data.elements {
				type.addElement(element)
			}

			queue.push(() => {
				var master = Type.import(data.master, metadata, references, alterations, queue, scope, node)

				type.setMaster(master.discard())
			})

			return type.flagComplete()
		} # }}}
	}
	constructor(@scope, @name, @master) { # {{{
		super(scope)
	} # }}}
	addElement(name: String) { # {{{
		@elements.pushUniq(name)
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		return {
			kind: TypeKind.EnumView
			@name
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

		for var field, name of @master.fields() {
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

			for var value of @master.values() {
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

			for var value of @master.values() {
				var args = [value.index(), value.name(), value.value()]

				for var name in fields from 3 {
					args.push(value.argument(name))
				}

				if filter(...args) {
					@elements.push(value.name())
				}
			}
		}

		unless ?#@elements {
			NotImplementedException.throw()
		}
	} # }}}
	getValue(name: String) { # {{{
		if @elements.contains(name) {
			return @master.getValue(name)
		}

		return null
	} # }}}
	getTestName() => @testName
	hashCode(): String { # {{{
		var mut hash = `^\(@name)(`

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
		return true if @name == value.name()
		return @isAssignableToVariable(value.type(), anycast, nullcast, downcast, limited)
	} # }}}
	assist isAssignableToVariable(value: EnumType, anycast, nullcast, downcast, limited) { # {{{
		return @master == value
	} # }}}
	override isComplex() => true
	override isEnum() => true
	override isExportable() => true
	override isView() => true
	master() => @master
	name() => @name
	setTestName(@testName)
	override toAwareTestFunctionFragments(varname, mut nullable, _, generics, subtypes, fragments, node) { # {{{
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
				.code(`\(varname) === \(@name).\(element)`)
		}
	} # }}}
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toQuote() { # {{{
		var mut fragments = `\(@name)(`

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

	private {
		constructor(@scope, @name) { # {{{
			super(scope)
		} # }}}
		setMaster(@master)
	}
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
