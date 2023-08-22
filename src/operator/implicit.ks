class UnaryOperatorImplicit extends Expression {
	private late {
		@property: String
		@type: Type
	}
	override analyse() { # {{{
		@property = @data.argument.name
	} # }}}
	override prepare(target, targetMode) { # {{{
		var late type: Type

		match @parent {
			is AssignmentOperatorAddition | AssignmentOperatorSubtraction | BinaryOperatorAddition | BinaryOperatorSubtraction | PolyadicOperatorAddition | PolyadicOperatorSubtraction {
				type = target
			}
			is AssignmentOperatorEquals | BinaryOperatorNullCoalescing {
				type = target
			}
			is BinaryOperatorMatch {
				type = @parent.subject().type()
			}
			is CallExpression {
				if !?@parent.assessment() {
					return
				}

				var arguments = @parent.arguments()
				var length = arguments.length
				var index = arguments.indexOf(this)
				var types = []

				for var function of @parent.assessment().functions {
					if function.min() <= length <= function.max() {
						for var route of function.assessment('', this).routes {
							for var tree of route.trees when tree.min <= length <= tree.max {
								for var column of tree.columns {
									findImplicitArgument(column, 0, index, @property, types)
								}
							}
						}
					}
				}

				unless #types {
					ReferenceException.throwUnresolvedImplicitProperty(@property, this)
				}

				type = Type.union(@scope, ...types)
			}
			is ClassVariableDeclaration {
				type = @parent.type().type()
			}
			is ComparisonExpression {
				var operands = @parent.operands()
				var index = operands.indexOf(this)
				var operand = operands[index - 1]

				type = operand.type().setNullable(false)
			}
			is ConditionalExpression {
				if target == AnyType.NullableUnexplicit {
					if var result ?= findTypeFromParent(@parent.parent(), @parent, @property) {
						type = result
					}
					else {
						return
					}
				}
				else {
					type = target
				}
			}
			is MatchConditionValue {
				type = @parent.parent().getValueType()
			}
			is NamedArgument {
				var name = @parent.name()
				var types = []

				for var function of @parent.parent().assessment().functions {
					for var parameter in function.parameters() {
						if parameter.getExternalName() == name {
							types.push(parameter.getVariableType())
						}
					}
				}

				type = Type.union(@scope, ...types)
			}
			is ClassConstructorDeclaration | ClassMethodDeclaration | FunctionDeclarator | StructFunction | TupleFunction | VariableDeclaration {
				type = target
			}
			else {
				echo(@parent)
				throw NotImplementedException.new()
			}
		}

		if type.isAny() || type.isUnion() {
			ReferenceException.throwUnresolvedImplicitProperty(@property, this)
		}
		else if type.isEnum() {
			if !type.discard().hasVariable(@property) {
				ReferenceException.throwNotDefinedEnumElement(@property, type.name(), this)
			}

			@type = type
		}
		else if var property ?= type.getProperty(@property) {
			@type = property.discardVariable()
		}
		else {
			ReferenceException.throwUnresolvedImplicitProperty(@property, this)
		}
	} # }}}
	override translate()
	property() => @property
	toFragments(fragments, mode) { # {{{
		fragments.compile(@type).code($dot).compile(@property)
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

func findTypeFromParent(parent: Expression, node: Expression, property: String): Type? { # {{{
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
