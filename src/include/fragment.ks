include '@kaoscript/source-generator'

enum Mode {
	None
	Async
}

class CodeFragment extends Fragment {
	private {
		end		= null
		start	= null
	}
	// TODO
	// constructor(code: String | Number) { # {{{
	// 	super(code)
	// } # }}}
	// constructor(code: String | Number, @start, @end) { # {{{
	// 	super(code)
	// } # }}}
	constructor(@code) { # {{{
		super(code)
	} # }}}
	constructor(code: Boolean | Number) { # {{{
		super(code)
	} # }}}
	constructor(@code, @start, @end) { # {{{
		super(code)
	} # }}}
}

func $code(code) { # {{{
	return new CodeFragment(code)
} # }}}

func $const(node) { # {{{
	return node._options.format.variables == 'es5' ? 'var ' : 'const '
} # }}}

func $quote(value) { # {{{
	return '"' + value.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"'
} # }}}

var $comma = $code(', ')
var $dot = $code('.')
var $equals = $code(' = ')
var $space = $code(' ')

class FragmentBuilder extends Writer {
	constructor(@indent) { # {{{
		super({
			indent: {
				level: indent
			}
			classes: {
				array: ArrayWriter
				block: BlockBuilder
				control: ControlBuilder
				expression: ExpressionBuilder
				fragment: CodeFragment
				line: LineBuilder
				object: ObjectWriter
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

class BlockBuilder extends BlockWriter {
	compile(node, mode = Mode::None) { # {{{
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

class ControlBuilder extends ControlWriter {
	block(): BlockBuilder? { # {{{
		if @step is BlockBuilder {
			return @step
		}
		else {
			return null
		}
	} # }}}
	compile(node, mode = Mode::None) { # {{{
		@step.compile(node, mode)

		return this
	} # }}}
	compileCondition(node, mode = Mode::None, junction = Junction::NONE) { # {{{
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
	wrapCondition(node, mode = Mode::None, junction = Junction::NONE) { # {{{
		@step.wrapCondition(node, mode, junction)

		return this
	} # }}}
	wrapNullable(node) { # {{{
		@step.wrapNullable(node)

		return this
	} # }}}
}

class ExpressionBuilder extends ExpressionWriter {
	code(...args) { # {{{
		var dyn data

		for arg, i in args {
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
	compile(node, mode = Mode::None) { # {{{
		if node is not Primitive {
			node.toFragments(this, mode)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}

		return this
	} # }}}
	compileCondition(node, mode = Mode::None, junction = Junction::NONE) { # {{{
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
	wrap(node, mode = Mode::None) { # {{{
		if node.isComputed() {
			@code('(')

			node.toFragments(this, mode)

			@code(')')
		}
		else {
			node.toFragments(this, mode)
		}

		return this
	} # }}}
	wrapCondition(node, mode = Mode::None, junction = Junction::NONE) { # {{{
		if node.isBooleanComputed(junction) {
			@code('(')

			node.toConditionFragments(this, mode, Junction::NONE)

			@code(')')
		}
		else {
			node.toConditionFragments(this, mode, junction)
		}

		return this
	} # }}}
	wrapNullable(node) { # {{{
		if node.isNullableComputed() {
			@code('(')

			node.toNullableFragments(this)

			@code(')')
		}
		else {
			node.toNullableFragments(this)
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

			if @whenDone != null {
				@whenDone()

				@whenDone = null
			}
		}
	} # }}}
	newControl(indent = @indent, initiator = true, terminator = true) { # {{{
		return @writer.newControl(indent, initiator, terminator)
	} # }}}
	newLine() => this
	whenDone(@whenDone)
}
