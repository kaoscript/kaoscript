/**
 * compiler.ks
 * Version 0.9.0
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![error(off)]
#![runtime(type(alias='KSType'))]

import {
	'../package.json'		as metadata
	'./fs.js'
	'@kaoscript/ast'
	'@kaoscript/parser'()	for parse
	'path'
}

extern console, JSON

include './include/error'

const $extensions = { // {{{
	binary: '.ksb',
	hash: '.ksh',
	metadata: '.ksm',
	source: '.ks'
} // }}}

const $targetRegex = /^(\w+)-v(\d+)(?:\.\d+)?(?:\.\d+)?$/

const $typeofs = { // {{{
	Any: true
	Array: true
	Boolean: true
	Class: true
	Function: true
	NaN: true
	Number: true
	Object: true
	RegExp: true
	String: true
} // }}}

const $ast = {
	block(data) { // {{{
		return data if data.kind == NodeKind::Block
		
		return {
			kind: NodeKind::Block
			statements: [
				data
			]
		}
	} // }}}
	body(data?) { // {{{
		if !?data {
			return []
		}
		else if data.kind == NodeKind::Block {
			return data.statements
		}
		else {
			return [
				{
					kind: NodeKind::ReturnStatement
					value: data
					start: data.start
					end: data.end
				}
			]
		}
	} // }}}
	identifier(name) { // {{{
		if name is String {
			return {
				kind: NodeKind::Identifier
				name: name
			}
		}
		else {
			return name
		}
	} // }}}
	toSource(data, validate) { // {{{
		switch data.kind {
			NodeKind::BinaryExpression => {
				return $ast.toSource(data.left, validate) + $ast.toBinarySource(data.operator) + $ast.toSource(data.right, validate)
			}
			NodeKind::CallExpression => {
				let source = $ast.toSource(data.callee, validate)
				
				source += '('
				
				for argument, index in data.arguments {
					if index != 0 {
						source += ', '
					}
					
					source += $ast.toSource(argument, validate)
				}
				
				source += ')'
				
				return source
			}
			NodeKind::CreateExpression => {
				let source = 'new ' + $ast.toSource(data.class, validate)
				
				source += '('
				
				for argument, index in data.arguments {
					if index != 0 {
						source += ', '
					}
					
					source += $ast.toSource(argument, validate)
				}
				
				source += ')'
				
				return source
			}
			NodeKind::Identifier => {
				validate(data.name)
				
				return data.name
			}
			NodeKind::ImportDeclaration => {
				if data.declarations.length == 1 {
					return 'import ' + $ast.toSource(data.declarations[0], validate)
				}
				else {
					throw new NotImplementedException()
				}
			}
			NodeKind::ImportDeclarator => {
				return $quote(data.source.value)
			}
			NodeKind::Literal => {
				return $quote(data.value)
			}
			NodeKind::MemberExpression => {
				let source = $ast.toSource(data.object, validate)
				
				if data.computed {
					source += '[' + $ast.toSource(data.property, validate) + ']'
				}
				else {
					source += '.' + $ast.toSource(data.property, validate)
				}
				
				return source
			}
			NodeKind::NumericExpression => {
				return data.value
			}
			NodeKind::TemplateExpression => {
				let source = '`'
				
				for element in data.elements {
					if element.kind == NodeKind::Literal {
						source += element.value
					}
					else {
						source += '\\(' + $ast.toSource(element, validate) + ')'
					}
				}
				
				return source + '`'
			}
			NodeKind::VariableDeclaration => {
				let source = data.rebindable ? 'let ' : 'const '
				
				for variable, index in data.variables {
					if index != 0 {
						source += ', '
					}
					
					source += $ast.toSource(variable, validate)
				}
				
				if data.init? {
					source += (data.autotype ? ' := ' : ' = ')
					
					source += $ast.toSource(data.init, validate)
				}
				
				return source
			}
			NodeKind::VariableDeclarator => {
				return $ast.toSource(data.name, validate)
			}
			=> {
				console.error(data)
				throw new NotImplementedException()
			}
		}
	} // }}}
	toBinarySource(data) { // {{{
		switch data.kind {
			BinaryOperatorKind::Division => {
				return '/'
			}
			BinaryOperatorKind::Multiplication => {
				return '*'
			}
			=> {
				console.error(data)
				throw new NotImplementedException()
			}
		}
	} // }}}
}

const $runtime = {
	helper(node) { // {{{
		node.module?().flag('Helper')
		
		return node._options.runtime.helper.alias
	} // }}}
	isDefined(name, node) { // {{{
		if node._options.runtime.helper.alias == name {
			node.module?().flag('Helper')
			
			return true
		}
		else if node._options.runtime.type.alias == name {
			node.module?().flag('Type')
			
			return true
		}
		else {
			return false
		}
	} // }}}
	scope(node) { // {{{
		return node._options.format.variables == 'es5' ? 'var ' : 'let '
	} // }}}
	type(node) { // {{{
		node.module?().flag('Type')
		
		return node._options.runtime.type.alias
	} // }}}
	typeof(type, node = null) { // {{{
		if node? {
			return null unless $typeofs[type]
			
			if type == 'NaN' {
				return 'isNaN'
			}
			else {
				return $runtime.type(node) + '.is' + type
			}
		}
		else {
			return $typeofs[type]
		}
	} // }}}
}

abstract class AbstractNode {
	private {
		_data
		_options
		_parent: AbstractNode	= null
		_reference
		_scope: AbstractScope	= null
	}
	constructor()
	constructor(@data, @parent, @scope = parent.scope()) { // {{{
		@options = parent._options
	} // }}}
	abstract analyse()
	abstract prepare()
	abstract translate()
	data() => @data
	directory() => this._parent.directory()
	file() => this._parent.file()
	greatParent() => this._parent?._parent
	greatScope() => this._parent?._scope
	isConsumedError(error): Boolean => @parent.isConsumedError(error)
	module() => this._parent.module()
	newScope() { // {{{
		if this._options.format.variables == 'es6' {
			return new Scope(this._scope)
		}
		else {
			return new XScope(this._scope)
		}
	} // }}}
	newScope(scope) { // {{{
		if this._options.format.variables == 'es6' {
			return new Scope(scope)
		}
		else {
			return new XScope(scope)
		}
	} // }}}
	parent() => this._parent
	reference() { // {{{
		if this._parent? && this._parent.reference()? {
			return this._parent.reference() + this._reference
		}
		else {
			return this._reference
		}
	} // }}}
	reference(@reference) { // {{{
	} // }}}
	scope() => this._scope
	statement() => this._parent?.statement()
}

include {
	'./include/util'
	'./include/attribute'
	'./include/fragment'
	'./include/type'
	'./include/variable'
	'./include/scope'
	'./include/module'
	'./include/statement'
	'./include/expression'
	'./include/parameter'
	'./operator/assignment'
	'./operator/binary'
	'./operator/polyadic'
	'./operator/unary'
	'./include/macro'
}

const $compile = {
	expression(data, parent, scope = parent.scope()) { // {{{
		let expression
		
		let clazz = $expressions[data.kind]
		if clazz? {
			expression = clazz is Class ? new clazz(data, parent, scope) : clazz(data, parent, scope)
		}
		else if data.kind == NodeKind::BinaryExpression {
			if clazz ?= $binaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else if data.operator.kind == BinaryOperatorKind::Assignment {
				if clazz = $assignmentOperators[data.operator.assignment] {
					expression = new clazz(data, parent, scope)
				}
				else {
					throw new NotSupportedException(`Unexpected assignment operator \(data.operator.assignment)`, parent)
				}
			}
			else {
				throw new NotSupportedException(`Unexpected binary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::PolyadicExpression {
			if clazz ?= $polyadicOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected polyadic operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::UnaryExpression {
			if clazz ?= $unaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected unary operator \(data.operator.kind)`, parent)
			}
		}
		else {
			throw new NotSupportedException(`Unexpected expression/statement \(data.kind)`, parent)
		}
		
		return expression
	} // }}}
	statement(data, parent) { // {{{
		if Attribute.conditional(data, parent.module()._compiler._target) {
			if data.kind == NodeKind::MacroDeclaration {
				parent.scope().addMacro(data.name.name, new Macro(data, parent))
				
				return null
			}
			else {
				let clazz = $statements[data.kind] ?? $statements.default
				
				return new clazz(data, parent)
			}
		}
		else {
			return null
		}
	} // }}}
}

const $assignmentOperators = {
	`\(AssignmentOperatorKind::Addition)`			: AssignmentOperatorAddition
	`\(AssignmentOperatorKind::BitwiseAnd)`			: AssignmentOperatorBitwiseAnd
	`\(AssignmentOperatorKind::BitwiseLeftShift)`	: AssignmentOperatorBitwiseLeftShift
	`\(AssignmentOperatorKind::BitwiseOr)`			: AssignmentOperatorBitwiseOr
	`\(AssignmentOperatorKind::BitwiseRightShift)`	: AssignmentOperatorBitwiseRightShift
	`\(AssignmentOperatorKind::BitwiseXor)`			: AssignmentOperatorBitwiseXor
	`\(AssignmentOperatorKind::Equality)`			: AssignmentOperatorEquality
	`\(AssignmentOperatorKind::Existential)`		: AssignmentOperatorExistential
	`\(AssignmentOperatorKind::Modulo)`				: AssignmentOperatorModulo
	`\(AssignmentOperatorKind::Multiplication)`		: AssignmentOperatorMultiplication
	`\(AssignmentOperatorKind::NonExistential)`		: AssignmentOperatorNonExistential
	`\(AssignmentOperatorKind::NullCoalescing)`		: AssignmentOperatorNullCoalescing
	`\(AssignmentOperatorKind::Subtraction)`		: AssignmentOperatorSubtraction
}

const $binaryOperators = {
	`\(BinaryOperatorKind::Addition)`			: BinaryOperatorAddition
	`\(BinaryOperatorKind::And)`				: BinaryOperatorAnd
	`\(BinaryOperatorKind::BitwiseAnd)`			: BinaryOperatorBitwiseAnd
	`\(BinaryOperatorKind::BitwiseLeftShift)`	: BinaryOperatorBitwiseLeftShift
	`\(BinaryOperatorKind::BitwiseOr)`			: BinaryOperatorBitwiseOr
	`\(BinaryOperatorKind::BitwiseRightShift)`	: BinaryOperatorBitwiseRightShift
	`\(BinaryOperatorKind::BitwiseXor)`			: BinaryOperatorBitwiseXor
	`\(BinaryOperatorKind::Division)`			: BinaryOperatorDivision
	`\(BinaryOperatorKind::Equality)`			: BinaryOperatorEquality
	`\(BinaryOperatorKind::GreaterThan)`		: BinaryOperatorGreaterThan
	`\(BinaryOperatorKind::GreaterThanOrEqual)`	: BinaryOperatorGreaterThanOrEqual
	`\(BinaryOperatorKind::Inequality)`			: BinaryOperatorInequality
	`\(BinaryOperatorKind::LessThan)`			: BinaryOperatorLessThan
	`\(BinaryOperatorKind::LessThanOrEqual)`	: BinaryOperatorLessThanOrEqual
	`\(BinaryOperatorKind::Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperatorKind::Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: BinaryOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: BinaryOperatorOr
	`\(BinaryOperatorKind::Subtraction)`		: BinaryOperatorSubtraction
	`\(BinaryOperatorKind::TypeCasting)`		: BinaryOperatorTypeCasting
	`\(BinaryOperatorKind::TypeEquality)`		: BinaryOperatorTypeEquality
	`\(BinaryOperatorKind::TypeInequality)`		: BinaryOperatorTypeInequality
}

const $expressions = {
	`\(NodeKind::ArrayBinding)`					: ArrayBinding
	`\(NodeKind::ArrayComprehension)`			: func(data, parent, scope) {
		if data.loop.kind == NodeKind::ForFromStatement {
			return new ArrayComprehensionForFrom(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForInStatement {
			return new ArrayComprehensionForIn(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForOfStatement {
			return new ArrayComprehensionForOf(data, parent, scope)
		}
		else if data.loop.kind == NodeKind::ForRangeStatement {
			return new ArrayComprehensionForRange(data, parent, scope)
		}
		else {
			throw new NotSupportedException(`Unexpected kind \(data.loop.kind)`, parent)
		}
	}
	`\(NodeKind::ArrayExpression)`				: ArrayExpression
	`\(NodeKind::ArrayRange)`					: ArrayRange
	`\(NodeKind::AwaitExpression)`				: AwaitExpression
	`\(NodeKind::BindingElement)`				: BindingElement
	`\(NodeKind::Block)`						: BlockExpression
	`\(NodeKind::CallExpression)`				: CallExpression
	`\(NodeKind::CallMacroExpression)`	 		: func(data, parent, scope) {
		const macro = scope.getMacro(data, parent)
		
		const statements = macro.execute(data.arguments, parent)
		
		if statements.length == 1 && statements[0] is ExpressionStatement {
			return $compile.expression(statements[0].data(), parent)
		}
		else {
			throw new NotImplementedException(parent)
		}
	}
	`\(NodeKind::ConditionalExpression)`		: ConditionalExpression
	`\(NodeKind::CreateExpression)`				: CreateExpression
	`\(NodeKind::CurryExpression)`				: CurryExpression
	`\(NodeKind::EnumExpression)`				: EnumExpression
	`\(NodeKind::FunctionExpression)`			: FunctionExpression
	`\(NodeKind::Identifier)`					: IdentifierLiteral
	`\(NodeKind::IfExpression)`					: IfExpression
	`\(NodeKind::LambdaExpression)`				: LambdaExpression
	`\(NodeKind::Literal)`						: StringLiteral
	`\(NodeKind::MemberExpression)`				: MemberExpression
	`\(NodeKind::NumericExpression)`			: NumberLiteral
	`\(NodeKind::ObjectBinding)`				: ObjectBinding
	`\(NodeKind::ObjectExpression)`				: ObjectExpression
	`\(NodeKind::ObjectMember)`					: ObjectMember
	`\(NodeKind::OmittedExpression)`			: OmittedExpression
	`\(NodeKind::RegularExpression)`			: RegularExpression
	`\(NodeKind::SequenceExpression)`			: SequenceExpression
	`\(NodeKind::TemplateExpression)`			: TemplateExpression
	`\(NodeKind::ThisExpression)`				: ThisExpression
	`\(NodeKind::UnlessExpression)`				: UnlessExpression
}

const $statements = {
	`\(NodeKind::BreakStatement)`				: BreakStatement
	`\(NodeKind::CallMacroExpression)`	 		: CallMacroStatement
	`\(NodeKind::ClassDeclaration)`				: ClassDeclaration
	`\(NodeKind::ContinueStatement)`			: ContinueStatement
	`\(NodeKind::DestroyStatement)`				: DestroyStatement
	`\(NodeKind::DoUntilStatement)`				: DoUntilStatement
	`\(NodeKind::DoWhileStatement)`				: DoWhileStatement
	`\(NodeKind::EnumDeclaration)`				: EnumDeclaration
	`\(NodeKind::ExportDeclaration)`			: ExportDeclaration
	`\(NodeKind::ExternDeclaration)`			: ExternDeclaration
	`\(NodeKind::ExternOrRequireDeclaration)`	: ExternOrRequireDeclaration
	`\(NodeKind::ForFromStatement)`				: ForFromStatement
	`\(NodeKind::ForInStatement)`				: ForInStatement
	`\(NodeKind::ForOfStatement)`				: ForOfStatement
	`\(NodeKind::ForRangeStatement)`			: ForRangeStatement
	`\(NodeKind::FunctionDeclaration)`			: FunctionDeclaration
	`\(NodeKind::IfStatement)`					: IfStatement
	`\(NodeKind::ImplementDeclaration)`			: ImplementDeclaration
	`\(NodeKind::ImportDeclaration)`			: ImportDeclaration
	`\(NodeKind::IncludeDeclaration)`			: IncludeDeclaration
	`\(NodeKind::IncludeOnceDeclaration)`		: IncludeOnceDeclaration
	`\(NodeKind::NamespaceDeclaration)`			: NamespaceDeclaration
	`\(NodeKind::RequireDeclaration)`			: RequireDeclaration
	`\(NodeKind::RequireOrExternDeclaration)`	: RequireOrExternDeclaration
	`\(NodeKind::RequireOrImportDeclaration)`	: RequireOrImportDeclaration
	`\(NodeKind::ReturnStatement)`				: ReturnStatement
	`\(NodeKind::SwitchStatement)`				: SwitchStatement
	`\(NodeKind::ThrowStatement)`				: ThrowStatement
	`\(NodeKind::TryStatement)`					: TryStatement
	`\(NodeKind::TypeAliasDeclaration)`			: TypeAliasDeclaration
	`\(NodeKind::UnlessStatement)`				: UnlessStatement
	`\(NodeKind::UntilStatement)`				: UntilStatement
	`\(NodeKind::VariableDeclaration)`			: VariableDeclaration
	`\(NodeKind::WhileStatement)`				: WhileStatement
	`default`									: ExpressionStatement
}

const $polyadicOperators = {
	`\(BinaryOperatorKind::Addition)`			: PolyadicOperatorAddition
	`\(BinaryOperatorKind::And)`				: PolyadicOperatorAnd
	`\(BinaryOperatorKind::BitwiseAnd)`			: PolyadicOperatorBitwiseAnd
	`\(BinaryOperatorKind::BitwiseLeftShift)`	: PolyadicOperatorBitwiseLeftShift
	`\(BinaryOperatorKind::BitwiseOr)`			: PolyadicOperatorBitwiseOr
	`\(BinaryOperatorKind::BitwiseRightShift)`	: PolyadicOperatorBitwiseRightShift
	`\(BinaryOperatorKind::BitwiseXor)`			: PolyadicOperatorBitwiseXor
	`\(BinaryOperatorKind::Division)`			: PolyadicOperatorDivision
	`\(BinaryOperatorKind::Equality)`			: PolyadicOperatorEquality
	`\(BinaryOperatorKind::GreaterThan)`		: PolyadicOperatorGreaterThan
	`\(BinaryOperatorKind::GreaterThanOrEqual)`	: PolyadicOperatorGreaterThanOrEqual
	`\(BinaryOperatorKind::LessThan)`			: PolyadicOperatorLessThan
	`\(BinaryOperatorKind::LessThanOrEqual)`	: PolyadicOperatorLessThanOrEqual
	`\(BinaryOperatorKind::Modulo)`				: PolyadicOperatorModulo
	`\(BinaryOperatorKind::Multiplication)`		: PolyadicOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: PolyadicOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: PolyadicOperatorOr
	`\(BinaryOperatorKind::Subtraction)`		: PolyadicOperatorSubtraction
}

const $unaryOperators = {
	`\(UnaryOperatorKind::BitwiseNot)`			: UnaryOperatorBitwiseNot
	`\(UnaryOperatorKind::DecrementPostfix)`	: UnaryOperatorDecrementPostfix
	`\(UnaryOperatorKind::DecrementPrefix)`		: UnaryOperatorDecrementPrefix
	`\(UnaryOperatorKind::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperatorKind::IncrementPostfix)`	: UnaryOperatorIncrementPostfix
	`\(UnaryOperatorKind::IncrementPrefix)`		: UnaryOperatorIncrementPrefix
	`\(UnaryOperatorKind::Negation)`			: UnaryOperatorNegation
	`\(UnaryOperatorKind::Negative)`			: UnaryOperatorNegative
	`\(UnaryOperatorKind::Spread)`				: UnaryOperatorSpread
}

const $targets = {
	ecma: { // {{{
		'5': {
			format: {
				classes: 'es5'
				destructuring: 'es5'
				functions: 'es5'
				parameters: 'es5'
				spreads: 'es5'
				variables: 'es5'
			}
		}
		'6': {
			format: {
				classes: 'es6'
				destructuring: 'es6'
				functions: 'es6'
				parameters: 'es6'
				spreads: 'es6'
				variables: 'es6'
			}
		}
	} // }}}
}

export class Compiler {
	private {
		_file: String
		_fragments
		_hashes
		_module
		_options
		_target
	}
	static {
		registerTarget(target, options) { // {{{
			if target !?= $targetRegex.exec(target) {
				throw new Error(`Invalid target syntax: \(target)`)
			}
			
			$targets[target[1]] ??= {}
			$targets[target[1]][target[2]] = options
		} // }}}
		registerTargets(targets) { // {{{
			for name, data of targets {
				if data is String {
					Compiler.registerTargetAlias(name, data)
				}
				else {
					Compiler.registerTarget(name, data)
				}
			}
		} // }}}
		registerTargetAlias(target, alias) { // {{{
			if target !?= $targetRegex.exec(target) {
				throw new Error(`Invalid target syntax: \(target)`)
			}
			if alias !?= $targetRegex.exec(alias) {
				throw new Error(`Invalid target syntax: \(alias)`)
			}
			
			if !?$targets[alias[1]] {
				throw new Error(`Undefined target '\(alias[1])'`)
			}
			else if !?$targets[alias[1]][alias[2]] {
				throw new Error(`Undefined target's version '\(alias[2])'`)
			}
			
			$targets[target[1]] ??= {}
			$targets[target[1]][target[2]] = $targets[alias[1]][alias[2]]
		} // }}}
	}
	constructor(@file, options = null, @hashes = {}) { // {{{
		@options = Object.merge({
			target: 'ecma-v6'
			register: true
			config: {
				header: true
				error: {
					level: 'fatal'
					ignore: []
					raise: []
				}
				parse: {
					parameters: 'kaoscript'
				}
				format: {}
				runtime: {
					helper: {
						alias: 'Helper'
						member: 'Helper'
						package: '@kaoscript/runtime'
					}
					type: {
						alias: 'Type'
						member: 'Type'
						package: '@kaoscript/runtime'
					}
				}
			}
		}, options)
		
		if target !?= $targetRegex.exec(@options.target) {
			throw new Error(`Invalid target syntax: \(@options.target)`)
		}
		
		@target = {
			name: target[1],
			version: target[2]
		}
		
		if !?$targets[@target.name] {
			throw new Error(`Undefined target '\(@target.name)'`)
		}
		else if !?$targets[@target.name][@target.version] {
			throw new Error(`Undefined target's version '\(@target.version)'`)
		}
		
		@options.target = `\(@target.name)-v\(@target.version)`
		
		@options.config = Object.defaults($targets[@target.name][@target.version], @options.config)
	} // }}}
	compile(data = null) { // {{{
		//console.time('parse')
		@module = new Module(data ?? fs.readFile(@file), this, @file)
		//console.timeEnd('parse')
		
		//console.time('compile')
		@module.compile()
		//console.timeEnd('compile')
		
		//console.time('toFragments')
		@fragments = @module.toFragments()
		//console.timeEnd('toFragments')
		
		return this
	} // }}}
	createServant(file) { // {{{
		return new Compiler(file, {
			config: @options.config
			register: false
			target: @options.target
		}, @hashes)
	} // }}}
	readFile() => fs.readFile(@file)
	sha256(file, data = null) { // {{{
		return this._hashes[file] ?? (this._hashes[file] = fs.sha256(data ?? fs.readFile(file)))
	} // }}}
	toHashes() { // {{{
		return this._module.toHashes()
	} // }}}
	toMetadata() { // {{{
		return this._module.toMetadata()
	} // }}}
	toSource() { // {{{
		let source = ''
		
		for fragment in @fragments {
			source += fragment.code
		}
		
		if source.length {
			return source.substr(0, source.length - 1)
		}
		else {
			return source
		}
	} // }}}
	toSourceMap() { // {{{
		return this._module.toSourceMap()
	} // }}}
	writeFiles() { // {{{
		fs.mkdir(path.dirname(this._file))
		
		fs.writeFile(getBinaryPath(this._file, this._options.target), this.toSource())
		
		if !this._module._binary {
			let metadata = this.toMetadata()
			
			fs.writeFile(getMetadataPath(this._file, this._options.target), JSON.stringify(metadata))
		}
		
		fs.writeFile(getHashPath(this._file, this._options.target), JSON.stringify(this._module.toHashes()))
	} // }}}
	writeOutput() { // {{{
		if !this._options.output {
			throw new Error('Undefined option: output')
		}
		
		fs.mkdir(this._options.output)
		
		let filename = path.join(this._options.output, path.basename(this._file)).slice(0, -3) + '.js'
		
		fs.writeFile(filename, this.toSource())
		
		return this
	} // }}}
}

export func compileFile(file, options = null) { // {{{
	let compiler = new Compiler(file, options)
	
	return compiler.compile().toSource()
} // }}}

export func getBinaryPath(file, target) => fs.hidden(file, target, $extensions.binary)

export func getHashPath(file, target) => fs.hidden(file, target, $extensions.hash)

export func getMetadataPath(file, target) => fs.hidden(file, target, $extensions.metadata)

export func isUpToDate(file, target, source) { // {{{
	let hashes
	try {
		hashes = JSON.parse(fs.readFile(getHashPath(file, target)))
	}
	catch {
		return false
	}
	
	let root = path.dirname(file)
	
	for name, hash of hashes {
		if name == '.' {
			return null if fs.sha256(source) != hash
		}
		else {
			return null if fs.sha256(fs.readFile(path.join(root, name))) != hash
		}
	}
	
	return true
} // }}}

export $extensions as extensions