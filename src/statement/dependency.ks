abstract class DependencyStatement extends Statement {
	abstract applyFlags(type: Type)
	define(declaration) { # {{{
		var options = Attribute.configure(declaration, @options, AttributeTarget.Statement, @file())
		var scope = @parent.scope()
		var module = @module()
		var name = declaration.name.name

		match declaration.kind {
			NodeKind.ClassDeclaration {
				var mut exhaustive = if options.rules.nonExhaustive set false else null
				// var mut libstd = false
				// TODO! remove newline

				var type =
					if module.isStandardLibrary() {
						set ClassType.new(scope)
					}
					else if var variable ?= scope.getVariable(name) {
						unless variable.isStandardLibrary() || variable.isPredefined() {
							SyntaxException.throwAlreadyDeclared(name, this)
						}

						var original = variable.getDeclaredType().type()

						if original is ClassType {
							var result = original.clone()
								..setStandardLibrary(.Yes + .Opened) if original.isStandardLibrary(.Yes)

							if variable.isStandardLibrary() {
								exhaustive ??= original.isExhaustive(this)
							}

							set result
						}
						else {
							NotImplementedException.throw(this)
						}
					}
					else {
						set ClassType.new(scope)
					}

				if var original ?= scope.getPredefinedType(name) {
					type.features(original.discard().features())
				}

				@applyFlags(type)

				for var modifier in declaration.modifiers {
					match modifier.kind {
						ModifierKind.Abstract {
							type.flagAbstract()
						}
						ModifierKind.Sealed {
							type.flagSealed()
						}
						ModifierKind.System {
							type.flagSystem()
						}
					}
				}

				if ?#declaration.typeParameters {
					var generics = [Type.toGeneric(parameter, this) for var parameter in declaration.typeParameters]

					type.generics(generics)
				}

				var variable = scope.define(name, true, type, this)

				if module.isStandardLibrary() {
					variable.flagStandardLibrary()
				}

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

				exhaustive ??= ?#declaration.members

				type.setExhaustive(exhaustive)

				for var member in declaration.members {
					type.addPropertyFromAST(member, name, this)
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
				var variable = scope.define(name, true, type, this)

				if options.rules.nonExhaustive || declaration.members.length == 0 {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				for var member in declaration.members {
					type.addPropertyFromAST(member, name, this)
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
				var mut exhaustive = if options.rules.nonExhaustive set false else null
				// var mut libstd = false
				// TODO! remove newline

				var type =
					if module.isStandardLibrary() {
						set NamespaceType.new(scope)
					}
					else if var variable ?= scope.getVariable(name) {
						unless variable.isStandardLibrary() || variable.isPredefined() {
							SyntaxException.throwAlreadyDeclared(name, this)
						}

						var original = variable.getDeclaredType().type()

						if original is NamespaceType {
							var result = original.clone()
								..setStandardLibrary(.Yes + .Opened) if original.isStandardLibrary(.Yes)

							if variable.isStandardLibrary() {
								exhaustive ??= original.isExhaustive(this)
							}

							set result
						}
						else {
							NotImplementedException.throw(this)
						}
					}
					else {
						set NamespaceType.new(scope)
					}

				@applyFlags(type)

				for var modifier in declaration.modifiers {
					match modifier.kind {
						ModifierKind.Sealed {
							type.flagSealed()
						}
						ModifierKind.System {
							type.flagSystem()
						}
					}
				}

				var variable = scope.define(name, true, type, this)

				if module.isStandardLibrary() {
					variable.flagStandardLibrary()
				}

				exhaustive ??= ?#declaration.statements

				type.setExhaustive(exhaustive)

				for var statement in declaration.statements {
					type.addPropertyFromAST(statement, name, this)
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

				return scope.define(name, true, type, true, this)
			}
			else {
				throw NotSupportedException.new(`Unexpected kind \(declaration.kind)`, this)
			}
		}
	} # }}}
}

class ExternDeclaration extends Statement {
	private {
		@declarators = []
	}
	initiate() { # {{{
		for var data in @data.declarations {
			ExternDeclarator.new(data, this)
				..initiate()
				|> @declarators.push
		}
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	toStatementFragments(fragments, mode) { # {{{
		for var declarator in @declarators {
			declarator.toStatementFragments(fragments, mode)
		}
	} # }}}
}

class ExternDeclarator extends DependencyStatement {
	private late {
		@auxiliary									= false
		@instanceMethods: ClassMethodType[]{}		= {}
		@name: String
		@type: Type
	}
	initiate() { # {{{
		@name = @data.name.name

		var mut variable = @scope.getVariable(@name)

		if ?variable && !variable.isPredefined() {
			if @data.kind == NodeKind.FunctionDeclaration {
				var late parameters
				if @data.parameters?.length != 0 {
					parameters = [ParameterType.fromAST(parameter, this) for var parameter in @data.parameters]
				}
				else {
					parameters = [ParameterType.new(@scope, Type.Any, 0, Infinity)]
				}

				var type = FunctionType.new(parameters, @data, this).flagAlien()

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
					SyntaxException.throwAlreadyDeclared(@name, this)
				}
			}
			else if !?@parent.includePath() {
				variable = @define(@data)
			}
			else {
				// TODO check & merge type
			}
		}
		else {
			variable = @define(@data)
		}

		variable.setComplete(true)

		@module().addAlien(variable.name(), variable.getDeclaredType())

		@type = variable.getDeclaredType().type()

		if @type.isClass() && @type.isSealed() {
			for var methods, name of @type.discard().listInstanceMethods() {
				for var method in methods {
					if !method.hasAuxiliary() && (method.hasGenerics() || method.hasDeferredParameter()) {
						@instanceMethods[name] = methods

						for var mth in methods {
							mth.flagAuxiliary()
						}

						break
					}
				}
			}

			if ?#@instanceMethods {
				var type = variable.getDeclaredType()

				if !type.hasAuxiliary() {
					type
						..flagAuxiliary()
						..useAuxiliaryName(@module())

					@auxiliary = true
				}
			}
		}
	} # }}}
	analyse()
	override prepare(target, targetMode)
	translate()
	override applyFlags(type) { # {{{
		return type
			.flagAlien()
			.flagRequired()
			.origin(TypeOrigin.Extern)
	} # }}}
	toStatementFragments(fragments, mode) { # {{{
		return unless ?#@instanceMethods

		if @auxiliary {
			var variable = @scope.getVariable(@name)
			var sealedName = variable.getDeclaredType().getAuxiliaryName()

			fragments.line(`\($runtime.immutableScope(this))\(sealedName) = {}`)
		}

		for var methods, name of @instanceMethods {
			@toSealedInstanceFragments(name, methods, fragments)
		}
	} # }}}
	toSealedInstanceFragments(name: String, methods: ClassMethodType[], fragments) { # {{{
		var variable = @scope.getVariable(@name)
		var sealedName = variable.getDeclaredType().getAuxiliaryName()
		var labelable = @type.isLabelableInstanceMethod(@name)
		var assessment = Router.assess(@type.listInstanceMethods(name), name, this)

		var mut line = fragments.newLine()

		if labelable {
			line.code(`\(sealedName)._im_\(name) = function(that, gens, kws, ...args)`)
		}
		else {
			line.code(`\(sealedName)._im_\(name) = function(that, gens, ...args)`)
		}

		var mut block = line.newBlock()

		if labelable {
			block.line(`return \(sealedName).__ks_func_\(name)_rt(that, gens || {}, kws, args)`)
		}
		else {
			block.line(`return \(sealedName).__ks_func_\(name)_rt(that, gens || {}, args)`)
		}

		block.done()
		line.done()

		line = fragments.newLine()

		if labelable {
			line.code(`\(sealedName).__ks_func_\(name)_rt = function(that, gens, kws, args)`)
		}
		else {
			line.code(`\(sealedName).__ks_func_\(name)_rt = function(that, gens, args)`)
		}

		block = line.newBlock()

		Router.toFragments(
			(function, writer) => {
				if function.isSealed() {
					writer.code(`\(sealedName).__ks_func_\(name)_\(function.index()).call(that`)

					return true
				}
				else {
					line.code(`that.\(name).call(that`)

					return true
				}
			}
			null
			assessment
			true
			block
			this
		)

		block.done()
		line.done()
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
		var type: Type = requirement.type()
		var libstd = type.getStandardLibrary()

		if libstd ~~ .Opened {
			type.setStandardLibrary(libstd + .Augmented)
		}

		@module()
			.addRequirement(requirement)
			.addAlien(requirement.name(), type)
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
								if var origin ?= type.origin() {
									type.origin(origin:!!!(TypeOrigin) + TypeOrigin.RequireOrExtern)
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

		if !?#@requirements {
			@toImportFragments(fragments)
		}
		else if #@requirements == 1 {
			var requirement = @requirements[0]
			var argument = module.getArgument(requirement.index())

			if !?argument {
				var ctrl = fragments.newControl()

				if requirement.isSystem() {
					ctrl.code(`if(!\(requirement.getAuxiliaryName()))`).step()
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
			var mut system = true

			for var requirement in @requirements {
				var argument = module.getArgument(requirement.index())

				if !?argument {
					if !requirement.isSystem() {
						fragments.line(`var \(requirement.getTempName())_valuable = \($runtime.type(this)).isValue(\(requirement.name()))`)
					}

					unknowns.push(requirement)

					system = false
				}
				else {
					if argument is Boolean {
						notpasseds.push(requirement)
					}

					system &&= requirement.isSystem()
				}
			}

			if ?#notpasseds || ?#unknowns {
				var mut ctrl = fragments

				if ?#unknowns {
					ctrl = fragments.newControl().code(`if(`)

					for var requirement, index in unknowns {
						ctrl.code(' || ') unless index == 0

						if requirement.isSystem() {
							ctrl.code(`!\(requirement.getAuxiliaryName())`)
						}
						else {
							ctrl.code(`!\(requirement.getTempName())_valuable`)
						}
					}

					ctrl.code(')').step()
				}

				if #notpasseds == #@requirements {
					@toImportFragments(ctrl, true)
				}
				else if system {
					@toImportFragments(ctrl, true, true)
				}
				else {
					@toImportFragments(ctrl, false, true)

					for var requirement in notpasseds {
						if requirement.isSystem() {
							ctrl.line(`\(requirement.getAuxiliaryName()) = __ks__.\(requirement.getAuxiliaryName())`)
						}
						else {
							ctrl.line(`\(requirement.name()) = __ks__.\(requirement.name())`)

							if requirement.isSealed() {
								ctrl.line(`\(requirement.getAuxiliaryName()) = __ks__.\(requirement.getAuxiliaryName())`)
							}
						}
					}

					for var requirement in unknowns {
						if requirement.isSystem() {
							ctrl.newControl()
								..code(`if(!\(requirement.getAuxiliaryName()))`).step()
								..line(`\(requirement.getAuxiliaryName()) = __ks__.\(requirement.getAuxiliaryName())`)
								..done()
						}
						else {
							ctrl.newControl()
								..code(`if(!\(requirement.getTempName())_valuable)`).step()
								..line(`\(requirement.name()) = __ks__.\(requirement.name())`)
								..line(`\(requirement.getAuxiliaryName()) = __ks__.\(requirement.getAuxiliaryName())`) if requirement.isSealed()
								..done()
						}
					}
				}

				if ?#unknowns {
					ctrl.done()
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

				if var origin ?= type.origin() {
					type.origin(origin:!!!(TypeOrigin) + TypeOrigin.ExternOrRequire)
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
				ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.getAuxiliaryName(), '))').step()
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
					fragments.line(`var \(requirement.getTempName())_valuable = \($runtime.type(this)).isValue(\(requirement.getAuxiliaryName()))`)
				}
				else {
					fragments.line(`var \(requirement.getTempName())_valuable = \($runtime.type(this)).isValue(\(requirement.name()))`)
				}
			}

			var ctrl = fragments.newControl().code(`if(`)

			for var requirement, index in @requirements {
				if index != 0 {
					ctrl.code(' || ')
				}

				ctrl.code(`!\(requirement.getTempName())_valuable`)
			}

			ctrl.code(')').step()

			@toImportFragments(ctrl, false)

			for var requirement in @requirements {
				var control = ctrl.newControl().code(`if(!\(requirement.getTempName())_valuable)`).step()

				if requirement.isSystem() {
					control.line(`\(requirement.getAuxiliaryName()) = __ks__.\(requirement.getAuxiliaryName())`)
				}
				else {
					control.line(`\(requirement.name()) = __ks__.\(requirement.name())`)

					if requirement.isSealed() {
						control.line(`\(requirement.getAuxiliaryName()) = __ks__.\(requirement.getAuxiliaryName())`)
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

		if @type.isUsingAuxiliary() {
			@type.flagAuxiliary()
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
	getAuxiliaryName() => @type.getAuxiliaryName()
	index() => @index
	index(@index)
	isRequired() => @type.isRequired()
	isSealed() => @type.isSealed()
	isSystem() => @type.isSystem()
	name() => @name
	toNameFragments(fragments) { # {{{
		if @type.isSealed() {
			fragments.code(@type.getAuxiliaryName())
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
				fragments.code(@type.getAuxiliaryName())
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
				fragments.code(@type.getAuxiliaryName())
			}
			else {
				fragments.code(@name)

				if @type.isSealed() {
					fragments.code($comma, @type.getAuxiliaryName())
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
				fragments.code(@type.getAuxiliaryName())
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
				fragments.code(@type.getAuxiliaryName())
			}
			else {
				fragments.code(@name)

				if @type.isSealed() {
					fragments.code($comma, @type.getAuxiliaryName())
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
				var ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', this.getAuxiliaryName(), '))').step()

				ctrl.line(`\(this.getAuxiliaryName()) = {}`)

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
				fragments.newControl()
					..code(`if(!\(@type.getAuxiliaryName()))`).step()
					..line(`\(@type.getAuxiliaryName()) = {}`)
					..done()
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
				fragments.line(`\($runtime.immutableScope(@node))\(@type.getAuxiliaryName()) = {}`)
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
		if !@type.isSystem() {
			@tempName = @node.module().scope().acquireTempName(false)
		}
	} # }}}
	getTempName() => @tempName
}
