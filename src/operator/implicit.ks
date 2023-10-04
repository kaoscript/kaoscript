class UnaryOperatorImplicit extends Expression {
	private late {
		@property: String
		@type: Type
		@varname: String?			= null
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
				if !type.discard().hasVariable(@property) {
					ReferenceException.throwNotDefinedEnumElement(@property, type.name(), this)
				}

				@type = type.setNullable(false)
			}
			else if var property ?= type.getProperty(@property) {
				@type = property.discardVariable()
			}
			else {
				ReferenceException.throwUnresolvedImplicitProperty(@property, this)
			}
		}
		else if var { name % @varname, type } ?= @scope.getImplicitVariable() {
			if var property ?= type.getProperty(@property) {
				@type = property.discardVariable()
			}
			else {
				@type = AnyType.NullableUnexplicit
			}
		}
		else {
			ReferenceException.throwUnresolvedImplicitProperty(@property, this)
		}
	} # }}}
	override translate()
	property() => @property
	toFragments(fragments, mode) { # {{{
		fragments.compile(@varname ?? @type).code($dot).compile(@property)
	} # }}}
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

			if !#types {
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
			var operand = operands[index - 1]

			return operand.type().setNullable(false)
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
		is ObjectComputedMember {
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

			unless #types {
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
