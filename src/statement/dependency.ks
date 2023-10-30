abstract class DependencyStatement extends Statement {
	abstract applyFlags(type: Type)
	define(declaration) { # {{{
		var options = Attribute.configure(declaration, @options, AttributeTarget.Statement, @file())
		var scope = @parent.scope()

		match declaration.kind {
			NodeKind.ClassDeclaration {
				var type = @applyFlags(ClassType.new(scope))

				for var modifier in declaration.modifiers {
					if modifier.kind == ModifierKind.Abstract {
						type.flagAbstract()
					}
					else if modifier.kind == ModifierKind.Sealed {
						type.flagSealed()
					}
					else if modifier.kind == ModifierKind.System {
						type.flagSystem()
					}
				}

				var variable = scope.define(declaration.name.name, true, type, this)

				if ?declaration.extends {
					var superVar = @scope.getVariable(declaration.extends.name)

					if !?superVar {
						ReferenceException.throwNotDefined(declaration.extends.name, this)
					}
					else if !superVar.getDeclaredType().isClass() {
						TypeException.throwNotClass(declaration.extends.name, this)
					}

					type.extends(superVar.getDeclaredType())
				}

				if declaration.members.length != 0 {
					for var member in declaration.members {
						type.addPropertyFromAST(member, this)
					}
				}

				if options.rules.nonExhaustive || declaration.members.length == 0 {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				type.flagComplete()

				return variable
			}
			NodeKind.EnumDeclaration {
				var mut ekind = EnumTypeKind.Number

				if ?declaration.type {
					if Type.fromAST(declaration.type, this).isString() {
						ekind = EnumTypeKind.String
					}
				}

				var type = @applyFlags(EnumType.new(scope, ekind))
				var variable = scope.define(declaration.name.name, true, type, this)

				if options.rules.nonExhaustive || declaration.members.length == 0 {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				if declaration.members.length != 0 {
					for var member in declaration.members {
						type.addPropertyFromAST(member, this)
					}
				}

				type.flagComplete()

				return variable
			}
			NodeKind.FunctionDeclaration {
				var mut type = null
				if ?declaration.parameters {
					var parameters = [ParameterType.fromAST(parameter, this) for var parameter in declaration.parameters]

					type = FunctionType.new(parameters, declaration, this)
				}
				else {
					type = @scope().reference('Function')
				}

				type = @applyFlags(type)

				var variable = scope.define(declaration.name.name, true, type, true, this)

				if options.rules.nonExhaustive || !?declaration.parameters {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				type.flagComplete()

				return variable
			}
			NodeKind.NamespaceDeclaration {
				var type = @applyFlags(NamespaceType.new(scope))

				for var modifier in declaration.modifiers {
					if modifier.kind == ModifierKind.Sealed {
						type.flagSealed()
					}
					else if modifier.kind == ModifierKind.System {
						type.flagSystem()
					}
				}

				var variable = scope.define(declaration.name.name, true, type, this)

				if options.rules.nonExhaustive || declaration.statements.length == 0 {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				if declaration.statements.length != 0 {
					for var statement in declaration.statements {
						type.addPropertyFromAST(statement, this)
					}
				}

				type.flagComplete()

				return variable
			}
			NodeKind.VariableDeclarator {
				var mut type = Type.fromAST(declaration.type, this)

				var instance = type is ClassType

				if type is ReferenceType && type.isClass() {
					type = ClassType.new(scope)

					type.setExhaustive(false)
				}
				else {
					if options.rules.nonExhaustive {
						type.setExhaustive(false)
					}
					else {
						type.setExhaustive(true)
					}
				}

				for var modifier in declaration.modifiers {
					if modifier.kind == ModifierKind.Sealed {
						if !type.isSealable() {
							type = SealableType.new(scope, type)
						}

						type.flagSealed()
					}
					else if modifier.kind == ModifierKind.System {
						if !type.isSealable() {
							type = SealableType.new(scope, type)
						}

						type.flagSystem()
					}
				}

				type = @applyFlags(type)

				type.flagComplete()

				if instance {
					type = @scope.reference(type)
				}

				return scope.define(declaration.name.name, true, type, true, this)
			}
			else {
				throw NotSupportedException.new(`Unexpected kind \(declaration.kind)`, this)
			}
		}
	} # }}}
}

class ExternDeclaration extends DependencyStatement {
	private {
		@lines = []
	}
	initiate() { # {{{
		var module = @module()

		var dyn variable
		for var declaration in @data.declarations {
			if (variable ?= @scope.getVariable(declaration.name.name)) && !variable.isPredefined() {
				if declaration.kind == NodeKind.FunctionDeclaration {
					var late parameters
					if declaration.parameters?.length != 0 {
						parameters = [ParameterType.fromAST(parameter, this) for var parameter in declaration.parameters]
					}
					else {
						parameters = [ParameterType.new(@scope, Type.Any, 0, Infinity)]
					}

					var type = FunctionType.new(parameters, declaration, this).flagAlien()

					if variable.getDeclaredType() is FunctionType {
						var newType = OverloadedFunctionType.new(@scope)

						newType.addFunction(variable.getDeclaredType())
						newType.addFunction(type)

						variable.setDeclaredType(newType)
					}
					else if variable.getDeclaredType() is OverloadedFunctionType {
						variable.getDeclaredType().addFunction(type)
					}
					else {
						SyntaxException.throwAlreadyDeclared(declaration.name.name, this)
					}
				}
				else if @parent.includePath() == null {
					variable = @define(declaration)

					if variable.getDeclaredType().isSealed() && variable.getDeclaredType().isExtendable() {
						@lines.push(`var \(variable.getDeclaredType().getSealedName()) = {}`)
					}
				}
				else {
					// TODO check & merge type
				}
			}
			else {
				variable = @define(declaration)

				var type = variable.getDeclaredType()

				if type.isSealed() && type.isExtendable() {
					@lines.push(`var \(type.getSealedName()) = {}`)
				}
			}

			variable.setComplete(true)

			module.addAlien(variable.name(), variable.getDeclaredType())
		}
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	override applyFlags(type) { # {{{
		return type
			.flagAlien()
			.flagRequired()
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for var line in @lines {
			fragments.line(line)
		}
	} # }}}
}

class RequireDeclaration extends DependencyStatement {
	initiate() { # {{{
		var module = @module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('require', this)
		}

		for var declaration in @data.declarations {
			if var variable ?= @scope.getVariable(declaration.name.name) {
				if declaration.kind == NodeKind.FunctionDeclaration {
					var requirement = module.getRequirement(declaration.name.name)

					var late parameters
					if declaration.parameters?.length != 0 {
						parameters = [ParameterType.fromAST(parameter, this) for var parameter in declaration.parameters]
					}
					else {
						parameters = [ParameterType.new(@scope, Type.Any, 0, Infinity)]
					}

					var type = FunctionType.new(parameters, declaration, this)

					if variable.getDeclaredType() is FunctionType {
						var newType = OverloadedFunctionType.new(@scope)

						newType.addFunction(variable.getDeclaredType())
						newType.addFunction(type)

						variable.setDeclaredType(newType)
						requirement.type(newType)
					}
					else if variable.getDeclaredType() is OverloadedFunctionType {
						variable.getDeclaredType().addFunction(type)
					}
					else {
						SyntaxException.throwAlreadyDeclared(declaration.name.name, this)
					}
				}
				else if @parent.includePath() == null {
					@addRequirement(declaration)
				}
				else {
					// TODO check & merge type
				}
			}
			else {
				@addRequirement(declaration)
			}
		}
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	addRequirement(declaration) { # {{{
		var variable = @define(declaration)
		var requirement = StaticRequirement.new(variable, this)

		@module().addRequirement(requirement)
	} # }}}
	override applyFlags(type) { # {{{
		return type
			.flagRequirement()
			.flagRequired()
	} # }}}
	toStatementFragments(fragments, mode)
}

class ExternOrRequireDeclaration extends DependencyStatement {
	initiate() { # {{{
		var module = @module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('extern|require', this)
		}

		module.flag('Type')

		if @parent.includePath() != null {
			for var declaration in @data.declarations {
				if var variable ?= @scope.getVariable(declaration.name.name) {
					// TODO check & merge type
				}
				else {
					@addRequirement(declaration)
				}
			}
		}
		else {
			for var declaration in @data.declarations {
				@addRequirement(declaration)
			}
		}
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	addRequirement(declaration) { # {{{
		var variable = @define(declaration)
		var requirement = EORDynamicRequirement.new(variable, this)

		@module()
			.addAlien(requirement.name(), requirement.type())
			.addRequirement(requirement)
	} # }}}
	override applyFlags(type) { # {{{
		return type
			.flagAlien()
			.flagRequirement()
			.origin(TypeOrigin.ExternOrRequire)
	} # }}}
	toStatementFragments(fragments, mode)
}

class RequireOrExternDeclaration extends DependencyStatement {
	private {
		@requirements: Array<ROEDynamicRequirement>		= []
	}
	initiate() { # {{{
		var module = @module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('require|extern', this)
		}

		module.flag('Type')

		if @parent.includePath() != null {
			for var data in @data.declarations {
				if var variable ?= @scope.getVariable(data.name.name) {
					// TODO check & merge type
				}
				else {
					@addRequirement(data)
				}
			}
		}
		else {
			for var data in @data.declarations {
				@addRequirement(data)
			}
		}
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	addRequirement(declaration) { # {{{
		var variable = @define(declaration)
		var requirement = ROEDynamicRequirement.new(variable, this)

		@module()
			.addRequirement(requirement)
			.addAlien(requirement.name(), requirement.type())
	} # }}}
	override applyFlags(type) { # {{{
		return type
			.flagAlien()
			.flagRequirement()
			.origin(TypeOrigin.RequireOrExtern + TypeOrigin.Require + TypeOrigin.Extern)
	} # }}}
	toStatementFragments(fragments, mode)
}

class RequireOrImportDeclaration extends Statement {
	private {
		@declarators = []
	}
	initiate() { # {{{
		if @module().isBinary() {
			SyntaxException.throwNotBinary('require|import', this)
		}

		for var data in @data.declarations {
			var declarator = RequireOrImportDeclarator.new(data, this)

			declarator.initiate()

			@declarators.push(declarator)
		}
	} # }}}
	analyse() { # {{{
		for var declarator in @declarators {
			declarator.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var declarator in @declarators {
			declarator.prepare(target)
		}
	} # }}}
	translate() { # {{{
		for var declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for var declarator in @declarators {
			declarator.toStatementFragments(fragments, mode)
		}
	} # }}}
}

class RequireOrImportDeclarator extends Importer {
	private {
		@requirements: Array	= []
	}
	initiate() { # {{{
		super()

		var module = @module()

		if @count != 0 {
			if @parent.includePath() == null {
				var line = @line()

				for var var of @variables {
					if var variable ?= @scope.getVariable(var.name) {
						if @scope.hasDefinedVariableBefore(var.name, line) {
							variable.declaration().flagForcefullyRebinded()
						}
						else {
							var requirement = ROIDynamicRequirement.new(variable, this)
							var type = requirement.type()

							if type.isAlien() {
								var origin = type.origin()
								if ?origin {
									type.origin(origin:TypeOrigin + TypeOrigin.RequireOrExtern)
								}
								else {
									type.origin(TypeOrigin.RequireOrExtern)
								}

								requirement.flagAlternative()
							}

							@requirements.push(requirement)
							module.addRequirement(requirement)
						}
					}
				}
			}
			else {
				throw NotImplementedException.new(this)
			}
		}

		if @requirements.length > 1 {
			for var requirement in @requirements {
				requirement.acquireTempName()
			}
		}

		if @alias != null {
			throw NotImplementedException.new(this)
		}
	} # }}}
	flagForcefullyRebinded()
	override mode() => ImportMode.RequireOrImport
	toStatementFragments(fragments, mode) { # {{{
		var module = @module()

		if @requirements.length == 0 {
			@toImportFragments(fragments)
		}
		else if @requirements.length == 1 {
			var requirement = @requirements[0]
			var argument = module.getArgument(requirement.index())

			if !?argument {
				var ctrl = fragments.newControl()

				if requirement.isSystem() {
					ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.getSealedName(), '))').step()
				}
				else {
					ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.name(), '))').step()
				}

				@toImportFragments(ctrl)

				ctrl.done()
			}
			else if argument is Boolean {
				@toImportFragments(fragments)
			}
		}
		else {
			var unknowns = []
			var notpasseds = []

			for var requirement in @requirements {
				var argument = module.getArgument(requirement.index())

				if !?argument {
					if requirement.isSystem() {
						fragments.line(`var \(requirement.tempName())_valuable = \($runtime.type(this)).isValue(\(requirement.getSealedName()))`)
					}
					else {
						fragments.line(`var \(requirement.tempName())_valuable = \($runtime.type(this)).isValue(\(requirement.name()))`)
					}

					unknowns.push(requirement)
				}
				else if argument is Boolean {
					notpasseds.push(requirement)
				}
			}

			if notpasseds.length > 0 || unknowns.length > 0 {
				var mut ctrl = fragments

				if unknowns.length > 0 {
					ctrl = fragments.newControl().code(`if(`)

					for var requirement, index in unknowns {
						ctrl.code(' || ') unless index == 0

						ctrl.code(`!\(requirement.tempName())_valuable`)
					}

					ctrl.code(')').step()
				}

				if notpasseds.length == @requirements.length {
					@toImportFragments(ctrl, true)
				}
				else {
					@toImportFragments(ctrl, false)

					for var requirement in notpasseds {
						if requirement.isSystem() {
							ctrl.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
						}
						else {
							ctrl.line(`\(requirement.name()) = __ks__.\(requirement.name())`)

							if requirement.isSealed() {
								ctrl.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
							}
						}
					}

					for var requirement in unknowns {
						var control = ctrl.newControl().code(`if(!\(requirement.tempName())_valuable)`).step()

						if requirement.isSystem() {
							control.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
						}
						else {
							control.line(`\(requirement.name()) = __ks__.\(requirement.name())`)

							if requirement.isSealed() {
								control.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
							}
						}

						control.done()
					}

					if unknowns.length > 0 {
						ctrl.done()
					}
				}
			}
		}
	} # }}}
}

class ExternOrImportDeclaration extends Statement {
	private {
		@declarators = []
	}
	initiate() { # {{{
		if @module().isBinary() {
			SyntaxException.throwNotBinary('extern|import', this)
		}

		for var data in @data.declarations {
			var declarator = ExternOrImportDeclarator.new(data, this)

			declarator.initiate()

			@declarators.push(declarator)
		}
	} # }}}
	analyse() { # {{{
		for var declarator in @declarators {
			declarator.analyse()
		}
	} # }}}
	override prepare(target, targetMode) { # {{{
		for var declarator in @declarators {
			declarator.prepare(target)
		}
	} # }}}
	translate() { # {{{
		for var declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		for var declarator in @declarators {
			declarator.toStatementFragments(fragments, mode)
		}
	} # }}}
}

class ExternOrImportDeclarator extends Importer {
	private {
		@requirements: Array	= []
	}
	override prepare(target, targetMode) { # {{{
		super(target)

		var module = @module()

		for var var of @variables {
			if var variable ?= @scope.getVariable(var.name) {
				var requirement = ROIDynamicRequirement.new(variable, this)
				var type = requirement.type().flagAlien()

				var origin = type.origin()
				if ?origin {
					type.origin(origin:TypeOrigin + TypeOrigin.ExternOrRequire)
				}
				else {
					type.origin(TypeOrigin.ExternOrRequire)
				}

				requirement.type(type)

				@requirements.push(requirement)

				module.addAlien(var.name, type)
			}
		}

		if @requirements.length > 1 {
			for var requirement in @requirements {
				requirement.acquireTempName()
			}
		}

		if @alias != null {
			throw NotImplementedException.new(this)
		}
	} # }}}
	flagForcefullyRebinded()
	override mode() => ImportMode.ExternOrImport
	toStatementFragments(fragments, mode) { # {{{
		if @requirements.length == 0 {
			@toImportFragments(fragments)
		}
		else if @requirements.length == 1 {
			var requirement = @requirements[0]

			var ctrl = fragments.newControl()

			if requirement.isSystem() {
				ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.getSealedName(), '))').step()
			}
			else {
				ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.name(), '))').step()
			}

			@toImportFragments(ctrl)

			ctrl.done()
		}
		else {
			for var requirement in @requirements {
				if requirement.isSystem() {
					fragments.line(`var \(requirement.tempName())_valuable = \($runtime.type(this)).isValue(\(requirement.getSealedName()))`)
				}
				else {
					fragments.line(`var \(requirement.tempName())_valuable = \($runtime.type(this)).isValue(\(requirement.name()))`)
				}
			}

			var ctrl = fragments.newControl().code(`if(`)

			for var requirement, index in @requirements {
				if index != 0 {
					ctrl.code(' || ')
				}

				ctrl.code(`!\(requirement.tempName())_valuable`)
			}

			ctrl.code(')').step()

			@toImportFragments(ctrl, false)

			for var requirement in @requirements {
				var control = ctrl.newControl().code(`if(!\(requirement.tempName())_valuable)`).step()

				if requirement.isSystem() {
					control.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
				}
				else {
					control.line(`\(requirement.name()) = __ks__.\(requirement.name())`)

					if requirement.isSealed() {
						control.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
					}
				}

				control.done()
			}

			ctrl.done()
		}
	} # }}}
}

abstract class Requirement {
	private {
		@alternative: Type?
		@index: Number				= -1
		@name: String
		@node: AbstractNode
		@type: Type
	}
	constructor(@name, @type, @node) { # {{{
		if @type.isSystem() && @name == 'Object' {
			node.module().flag('Object')
		}
	} # }}}
	constructor(variable: Variable, @node) { # {{{
		this(variable.name(), variable.getDeclaredType(), node)
	} # }}}
	alternative(): valueof @alternative
	flagAlternative(): valueof this { # {{{
		var mut type = @type

		while ?type.minorOriginal() {
			type = type.minorOriginal()
		}

		@alternative = type
	} # }}}
	getSealedName() => @type.getSealedName()
	index() => @index
	index(@index)
	isRequired() => @type.isRequired()
	isSealed() => @type.isSealed()
	isSystem() => @type.isSystem()
	name() => @name
	toNameFragments(fragments) { # {{{
		if @type.isSealed() {
			fragments.code(@type.getSealedName())
		}
		else {
			fragments.code(@name)
		}
	} # }}}
	toRequiredMetadata() { # {{{
		if @type.isRequired() {
			return true
		}
		else if ?@alternative {
			return @alternative.referenceIndex()
		}
		else {
			return false
		}
	} # }}}
	type() => @type
	type(@type) => this
}

class StaticRequirement extends Requirement {
	constructor(@name, @type, @node) { # {{{
		super(name, type, node)
	} # }}}
	constructor(variable: Variable, @node) { # {{{
		super(variable, node)
	} # }}}
	toFragments(fragments)
	toParameterFragments(fragments, comma) { # {{{
		var module = @node.module()
		var argument = module.getArgument(@index)

		if !?argument {
			fragments.code($comma) if comma

			if @type.isSystem() {
				fragments.code(@type.getSealedName())
			}
			else {
				fragments.code(@name)

				if @type.isSealed() {
					fragments.code(`, __ks_\(@name)`)
				}
			}

			return true
		}
		else if argument is not Boolean {
			fragments.code($comma) if comma

			if @type.isSystem() {
				fragments.code(@type.getSealedName())
			}
			else {
				fragments.code(@name)

				if @type.isSealed() {
					fragments.code($comma, @type.getSealedName())
				}
			}

			return true
		}
		else {
			return comma
		}
	} # }}}
}

class ImportingRequirement extends StaticRequirement {
	constructor(@name, @type, node) { # {{{
		super(name, type, node)
	} # }}}
	isRequired() => false
}

abstract class DynamicRequirement extends Requirement {
	private late {
		@parameter: String
	}
	toParameterFragments(fragments, comma) { # {{{
		var module = @node.module()
		var argument = module.getArgument(@index)

		if !?argument {
			fragments.code($comma) if comma

			if @type.isSystem() {
				fragments.code(@type.getSealedName())
			}
			else {
				fragments.code(@parameter)

				if @type.isSealed() {
					fragments.code(`, __ks_\(@parameter)`)
				}
			}

			return true
		}
		else if argument is not Boolean {
			fragments.code($comma) if comma

			if @type.isSystem() {
				fragments.code(@type.getSealedName())
			}
			else {
				fragments.code(@name)

				if @type.isSealed() {
					fragments.code($comma, @type.getSealedName())
				}
			}

			return true
		}
		else {
			return comma
		}
	} # }}}
}

class EORDynamicRequirement extends DynamicRequirement {
	constructor(variable: Variable, @node) { # {{{
		super(variable, node)

		if !@type.isSystem() {
			@parameter = @node.module().scope().acquireTempName(false)
		}
	} # }}}
	toFragments(fragments) { # {{{
		var module = @node.module()
		var argument = module.getArgument(@index)

		if !?argument {
			if @type.isSystem() {
				var ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', this.getSealedName(), '))').step()

				ctrl.line(`\(this.getSealedName()) = {}`)

				ctrl.done()
			}
			else {
				var ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', @name, '))').step()

				ctrl.line(`\(@name) = \(@parameter)`)

				if @type.isSealed() {
					ctrl.line(`__ks_\(@name) = {}`)

					ctrl.step().code('else').step()

					ctrl.line(`__ks_\(@name) = __ks_\(@parameter)`)
				}

				ctrl.done()
			}
		}
	} # }}}
}

