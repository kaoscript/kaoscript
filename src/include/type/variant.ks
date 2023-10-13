class VariantType extends Type {
	private late {
		@enum: EnumType
		@fields: Subtype{}				= {}
		@master: Type
	}
	static {
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): VariantType { # {{{
			var type = VariantType.new(scope)

			queue.push(() => {
				type.setMaster(Type.import(data.master, metadata, references, alterations, queue, scope, node))

				for var data, name of data.fields {
					type.addField(name, Type.import(data, metadata, references, alterations, queue, scope, node))
				}
			})

			return type.flagComplete()
		} # }}}
	}
	addField(name: String, type: Type) { # {{{
		@fields[name] = { name, type }
	} # }}}
	override clone() { # {{{
		NotImplementedException.throw()
	} # }}}
	override export(references, indexDelta, mode, module) { # {{{
		var export = {
			kind: TypeKind.Variant
			master: @master.toReference(references, indexDelta, mode, module)
			fields: {}
		}

		for var { name, type } of @fields {
			export.fields[name] = type.export(references, indexDelta, mode, module)
		}

		return export
	} # }}}
	getEnumType() => @enum
	getField(name: String) => @fields[name]
	getMaster() => @master
	hasSubtype(name: String) => @enum.hasProperty(name)
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		NotImplementedException.throw()
	} # }}}
	setMaster(@master) { # {{{
		var type = @master.discard()

		unless type is EnumType {
			NotImplementedException.throw()
		}

		@enum = type
	} # }}}
	override toFragments(fragments, node) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		NotImplementedException.throw()
	} # }}}
	override toTestFunctionFragments(fragments, node) { # {{{
		var block = fragments.code('variant =>').newBlock()

		block
			.newControl()
			.code(`if(!\($runtime.type(node)).isEnumInstance(variant))`)
			.step()
			.line('return false')
			.done()

		block
			.newControl()
			.code(`if(filter && !filter(variant))`)
			.step()
			.line('return false')
			.done()

		for var { name, type } of @fields {
			var ctrl = block
				.newControl()
				.code(`if(variant === \(@master.name()).\(name))`)
				.step()

			var line = ctrl.newLine().code(`return `)

			type.toTestFragments(line, node, Junction.NONE)

			line.done()
			ctrl.done()
		}

		block
			.line('return true')
			.done()
	} # }}}
	override toVariations(variations) { # {{{
		NotImplementedException.throw()
	} # }}}
}
