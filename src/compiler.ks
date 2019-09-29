/**
 * compiler.ks
 * Version 0.9.1
 * September 14th, 2016
 *
 * Copyright (c) 2016 Baptiste Augrain
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 **/
#![runtime(prefix='KS')]

#![error(off)]
#![rules(ignore-misfit)]

import {
	'../package.json'	=> metadata
	'./fs.js'
	'path'
}

extern console, JSON

include {
	'@kaoscript/ast'
	'@kaoscript/parser'
	'@kaoscript/util'
	'./include/error'
}

const $extensions = { // {{{
	binary: '.ksb',
	hash: '.ksh',
	metadata: '.ksm',
	source: '.ks'
} // }}}

const $targetRegex = /^(\w+)-v((?:\d+)(?:\.\d+)?(?:\.\d+)?)$/

const $typeofs = { // {{{
	Array: true
	Boolean: true
	Class: true
	Enum: true
	Function: true
	Namespace: true
	Number: true
	Object: true
	RegExp: true
	String: true
} // }}}

const $ast = {
	block(data) { // {{{
		if data.kind == NodeKind::Block {
			return data
		}
		else {
			return {
				kind: NodeKind::Block
				statements: [
					data
				]
				start: data.start
				end: data.end
			}
		}
	} // }}}
	body(data?) { // {{{
		if !?data.body {
			return {
				kind: NodeKind::Block
				statements: []
				start: data.start
				end: data.end
			}
		}
		else if data.body.kind == NodeKind::Block ||  data.body.kind == NodeKind::ReturnStatement {
			return data.body
		}
		else if data.body.kind == NodeKind::IfStatement || data.body.kind == NodeKind::UnlessStatement {
			return {
				kind: NodeKind::Block
				statements: [data.body]
				start: data.body.start
				end: data.body.end
			}
		}
		else {
			return {
				kind: NodeKind::ReturnStatement
				value: data.body
				start: data.body.start
				end: data.body.end
			}
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
}

const $runtime = {
	helper(node) { // {{{
		node.module?().flag('Helper')

		return node._options.runtime.helper.alias
	} // }}}
	getVariable(name, node) { // {{{
		if node._options.runtime.helper.alias == name || (node.isIncluded() && name == 'Helper') {
			node.module?().flag('Helper')

			return node._options.runtime.helper.alias
		}
		else if node._options.runtime.type.alias == name || (node.isIncluded() && name == 'Type') {
			node.module?().flag('Type')

			return node._options.runtime.type.alias
		}
		else {
			return null
		}
	} // }}}
	operator(node) { // {{{
		node.module?().flag('Operator')

		return node._options.runtime.operator.alias
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
			if $typeofs[type] {
				return $runtime.type(node) + '.is' + type
			}
			else {
				return null
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
		_parent: AbstractNode?	= null
		_reference
		_scope: Scope?			= null
	}
	constructor()
	constructor(@data, @parent, @scope = parent?.scope()) { // {{{
		@options = parent._options
	} // }}}
	constructor(@data, @parent, scope: Scope, kind: ScopeType) { // {{{
		@options = parent._options

		@scope = this.newScope(scope, kind)
	} // }}}
	abstract analyse()
	abstract prepare()
	abstract translate()
	data() => @data
	directory() => @parent.directory()
	file() => @parent.file()
	isConsumedError(error): Boolean => @parent.isConsumedError(error)
	isIncluded(): Boolean => this.file() != this.module().file()
	module() => @parent.module()
	newScope(scope: Scope, type: ScopeType) { // {{{
		switch type {
			ScopeType::Bleeding => {
				return new BleedingScope(scope)
			}
			ScopeType::Block => {
				return new BlockScope(scope)
			}
			ScopeType::Function => {
				return new FunctionScope(scope)
			}
			ScopeType::Hollow => {
				return new HollowScope(scope)
			}
			ScopeType::InlineBlock => {
				if @options.format.variables == 'es6' {
					return new InlineBlockScope(scope)
				}
				else {
					return new LaxInlineBlockScope(scope)
				}
			}
			ScopeType::Operation => {
				return new OperationScope(scope)
			}
		}
	} // }}}
	parent() => @parent
	reference() { // {{{
		if @parent?.reference()? {
			return @parent.reference() + @reference
		}
		else {
			return @reference
		}
	} // }}}
	reference(@reference)
	scope() => @scope
	statement() => @parent?.statement()
}

include {
	'./include/attribute'
	'./include/fragment'
	'./include/type'
	'./include/variable'
	'./include/scope'
	'./include/module'
	'./include/statement'
	'./include/expression'
	'./include/parameter'
	'./include/operator'
	'./include/block'
	'./include/macro'
	'./include/router'
}

const $compile = {
	block(data, parent, scope = parent.scope()) => new Block($ast.block(data), parent, scope)
	expression(data, parent, scope = parent.scope()) { // {{{
		let expression

		if const clazz = $expressions[data.kind] {
			expression = clazz is Class ? new clazz(data, parent, scope) : clazz(data, parent, scope)
		}
		else if data.kind == NodeKind::BinaryExpression {
			if data.operator.kind == BinaryOperatorKind::Assignment {
				if clazz = $assignmentOperators[data.operator.assignment] {
					expression = new clazz(data, parent, scope)
				}
				else {
					throw new NotSupportedException(`Unexpected assignment operator \(data.operator.assignment)`, parent)
				}
			}
			else if const clazz = $binaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected binary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::PolyadicExpression {
			if const clazz = $polyadicOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected polyadic operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::UnaryExpression {
			if const clazz = $unaryOperators[data.operator.kind] {
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
	statement(data, parent, scope = parent.scope()) { // {{{
		if Attribute.conditional(data, parent) {
			let clazz = $statements[data.kind] ?? $statements.default

			return new clazz(data, parent, scope)
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
	`\(AssignmentOperatorKind::Division)`			: AssignmentOperatorDivision
	`\(AssignmentOperatorKind::Equality)`			: AssignmentOperatorEquality
	`\(AssignmentOperatorKind::Existential)`		: AssignmentOperatorExistential
	`\(AssignmentOperatorKind::Modulo)`				: AssignmentOperatorModulo
	`\(AssignmentOperatorKind::Multiplication)`		: AssignmentOperatorMultiplication
	`\(AssignmentOperatorKind::NonExistential)`		: AssignmentOperatorNonExistential
	`\(AssignmentOperatorKind::NullCoalescing)`		: AssignmentOperatorNullCoalescing
	`\(AssignmentOperatorKind::Quotient)`			: AssignmentOperatorQuotient
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
	`\(BinaryOperatorKind::Imply)`				: BinaryOperatorImply
	`\(BinaryOperatorKind::Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperatorKind::Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: BinaryOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: BinaryOperatorOr
	`\(BinaryOperatorKind::Quotient)`			: BinaryOperatorQuotient
	`\(BinaryOperatorKind::Subtraction)`		: BinaryOperatorSubtraction
	`\(BinaryOperatorKind::TypeCasting)`		: BinaryOperatorTypeCasting
	`\(BinaryOperatorKind::TypeEquality)`		: BinaryOperatorTypeEquality
	`\(BinaryOperatorKind::TypeInequality)`		: BinaryOperatorTypeInequality
	`\(BinaryOperatorKind::Xor)`				: BinaryOperatorXor
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
	`\(NodeKind::CallExpression)`				: CallExpression
	`\(NodeKind::CallMacroExpression)`	 		: $callMacroExpression
	`\(NodeKind::ComparisonExpression)`			: ComparisonExpression
	`\(NodeKind::ConditionalExpression)`		: ConditionalExpression
	`\(NodeKind::CreateExpression)`				: CreateExpression
	`\(NodeKind::CurryExpression)`				: CurryExpression
	`\(NodeKind::EnumExpression)`				: EnumExpression
	`\(NodeKind::FunctionExpression)`			: AnonymousFunctionExpression
	`\(NodeKind::Identifier)`					: IdentifierLiteral
	`\(NodeKind::IfExpression)`					: IfExpression
	`\(NodeKind::LambdaExpression)`				: ArrowFunctionExpression
	`\(NodeKind::Literal)`						: StringLiteral
	`\(NodeKind::MemberExpression)`				: MemberExpression
	`\(NodeKind::NumericExpression)`			: NumberLiteral
	`\(NodeKind::ObjectBinding)`				: ObjectBinding
	`\(NodeKind::ObjectExpression)`				: ObjectExpression
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
	`\(NodeKind::DiscloseDeclaration)`			: DiscloseDeclaration
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
	`\(NodeKind::IncludeAgainDeclaration)`		: IncludeAgainDeclaration
	`\(NodeKind::MacroDeclaration)`				: MacroDeclaration
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
	`\(BinaryOperatorKind::Modulo)`				: PolyadicOperatorModulo
	`\(BinaryOperatorKind::Imply)`				: PolyadicOperatorImply
	`\(BinaryOperatorKind::Multiplication)`		: PolyadicOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: PolyadicOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: PolyadicOperatorOr
	`\(BinaryOperatorKind::Quotient)`			: PolyadicOperatorQuotient
	`\(BinaryOperatorKind::Subtraction)`		: PolyadicOperatorSubtraction
	`\(BinaryOperatorKind::Xor)`				: PolyadicOperatorXor
}

const $unaryOperators = {
	`\(UnaryOperatorKind::BitwiseNot)`			: UnaryOperatorBitwiseNot
	`\(UnaryOperatorKind::DecrementPostfix)`	: UnaryOperatorDecrementPostfix
	`\(UnaryOperatorKind::DecrementPrefix)`		: UnaryOperatorDecrementPrefix
	`\(UnaryOperatorKind::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperatorKind::ForcedTypeCasting)`	: UnaryOperatorForcedTypeCasting
	`\(UnaryOperatorKind::IncrementPostfix)`	: UnaryOperatorIncrementPostfix
	`\(UnaryOperatorKind::IncrementPrefix)`		: UnaryOperatorIncrementPrefix
	`\(UnaryOperatorKind::Negation)`			: UnaryOperatorNegation
	`\(UnaryOperatorKind::Negative)`			: UnaryOperatorNegative
	`\(UnaryOperatorKind::NullableTypeCasting)`	: UnaryOperatorNullableTypeCasting
	`\(UnaryOperatorKind::Spread)`				: UnaryOperatorSpread
}

func $expandOptions(options) { // {{{
	const engine = $targets[options.target.name]
	if !?engine {
		throw new Error(`Undefined target '\(options.target.name)'`)
	}

	if engine is Function {
		if const opts = engine(options.target.version.split('.').map(v => parseInt(v)), $targets) {
			return Object.defaults(options, opts)
		}
		else {
			throw new Error(`Undefined target's version '\(options.target.version)'`)
		}
	}
	else {
		if !?engine[options.target.version] {
			throw new Error(`Undefined target's version '\(options.target.version)'`)
		}

		return Object.defaults(options, engine[options.target.version])
	}
} // }}}

const $targets = {
	ecma: { // {{{
		'5': {
			format: {
				classes: 'es5'
				destructuring: 'es5'
				functions: 'es5'
				parameters: 'es5'
				properties: 'es5'
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
				properties: 'es6'
				spreads: 'es6'
				variables: 'es6'
			}
		}
	} // }}}
	v8(version, targets) { // {{{
		if version[0] < 5 {
			return targets.ecma['5']
		}
		else {
			return targets.ecma['6']
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
	}
	static {
		registerTarget(target: String, fn: Function) { // {{{
			$targets[target] = fn
		} // }}}
		registerTarget(target: String, options: Object) { // {{{
			if target !?= $targetRegex.exec(target) {
				throw new Error(`Invalid target syntax: \(target)`)
			}

			$targets[target[1]] ??= {}
			$targets[target[1]][target[2]] = options
		} // }}}
		registerTargets(targets) { // {{{
			for const data, name of targets {
				if data is String {
					Compiler.registerTargetAlias(name, data)
				}
				else {
					Compiler.registerTarget(name, data)
				}
			}
		} // }}}
		registerTargetAlias(target: String, alias: String) { // {{{
			if alias !?= $targetRegex.exec(alias) {
				if !?$targets[alias] || $targets[alias] is not Function {
					throw new Error(`Invalid target syntax: \(alias)`)
				}

				$targets[target] = $targets[alias]
			}
			else {
				if target !?= $targetRegex.exec(target) {
					throw new Error(`Invalid target syntax: \(target)`)
				}


				if !?$targets[alias[1]] {
					throw new Error(`Undefined target '\(alias[1])'`)
				}
				else if !?$targets[alias[1]][alias[2]] {
					throw new Error(`Undefined target's version '\(alias[2])'`)
				}

				$targets[target[1]] ??= {}
				$targets[target[1]][target[2]] = $targets[alias[1]][alias[2]]
			}
		} // }}}
	}
	constructor(@file, options = null, @hashes = {}) { // {{{
		@options = Object.merge({
			target: 'ecma-v6'
			register: true
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
			rules: {
				ignoreMisfit: false
				noUndefined: false
			}
			runtime: {
				helper: {
					alias: 'Helper'
					member: 'Helper'
					package: '@kaoscript/runtime'
				}
				operator: {
					alias: 'Operator'
					member: 'Operator'
					package: '@kaoscript/runtime'
				}
				type: {
					alias: 'Type'
					member: 'Type'
					package: '@kaoscript/runtime'
				}
			}
		}, options)

		if @options.target is String {
			if target !?= $targetRegex.exec(@options.target) {
				throw new Error(`Invalid target syntax: \(@options.target)`)
			}

			@options.target = {
				name: target[1],
				version: target[2]
			}
		}
		else if @options.target is not Object || !$targetRegex.test(`\(@options.target.name)-v\(@options.target.version)`) {
			throw new Error(`Undefined target`)
		}

		@options = $expandOptions(@options)
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
		return new Compiler(file, Object.defaults(@options, {
			register: false
		}), @hashes)
	} // }}}
	readFile() => fs.readFile(@file)
	sha256(file, data = null) { // {{{
		return @hashes[file] ?? (@hashes[file] = fs.sha256(data ?? fs.readFile(file)))
	} // }}}
	toHashes() { // {{{
		return @module.toHashes()
	} // }}}
	toMetadata() { // {{{
		return @module.toMetadata()
	} // }}}
	toSource() { // {{{
		let source = ''

		for fragment in @fragments {
			source += fragment.code
		}

		if source.length != 0 {
			return source.substr(0, source.length - 1)
		}
		else {
			return source
		}
	} // }}}
	toSourceMap() { // {{{
		return @module.toSourceMap()
	} // }}}
	writeFiles() { // {{{
		fs.mkdir(path.dirname(@file))

		fs.writeFile(getBinaryPath(@file, @options.target), this.toSource())

		if !@module._binary {
			const metadata = this.toMetadata()

			fs.writeFile(getMetadataPath(@file, @options.target), JSON.stringify(metadata, func(key, value) => key == 'max' && value == Infinity ? 'Infinity' : value))
		}

		fs.writeFile(getHashPath(@file, @options.target), JSON.stringify(@module.toHashes()))
	} // }}}
	writeMetadata() { // {{{
		if @options.output is not String {
			throw new Error('Undefined option: output')
		}

		const metadata = this.toMetadata()

		const filename = path.join(@options.output, path.basename(@file)).slice(0, -3) + '.json'

		fs.writeFile(filename, JSON.stringify(metadata, func(key, value) => key == 'max' && value == Infinity ? 'Infinity' : value))

		return this
	} // }}}
	writeOutput() { // {{{
		if @options.output is not String {
			throw new Error('Undefined option: output')
		}

		fs.mkdir(@options.output)

		const filename = path.join(@options.output, path.basename(@file)).slice(0, -3) + '.js'

		fs.writeFile(filename, this.toSource())

		return this
	} // }}}
}

export func compileFile(file, options = null) { // {{{
	let compiler = new Compiler(file, options)

	return compiler.compile().toSource()
} // }}}

export func getBinaryPath(file, target) => fs.hidden(file, target.name, target.version, $extensions.binary)

export func getHashPath(file, target) => fs.hidden(file, target.name, target.version, $extensions.hash)

export func getMetadataPath(file, target) => fs.hidden(file, target.name, target.version, $extensions.metadata)

export func isUpToDate(file, target, source) { // {{{
	let hashes
	try {
		hashes = JSON.parse(fs.readFile(getHashPath(file, target)))
	}
	catch {
		return false
	}

	let root = path.dirname(file)

	for const hash, name of hashes {
		if name == '.' {
			return null if fs.sha256(source) != hash
		}
		else {
			return null if fs.sha256(fs.readFile(path.join(root, name))) != hash
		}
	}

	return true
} // }}}

export $extensions => extensions

export AssignmentOperatorKind, BinaryOperatorKind, MacroElementKind, ModifierKind, NodeKind, ReificationKind, ScopeKind, UnaryOperatorKind, FragmentBuilder