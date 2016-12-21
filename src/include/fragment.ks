const $indentations = []

class CodeFragment {
	private {
		end		= null
		code
		start	= null
	}
	CodeFragment(@code)
	CodeFragment(@code, @start, @end)
	toString() { // {{{
		if this._start? {
			return `\(this._code): \($locationDataToString(this._location))`
		}
		else {
			return this.code
		}
	} // }}}
}

func $code(code) { // {{{
	return new CodeFragment(code)
} // }}}

func $codeLoc(code, start, end) { // {{{
	return new CodeFragment(code, start, end)
} // }}}

func $fragmentsToText(fragments) { // {{{
	return [fragment.code for fragment in fragments].join('')
} // }}}

func $indent(indent) { // {{{
	return $indentations[indent] ?? ($indentations[indent] = $code('\t'.repeat(indent)))
} // }}}

func $locationDataToString(location?) { // {{{
	if location? {
		return `\(location.first_line + 1):\(location.first_column + 1)-\(location.last_line + 1):\(location.last_column + 1)`
	}
	else {
		return 'No location data'
	}
} // }}}

func $quote(value) { // {{{
	return '"' + value.replace(/"/g, '\\"') + '"'
} // }}}

const $comma = $code(', ')
const $dot = $code('.')
const $equals = $code(' = ')
const $space = $code(' ')
const $terminator = $code(';\n')

class FragmentBuilder {
	private {
		_arrays			= {}
		_blocks			= {}
		_expressions	= {}
		_fragments		= []
		_indent
		_lines			= {}
		_objects		= {}
	}
	FragmentBuilder(@indent)
	line(...args) { // {{{
		let line = LineBuilder.create(this, this._indent)
		
		if args.length == 1 && args[0] is Object {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}
		
		line.done()
		
		return this
	} // }}}
	newControl() { // {{{
		return new ControlBuilder(this, this._indent)
	} // }}}
	newLine() { // {{{
		return LineBuilder.create(this, this._indent)
	} // }}}
	toArray() => this._fragments
}

class ControlBuilder {
	private {
		_addLastNewLine
		_builder
		_firstStep = true
		_indent
		_step
	}
	ControlBuilder(@builder, @indent, @addLastNewLine = true) { // {{{
		this._step = ExpressionBuilder.create(this._builder, this._indent)
	} // }}}
	code(...args) { // {{{
		this._step.code(...args)
		
		return this
	} // }}}
	compile(node, mode = Mode::None) { // {{{
		this._step.compile(node, mode)
		
		return this
	} // }}}
	compileBoolean(node) { // {{{
		this._step.compileBoolean(node)
		
		return this
	} // }}}
	compileNullable(node) { // {{{
		this._step.compileNullable(node)
		
		return this
	} // }}}
	done() { // {{{
		this._step.done()
		
		if this._addLastNewLine {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
	} // }}}
	isFirstStep() { // {{{
		return this._firstStep
	} // }}}
	line(...args) { // {{{
		this._step.line(...args)
		
		return this
	} // }}}
	newControl() { // {{{
		return this._step.newControl()
	} // }}}
	newLine() { // {{{
		return this._step.newLine()
	} // }}}
	step() { // {{{
		this._step.done()
		
		if this._step is ExpressionBuilder {
			this._step = BlockBuilder.create(this._builder, this._indent)
		}
		else {
			if this._addLastNewLine {
				this._builder._fragments.push(new CodeFragment('\n'))
			}
			
			this._step = ExpressionBuilder.create(this._builder, this._indent)
		}
		
		this._firstStep = false if this._firstStep
		
		return this
	} // }}}
	wrap(node) { // {{{
		this._step.wrap(node)
		
		return this
	} // }}}
	wrapBoolean(node) { // {{{
		this._step.wrapBoolean(node)
		
		return this
	} // }}}
	wrapNullable(node) { // {{{
		this._step.wrapNullable(node)
		
		return this
	} // }}}
}

class BlockBuilder {
	static create(builder, indent) { // {{{
		builder._blocks[indent] ??= new BlockBuilder(builder, indent)
	
		return builder._blocks[indent].init()
	} // }}}
	private {
		_builder
		_indent
	}
	BlockBuilder(@builder, @indent)
	compile(node, mode = Mode::None) { // {{{
		if node is Object {
			node.toFragments(this, mode)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	done() { // {{{
		this._builder._fragments.push($indent(this._indent), new CodeFragment('}'))
	} // }}}
	private init() { // {{{
		this._builder._fragments.push(new CodeFragment(' {\n'))
		
		return this
	} // }}}
	line(...args) { // {{{
		let line = LineBuilder.create(this._builder, this._indent + 1)
		
		if args.length == 1 && args[0] is Object {
			line.compile(args[0])
		}
		else {
			line.code(...args)
		}
		
		line.done()
		
		return this
	} // }}}
	newControl(indent = this._indent + 1) { // {{{
		return new ControlBuilder(this._builder, indent)
	} // }}}
	newLine(indent = this._indent + 1) { // {{{
		return LineBuilder.create(this._builder, indent)
	} // }}}
}

class ExpressionBuilder {
	static create(builder, indent) { // {{{
		builder._expressions[indent] ??= new ExpressionBuilder(builder, indent)
	
		return builder._expressions[indent].init()
	} // }}}
	private {
		_builder
		_indent
	}
	ExpressionBuilder(@builder, @indent)
	code(...args) { // {{{
		let arg, data
		for i from 0 til args.length {
			arg = args[i]
			
			if arg is Array {
				this.push(...arg)
			}
			else if arg is Object {
				this._builder._fragments.push(arg)
			}
			else {
				if i + 1 < args.length && (data = args[i + 1]) is Object && data.kind? {
					if data.start? {
						this._builder._fragments.push(new CodeFragment(arg, data.start, data.end))
					}
					else {
						this._builder._fragments.push(new CodeFragment(arg))
					}
					
					i++
				}
				else {
					this._builder._fragments.push(new CodeFragment(arg))
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
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	compileBoolean(node, mode = Mode::None) { // {{{
		if node is Object {
			node.toBooleanFragments(this, mode)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	compileNullable(node) { // {{{
		if node is Object {
			node.toNullableFragments(this)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	compileReusable(node) { // {{{
		if node is Object {
			node.toReusableFragments(this)
		}
		else {
			this._builder._fragments.push(new CodeFragment(node))
		}
		
		return this
	} // }}}
	done(skipLastNewLine = false) { // {{{
	} // }}}
	private init() { // {{{
		this._builder._fragments.push($indent(this._indent))
		
		return this
	} // }}}
	newArray(indent = this._indent) { // {{{
		return ArrayBuilder.create(this._builder, indent)
	} // }}}
	newBlock(indent = this._indent) { // {{{
		return BlockBuilder.create(this._builder, indent)
	} // }}}
	newControl(indent = this._indent + 1) { // {{{
		return new ControlBuilder(this._builder, indent)
	} // }}}
	newLine(indent = this._indent + 1) { // {{{
		return LineBuilder.create(this._builder, indent)
	} // }}}
	newObject(indent = this._indent) { // {{{
		return ObjectBuilder.create(this._builder, indent)
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
	static create(builder, indent) { // {{{
		builder._lines[indent] ??= new LineBuilder(builder, indent)
	
		return builder._lines[indent].init()
	} // }}}
	done() { // {{{
		this._builder._fragments.push($terminator)
	} // }}}
}

class ObjectBuilder {
	static create(builder, indent) { // {{{
		builder._objects[indent] ??= new ObjectBuilder(builder, indent)
	
		return builder._objects[indent].init()
	} // }}}
	private {
		_builder
		_indent
		_line
	}
	ObjectBuilder(@builder, @indent)
	done() { // {{{
		if this._line? {
			this._line.done()
			
			this._line = null
			
			this._builder._fragments.push(new CodeFragment('\n'), $indent(this._indent), new CodeFragment('}'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('}'))
		}
	} // }}}
	private init() { // {{{
		this._line = null
		
		this._builder._fragments.push(new CodeFragment('{'))
		
		return this
	} // }}}
	line(...args) { // {{{
		let line = this.newLine()
		
		line.code(...args)
		
		return this
	} // }}}
	newControl() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = new ControlBuilder(this._builder, this._indent + 1, false)
	} // }}}
	newLine() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = ExpressionBuilder.create(this._builder, this._indent + 1)
	} // }}}
}

class ArrayBuilder {
	static create(builder, indent) { // {{{
		builder._arrays[indent] ??= new ArrayBuilder(builder, indent)
	
		return builder._arrays[indent].init()
	} // }}}
	private {
		_builder
		_indent
		_line
	}
	ArrayBuilder(@builder, @indent)
	done() { // {{{
		if this._line? {
			this._line.done()
			
			this._line = null
			
			this._builder._fragments.push(new CodeFragment('\n'), $indent(this._indent), new CodeFragment(']'))
		}
		else {
			this._builder._fragments.push(new CodeFragment(']'))
		}
	} // }}}
	private init() { // {{{
		this._line = null
		
		this._builder._fragments.push(new CodeFragment('['))
		
		return this
	} // }}}
	line(...args) { // {{{
		this.newLine().code(...args)
		
		return this
	} // }}}
	newControl() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = new ControlBuilder(this._builder, this._indent + 1, false)
	} // }}}
	newLine() { // {{{
		if this._line? {
			this._line.done()
			
			this._builder._fragments.push(new CodeFragment(',\n'))
		}
		else {
			this._builder._fragments.push(new CodeFragment('\n'))
		}
		
		return this._line = ExpressionBuilder.create(this._builder, this._indent + 1)
	} // }}}
}