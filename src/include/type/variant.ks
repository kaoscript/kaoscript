enum VariantKind {
	Boolean
	Enum
}

class VariantType extends Type {
	private late {
		@aliases: Variant{}						= {}
		@deferrable: Boolean					= false
		@enum: EnumType | EnumViewType | Null
		@fields: Variant[]						= []
		@kind: VariantKind						= .Enum
		@master: Type
		@names: Variant{}						= {}
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): VariantType { # {{{
			var type = VariantType.new(scope)

			queue.push(() => {
				type.setMaster(Type.import(data.master, metadata, references, alterations, queue, scope, node))

				for var { names, type % data } in data.fields {
					type.addField(names, Type.import(data, metadata, references, alterations, queue, scope, node))
				}

				type.buildAliases(node)
			})

			return type.flagComplete()
		} # }}}
	}
	addField(names: String[], type: Type) { # {{{
		var mut value = null

		if @kind == .Boolean {
			if names.contains('false') {
				unless !names.contains('true') {
					NotImplementedException.throw()
				}

				value = ValueType.new(false, @scope.reference('Boolean'), 'false', @scope)
			}
			else if names.contains('true') {
				unless !names.contains('false') {
					NotImplementedException.throw()
				}

				value = ValueType.new(false, @scope.reference('Boolean'), 'true', @scope)
			}
			else {
				NotImplementedException.throw()
			}
		}
		else {
			value = ValueType.new(@master, `\(@master.path()).\(names[0])`, @scope)
		}

		var variant = { names, type, value }

		@fields.push(variant)
		@deferrable ||= type.canBeDeferred()

		for var name in names {
			unless !?@names[name] {
				NotImplementedException.throw()
			}

			@names[name] = variant
		}
	} # }}}
	buildAliases(node: AbstractNode) { # {{{
		return unless @kind == .Enum

		for var value of @enum.getOnlyAliases() {
			block value {
				if var field ?= @names[value.original()] {
					var mut type = field.type

					for var original in value.originals() from 1 {
						if ?@names[original] {
							type = type.merge(@names[original].type, null, null, true, node)
						}
						else {
							break value
						}
					}

					@aliases[value.name()] = { names: value.originals(), type }
				}
			}
		}
	} # }}}
	override canBeBoolean() => @kind == .Boolean
	override canBeDeferred() => @deferrable
	override canBeRawCasted() => @master.canBeRawCasted()
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	discardVariable() => @master
	explodeVarnames(...values: { name: String }): String[] { # {{{
		if @kind == .Enum {
			return @enum.explodeVarnames(...values)
		}
		else {
			var result = []

			for var { name } in values {
				var { names } = @names[name]

				result.pushUniq(...names)
			}

			return result
		}
	} # }}}
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
	override flagReferenced() { # {{{
		for {
			var { type } in @fields
			var property, name of type.properties()
		}
		then {
			property.flagIndirectlyReferenced()
		}

		return this
	} # }}}
	getAlias(name: String) => @aliases[name]
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
	getVariantType() => this
	hashCode() => `~\(@master.hashCode())`
	hasSubtype(name: String) { # {{{
		if ?@names[name] {
			return true
		}
		else if @kind == .Enum {
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
	isEmpty() => @fields.length == 0
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
	isTrueValue(name: String): Boolean { # {{{
		if var { names } ?= @names[name] {
			return names.contains('true')
		}
		else {
			return false
		}
	} # }}}
	isValidField({ names }: Variant, subtypes: AltType[]?) { # {{{
		return true unless ?#subtypes

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

			unless type is EnumType | EnumViewType {
				NotImplementedException.throw()
			}

			@enum = type
		}
		else {
			NotImplementedException.throw()
		}
	} # }}}
	override toBlindSubtestFunctionFragments(funcname, varname, casting, propname, _, generics, fragments, node) { # {{{
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

					if @names.true.type is ObjectType {
						@names.true.type.toBlindTestFragments(funcname, varname, casting, false, false, generics, null, Junction.NONE, line, node)
					}
					else {
						@names.true.type.toBlindTestFragments(funcname, varname, casting, generics, null, Junction.NONE, line, node)
					}

					line.done()
				}

				ctrl.step().code('else').step()

				if @deferrable {
					ctrl.line(`return __ksType.\(funcname).__0(\(varname)\(@names.false.type.canBeDeferred() ? ', mapper' : ''))`)
				}
				else {
					var line = ctrl.newLine().code(`return `)

					if @names.false.type is ObjectType {
						@names.false.type.toBlindTestFragments(funcname, varname, casting, false, false, generics, null, Junction.NONE, line, node)
					}
					else {
						@names.false.type.toBlindTestFragments(funcname, varname, casting, generics, null, Junction.NONE, line, node)
					}

					line.done()
				}

				ctrl.done()

				block.done()
			}
			.Enum {
				var block = fragments.code('variant =>').newBlock()

				var ctrl = block
					.newControl()
					.code(`if(cast)`)
					.step()

				var ifCtrl = ctrl.newControl()

				if @enum is EnumType {
					ifCtrl.code(`if((variant = `).compile(@master).code(`(variant)) === null)`)
				}
				else {
					ifCtrl.code(`if((variant = `).compile(@enum).code(`(variant)) === null || !\(@enum.getTestName())(variant))`)
				}

				ifCtrl
					.step()
					.line('return false')
					.done()

				ctrl
					.line(`\(varname)[\(propname)] = variant`)
					.step()

				if @enum is EnumType {
					ctrl.code(`else if(!\($runtime.type(node)).isEnumInstance(variant, `).compile(@master).code(`))`)
				}
				else {
					ctrl.code(`else if(!\(@enum.getTestName())(variant))`)
				}

				ctrl
					.step()
					.line('return false')
					.done()

				block
					.newControl()
					.code(`if(filter && !filter(variant))`)
					.step()
					.line('return false')
					.done()

				var root = @enum is EnumType ? @master : @enum

				for var { names, type }, index in @fields {
					var ctrl = block
						.newControl()
						.code(`if(variant === `).compile(root).code(`.\(names[0]))`)
						.step()

					if @deferrable {
						ctrl.line(`return __ksType.\(funcname).__\(index)(\(varname)\(type.canBeDeferred() ? ', mapper' : ''))`)
					}
					else {
						var line = ctrl.newLine().code(`return `)

						if type is ObjectType {
							type.toBlindTestFragments(funcname, varname, casting, false, false, generics, null, Junction.NONE, line, node)
						}
						else {
							type.toBlindTestFragments(funcname, varname, casting, generics, null, Junction.NONE, line, node)
						}

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
	toFilterFragments(varname: String, subtypes: AltType[], fragments) { # {{{
		if @canBeBoolean() {
			fragments.code(`, \(varname) => `)

			for var { name, type }, index in subtypes {
				fragments
					..code(' || ') if index > 0
					..code('!') if @isFalseValue(name)
					..code(varname)
			}
		}
		else if subtypes.length == 1 {
			var { name, type } = subtypes[0]
			var value = type.discard().getValue(name)

			if value.isAlias() {
				if value.isDerivative() {
					fragments.code(', ').compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(name))`)
				}
				else {
					fragments.code(`, \(varname) => \(varname) === `).compile(type).code(`.\(value.original())`)
				}
			}
			else {
				fragments.code(`, \(varname) => \(varname) === `).compile(type).code(`.\(name)`)
			}
		}
		else {
			fragments.code(`, \(varname) => `)

			for var { name, type }, index in subtypes {
				fragments.code(' || ') if index > 0

				var value = type.discard().getValue(name)

				if value.isAlias() {
					if value.isDerivative() {
						fragments.compile(type).code(`.__ks_eq_\(type.discard().getTopProperty(name))(\(varname))`)
					}
					else {
						fragments.code(`\(varname) === `).compile(type).code(`.\(value.original())`)
					}
				}
				else {
					fragments.code(`\(varname) === `).compile(type).code(`.\(name)`)
				}
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
