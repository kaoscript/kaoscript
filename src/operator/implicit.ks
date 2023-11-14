class UnaryOperatorImplicit extends Expression {
	private late {
		@derivative: Boolean				= false
		@originalProperty: String?
		@property: String
		@type: Type
		@varname: String?				= null
	}
	override analyse() { # {{{
		@property = @data.argument.name
	} # }}}
	override prepare(target, targetMode) { # {{{
		if var type ?= findImplicitType(target, @parent, this, @property) {
			if type.isAny() || type.isUnion() {
				ReferenceException.throwUnresolvedImplicitProperty(@property, this)
			}
			else if type.isEnum() {
				if var variable ?= type.discard().getVariable(@property) {
					if type is ValueType {
						@type = type.setNullable(false)
					}
					else {
						@type = ValueType.new(@property, type.setNullable(false).reference(@scope), `\(type.path()).\(@property)`, @scope)
					}

					if variable.isAlias() {
						if variable.isDerivative() {
							@derivative = true
						}
						else {
							@originalProperty = variable.original()
						}
					}
				}
				else {
					ReferenceException.throwNotDefinedEnumElement(@property, type.name(), this)
				}
			}
			else if type is VariantType {
				var master = type.getMaster()

				unless master.discard().hasVariable(@property) {
					ReferenceException.throwNotDefinedEnumElement(@property, master.name(), this)
				}

				@varname = master.name()
				@type = ValueType.new(@property, master.setNullable(false), `\(@varname).\(@property)`, @scope)
			}
			else if var property ?= type.getProperty(@property) {
				@type = property.discardVariable()
			}
		}

		if !?@type {
			// TODO!
			// if var { name % @varname, type } ?= @scope.getImplicitVariable() {
			if var { name % @varname, type % vartype } ?= @scope.getImplicitVariable() {
				// TODO!
				// echo('implicit:', type)
				if var property ?= vartype.getProperty(@property) {
					@type = property.discardVariable()
				}
				else {
					@type = AnyType.NullableUnexplicit
				}
			}
		}

		unless ?@type {
			ReferenceException.throwUnresolvedImplicitProperty(@property, this)
		}
	} # }}}
	override translate()
	property() => @property
	isDerivative() => @derivative
	toFragments(fragments, mode) { # {{{
		fragments.compile(@varname ?? @type.discardValue()).code($dot).compile(@originalProperty ?? @property)
	} # }}}
	toPropertyFragments(property: String, fragments, mode) { # {{{
		fragments.compile(@varname ?? @type).code(`.\(property)`)
	} # }}}
	toQuote() => `.\(@property)`
	type() => @type
}

func findImplicitArgument(tree, min: Number, index: Number, property: String, types: Type[]) { # {{{
	if index < min + tree.min {
		if tree.type.hasProperty(property) {
			types.pushUniq(tree.type)
		}
	}
	else if tree.rest {
		if tree.type.hasProperty(property) {
			types.pushUniq(tree.type)
		}
	}
	else {
		var mut addable = true

		for var i from tree.min to tree.max {
			if index < min + i {
				if addable && tree.type.hasProperty(property) {
					types.pushUniq(tree.type)

					addable = false
				}
			}
			else if ?tree.columns {
				for var column of tree.columns {
					findImplicitArgument(column, min + i, index, property, types)
				}
			}
		}
	}
} # }}}

func findImplicitType(#target: Type, #parent: AbstractNode, #node: Expression, #property: String) { # {{{
	match parent {
		is AssignmentOperatorAddition | AssignmentOperatorNullCoalescing | AssignmentOperatorSubtraction | BinaryOperatorSubtraction | PolyadicOperatorSubtraction {
			return target
		}
		is AssignmentOperatorEquals | BinaryOperatorNullCoalescing {
			return target
		}
		is BinaryOperatorMatch {
			return parent.subject().type()
		}
		is BinaryOperatorAddition | PolyadicOperatorAddition {
			if target == AnyType.NullableUnexplicit {
				return findImplicitType(target, parent.parent(), parent, property)
			}
			else {
				return target
			}
		}
		is CallExpression {
			if !?parent.assessment() {
				return null
			}

			var arguments = parent.arguments()
			var length = arguments.length
			var index = arguments.indexOf(node)
			var types = []

			for var function of parent.assessment().functions {
				if function.min() <= length <= function.max() {
					for var route of function.assessment('', node).routes {
						for var tree of route.trees when tree.min <= length <= tree.max {
							for var column of tree.columns {
								findImplicitArgument(column, 0, index, property, types)
							}
						}
					}
				}
			}

			if !?#types {
				if node.scope().hasImplicitVariable() {
					return null
				}
				else {
					ReferenceException.throwUnresolvedImplicitProperty(property, node)
				}
			}

			return Type.union(node.scope(), ...types)
		}
		is ClassVariableDeclaration {
			return parent.type().type()
		}
		is ComparisonExpression {
			var operands = parent.operands()
			var index = operands.indexOf(node)
			var operand = operands[index - 1] ?? operands[index + 1]

			if var type ?= operand.type() {
				return type.setNullable(false)
			}
		}
		is ConditionalExpression {
			if target == AnyType.NullableUnexplicit {
				return findTypeFromParent(parent.parent(), parent, property)
			}
			else {
				return target
			}
		}
		is MatchConditionValue {
			return parent.parent().getValueType()
		}
		is NamedArgument {
			var name = parent.name()
			var types = []

			for var function of parent.parent().assessment().functions {
				for var parameter in function.parameters() {
					if parameter.getExternalName() == name {
						types.push(parameter.getVariableType())
					}
				}
			}

			return Type.union(node.scope(), ...types)
		}
		is ClassConstructorDeclaration | ClassMethodDeclaration | FunctionDeclarator | StructFunction | TupleFunction | VariableDeclaration {
			return target
		}
		is ObjectComputedMember | ObjectLiteralMember {
			return target
		}
		else {
			return null
		}
	}
} # }}}

func findTypeFromParent(#parent: Expression, #node: Expression, #property: String): Type? { # {{{
	match parent {
		is CallExpression {
			if !?parent.assessment() {
				return null
			}

			var arguments = parent.arguments()
			var length = arguments.length
			var index = arguments.indexOf(node)
			var types = []

			for var function of parent.assessment().functions {
				if function.min() <= length <= function.max() {
					for var route of function.assessment('', node).routes {
						for var tree of route.trees when tree.min <= length <= tree.max {
							for var column of tree.columns {
								findImplicitArgument(column, 0, index, property, types)
							}
						}
					}
				}
			}

			unless ?#types {
				throw NotImplementedException.new()
			}

			return Type.union(node.scope(), ...types)
		}
		else {
			echo(parent)
			throw NotImplementedException.new()
		}
	}
} # }}}
