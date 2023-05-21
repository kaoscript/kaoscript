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

			// echo(expression.type().hashCode())
			// echo(expression.type().isNullable() , expression.isLateInit() , @options.rules.ignoreMisfit , expression is MemberExpression)
			unless expression.type().isNullable() || expression.isLateInit() || @options.rules.ignoreMisfit || expression is MemberExpression {
				TypeException.throwNotNullableExistential(expression, this)
			}
		}
		else if @nonEmpty {
			var expression = @topic.expression()

			unless expression.type().isIterable() || expression.isLateInit() || @options.rules.ignoreMisfit || expression is MemberExpression {
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
		// echo(`BinaryOperatorPipeline.acquireReusable#\(@data.start.line)-\(@data.end.line)`, @isTested(), @topic.isComposite())
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
	// isComputed() => @existential || @nonEmpty || @expression.isComputed()
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
		// echo(`BinaryOperatorPipeline.toFragments#\(@data.start.line)-\(@data.end.line)`, @reusable, @inverted, @expression.isInverted(), @topic.isReusable(), @expression.isComputed())

		if @reusable {
			fragments.code(@reuseName)
		}
		else if !@inverted && @expression.isInverted() {
			@inverted = true

			@expression.toInvertedFragments(fragments, (fragments) => {
				// echo(`BinaryOperatorPipeline.toFragments.callback#\(@data.start.line)-\(@data.end.line)`, @topic.isComposite())
				@toInvertedFragments(fragments, (fragments) => {
					// echo(`BinaryOperatorPipeline.toFragments.callback2#\(@data.start.line)-\(@data.end.line)`)
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
		// echo(`BinaryOperatorPipeline.toInvertedFragments#\(@data.start.line)-\(@data.end.line)`, @inverted, @expression.isInverted(), @existential || @nonEmpty, @topic.isComposite(), @topic.isReusable(), @expression.isComputed())

		if !@inverted && @expression.isInverted() {
			@inverted = true

			@expression.toInvertedFragments(fragments, (fragments) => {
				// echo(`BinaryOperatorPipeline.toInvertedFragments.callback#\(@data.start.line)-\(@data.end.line)`, @topic.isComposite())
				// @toInvertedFragments(fragments, (fragments) => {
				// 	echo(`BinaryOperatorPipeline.toInvertedFragments.callback2#\(@data.start.line)-\(@data.end.line)`)
				// 	callback(fragments)
				// })
				@toInvertedFragments(fragments, callback)
			})
		}
		else if @existential || @nonEmpty {
			@inverted = true

			var composite = @topic.isComposite()
			// var composite = @data.end.line != 9

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
		// echo(`BinaryOperatorPipeline.toReusableFragments#\(@data.start.line)-\(@data.end.line)`, @reusable, @reuseName, @inverted, @expression.isInverted())
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
	// acquireReusable(acquire) { # {{{
	// 	// echo(`BinaryOperatorPipeline.acquireReusable#\(@data.start.line)-\(@data.end.line)`, @isTested(), @topic.isComposite())
	// 	if acquire {
	// 		@reuseName = @scope.acquireTempName()
	// 	}

	// 	@expression.acquireReusable(false)
	// } # }}}
	override getExpressionData() => @data.left
	override getValueData() => @data.right
	// releaseReusable() { # {{{
	// 	if ?@reuseName {
	// 		@scope.releaseTempName(@reuseName)
	// 	}

	// 	@expression.releaseReusable()
	// } # }}}
	// toFragments(fragments, mode) { # {{{
	// 	// echo(`BinaryOperatorPipeline.toFragments#\(@data.start.line)-\(@data.end.line)`, @expression.isInverted(), @inverted, @isTested())
	// 	if @reusable {
	// 		fragments.code(@reuseName)
	// 	}
	// 	else {
	// 		if @topic?.isReusable() {
	// 			fragments.code('(').compileReusable(@topic).code($comma).compileReusable(@expression).code(')')
	// 		}
	// 		else {
	// 			@expression.toFragments(fragments, mode)
	// 		}
	// 	}
	// } # }}}
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
	// private {
	// 	@inverted: Boolean				= false
	// }
	// acquireReusable(acquire) { # {{{
	// 	// echo(`BinaryOperatorPipeline.acquireReusable#\(@data.start.line)-\(@data.end.line)`, @isTested(), @topic.isComposite())
	// 	if acquire {
	// 		@reuseName = @scope.acquireTempName()
	// 	}

	// 	@topic.acquireReusable((@existential || @nonEmpty) && @topic.isComposite())

	// 	@expression.acquireReusable(false)
	// } # }}}
	// isInverted() => true
	// isTested() => @existential || @nonEmpty || (@topic.expression() is BinaryOperatorForwardPipeline && @topic.expression().isTested())
	override getExpressionData() => @data.right
	override getValueData() => @data.left
	// releaseReusable() { # {{{
	// 	if ?@reuseName {
	// 		@scope.releaseTempName(@reuseName)
	// 	}

	// 	@expression.releaseReusable()
	// 	@topic.releaseReusable()
	// } # }}}
	// toFragments(fragments, mode) { # {{{
	// 	// echo(`BinaryOperatorPipeline.toFragments#\(@data.start.line)-\(@data.end.line)`, @expression.isInverted(), @inverted, @isTested())
	// 	if @reusable {
	// 		fragments.code(@reuseName)
	// 	}
	// 	else if !@inverted && @expression.isInverted() {
	// 		@inverted = true

	// 		@expression.toInvertedFragments(fragments, (fragments) => {
	// 			// echo(`BinaryOperatorPipeline.toFragments.callback#\(@data.start.line)-\(@data.end.line)`, @topic.isComposite())
	// 			@toInvertedFragments(fragments, (fragments) => {
	// 				// echo(`BinaryOperatorPipeline.toFragments.callback2#\(@data.start.line)-\(@data.end.line)`)
	// 				@expression.toFragments(fragments, mode)
	// 			})
	// 		})
	// 	}
	// 	else {
	// 		if @topic.isReusable() {
	// 			fragments.code('(').compileReusable(@topic).code($comma).compileReusable(@expression).code(')')
	// 		}
	// 		else {
	// 			@expression.toFragments(fragments, mode)
	// 		}
	// 	}
	// } # }}}
	// toInvertedFragments(fragments, callback) { # {{{
	// 	// echo(`BinaryOperatorPipeline.toInvertedFragments#\(@data.start.line)-\(@data.end.line)`, @topic.isComposite(), @topic._reuseName, @existential, @nonEmpty)

	// 	if !@inverted && @expression.isInverted() {
	// 		@inverted = true

	// 		@expression.toInvertedFragments(fragments, (fragments) => {
	// 			// echo(`BinaryOperatorPipeline.toInvertedFragments.callback#\(@data.start.line)-\(@data.end.line)`, @topic.isComposite())
	// 			// @toInvertedFragments(fragments, (fragments) => {
	// 			// 	echo(`BinaryOperatorPipeline.toInvertedFragments.callback2#\(@data.start.line)-\(@data.end.line)`)
	// 			// 	callback(fragments)
	// 			// })
	// 			@toInvertedFragments(fragments, callback)
	// 		})
	// 	}
	// 	else if @existential || @nonEmpty {
	// 		@inverted = true

	// 		var composite = @topic.isComposite()
	// 		// var composite = @data.end.line != 9

	// 		if composite {
	// 			fragments.code('(').compileReusable(@topic).code($comma)
	// 		}

	// 		if @existential {
	// 			fragments.code($runtime.type(this) + '.isValue(').compile(@topic).code(') ? ')

	// 			callback(fragments)

	// 			fragments.code(' : null')
	// 		}
	// 		else {
	// 			fragments.code($runtime.type(this) + '.isNotEmpty(').compile(@topic).code(') ? ')

	// 			callback(fragments)

	// 			fragments.code(' : null')
	// 		}

	// 		if composite {
	// 			fragments.code(')')
	// 		}
	// 	}
	// 	else {
	// 		@inverted = true

	// 		callback(fragments)
	// 	}
	// } # }}}
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

			// TODO!
			// @state += .Analyse
			@state += NodeState.Analyse
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
	// isComputed() => @isComposite() || @expression.isComputed()
	// isInverted() => @expression is BinaryOperatorPipeline
	isInverted() => true
	isReusable() => @destructuring || @usage > 1
	releaseReusable() { # {{{
		if @state !~ .ReleaseReusable {
			@expression.releaseReusable()

			@state += NodeState.ReleaseReusable
		}
	} # }}}
	toFragments(fragments, mode) { # {{{
		// echo(`TopicReference.toFragments#\(@data.start.line)-\(@data.end.line)`, @expression.isInverted())
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
		// echo(`TopicReference.toInvertedFragments#\(@data.start.line)-\(@data.end.line)`, @expression is BinaryOperatorPipeline, @expression.isTested?(), @destructuring, @reuseName)

		if @expression is BinaryOperatorPipeline {
			if @expression.isTested() {
				// @expression.toInvertedFragments(fragments, (fragments) => {
				// 	echo(`TopicReference.toInvertedFragments.callback#\(@data.start.line)-\(@data.end.line)`, @reuseName)
				// 	callback(fragments)
				// })
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
		// echo(`TopicReference.toReusableFragments#\(@data.start.line)-\(@data.end.line)`, @reusable, @reuseName)
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
