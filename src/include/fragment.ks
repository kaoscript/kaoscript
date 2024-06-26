include 'npm:@kaoscript/source-generator'

enum Mode {
	None
	Async
}

class CodeFragment extends SourceGeneration.Fragment {
	private {
		end		= null
		start	= null
	}
	constructor(code: Boolean | Number | String) { # {{{
		super(code)
	} # }}}
	constructor(code: Boolean | Number | String, @start, @end) { # {{{
		super(code)
	} # }}}
}

func $code(code) { # {{{
	return CodeFragment.new(code)
} # }}}

func $const(node) { # {{{
	return if node._options.format.variables == 'es5' set 'var ' else 'const '
} # }}}

func $quote(value) { # {{{
	return '"' + value.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"'
} # }}}

var $comma = $code(', ')
var $dot = $code('.')
var $equals = $code(' = ')
var $space = $code(' ')

class FragmentBuilder extends SourceGeneration.Writer {
	constructor(@indent) { # {{{
		super({
			indent: {
				level: indent
			}
			classes: {
				array: SourceGeneration.ArrayWriter
				block: BlockBuilder
				control: ControlBuilder
				expression: ExpressionBuilder
				fragment: CodeFragment
				line: LineBuilder
				object: SourceGeneration.ObjectWriter
			}
		})
	} # }}}
	line(...args) { # {{{
		var line = @newLine(@indent)

		if args.length == 1 && args[0] is not Primitive {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}

		line.done()

		return this
	} # }}}
}

class BlockBuilder extends SourceGeneration.BlockWriter {
	compile(node, mode = Mode.None) { # {{{
		if node is not Primitive {
			node.toFragments(this, mode)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}

		return this
	} # }}}
	line(...args) { # {{{
		var line = @writer.newLine(@indent + 1)

		if args.length == 1 && args[0] is not Primitive {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}

		line.done()

		return this
	} # }}}
}

class ControlBuilder extends SourceGeneration.ControlWriter {
	block(): BlockBuilder? { # {{{
		if @step is BlockBuilder {
			return @step
		}
		else {
			return null
		}
	} # }}}
	compile(node, mode = Mode.None) { # {{{
		@step.compile(node, mode)

		return this
	} # }}}
	compileCondition(node, mode = Mode.None, junction = Junction.NONE) { # {{{
		@step.compileCondition(node, mode, junction)

		return this
	} # }}}
	compileNullable(node) { # {{{
		@step.compileNullable(node)

		return this
	} # }}}
	compileReusable(node) { # {{{
		if node is not Primitive {
			node.toReusableFragments(this)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}

		return this
	} # }}}
	wrap(node, mode? = null) { # {{{
		@step.wrap(node, mode)

		return this
	} # }}}
	wrapCondition(node, mode = Mode.None, junction = Junction.NONE) { # {{{
		@step.wrapCondition(node, mode, junction)

		return this
	} # }}}
	wrapNullable(node) { # {{{
		@step.wrapNullable(node)

		return this
	} # }}}
	wrapReusable(node) { # {{{
		@step.wrapReusable(node)

		return this
	} # }}}
}

class ExpressionBuilder extends SourceGeneration.ExpressionWriter {
	code(...args) { # {{{
		var dyn data

		for var mut arg, i in args {
			if arg is Array {
				@code(...arg)
			}
			else if arg is not Primitive {
				@writer.push(arg)
			}
			else {
				if i + 1 < args.length && (data <- args[i + 1]) is not Primitive && ?data.kind {
					if ?data.start {
						@writer.push(@writer.newFragment(arg, data.start, data.end))
					}
					else {
						@writer.push(@writer.newFragment(arg))
					}

					i += 1
				}
				else {
					@writer.push(@writer.newFragment(arg))
				}
			}
		}

		return this
	} # }}}
	compile(node, mode = Mode.None) { # {{{
		if node is not Primitive {
			node.toFragments(this, mode)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}

		return this
	} # }}}
	compileCondition(node, mode = Mode.None, junction = Junction.NONE) { # {{{
		if node is not Primitive {
			node.toConditionFragments(this, mode, junction)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}

		return this
	} # }}}
	compileNullable(node) { # {{{
		if node is not Primitive {
			node.toNullableFragments(this)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}

		return this
	} # }}}
	compileReusable(node) { # {{{
		if node is not Primitive {
			node.toReusableFragments(this)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}

		return this
	} # }}}
	wrap(node, mode = Mode.None) { # {{{
		if node is Primitive {
			@writer.push(@writer.newFragment(node))
		}
		else if node.isComputed() {
			@code('(')

			node.toFragments(this, mode)

			@code(')')
		}
		else {
			node.toFragments(this, mode)
		}

		return this
	} # }}}
	wrapCondition(node, mode = Mode.None, junction = Junction.NONE) { # {{{
		if node is Primitive {
			@writer.push(@writer.newFragment(node))
		}
		else if node.isBooleanComputed(junction) {
			@code('(')

			node.toConditionFragments(this, mode, Junction.NONE)

			@code(')')
		}
		else {
			node.toConditionFragments(this, mode, junction)
		}

		return this
	} # }}}
	wrapNullable(node) { # {{{
		if node is Primitive {
			@writer.push(@writer.newFragment(node))
		}
		else if node.isNullableComputed() {
			@code('(')

			node.toNullableFragments(this)

			@code(')')
		}
		else {
			node.toNullableFragments(this)
		}

		return this
	} # }}}
	wrapReusable(node) { # {{{
		if node is Primitive {
			@writer.push(@writer.newFragment(node))
		}
		else if node.isComputed() {
			@code('(')

			node.toReusableFragments(this)

			@code(')')
		}
		else {
			node.toReusableFragments(this)
		}

		return this
	} # }}}
}

class LineBuilder extends ExpressionBuilder {
	private {
		@whenDone: Function?	= null
	}
	block() => @newBlock()
	done() { # {{{
		if @notDone {
			if @terminator {
				@writer.push(@writer.lineTerminator)
			}
			else {
				@writer.push(@writer.breakTerminator)
			}

			@notDone = false

			if ?@whenDone {
				this._whenDone()

				@whenDone = null
			}
		}
	} # }}}
	newControl(indent = @indent, initiator = true, terminator = true) { # {{{
		return @writer.newControl(indent, initiator, null, terminator)
	} # }}}
	newLine() => this
	whenDone(@whenDone)
}
