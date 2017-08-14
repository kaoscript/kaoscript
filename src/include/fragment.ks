include '@kaoscript/source-writer'

enum Mode {
	None
	Async
}

class CodeFragment extends Fragment {
	private {
		end		= null
		start	= null
	}
	constructor(@code) { // {{{
		super(code)
	} // }}}
	constructor(@code, @start, @end) { // {{{
		super(code)
	} // }}}
}

func $code(code) { // {{{
	return new CodeFragment(code)
} // }}}

func $quote(value) { // {{{
	return '"' + value.replace(/"/g, '\\"').replace(/\n/g, '\\n') + '"'
} // }}}

const $comma = $code(', ')
const $dot = $code('.')
const $equals = $code(' = ')
const $space = $code(' ')

class FragmentBuilder extends Writer { // {{{
	constructor(@indent) {
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
	}
	line(...args) { // {{{
		let line = this.newLine(@indent)
		
		if args.length == 1 && args[0] is Object {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}
		
		line.done()
		
		return this
	} // }}}
} // }}}

class BlockBuilder extends BlockWriter {
	compile(node, mode = Mode::None) { // {{{
		if node is Object {
			node.toFragments(this, mode)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}
		
		return this
	} // }}}
	line(...args) { // {{{
		let line = @writer.newLine(@indent + 1)
		
		if args.length == 1 && args[0] is Object {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}
		
		line.done()
		
		return this
	} // }}}
}

class ControlBuilder extends ControlWriter {
	compile(node, mode = Mode::None) { // {{{
		@step.compile(node, mode)
		
		return this
	} // }}}
	compileBoolean(node) { // {{{
		@step.compileBoolean(node)
		
		return this
	} // }}}
	compileNullable(node) { // {{{
		@step.compileNullable(node)
		
		return this
	} // }}}
	wrap(node, mode = null) { // {{{
		@step.wrap(node, mode)
		
		return this
	} // }}}
	wrapBoolean(node) { // {{{
		@step.wrapBoolean(node)
		
		return this
	} // }}}
	wrapNullable(node) { // {{{
		@step.wrapNullable(node)
		
		return this
	} // }}}
}

class ExpressionBuilder extends ExpressionWriter {
	code(...args) { // {{{
		let data
		
		for arg, i in args {
			if arg is Array {
				this.code(...arg)
			}
			else if arg is Object {
				@writer.push(arg)
			}
			else {
				if i + 1 < args.length && (data = args[i + 1]) is Object && data.kind? {
					if data.start? {
						@writer.push(@writer.newFragment(arg, data.start, data.end))
					}
					else {
						@writer.push(@writer.newFragment(arg))
					}
					
					i++
				}
				else {
					@writer.push(@writer.newFragment(arg))
				}
			}
		}
		
		return this
	} // }}}
	compile(node, mode = Mode::None) { // {{{
		if node is Object {
			node.toFragments(this, mode)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}
		
		return this
	} // }}}
	compileBoolean(node, mode = Mode::None) { // {{{
		if node is Object {
			node.toBooleanFragments(this, mode)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}
		
		return this
	} // }}}
	compileNullable(node) { // {{{
		if node is Object {
			node.toNullableFragments(this)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}
		
		return this
	} // }}}
	compileReusable(node) { // {{{
		if node is Object {
			node.toReusableFragments(this)
		}
		else {
			@writer.push(@writer.newFragment(node))
		}
		
		return this
	} // }}}
	wrap(node, mode = Mode::None) { // {{{
		if node.isComputed() {
			this.code('(')
			
			node.toFragments(this, mode)
			
			this.code(')')
		}
		else {
			node.toFragments(this, mode)
		}
		
		return this
	} // }}}
	wrapBoolean(node, mode = Mode::None) { // {{{
		if node.isBooleanComputed() {
			this.code('(')
			
			node.toBooleanFragments(this, mode)
			
			this.code(')')
		}
		else {
			node.toBooleanFragments(this, mode)
		}
		
		return this
	} // }}}
	wrapNullable(node) { // {{{
		if node.isNullableComputed() {
			this.code('(')
			
			node.toNullableFragments(this)
			
			this.code(')')
		}
		else {
			node.toNullableFragments(this)
		}
		
		return this
	} // }}}
}

class LineBuilder extends ExpressionBuilder {
	done() { // {{{
		if @undone {
			@writer.push(@writer._terminator)
			
			@undone = false
		}
	} // }}}
}