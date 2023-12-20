abstract class BinaryOperatorPipeline extends Expression {
	private {
		@destructuring: Boolean			= false
		@existential: Boolean			= false
		@expression
		@inverted: Boolean				= false
		@main: Boolean					= true
		@nonEmpty: Boolean				= false
		@reusable: Boolean				= false
		@reuseName: String?				= null
		@topic
		@type
	}
	abstract {
		getExpressionData()
		getValueData()
	}
	override analyse() { # {{{
		for var { kind } in @data.operator.modifiers {
			match kind as ModifierKind {
				.Existential {
					@existential = true
				}
				.NonEmpty {
					@nonEmpty = true
				}
				.Wildcard {
					@destructuring = true
				}
			}
		}

		var data = TopicReference.pushReference(@getExpressionData())

		@expression = $compile.expression(data, this)
		@expression.analyse()

		if @topic.expression() is BinaryOperatorPipeline {
			@topic.expression().unflagMain()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		@expression.prepare(target, targetMode)

		@type = @expression.type()

		if @type.isInoperative() {
			TypeException.throwUnexpectedInoperative(@expression, this)
		}

		if @existential {
			var expression = @topic.expression()

			unless expression.type().isNullable() || expression.isLateInit() || @isMisfit() || expression is MemberExpression {
				TypeException.throwNotNullableExistential(expression, this)
			}
		}
		else if @nonEmpty {
			var expression = @topic.expression()

			unless expression.type().isIterable() || expression.isLateInit() || @isMisfit() || expression is MemberExpression {
				TypeException.throwNotIterable(expression, this)
			}
		}

		if @main && @isTested() {
			@type = @type.setNullable(true)
		}
	} # }}}
	override translate() { # {{{
		@expression.translate()
	} # }}}
	acquireReusable(acquire) { # {{{
		if acquire {
			@reuseName = @scope.acquireTempName()
		}

		@topic.acquireReusable((@existential || @nonEmpty) && @topic.isComposite())

		@expression.acquireReusable(false)
	} # }}}
	getTopicReference(data) { # {{{
		if !?@topic {
			var mut destructuring = @destructuring

			for var { kind } in data.modifiers {
				match kind as ModifierKind {
					.Spread {
						destructuring = true
					}
				}
			}

			@topic = TopicReference.new(@getValueData(), this)

			if destructuring {
				@topic.flagDestructuring()
			}
			if @existential || @nonEmpty {
				@topic.flagTested()
			}
		}

		return @topic
	} # }}}
	isComposite() => @existential || @nonEmpty || @expression.isComposite()
	isInverted() => true
	isTested() => @existential || @nonEmpty || (@topic.expression() is BinaryOperatorPipeline && @topic.expression().isTested())
	releaseReusable() { # {{{
		if ?@reuseName {
			@scope.releaseTempName(@reuseName)
		}

		@expression.releaseReusable()
		@topic.releaseReusable()
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			fragments.code(@reuseName)
		}
		else if !@inverted && @expression.isInverted() {
			@inverted = true

			@expression.toInvertedFragments(fragments, (fragments) => {
				@toInvertedFragments(fragments, (fragments) => {
					@expression.toFragments(fragments, mode)
				})
			})
		}
		else {
			if @topic.isReusable() {
				fragments.code('(').compileReusable(@topic).code($comma).compileReusable(@expression).code(')')
			}
			else {
				@expression.toFragments(fragments, mode)
			}
		}
	} # }}}
	toInvertedFragments(fragments, callback) { # {{{
		if !@inverted && @expression.isInverted() {
			@inverted = true

			@expression.toInvertedFragments(fragments, (fragments) => {
				@toInvertedFragments(fragments, callback)
			})
		}
		else if @existential || @nonEmpty {
			@inverted = true

			var composite = @topic.isComposite()

			if composite {
				fragments.code('(').compileReusable(@topic).code($comma)
			}

			if @existential {
				fragments.code($runtime.type(this) + '.isValue(').compile(@topic).code(') ? ')

				callback(fragments)

				fragments.code(' : null')
			}
			else {
				fragments.code($runtime.type(this) + '.isNotEmpty(').compile(@topic).code(') ? ')

				callback(fragments)

				fragments.code(' : null')
			}

			if composite {
				fragments.code(')')
			}
		}
		else {
			var reusable = @topic.isReusable()

			if reusable {
				fragments.code('(').compileReusable(@topic).code($comma)
			}

			callback(fragments)

			if reusable {
				fragments.code(')')
			}
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		if !@reusable && ?@reuseName {
			fragments.code(@reuseName, $equals).compile(this)

			@reusable = true
		}
		else {
			fragments.compile(this)
		}
	} # }}}
	type() => @type
	unflagMain() { # {{{
		@main = false
	} # }}}
}

class BinaryOperatorBackwardPipeline extends BinaryOperatorPipeline {
	override getExpressionData() => @data.left
	override getValueData() => @data.right
	toQuote() { # {{{
		var mut fragments = `\(@topic.toQuote()) `

		if @existential {
			fragments += '?'
		}
		else if @nonEmpty {
			fragments += '#'
		}

		fragments += '<|'

		if @destructuring {
			fragments += '*'
		}

		fragments += ` \(@expression.toQuote())`

		return fragments
	} # }}}
}

class BinaryOperatorForwardPipeline extends BinaryOperatorPipeline {
	override getExpressionData() => @data.right
	override getValueData() => @data.left
	toQuote() { # {{{
		var mut fragments = `\(@topic.toQuote()) `

		if @destructuring {
			fragments += '*'
		}

		fragments += '|>'

		if @existential {
			fragments += '?'
		}
		else if @nonEmpty {
			fragments += '#'
		}

		fragments += ` \(@expression.toQuote())`

		return fragments
	} # }}}
}

bitmask NodeState {
	Nil

	AcquireReusable
	Analyse
	Prepare
	ReleaseReusable
	Translate
}

class TopicReference extends Expression {
	private {
		@destructuring: Boolean		= false
		@expression
		@reusable: Boolean			= false
		@reuseName: String?			= null
		@spread: Boolean			= false
		@state: NodeState			= .Nil
		@tested: Boolean			= false
		@type
		@usage: Number				= 1
	}
	static {
		hasReference(data: { kind: NodeKind }): Boolean { # {{{
			match data.kind {
				.MemberExpression {
					return TopicReference.hasReference(data.object)
				}
				.TopicReference {
					return true
				}
				else {
					return false
				}
			}
		} # }}}
		pushReference(data: { kind: NodeKind }) { # {{{
			match data.kind {
				.AwaitExpression {
					if !?data.operation {
						data.operation = $ast.topicReference()
					}
					else {
						TopicReference.pushReference(data.operation)
					}

					return data
				}
				.CallExpression {
					if data.callee.kind == NodeKind.MemberExpression {
						TopicReference.pushReference(data.callee)
					}

					return data
				}
				.Identifier {
					return $ast.call(data, [$ast.topicReference()])
				}
				.LambdaExpression {
					return $ast.call(data, [$ast.topicReference()])
				}
				.MemberExpression {
					if !?data.object {
						data.object = $ast.topicReference()

						return data
					}
					else if data.object.kind == NodeKind.MemberExpression {
						TopicReference.pushReference(data.object)
					}

					if TopicReference.hasReference(data) {
						return data
					}
					else {
						return $ast.call(data, [$ast.topicReference()])
					}
				}
				.ThisExpression {
					return $ast.call(data, [$ast.topicReference()])
				}
				else {
					return data
				}
			}
		} # }}}
	}
	override analyse() { # {{{
		if @state ~~ .Analyse  {
			@usage += 1
		}
		else {
			@expression = $compile.expression(@data, this)
			@expression.analyse()

			@state += .Analyse
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		if @state !~ .Prepare {
			@expression.prepare(target, targetMode)

			@type = @expression.type()

			if @destructuring {
				if @type.isArray() {
					@type = @type.flagSpread()
				}
				else {
					@type = Type.arrayOf(@type, @scope).flagSpread()

					@spread = true
				}
			}

			if @tested || (@expression is BinaryOperatorPipeline && @expression.isTested()) {
				@type = @type.setNullable(false)
			}

			@state += NodeState.Prepare
		}
	} # }}}
	override translate() { # {{{
		if @state !~ .Translate {
			@expression.translate()

			@state += NodeState.Translate
		}
	} # }}}
	acquireReusable(acquire) { # {{{
		if @state !~ .AcquireReusable {
			if acquire || @isReusable() {
				@reuseName = @scope.acquireTempName()
			}

			@expression.acquireReusable(false)

			@state += NodeState.AcquireReusable
		}
	} # }}}
	argument() => this
	expression() => @expression
	flagDestructuring() { # {{{
		@destructuring = true
	} # }}}
	flagTested() { # {{{
		@tested = true
	} # }}}
	isComposite() => @isReusable() || @expression.isComposite()
	isInverted() => true
	isReusable() => @destructuring || @usage > 1
	releaseReusable() { # {{{
		if @state !~ .ReleaseReusable {
			@expression.releaseReusable()

			@state += NodeState.ReleaseReusable
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		if @reusable {
			if @spread {
				fragments.code('...')
			}

			fragments.code(@reuseName)
		}
		else {
			@expression.toFragments(fragments, mode)
		}
	} # }}}
	toInvertedFragments(fragments, callback) { # {{{
		if @expression is BinaryOperatorPipeline {
			if @expression.isTested() {
				@expression.toInvertedFragments(fragments, callback)
			}
			else {
				callback(fragments)
			}
		}
		else {
			callback(fragments)
		}
	} # }}}
	toReusableFragments(fragments) { # {{{
		if !@reusable && ?@reuseName {
			fragments.code(@reuseName, $equals).compile(this)

			@reusable = true
		}
		else {
			fragments.compile(this)
		}
	} # }}}
	toQuote() { # {{{
		return @expression.toQuote()
	} # }}}
	type() => @type
}
