abstract class DependencyStatement extends Statement {
	abstract applyFlags(type: Type)
	define(declaration) { // {{{
		const options = Attribute.configure(declaration, @options, AttributeTarget::Statement, @file())
		const scope = @parent.scope()

		switch declaration.kind {
			NodeKind::ClassDeclaration => {
				const type = this.applyFlags(new ClassType(scope))
				const variable = scope.define(declaration.name.name, true, type, this)

				if declaration.extends? {
					if superVar !?= @scope.getVariable(declaration.extends.name) {
						ReferenceException.throwNotDefined(declaration.extends.name, this)
					}
					else if !superVar.getDeclaredType().isClass() {
						TypeException.throwNotClass(declaration.extends.name, this)
					}

					type.extends(superVar.getDeclaredType())
				}

				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Abstract {
						type.flagAbstract()
					}
					else if modifier.kind == ModifierKind::Sealed {
						type.flagSealed()
					}
					else if modifier.kind == ModifierKind::Systemic {
						type.flagSystemic()
					}
				}

				if declaration.members.length != 0 {
					for member in declaration.members {
						type.addPropertyFromAST(member, this)
					}
				}

				if options.rules.nonExhaustive || declaration.members.length == 0 {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				return variable
			}
			NodeKind::EnumDeclaration => {
				let ekind = EnumTypeKind::Number

				if declaration.type? {
					if Type.fromAST(declaration.type, this).isString() {
						ekind = EnumTypeKind::String
					}
				}

				const type = this.applyFlags(new EnumType(scope, ekind))
				const variable = scope.define(declaration.name.name, true, type, this)

				if options.rules.nonExhaustive || declaration.members.length == 0 {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				if declaration.members.length != 0 {
					for member in declaration.members {
						type.addPropertyFromAST(member, this)
					}
				}

				return variable
			}
			NodeKind::FunctionDeclaration => {
				let type
				if declaration.parameters? {
					const parameters = [ParameterType.fromAST(parameter, this) for parameter in declaration.parameters]

					type = new FunctionType(parameters, declaration, this)
				}
				else {
					type = this.scope().reference('Function')
				}

				type = this.applyFlags(type)

				const variable = scope.define(declaration.name.name, true, type, true, this)

				if options.rules.nonExhaustive || !?declaration.parameters {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				return variable
			}
			NodeKind::NamespaceDeclaration => {
				const type = this.applyFlags(new NamespaceType(scope))
				const variable = scope.define(declaration.name.name, true, type, this)

				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Sealed {
						type.flagSealed()
					}
					else if modifier.kind == ModifierKind::Systemic {
						type.flagSystemic()
					}
				}

				if options.rules.nonExhaustive || declaration.statements.length == 0 {
					type.setExhaustive(false)
				}
				else {
					type.setExhaustive(true)
				}

				if declaration.statements.length != 0 {
					for statement in declaration.statements {
						type.addPropertyFromAST(statement, this)
					}
				}

				return variable
			}
			NodeKind::VariableDeclarator => {
				let type = Type.fromAST(declaration.type, this)

				let instance = type is ClassType

				if type is ReferenceType && type.isClass() {
					type = new ClassType(scope)

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

				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Sealed {
						if !type.isSealable() {
							type = new SealableType(scope, type)
						}

						type.flagSealed()
					}
					else if modifier.kind == ModifierKind::Systemic {
						if !type.isSealable() {
							type = new SealableType(scope, type)
						}

						type.flagSystemic()
					}
				}

				type = this.applyFlags(type)

				if instance {
					type = @scope.reference(type)
				}

				return scope.define(declaration.name.name, true, type, true, this)
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(declaration.kind)`, this)
			}
		}
	} // }}}
}

class ExternDeclaration extends DependencyStatement {
	private {
		_lines = []
	}
	initiate() { // {{{
		const module = this.module()

		let variable
		for const declaration in @data.declarations {
			if (variable ?= @scope.getVariable(declaration.name.name)) && !variable.isPredefined() {
				if declaration.kind == NodeKind::FunctionDeclaration {
					let parameters
					if declaration.parameters?.length != 0 {
						parameters = [ParameterType.fromAST(parameter, this) for parameter in declaration.parameters]
					}
					else {
						parameters = [new ParameterType(@scope, Type.Any, 0, Infinity)]
					}

					const type = new FunctionType(parameters, declaration, this).flagAlien()

					if variable.getDeclaredType() is FunctionType {
						const newType = new OverloadedFunctionType(@scope)

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
					variable = this.define(declaration)

					if variable.getDeclaredType().isSealed() && variable.getDeclaredType().isExtendable() {
						@lines.push(`var \(variable.getDeclaredType().getSealedName()) = {}`)
					}
				}
				else {
					// TODO: check & merge type
				}
			}
			else {
				variable = this.define(declaration)

				const type = variable.getDeclaredType()

				if type.isSealed() && type.isExtendable() {
					@lines.push(`var \(type.getSealedName()) = {}`)
				}
			}

			variable.setComplete(true)

			module.addAlien(variable.name(), variable.getDeclaredType())
		}
	} // }}}
	analyse()
	prepare()
	translate()
	override applyFlags(type) { // {{{
		return type
			.flagAlien()
			.flagRequired()
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for line in @lines {
			fragments.line(line)
		}
	} // }}}
}

class RequireDeclaration extends DependencyStatement {
	initiate() { // {{{
		const module = this.module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('require', this)
		}

		for const declaration in @data.declarations {
			if const variable = @scope.getVariable(declaration.name.name) {
				if declaration.kind == NodeKind::FunctionDeclaration {
					const requirement = module.getRequirement(declaration.name.name)

					let parameters
					if declaration.parameters?.length != 0 {
						parameters = [ParameterType.fromAST(parameter, this) for parameter in declaration.parameters]
					}
					else {
						parameters = [new ParameterType(@scope, Type.Any, 0, Infinity)]
					}

					const type = new FunctionType(parameters, declaration, this)

					if variable.getDeclaredType() is FunctionType {
						const newType = new OverloadedFunctionType(@scope)

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
					this.addRequirement(declaration)
				}
				else {
					// TODO check & merge type
				}
			}
			else {
				this.addRequirement(declaration)
			}
		}
	} // }}}
	analyse()
	prepare()
	translate()
	addRequirement(declaration) { // {{{
		const variable = this.define(declaration)
		const requirement = new StaticRequirement(variable, this)

		this.module().addRequirement(requirement)
	} // }}}
	override applyFlags(type) { // {{{
		return type
			.flagRequirement()
			.flagRequired()
	} // }}}
	toStatementFragments(fragments, mode)
}

class ExternOrRequireDeclaration extends DependencyStatement {
	initiate() { // {{{
		const module = this.module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('extern|require', this)
		}

		module.flag('Type')

		if @parent.includePath() != null {
			let variable
			for declaration in @data.declarations {
				if variable ?= @scope.getVariable(declaration.name.name) {
					// TODO: check & merge type
				}
				else {
					this.addRequirement(declaration)
				}
			}
		}
		else {
			for declaration in @data.declarations {
				this.addRequirement(declaration)
			}
		}
	} // }}}
	analyse()
	prepare()
	translate()
	addRequirement(declaration) { // {{{
		const variable = this.define(declaration)
		const requirement = new EORDynamicRequirement(variable, this)

		this.module()
			.addAlien(requirement.name(), requirement.type())
			.addRequirement(requirement)
	} // }}}
	override applyFlags(type) { // {{{
		return type
			.flagAlien()
			.flagRequirement()
			.origin(TypeOrigin::ExternOrRequire)
	} // }}}
	toStatementFragments(fragments, mode)
}

class RequireOrExternDeclaration extends DependencyStatement {
	private {
		_requirements: Array<ROEDynamicRequirement>		= []
	}
	initiate() { // {{{
		const module = this.module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('require|extern', this)
		}

		module.flag('Type')

		if @parent.includePath() != null {
			for const data in @data.declarations {
				if const variable = @scope.getVariable(data.name.name) {
					// TODO: check & merge type
				}
				else {
					this.addRequirement(data)
				}
			}
		}
		else {
			for const data in @data.declarations {
				this.addRequirement(data)
			}
		}
	} // }}}
	analyse()
	prepare()
	translate()
	addRequirement(declaration) { // {{{
		const variable = this.define(declaration)
		const requirement = new ROEDynamicRequirement(variable, this)

		this.module()
			.addRequirement(requirement)
			.addAlien(requirement.name(), requirement.type())
	} // }}}
	override applyFlags(type) { // {{{
		return type
			.flagAlien()
			.flagRequirement()
			.origin(TypeOrigin::RequireOrExtern + TypeOrigin::Require + TypeOrigin::Extern)
	} // }}}
	toStatementFragments(fragments, mode)
}

class RequireOrImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	initiate() { // {{{
		if this.module().isBinary() {
			SyntaxException.throwNotBinary('require|import', this)
		}

		for const data in @data.declarations {
			const declarator = new RequireOrImportDeclarator(data, this)

			declarator.initiate()

			@declarators.push(declarator)
		}
	} // }}}
	analyse() { // {{{
		for declarator in @declarators {
			declarator.analyse()
		}
	} // }}}
	prepare() { // {{{
		for declarator in @declarators {
			declarator.prepare()
		}
	} // }}}
	translate() { // {{{
		for const declarator in @declarators {
			declarator.translate()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for const declarator in @declarators {
			declarator.toStatementFragments(fragments, mode)
		}
	} // }}}
}

class RequireOrImportDeclarator extends Importer {
	private {
		_requirements: Array	= []
	}
	initiate() { // {{{
		super()

		const module = this.module()

		if @count != 0 {
			if @parent.includePath() == null {
				const line = this.line()

				for const var of @variables {
					if const variable = @scope.getVariable(var.name) {
						if @scope.hasDefinedVariableBefore(var.name, line) {
							variable.declaration().flagForcefullyRebinded()
						}
						else {
							const requirement = new ROIDynamicRequirement(variable, this)
							const type = requirement.type()

							if type.isAlien() {
								const origin = type.origin()
								if origin? {
									type.origin(origin:TypeOrigin + TypeOrigin::RequireOrExtern)
								}
								else {
									type.origin(TypeOrigin::RequireOrExtern)
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
				throw new NotImplementedException(this)
			}
		}

		if @requirements.length > 1 {
			for const requirement in @requirements {
				requirement.acquireTempName()
			}
		}

		if @alias != null {
			throw new NotImplementedException(this)
		}
	} // }}}
	flagForcefullyRebinded()
	override mode() => ImportMode::RequireOrImport
	toStatementFragments(fragments, mode) { // {{{
		const module = this.module()

		if @requirements.length == 0 {
			this.toImportFragments(fragments)
		}
		else if @requirements.length == 1 {
			const requirement = @requirements[0]
			const argument = module.getArgument(requirement.index())

			if !?argument {
				const ctrl = fragments.newControl()

				if requirement.isSystemic() {
					ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.getSealedName(), '))').step()
				}
				else {
					ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.name(), '))').step()
				}

				this.toImportFragments(ctrl)

				ctrl.done()
			}
			else if argument is Boolean {
				this.toImportFragments(fragments)
			}
		}
		else {
			const unknowns = []
			const notpasseds = []

			for const requirement in @requirements {
				const argument = module.getArgument(requirement.index())

				if !?argument {
					if requirement.isSystemic() {
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
				let ctrl = fragments

				if unknowns.length > 0 {
					ctrl = fragments.newControl().code(`if(`)

					for const requirement, index in unknowns {
						ctrl.code(' || ') unless index == 0

						ctrl.code(`!\(requirement.tempName())_valuable`)
					}

					ctrl.code(')').step()
				}

				if notpasseds.length == @requirements.length {
					this.toImportFragments(ctrl, true)
				}
				else {
					this.toImportFragments(ctrl, false)

					for const requirement in notpasseds {
						if requirement.isSystemic() {
							ctrl.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
						}
						else {
							ctrl.line(`\(requirement.name()) = __ks__.\(requirement.name())`)

							if requirement.isSealed() {
								ctrl.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
							}
						}
					}

					for const requirement in unknowns {
						const control = ctrl.newControl().code(`if(!\(requirement.tempName())_valuable)`).step()

						if requirement.isSystemic() {
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
	} // }}}
}

class ExternOrImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	initiate() { // {{{
		if this.module().isBinary() {
			SyntaxException.throwNotBinary('extern|import', this)
		}

		for const data in @data.declarations {
			const declarator = new ExternOrImportDeclarator(data, this)

			declarator.initiate()

			@declarators.push(declarator)
		}
	} // }}}
	analyse() { // {{{
		for declarator in @declarators {
			declarator.analyse()
		}
	} // }}}
	prepare() { // {{{
		for const declarator in @declarators {
			declarator.prepare()
		}
	} // }}}
	translate() { // {{{
		for const declarator in @declarators {
			declarator.translate()
		}
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
		for const declarator in @declarators {
			declarator.toStatementFragments(fragments, mode)
		}
	} // }}}
}

class ExternOrImportDeclarator extends Importer {
	private {
		_requirements: Array	= []
	}
	prepare() { // {{{
		super()

		const module = this.module()

		for const var of @variables {
			if const variable = @scope.getVariable(var.name) {
				const requirement = new ROIDynamicRequirement(variable, this)
				const type = requirement.type().flagAlien()

				const origin = type.origin()
				if origin? {
					type.origin(origin:TypeOrigin + TypeOrigin::ExternOrRequire)
				}
				else {
					type.origin(TypeOrigin::ExternOrRequire)
				}

				requirement.type(type)

				@requirements.push(requirement)

				module.addAlien(var.name, type)
			}
		}

		if @requirements.length > 1 {
			for const requirement in @requirements {
				requirement.acquireTempName()
			}
		}

		if @alias != null {
			throw new NotImplementedException(this)
		}
	} // }}}
	flagForcefullyRebinded()
	override mode() => ImportMode::ExternOrImport
	toStatementFragments(fragments, mode) { // {{{
		if @requirements.length == 0 {
			this.toImportFragments(fragments)
		}
		else if @requirements.length == 1 {
			const requirement = @requirements[0]

			const ctrl = fragments.newControl()

			if requirement.isSystemic() {
				ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.getSealedName(), '))').step()
			}
			else {
				ctrl.code('if(!', $runtime.type(this), '.isValue(', requirement.name(), '))').step()
			}

			this.toImportFragments(ctrl)

			ctrl.done()
		}
		else {
			for const requirement in @requirements {
				if requirement.isSystemic() {
					fragments.line(`var \(requirement.tempName())_valuable = \($runtime.type(this)).isValue(\(requirement.getSealedName()))`)
				}
				else {
					fragments.line(`var \(requirement.tempName())_valuable = \($runtime.type(this)).isValue(\(requirement.name()))`)
				}
			}

			const ctrl = fragments.newControl().code(`if(`)

			for const requirement, index in @requirements {
				if index != 0 {
					ctrl.code(' || ')
				}

				ctrl.code(`!\(requirement.tempName())_valuable`)
			}

			ctrl.code(')').step()

			this.toImportFragments(ctrl, false)

			for const requirement in @requirements {
				const control = ctrl.newControl().code(`if(!\(requirement.tempName())_valuable)`).step()

				if requirement.isSystemic() {
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
	} // }}}
}

abstract class Requirement {
	private {
		_alternative: Type?
		_index: Number				= -1
		_name: String
		_node: AbstractNode
		_type: Type
	}
	constructor(@name, @type, @node) { // {{{
		if @type.isSystemic() && @name == 'Dictionary' {
			node.module().flag('Dictionary')
		}
	} // }}}
	constructor(variable: Variable, @node) { // {{{
		this(variable.name(), variable.getDeclaredType(), node)
	} // }}}
	alternative(): @alternative
	flagAlternative(): this { // {{{
		let type = @type

		while type.minorOriginal()? {
			type = type.minorOriginal()
		}

		@alternative = type
	} // }}}
	getSealedName() => @type.getSealedName()
	index() => @index
	index(@index)
	isRequired() => @type.isRequired()
	isSealed() => @type.isSealed()
	isSystemic() => @type.isSystemic()
	name() => @name
	toNameFragments(fragments) { // {{{
		if @type.isSealed() {
			fragments.code(@type.getSealedName())
		}
		else {
			fragments.code(@name)
		}
	} // }}}
	toRequiredMetadata() { // {{{
		if @type.isRequired() {
			return true
		}
		else if @alternative? {
			return @alternative.referenceIndex()
		}
		else {
			return false
		}
	} // }}}
	type() => @type
	type(@type) => this
}

class StaticRequirement extends Requirement {
	constructor(@name, @type, @node) { // {{{
		super(name, type, node)
	} // }}}
	constructor(variable: Variable, @node) { // {{{
		super(variable, node)
	} // }}}
	toFragments(fragments)
	toParameterFragments(fragments, comma) { // {{{
		const module = @node.module()
		const argument = module.getArgument(@index)

		if !?argument {
			fragments.code($comma) if comma

			if @type.isSystemic() {
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

			if @type.isSystemic() {
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
	} // }}}
}

class ImportingRequirement extends StaticRequirement {
	constructor(@name, @type, node) { // {{{
		super(name, type, node)
	} // }}}
	isRequired() => false
}

abstract class DynamicRequirement extends Requirement {
	private lateinit {
		_parameter: String
	}
	toParameterFragments(fragments, comma) { // {{{
		const module = @node.module()
		const argument = module.getArgument(@index)

		if !?argument {
			fragments.code($comma) if comma

			if @type.isSystemic() {
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

			if @type.isSystemic() {
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
	} // }}}
}

class EORDynamicRequirement extends DynamicRequirement {
	constructor(variable: Variable, @node) { // {{{
		super(variable, node)

		if !@type.isSystemic() {
			@parameter = @node.module().scope().acquireTempName(false)
		}
	} // }}}
	toFragments(fragments) { // {{{
		const module = @node.module()
		const argument = module.getArgument(@index)

		if !?argument {
			if @type.isSystemic() {
				const ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', this.getSealedName(), '))').step()

				ctrl.line(`\(this.getSealedName()) = {}`)

				ctrl.done()
			}
			else {
				const ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', @name, '))').step()

				ctrl.line(`\(@name) = \(@parameter)`)

				if @type.isSealed() {
					ctrl.line(`__ks_\(@name) = {}`)

					ctrl.step().code('else').step()

					ctrl.line(`__ks_\(@name) = __ks_\(@parameter)`)
				}

				ctrl.done()
			}
		}
	} // }}}
}

class ROEDynamicRequirement extends DynamicRequirement {
	constructor(variable: Variable, @node) { // {{{
		super(variable, node)

		if !@type.isSystemic() {
			@parameter = @node.module().scope().acquireTempName(false)
		}
	} // }}}
	toFragments(fragments) { // {{{
		const module = @node.module()
		const argument = module.getArgument(@index)

		if !?argument {
			if @type.isSystemic() {
				const ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', @type.getSealedName(), '))').step()

				ctrl.line(`\(@type.getSealedName()) = {}`)

				ctrl.done()
			}
			else {
				const ctrl = fragments.newControl().code('if(', $runtime.type(@node), '.isValue(', @parameter, '))').step()

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
	} // }}}
}

class ROIDynamicRequirement extends StaticRequirement {
	private lateinit {
		_importer
		_tempName: String
	}
	constructor(@name, @type, @node) { // {{{
		super(name, type, node)
	} // }}}
	constructor(variable: Variable, importer) { // {{{
		super(variable, @importer = importer)
	} // }}}
	acquireTempName() { // {{{
		@tempName = @node.module().scope().acquireTempName(false)
	} // }}}
	tempName() => @tempName
}
