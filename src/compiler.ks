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
	'../package.json' => metadata
	'./fs.js'
	'path' {
		var sep: String
		func basename(path: String): String
		func dirname(path: String): String
		func join(...paths: String): String
		func relative(from: String, to: String): String
	}
}

extern console, JSON

include {
	'@kaoscript/ast'
	'@kaoscript/parser'
	'@kaoscript/util'
	'./include/error'
}

var $extensions = { # {{{
	binary: '.ksb',
	exports: '.kse',
	hash: '.ksh',
	requirements: '.ksr',
	source: '.ks'
} # }}}

var $targetRegex = /^(\w+)-v((?:\d+)(?:\.\d+)?(?:\.\d+)?)$/

var $typeofs = { # {{{
	Array: true
	Boolean: true
	Class: true
	Dictionary: true
	Enum: true
	Function: true
	// Instance: true
	Namespace: true
	Number: true
	Object: true
	Primitive: true
	RegExp: true
	String: true
	Struct: true
	Tuple: true
} # }}}

var $ast = {
	block(data) { # {{{
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
	} # }}}
	body(data?) { # {{{
		if !?data.body {
			return {
				kind: NodeKind::Block
				statements: []
				start: data.start
				end: data.end
			}
		}
		else if data.body.kind == NodeKind::Block || data.body.kind == NodeKind::ReturnStatement {
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
	} # }}}
	identifier(name) { # {{{
		if name is String {
			return {
				kind: NodeKind::Identifier
				name: name
			}
		}
		else {
			return name
		}
	} # }}}
	parameter() { # {{{
		return {
			kind: NodeKind::Parameter
			attributes: []
			modifiers: []
		}
	} # }}}
}

var $runtime = {
	dictionary(node) { # {{{
		node.module?().flag('Dictionary')

		return node._options.runtime.dictionary.alias
	} # }}}
	getVariable(name, node) { # {{{
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
	} # }}}
	helper(node) { # {{{
		node.module?().flag('Helper')

		return node._options.runtime.helper.alias
	} # }}}
	immutableScope(node) { # {{{
		return node._options.format.variables == 'es5' ? 'var ' : 'const '
	} # }}}
	initFlag(node) { # {{{
		node.module?().flag('initFlag')

		return node._options.runtime.initFlag.alias
	} # }}}
	operator(node) { # {{{
		node.module?().flag('Operator')

		return node._options.runtime.operator.alias
	} # }}}
	scope(node) { # {{{
		return node._options.format.variables == 'es5' ? 'var ' : 'let '
	} # }}}
	type(node) { # {{{
		node.module?().flag('Type')

		return node._options.runtime.type.alias
	} # }}}
	typeof(type, node? = null) { # {{{
		if ?node {
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
	} # }}}
}

enum TargetMode {
	Ignore
	Permissive
	Strict
}

abstract class AbstractNode {
	private {
		@data: Any?				= null
		@options
		@parent: AbstractNode?	= null
		@reference
		@scope: Scope?			= null
	}
	constructor()
	constructor(@data, @parent, @scope = parent?.scope()) { # {{{
		@options = parent._options
	} # }}}
	constructor(@data, @parent, scope: Scope, kind: ScopeType) { # {{{
		@options = parent._options

		@scope = @newScope(scope, kind)
	} # }}}
	abstract analyse()
	// TODO remove default value
	abstract prepare(target: Type = Type.Void, targetMode: TargetMode = TargetMode::Strict)
	abstract translate()
	authority() => @parent.authority()
	data() => @data
	directory() => @parent.directory()
	enhance()
	file() => @parent.file()
	getFunctionNode() => @parent?.getFunctionNode()
	initiate()
	isConsumedError(error): Boolean => @parent.isConsumedError(error)
	isIncluded(): Boolean => @file() != @module().file()
	module() => @parent.module()
	newScope(scope: Scope, type: ScopeType) { # {{{
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
	} # }}}
	parent() => @parent
	printDebug() { # {{{
		console.log(`\(@file()):\(@data.start.line)`)
	} # }}}
	reference() { # {{{
		if ?@parent?.reference() {
			return @parent.reference() + @reference
		}
		else {
			return @reference
		}
	} # }}}
	reference(@reference)
	scope() => @scope
	statement() => @parent?.statement()
	walkNode(fn: (node: AbstractNode): Boolean): Boolean => fn(this)
	walkVariable(fn: (name: String, type: Type): Void): Void
}

include {
	'./include/attribute'
	'./include/fragment'
	'./include/type'
	'./include/variable'
	'./include/scope'
	'./include/module'
	'./include/router'
	'./include/statement'
	'./include/expression'
	'./include/parameter'
	'./statement/struct'
	'./statement/tuple'
	'./operator/index'
	'./include/block'
	'./include/macro'
}

var $compile = {
	block(data, parent, scope = parent.scope()) => new Block($ast.block(data), parent, scope)
	expression(data, parent, scope = parent.scope()) { # {{{
		var dyn expression

		if var clazz ?= $expressions[data.kind] {
			expression = clazz is Class ? new clazz(data, parent, scope) : clazz(data, parent, scope)
		}
		else if data.kind == NodeKind::BinaryExpression {
			if data.operator.kind == BinaryOperatorKind::Assignment {
				if var clazz ?= $assignmentOperators[data.operator.assignment] {
					expression = new clazz(data, parent, scope)
				}
				else {
					throw new NotSupportedException(`Unexpected assignment operator \(data.operator.assignment)`, parent)
				}
			}
			else if var clazz ?= $binaryOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected binary operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::PolyadicExpression {
			if var clazz ?= $polyadicOperators[data.operator.kind] {
				expression = new clazz(data, parent, scope)
			}
			else {
				throw new NotSupportedException(`Unexpected polyadic operator \(data.operator.kind)`, parent)
			}
		}
		else if data.kind == NodeKind::UnaryExpression {
			if var clazz ?= $unaryOperators[data.operator.kind] {
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
	} # }}}
	function(data, parent, scope = parent.scope()) => new FunctionBlock($ast.block(data), parent, scope)
	statement(data, parent, scope = parent.scope()) { # {{{
		if Attribute.conditional(data, parent) {
			var clazz = $statements[data.kind] ?? $statements.default

			return new clazz(data, parent, scope)
		}
		else {
			return null
		}
	} # }}}
}

var $assignmentOperators = {
	`\(AssignmentOperatorKind::Addition)`			: AssignmentOperatorAddition
	`\(AssignmentOperatorKind::And)`				: AssignmentOperatorAnd
	`\(AssignmentOperatorKind::Division)`			: AssignmentOperatorDivision
	`\(AssignmentOperatorKind::Empty)`				: AssignmentOperatorEmpty
	`\(AssignmentOperatorKind::EmptyCoalescing)`	: AssignmentOperatorEmptyCoalescing
	`\(AssignmentOperatorKind::Equals)`				: AssignmentOperatorEquals
	`\(AssignmentOperatorKind::Existential)`		: AssignmentOperatorExistential
	`\(AssignmentOperatorKind::LeftShift)`			: AssignmentOperatorLeftShift
	`\(AssignmentOperatorKind::Modulo)`				: AssignmentOperatorModulo
	`\(AssignmentOperatorKind::Multiplication)`		: AssignmentOperatorMultiplication
	`\(AssignmentOperatorKind::NonEmpty)`			: AssignmentOperatorNonEmpty
	`\(AssignmentOperatorKind::NonExistential)`		: AssignmentOperatorNonExistential
	`\(AssignmentOperatorKind::NullCoalescing)`		: AssignmentOperatorNullCoalescing
	`\(AssignmentOperatorKind::Or)`					: AssignmentOperatorOr
	`\(AssignmentOperatorKind::Quotient)`			: AssignmentOperatorQuotient
	`\(AssignmentOperatorKind::Return)`				: AssignmentOperatorReturn
	`\(AssignmentOperatorKind::RightShift)`			: AssignmentOperatorRightShift
	`\(AssignmentOperatorKind::Subtraction)`		: AssignmentOperatorSubtraction
	`\(AssignmentOperatorKind::Xor)`				: AssignmentOperatorXor
}

var $binaryOperators = {
	`\(BinaryOperatorKind::Addition)`			: BinaryOperatorAddition
	`\(BinaryOperatorKind::And)`				: BinaryOperatorAnd
	`\(BinaryOperatorKind::Division)`			: BinaryOperatorDivision
	`\(BinaryOperatorKind::EmptyCoalescing)`	: BinaryOperatorEmptyCoalescing
	`\(BinaryOperatorKind::Imply)`				: BinaryOperatorImply
	`\(BinaryOperatorKind::LeftShift)`			: BinaryOperatorLeftShift
	`\(BinaryOperatorKind::Match)`				: BinaryOperatorMatch
	`\(BinaryOperatorKind::Mismatch)`			: BinaryOperatorMismatch
	`\(BinaryOperatorKind::Modulo)`				: BinaryOperatorModulo
	`\(BinaryOperatorKind::Multiplication)`		: BinaryOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: BinaryOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: BinaryOperatorOr
	`\(BinaryOperatorKind::Quotient)`			: BinaryOperatorQuotient
	`\(BinaryOperatorKind::RightShift)`			: BinaryOperatorRightShift
	`\(BinaryOperatorKind::Subtraction)`		: BinaryOperatorSubtraction
	`\(BinaryOperatorKind::TypeCasting)`		: BinaryOperatorTypeCasting
	`\(BinaryOperatorKind::TypeEquality)`		: BinaryOperatorTypeEquality
	`\(BinaryOperatorKind::TypeInequality)`		: BinaryOperatorTypeInequality
	`\(BinaryOperatorKind::Xor)`				: BinaryOperatorXor
}

var $expressions = {
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
	`\(NodeKind::PositionalArgument)`			: PositionalArgument
	`\(NodeKind::RegularExpression)`			: RegularExpression
	`\(NodeKind::SequenceExpression)`			: SequenceExpression
	`\(NodeKind::TemplateExpression)`			: TemplateExpression
	`\(NodeKind::ThisExpression)`				: ThisExpression
	`\(NodeKind::TryExpression)`				: TryExpression
	`\(NodeKind::UnlessExpression)`				: UnlessExpression
}

var $statements = {
	`\(NodeKind::BitmaskDeclaration)`			: BitmaskDeclaration
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
	`\(NodeKind::PassStatement)`				: PassStatement
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
	`\(NodeKind::VariableStatement)`			: VariableStatement
	`\(NodeKind::WhileStatement)`				: WhileStatement
	`\(NodeKind::WithStatement)`				: WithStatement
	`default`									: ExpressionStatement
}

var $polyadicOperators = {
	`\(BinaryOperatorKind::Addition)`			: PolyadicOperatorAddition
	`\(BinaryOperatorKind::And)`				: PolyadicOperatorAnd
	`\(BinaryOperatorKind::Division)`			: PolyadicOperatorDivision
	`\(BinaryOperatorKind::EmptyCoalescing)`	: PolyadicOperatorEmptyCoalescing
	`\(BinaryOperatorKind::Modulo)`				: PolyadicOperatorModulo
	`\(BinaryOperatorKind::Imply)`				: PolyadicOperatorImply
	`\(BinaryOperatorKind::LeftShift)`			: PolyadicOperatorLeftShift
	`\(BinaryOperatorKind::Multiplication)`		: PolyadicOperatorMultiplication
	`\(BinaryOperatorKind::NullCoalescing)`		: PolyadicOperatorNullCoalescing
	`\(BinaryOperatorKind::Or)`					: PolyadicOperatorOr
	`\(BinaryOperatorKind::Quotient)`			: PolyadicOperatorQuotient
	`\(BinaryOperatorKind::RightShift)`			: PolyadicOperatorRightShift
	`\(BinaryOperatorKind::Subtraction)`		: PolyadicOperatorSubtraction
	`\(BinaryOperatorKind::Xor)`				: PolyadicOperatorXor
}

var $unaryOperators = {
	`\(UnaryOperatorKind::Existential)`			: UnaryOperatorExistential
	`\(UnaryOperatorKind::ForcedTypeCasting)`	: UnaryOperatorForcedTypeCasting
	`\(UnaryOperatorKind::Negation)`			: UnaryOperatorNegation
	`\(UnaryOperatorKind::Negative)`			: UnaryOperatorNegative
	`\(UnaryOperatorKind::NonEmpty)`			: UnaryOperatorNonEmpty
	`\(UnaryOperatorKind::NullableTypeCasting)`	: UnaryOperatorNullableTypeCasting
	`\(UnaryOperatorKind::Spread)`				: UnaryOperatorSpread
}

func $expandOptions(options) { # {{{
	var engine = $targets[options.target.name]
	if !?engine {
		throw new Error(`Undefined target '\(options.target.name)'`)
	}

	if engine is Function {
		if var opts ?= engine(options.target.version.split('.').map((value, _, _) => parseInt(value)), $targets) {
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
} # }}}

var $targets = {
	ecma: { # {{{
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
	} # }}}
	v8(version, targets) { # {{{
		if version[0] < 5 {
			return targets.ecma['5']
		}
		else {
			return targets.ecma['6']
		}
	} # }}}
}

export class Compiler {
	private late {
		@module: Module
	}
	private {
		@file: String
		@fragments
		@hashes: Dictionary
		@hierarchy: Array
		@options: Dictionary
	}
	static {
		registerTarget(target: String, fn: Function) { # {{{
			$targets[target] = fn
		} # }}}
		registerTarget(mut target: String, options: Dictionary) { # {{{
			if target !?= $targetRegex.exec(target) {
				throw new Error(`Invalid target syntax: \(target)`)
			}

			$targets[target[1]] ??= {}
			$targets[target[1]][target[2]] = options
		} # }}}
		registerTargets(targets) { # {{{
			for var data, name of targets {
				if data is String {
					Compiler.registerTargetAlias(name, data)
				}
				else {
					Compiler.registerTarget(name, data)
				}
			}
		} # }}}
		registerTargetAlias(mut target: String, mut alias: String) { # {{{
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
		} # }}}
	}
	constructor(@file, options? = null, @hashes = {}, @hierarchy = [@file]) { # {{{
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
			parameters: {
				retain: false
			}
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
	} # }}}
	initiate(data: String? = null) { # {{{
		@module = new Module(data ?? fs.readFile(@file), this, @file)

		@module.initiate()

		return this
	} # }}}
	compile(data: String? = null) { # {{{
		return @initiate(data).finish()
	} # }}}
	createServant(file) { # {{{
		return new Compiler(file, Dictionary.defaults(@options, {
			register: false
		}), @hashes, [...@hierarchy, file])
	} # }}}
	finish() { # {{{
		@module.finish()

		@fragments = @module.toFragments()

		return this
	} # }}}
	isInHierarchy(file) => @hierarchy.contains(file)
	module(): @module
	readFile() => fs.readFile(@file)
	setArguments(arguments: Array, module: String? = null, node: AbstractNode? = null) => @module.setArguments(arguments, module, node)
	sha256(file, data? = null) { # {{{
		return @hashes[file] ?? (@hashes[file] <- fs.sha256(data ?? fs.readFile(file)))
	} # }}}
	toExports() => @module.toExports()
	toHashes() => @module.toHashes()
	toRequirements() => @module.toRequirements()
	toSource() { # {{{
		var mut source = ''

		for fragment in @fragments {
			source += fragment.code
		}

		if source.length != 0 {
			return source.substr(0, source.length - 1)
		}
		else {
			return source
		}
	} # }}}
	toSourceMap() => @module.toSourceMap()
	toVariationId() => @module.toVariationId()
	writeFiles() { # {{{
		fs.mkdir(path.dirname(@file))

		if @module.isBinary() {
			@writeBinaryFiles()
		}
		else {
			@writeModuleFiles()
		}
	} # }}}
	private writeBinaryFiles() { # {{{
		var variationId = @module.toVariationId()

		fs.writeFile(getBinaryPath(@file, variationId), @toSource())

		@writeHashFile(variationId)
	} # }}}
	private writeHashFile(variationId: String) { # {{{
		var hashPath = getHashPath(@file)

		var dyn data

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
	} # }}}
	private writeModuleFiles() { # {{{
		var variationId = @module.toVariationId()

		fs.writeFile(getBinaryPath(@file, variationId), @toSource())

		fs.writeFile(getRequirementsPath(@file), JSON.stringify(@toRequirements(), fs.escapeJSON))

		fs.writeFile(getExportsPath(@file, variationId), JSON.stringify(@toExports(), fs.escapeJSON))

		@writeHashFile(variationId)
	} # }}}
	writeOutput() { # {{{
		if @options.output is not String {
			throw new Error('Undefined option: output')
		}

		fs.mkdir(@options.output)

		var filename = path.join(@options.output, path.basename(@file)).slice(0, -3) + '.js'

		fs.writeFile(filename, @toSource())

		return this
	} # }}}
}

export func compileFile(file, options? = null) { # {{{
	var compiler = new Compiler(file, options)

	return compiler.compile().toSource()
} # }}}

export func getBinaryPath(file, variationId? = null) => fs.hidden(file, variationId, $extensions.binary)

export func getExportsPath(file, variationId) => fs.hidden(file, variationId, $extensions.exports)

export func getHashPath(file) => fs.hidden(file, null, $extensions.hash)

export func getRequirementsPath(file) => fs.hidden(file, null, $extensions.requirements)

export func isUpToDate(file, variationId, source) { # {{{
	var late data
	try {
		data = JSON.parse(fs.readFile(getHashPath(file)))
	}
	catch {
		return false
	}

	if !data.variations:Array.contains(variationId) {
		return false
	}

	var root = path.dirname(file)

	for var hash, name of data.hashes {
		if name == '.' {
			return null if fs.sha256(source) != hash
		}
		else {
			return null if fs.sha256(fs.readFile(path.join(root, name))) != hash
		}
	}

	return true
} # }}}

export $extensions => extensions

export AssignmentOperatorKind, BinaryOperatorKind, MacroElementKind, ModifierKind, NodeKind, ReificationKind, ScopeKind, UnaryOperatorKind, FragmentBuilder
