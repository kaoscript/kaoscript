class UnaryOperatorImplicit extends Expression {
	private late {
		@derivative: Boolean			= false
		@immutableValue: String?		= null
		@originalProperty: String?
		@path: String?					= null
		@property: String
		@type: Type
		@varname: String?				= null
	}
	override analyse() { # {{{
		@property = @data.argument.name
	} # }}}
	override prepare(target, targetMode) { # {{{
		var result = findImplicitType(target, @parent, this, @property)

		if ?#result.mismatcheds {
			ReferenceException.throwMismatchedImplicitProperty(@property, result.mismatcheds, this)
		}

		if result.ok {
			var { type } = result

			if type.isAny() || type.isUnion() {
				ReferenceException.throwUnresolvedImplicitProperty(@property, this)
			}
			else if type is VariantType {
				var master = type.getMaster()
				var root = master.discard()

				unless root.hasValue(@property) {
					ReferenceException.throwNotDefinedVariantElement(@property, master.name(), this)
				}

				@varname = if root is EnumViewType set root.master().path() else master.path()
				@path = `\(@varname).\(@property)`
				@type = ValueType.new(@property, master.setNullable(false), @path, @scope)
			}
			else if type.isBitmask() {
				if var property ?= type.discard().getValue(@property) {
					@path = `\(type.path()).\(@property)`
					@immutableValue = property.value()

					if type is ValueType {
						@type = type.setNullable(false)
					}
					else {
						@type = ValueType.new(@property, type.setNullable(false).reference(@scope), @path, @scope)
					}
				}
				else {
					ReferenceException.throwNotDefinedBitmaskElement(@property, type.name(), this)
				}
			}
			else if type.isEnum() {
				if var value ?= type.discard().getValue(@property) {
					@path = `\(type.path()).\(@property)`

					if type is ValueType {
						@type = type.setNullable(false)
					}
					else if type is EnumViewType {
						@type = ValueType.new(@property, type.master().reference(@scope), @path, @scope)
					}
					else {
						@type = ValueType.new(@property, type.setNullable(false).reference(@scope), @path, @scope)
					}

					if value.isAlias() {
						if value.isDerivative() {
							@derivative = true
						}
						else {
							@originalProperty = value.original()
						}
					}
				}
				else {
					ReferenceException.throwNotDefinedEnumElement(@property, type.name(), this)
				}
			}
			else if type.isVariant() {
				var variant = type.discard().getVariantType()
				var master = variant.getMaster()

				unless variant.hasSubtype(@property) {
					ReferenceException.throwNotDefinedVariantElement(@property, master.name(), this)
				}

				@path = `\(master.path()).\(@property)`
				@type = ReferenceType.new(@scope, type.name(), false, null, [{ name: @property, type: master }])

				unless @type.isAssignableToVariable(type!!, false, false, true) {
					TypeException.throwInvalidTypeChecking(this, type, this)
				}

				if type.isSubsetOf(@type, MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass) {
					TypeException.throwUnnecessaryTypeChecking(this, type, this)
				}
			}
			else if var property ?= type.getProperty(@property) {
				@path = `\(type.path()).\(@property)`
				@type = property.discardVariable()
			}
		}

		if !?@type {
			if var { name % @varname, type % vartype } ?= @scope.getImplicitVariable() {
				@path = `\(@varname).\(@property)`

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
	getImmutableValue() => @immutableValue
	isDerivative() => @derivative
	isImmutableValue() => ?@immutableValue
	override path() => @path
	property() => @property
	toFragments(fragments, mode) { # {{{
		fragments.compile(@varname ?? @type.discardValue()).code($dot).compile(@originalProperty ?? @property)
	} # }}}
	toPropertyFragments(property: String, fragments, mode) { # {{{
		fragments.compile(@varname ?? @type).code(`.\(property)`)
	} # }}}
	toQuote() => `.\(@property)`
	type() => @type
}

func findImplicitArgument(tree, min: Number, index: Number, property: String, types: Type[], mismatcheds: Type[]) { # {{{
	var type = tree.type.setNullable(false).type()

	if index < min + tree.min {
		if type.hasProperty(property) {
			types.pushUniq(type)
		}
		else if type.hasInvalidProperty(property) {
			mismatcheds.push(type)
		}
	}
	else if tree.rest {
		if type.hasProperty(property) {
			types.pushUniq(type)
		}
		else if type.hasInvalidProperty(property) {
			mismatcheds.push(type)
		}
	}
	else {
		var mut addable = true

		for var i from tree.min to tree.max {
			if index < min + i {
				if addable {
					if type.hasProperty(property) {
						types.pushUniq(type)

						addable = false
					}
					else if type.hasInvalidProperty(property) {
						mismatcheds.push(type)

						addable = false
					}
				}
			}
			else if ?tree.columns {
				for var column of tree.columns {
					findImplicitArgument(column, min + i, index, property, types, mismatcheds)
				}
			}
		}
	}
} # }}}

func findImplicitType(#target: Type, #parent: AbstractNode, #node: Expression, #property: String) { # {{{
	match parent {
		is AssignmentOperatorAddition | AssignmentOperatorNullCoalescing | AssignmentOperatorSubtraction | BinaryOperatorSubtraction | PolyadicOperatorSubtraction {
			return { ok: true, type: target }
		}
		is AssignmentOperatorEquals | BinaryOperatorNullCoalescing {
			return { ok: true, type: target }
		}
		is BinaryOperatorMatch {
			return { ok: true, type: parent.subject().type() }
		}
		is BinaryOperatorAddition | PolyadicOperatorAddition {
			return findImplicitType(target, parent.parent(), parent, property)
		}
		is CallExpression {
			if !?parent.assessment() {
				return { ok: false }
			}

			var arguments = parent.arguments()
			var length = arguments.length
			var index = arguments.indexOf(node)
			var types = []
			var mismatcheds = []

			for var function of parent.assessment().functions {
				if function.min() <= length <= function.max() {
					var assessment = function.assessment('', node)

					for var routeName of assessment.mainRoutes {
						var route = assessment.routes[routeName]

						for var tree of route.trees when tree.min <= length <= tree.max {
							for var column of tree.columns {
								findImplicitArgument(column, 0, index, property, types, mismatcheds)
							}
						}
					}
				}
			}

			if !?#types {
				if node.scope().hasImplicitVariable() {
					return { ok: false, mismatcheds }
				}
				else {
					echo(mismatcheds)
					ReferenceException.throwUnresolvedImplicitProperty(property, node)
				}
			}

			return { ok: true, type: Type.union(node.scope(), ...types) }
		}
		is ClassVariableDeclaration {
			return { ok: true, type: parent.type().type() }
		}
		is ComparisonExpression {
			var operands = parent.operands()
			var index = operands.indexOf(node)
			var operand = operands[index - 1] ?? operands[index + 1]

			if var type ?= operand.type() {
				return { ok: true, type: type.discardValue().setNullable(false) }
			}
		}
		is EnumValueDeclaration {
			var arguments = parent.arguments()
			var length = arguments.length
			var index = arguments.indexOf(node)
			var types = []
			var mismatcheds = []

			for {
				var route of parent.assessment().routes
				var tree of route.trees when tree.min <= length <= tree.max
				var column of tree.columns
			}
			then {
				findImplicitArgument(column, 0, index, property, types, mismatcheds)
			}

			if !?#types {
				if node.scope().hasImplicitVariable() {
					return { ok: false, mismatcheds }
				}
				else {
					ReferenceException.throwUnresolvedImplicitProperty(property, node)
				}
			}

			return { ok: true, type: Type.union(node.scope(), ...types) }
		}
		is MatchConditionValue {
			return { ok: true, type: parent.parent().getValueType() }
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

			return { ok: true, type: Type.union(node.scope(), ...types) }
		}
		is ClassConstructorDeclaration | ClassMethodDeclaration | FunctionDeclarator | StructFunction | TupleFunction | VariableDeclaration {
			return { ok: true, type: target }
		}
		is ObjectComputedMember | ObjectLiteralMember {
			return { ok: true, type: target }
		}
		is ReturnStatement {
			return { ok: true, type: target }
		}
		is SetStatement {
			if target == AnyType.NullableUnexplicit {
				return findTypeFromParent(parent.parent(), parent, property)
			}
			else {
				return { ok: true, type: target }
			}
		}
	}

	return { ok: false }
} # }}}

func findTypeFromParent(#parent: Expression | Block, #node: Expression | SetStatement, #property: String) { # {{{
	match parent {
		is Block {
			return findTypeFromParent(parent.parent(), parent.parent(), property)
		}
		is CallExpression {
			if !?parent.assessment() {
				return { ok: false }
			}

			var arguments = parent.arguments()
			var length = arguments.length
			var index = arguments.indexOf(node)
			var types = []
			var mismatcheds = []

			for var function of parent.assessment().functions {
				if function.min() <= length <= function.max() {
					for var route of function.assessment('', node).routes {
						for var tree of route.trees when tree.min <= length <= tree.max {
							for var column of tree.columns {
								findImplicitArgument(column, 0, index, property, types, mismatcheds)
							}
						}
					}
				}
			}

			unless ?#types {
				throw NotImplementedException.new()
			}

			return { ok: true, type: Type.union(node.scope(), ...types) }
		}
		is IfExpression {
			return findTypeFromParent(parent.parent(), parent, property)
		}
		else {
			echo(parent)
			throw NotImplementedException.new()
		}
	}
} # }}}
