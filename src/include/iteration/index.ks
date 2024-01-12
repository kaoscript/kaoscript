enum ElseTestKind {
	None
	Setter
}

enum LoopKind {
	Ordered
	Static
	Unknown
}

enum OrderKind {
	Ascending
	Descending
	None
}

abstract class IterationNode extends AbstractNode {
	protected late {
		@bindingScope: Scope
		@bodyScope: Scope
		@elseTest: ElseTestKind				= .None
	}
	static {
		fromAST(data, node, scope) { # {{{
			return match data.kind {
				IterationKind.Array => ArrayIteration.new(data, node, scope)
				IterationKind.From => FromIteration.new(data, node, scope)
				IterationKind.Object => ObjectIteration.new(data, node, scope)
				IterationKind.Range => RangeIteration.new(data, node, scope)
				IterationKind.Repeat => RepeatIteration.new(data, node, scope)
				// TODO remove else
				else => throw NotImplementedException.new()
			}
		} # }}}
	}
	abstract {
		releaseVariables(): Void
		toIterationFragments(fragments)
	}
	assignTempVariables(scope: Scope): Void { # {{{
		@parent.assignTempVariables(scope)
	} # }}}
	getBodyScope(): valueof @bodyScope
	hasElse(): Boolean => @parent.hasElse()
	setElseTest(@elseTest): Void
	protected {
		close(fragments, elseCtrl?) { # {{{
			fragments.done()

			if ?elseCtrl {
				if @parent.hasManyIterations() {
					elseCtrl.done()
				}
				else {
					return elseCtrl
				}
			}

			return null
		} # }}}
	}
}

include {
	'./array.ks'
	'./from.ks'
	'./object.ks'
	'./range.ks'
	'./repeat.ks'
}
