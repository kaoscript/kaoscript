enum VariantKind {
	Boolean
	Enum
}

class VariantType extends Type {
	private late {
		@deferrable: Boolean			= false
		@enum: EnumType?
		@fields: Variant[]				= []
		@kind: VariantKind				= .Enum
		@master: Type
		@names: Variant{}				= {}
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): VariantType { # {{{
			var type = VariantType.new(scope)

			queue.push(() => {
				type.setMaster(Type.import(data.master, metadata, references, alterations, queue, scope, node))

				for var { names, type % data } in data.fields {
					type.addField(names, Type.import(data, metadata, references, alterations, queue, scope, node))
				}
			})

			return type.flagComplete()
		} # }}}
	}
	addField(names: String[], type: Type) { # {{{
		if @kind == .Boolean {
			if names.contains('false') {
				unless !names.contains('true') {
					NotImplementedException.throw()
				}
			}
			else if names.contains('true') {
				unless !names.contains('false') {
					NotImplementedException.throw()
				}
			}
			else {
				NotImplementedException.throw()
			}
		}

		var variant = { names, type }

		@fields.push(variant)
		@deferrable ||= type.canBeDeferred()

		for var name in names {
			unless !?@names[name] {
				NotImplementedException.throw()
			}

			@names[name] = variant
		}
	} # }}}
	override canBeBoolean() => @kind == .Boolean
	override canBeDeferred() => @deferrable
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	discardVariable() => @master
	override export(references, indexDelta, mode, module) { # {{{
		var export = {
			kind: TypeKind.Variant
			master: @master.toReference(references, indexDelta, mode, module)
			fields: []
		}

		for var { names, type } in @fields {
			export.fields.push({
				names
				type: type.export(references, indexDelta, mode, module)
			})
		}

		return export
	} # }}}
	getEnumType() => @enum
	getField(name: String) => @names[name]
	getFieldIndex(name: String): Number? { # {{{
		if var field ?= @names[name] {
			return @fields.indexOf(field)
		}
		else {
			return null
		}
	} # }}}
	getFields() => @fields
	getKind() => @kind
	getMainName(name: String): String? { # {{{
		if var field ?= @names[name] {
			return field.names[0]
		}
		else if @kind == .Enum {
			return name if @enum.hasProperty(name)
		}
		else {
			return name if name == 'true' | 'false'
		}

		return null
	} # }}}
	getMaster() => @master
	hasSubtype(name: String) { # {{{
		if @kind == .Enum {
			return @enum.hasProperty(name)
		}
		else {
			return name == 'false' | 'true'
		}
	} # }}}
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		NotImplementedException.throw()
	} # }}}
	override isBoolean() => @kind == .Boolean
	isFalseValue(name: String): Boolean { # {{{
		if var { names } ?= @names[name] {
			return names.contains('false')
		}
		else {
			return false
		}
	} # }}}
	assist isSubsetOf(value: VariantType, generics, subtypes, mode) { # {{{
		return this == value
	} # }}}
	isValidField({ names }: Variant, subtypes: AltType[]?) { # {{{
		return true unless #subtypes

		for var { name } in subtypes {
			if names.contains(name) {
				return true
			}
		}

		return false
	} # }}}
	setMaster(@master) { # {{{
		if @master.isBoolean() {
			@kind = .Boolean
		}
		else if @master.isEnum() {
			var type = @master.discard()

			unless type is EnumType {
				NotImplementedException.throw()
			}

			@enum = type
		}
		else {
			NotImplementedException.throw()
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, _, generics, fragments, node) { # {{{
		match @kind {
			.Boolean {
				var block = fragments.code('variant =>').newBlock()

				block
					.newControl()
					.code(`if(!\($runtime.type(node)).isBoolean(variant))`)
					.step()
					.line('return false')
					.done()

				block
					.newControl()
					.code(`if(filter && !filter(variant))`)
					.step()
					.line('return false')
					.done()

				var ctrl = block
					.newControl()
					.code(`if(variant)`)
					.step()

				if @deferrable {
					ctrl.line(`return __ksType.\(funcname).__1(\(varname)\(@names.true.type.canBeDeferred() ? ', mapper' : ''))`)
				}
				else {
					var line = ctrl.newLine().code(`return `)

					@names.true.type.toBlindTestFragments(varname, false, false, generics, Junction.NONE, line, node)

					line.done()
				}

				ctrl.step().code('else').step()

				if @deferrable {
					ctrl.line(`return __ksType.\(funcname).__0(\(varname)\(@names.false.type.canBeDeferred() ? ', mapper' : ''))`)
				}
				else {
					var line = ctrl.newLine().code(`return `)

					@names.false.type.toBlindTestFragments(varname, false, false, generics, Junction.NONE, line, node)

					line.done()
				}

				ctrl.done()

				block.done()
			}
			.Enum {
				var block = fragments.code('variant =>').newBlock()

				block
					.newControl()
					.code(`if(!\($runtime.type(node)).isEnumInstance(variant, `).compile(@master).code(`))`)
					.step()
					.line('return false')
					.done()

				block
					.newControl()
					.code(`if(filter && !filter(variant))`)
					.step()
					.line('return false')
					.done()

				for var { names, type }, index in @fields {
					var ctrl = block
						.newControl()
						.code(`if(variant === \(@master.name()).\(names[0]))`)
						.step()

					if @deferrable {
						ctrl.line(`return __ksType.\(funcname).__\(index)(\(varname)\(type.canBeDeferred() ? ', mapper' : ''))`)
					}
					else {
						var line = ctrl.newLine().code(`return `)

						type.toBlindTestFragments(varname, false, false, generics, Junction.NONE, line, node)

						line.done()
					}

					ctrl.done()
				}

				block
					.line('return true')
					.done()
			}
		}
	} # }}}
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toQuote() { # {{{
		var mut fragments = 'variant { '

		for var name, index in Object.keys(@fields) {
			fragments += index == 0 ? name : `, \(name)`
		}

		fragments += ' }'

		return fragments
	} # }}}
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
}