class ROEDynamicRequirement extends DynamicRequirement {
	constructor(variable: Variable, @node) { # {{{
		super(variable, node)

		if !@type.isSystem() {
			@parameter = @node.module().scope().acquireTempName(false)
		}
	} # }}}
	toFragments(fragments) { # {{{
		var module = @node.module()
		var argument = module.getArgument(@index)

		if !?argument {
			if @type.isSystem() {
				var ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', @type.getSealedName(), '))').step()

				ctrl.line(`\(@type.getSealedName()) = {}`)

				ctrl.done()
			}
			else {
				var ctrl = fragments.newControl().code('if(', $runtime.type(@node), '.isValue(', @parameter, '))').step()

				ctrl.line(`\(@name) = \(@parameter)`)

				if @type.isSealed() {
					ctrl.line(`__ks_\(@name) = __ks_\(@parameter)`)

					ctrl.step().code('else').step()

					ctrl.line(`__ks_\(@name) = {}`)
				}

				ctrl.done()
			}
		}
		else if argument is Boolean {
			if @type.isSealed() {
				fragments.line(`\($runtime.immutableScope(@node))\(@type.getSealedName()) = {}`)
			}
		}
	} # }}}
}

class ROIDynamicRequirement extends StaticRequirement {
	private late {
		@importer
		@tempName: String
	}
	constructor(@name, @type, @node) { # {{{
		super(name, type, node)
	} # }}}
	constructor(variable: Variable, importer) { # {{{
		super(variable, @importer <- importer)
	} # }}}
	acquireTempName() { # {{{
		@tempName = @node.module().scope().acquireTempName(false)
	} # }}}
	tempName() => @tempName
}
