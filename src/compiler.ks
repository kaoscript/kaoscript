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
	exports: '.kse',
	hash: '.ksh',
	requirements: '.ksr',
	source: '.ks'
} // }}}

const $targetRegex = /^(\w+)-v((?:\d+)(?:\.\d+)?(?:\.\d+)?)$/

const $typeofs = { // {{{
	Array: true
	Boolean: true
	Class: true
	Dictionary: true
	Enum: true
	Function: true
	Namespace: true
	Number: true
	Object: true
	Primitive: true
	RegExp: true
	String: true
	Struct: true
	Tuple: true
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
	dictionary(node) { // {{{
		node.module?().flag('Dictionary')

		return node._options.runtime.dictionary.alias
	} // }}}
	getVariable(name, node) { // {{{
		if node._options.runtime.dictionary.alias == name || (node.isIncluded() && name == 'Dictionary') {
			node.module?().flag('Dictionary')

			return node._options.runtime.dictionary.alias
		}
		else if node._options.runtime.helper.alias == name || (node.isIncluded() && name == 'Helper') {
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
	helper(node) { // {{{
		node.module?().flag('Helper')

		return node._options.runtime.helper.alias
	} // }}}
	immutableScope(node) { // {{{
		return node._options.format.variables == 'es5' ? 'var ' : 'const '
	} // }}}
	initFlag(node) { // {{{
		node.module?().flag('initFlag')

		return node._options.runtime.initFlag.alias
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
		_data: Any?				= null
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
	authority() => @parent.authority()
	data() => @data
	directory() => @parent.directory()
	enhance()
	file() => @parent.file()
	getFunctionNode() => @parent?.getFunctionNode()
	initiate()
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
	printDebug() { // {{{
		console.log(`\(this.file()):\(@data.start.line)`)
	} // }}}
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
	'./statement/struct'
	'./statement/tuple'
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
		else if data.kind == NodeKind::JunctionExpression {
			throw new NotSupportedException(`Unexpected junction expression`, parent)
		}
		else {
			throw new NotSupportedException(`Unexpected expression/statement \(data.kind)`, parent)
		}

		return expression
	} // }}}
	function(data, parent, scope = parent.scope()) => new FunctionBlock($ast.block(data), parent, scope)
	statement(data, parent, scope = parent.scope()) { // {{{
		if Attribute.conditional(data, parent) {
			const clazz = $statements[data.kind] ?? $statements.default

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
	`\(BinaryOperatorKind::Match)`				: BinaryOperatorMatch
	`\(BinaryOperatorKind::Mismatch)`			: BinaryOperatorMismatch
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
	`\(NodeKind::NamedArgument)`				: NamedArgument
	`\(NodeKind::NumericExpression)`			: NumberLiteral
	`\(NodeKind::ObjectBinding)`				: ObjectBinding
	`\(NodeKind::ObjectExpression)`				: DictionaryExpression
	`\(NodeKind::OmittedExpression)`			: OmittedExpression
	`\(NodeKind::RegularExpression)`			: RegularExpression
	`\(NodeKind::SequenceExpression)`			: SequenceExpression
	`\(NodeKind::TemplateExpression)`			: TemplateExpression
	`\(NodeKind::ThisExpression)`				: ThisExpression
	`\(NodeKind::TryExpression)`				: TryExpression
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
	`\(NodeKind::ExternOrImportDeclaration)`	: ExternOrImportDeclaration
	`\(NodeKind::ExternOrRequireDeclaration)`	: ExternOrRequireDeclaration
	`\(NodeKind::FallthroughStatement)`			: FallthroughStatement
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
	`\(NodeKind::StructDeclaration)`			: StructDeclaration
	`\(NodeKind::SwitchStatement)`				: SwitchStatement
	`\(NodeKind::ThrowStatement)`				: ThrowStatement
	`\(NodeKind::TryStatement)`					: TryStatement
	`\(NodeKind::TupleDeclaration)`				: TupleDeclaration
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
		if const opts = engine(options.target.version.split('.').map((value, _, _) => parseInt(value)), $targets) {
			return Dictionary.defaults(options, opts)
		}
		else {
			throw new Error(`Undefined target's version '\(options.target.version)'`)
		}
	}
	else {
		if !?engine[options.target.version] {
			throw new Error(`Undefined target's version '\(options.target.version)'`)
		}

		return Dictionary.defaults(options, engine[options.target.version])
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
	private lateinit {
		_module: Module
	}
	private {
		_file: String
		_fragments
		_hashes: Dictionary
		_hierarchy: Array
		_options: Dictionary
	}
	static {
		registerTarget(target: String, fn: Function) { // {{{
			$targets[target] = fn
		} // }}}
		registerTarget(target: String, options: Dictionary) { // {{{
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
	constructor(@file, options = null, @hashes = {}, @hierarchy = [@file]) { // {{{
		@options = Dictionary.merge({
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
				assertNewStruct: true
				assertNewTuple: true
				assertOverride: true
				assertParameter: true
				assertParameterType: true
				noUndefined: false
				ignoreMisfit: false
			}
			runtime: {
				dictionary: {
					alias: 'Dictionary'
					member: 'Dictionary'
					package: '@kaoscript/runtime'
				}
				helper: {
					alias: 'Helper'
					member: 'Helper'
					package: '@kaoscript/runtime'
				}
				initFlag: {
					alias: 'initFlag'
					member: 'initFlag'
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
				name: target[1]
				version: target[2]
			}
		}
		else if !(@options.target is Dictionary || @options.target is Object) || !$targetRegex.test(`\(@options.target.name)-v\(@options.target.version)`) {
			throw new Error(`Undefined target`)
		}

		@options = $expandOptions(@options)
	} // }}}
	initiate(data: String = null) { // {{{
		@module = new Module(data ?? fs.readFile(@file), this, @file)

		@module.initiate()

		return this
	} // }}}
	compile(data: String = null) { // {{{
		return this.initiate(data).finish()
	} // }}}
	createServant(file) { // {{{
		return new Compiler(file, Dictionary.defaults(@options, {
			register: false
		}), @hashes, [...@hierarchy, file])
	} // }}}
	finish() { // {{{
		@module.finish()

		@fragments = @module.toFragments()

		return this
	} // }}}
	isInHierarchy(file) => @hierarchy.contains(file)
	module(): @module
	readFile() => fs.readFile(@file)
	setArguments(arguments: Array, module: String = null, node: AbstractNode = null) => @module.setArguments(arguments, module, node)
	sha256(file, data = null) { // {{{
		return @hashes[file] ?? (@hashes[file] = fs.sha256(data ?? fs.readFile(file)))
	} // }}}
	toExports() => @module.toExports()
	toHashes() => @module.toHashes()
	toRequirements() => @module.toRequirements()
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
	toSourceMap() => @module.toSourceMap()
	toVariationId() => @module.toVariationId()
	writeFiles() { // {{{
		fs.mkdir(path.dirname(@file))

		if @module._binary {
			this.writeBinaryFiles()
		}
		else {
			this.writeModuleFiles()
		}
	} // }}}
	private writeBinaryFiles() { // {{{
		const variationId = @module.toVariationId()

		fs.writeFile(getBinaryPath(@file, variationId), this.toSource())

		this.writeHashFile(variationId)
	} // }}}
	private writeHashFile(variationId: String) { // {{{
		const hashPath = getHashPath(@file)

		let data

		try {
			data = JSON.parse(fs.readFile(hashPath))
		}
		catch {
			data = {
				hashes: {}
			}
		}

		if @module.isUpToDate(data.hashes) {
			data.variations.push(variationId)
		}
		else {
			data = {
				hashes: @module.toHashes()
				variations: [variationId]
			}
		}

		fs.writeFile(hashPath, JSON.stringify(data))
	} // }}}
	private writeModuleFiles() { // {{{
		const variationId = @module.toVariationId()

		fs.writeFile(getBinaryPath(@file, variationId), this.toSource())

		fs.writeFile(getRequirementsPath(@file), JSON.stringify(this.toRequirements(), fs.escapeJSON))

		fs.writeFile(getExportsPath(@file, variationId), JSON.stringify(this.toExports(), fs.escapeJSON))

		this.writeHashFile(variationId)
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

export func getBinaryPath(file, variationId = null) => fs.hidden(file, variationId, $extensions.binary)

export func getExportsPath(file, variationId) => fs.hidden(file, variationId, $extensions.exports)

export func getHashPath(file) => fs.hidden(file, null, $extensions.hash)

export func getRequirementsPath(file) => fs.hidden(file, null, $extensions.requirements)

export func isUpToDate(file, variationId, source) { // {{{
	let data
	try {
		data = JSON.parse(fs.readFile(getHashPath(file)))
	}
	catch {
		return false
	}

	if !data.variations:Array.contains(variationId) {
		return false
	}

	let root = path.dirname(file)

	for const hash, name of data.hashes {
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
