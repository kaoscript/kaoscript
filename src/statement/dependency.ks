enum DependencyKind {
	Extern
	ExternOrRequire
	Require
	RequireOrExtern
	RequireOrImport
}

abstract class DependencyStatement extends Statement {
	define(declaration, kind) { // {{{
		const scope = @parent.scope()

		switch declaration.kind {
			NodeKind::ClassDeclaration => {
				let type = new ClassType(scope)
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

				if kind != DependencyKind::Extern {
					type.flagRequired()
				}

				if	kind == DependencyKind::Extern ||
					kind == DependencyKind::ExternOrRequire ||
					kind == DependencyKind::RequireOrExtern
				{
					type = type.flagAlien()
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

					type.setExhaustive(true)
				}

				if @options.rules.nonExhaustive {
					type.setExhaustive(false)
				}

				return variable
			}
			NodeKind::EnumDeclaration => {
				let kind = EnumTypeKind::Number

				if declaration.type? {
					if Type.fromAST(declaration.type, this).isString() {
						kind = EnumTypeKind::String
					}
				}

				let type = new EnumType(scope, kind)
				const variable = scope.define(declaration.name.name, true, type, this)

				if kind != DependencyKind::Extern {
					type.flagRequired()
				}

				if	kind == DependencyKind::Extern ||
					kind == DependencyKind::ExternOrRequire ||
					kind == DependencyKind::RequireOrExtern
				{
					type = type.flagAlien()
				}

				if declaration.members.length != 0 {
					for member in declaration.members {
						type.addElement(member.name.name)
					}

					type.setExhaustive(true)
				}

				if @options.rules.nonExhaustive {
					type.setExhaustive(false)
				}

				return variable
			}
			NodeKind::FunctionDeclaration => {
				let type
				if declaration.parameters? {
					const parameters = [Type.fromAST(parameter, this) for parameter in declaration.parameters]

					type = new FunctionType(parameters, declaration, this)
					type.setExhaustive(true)
				}
				else {
					type = this.scope().reference('Function')
				}

				const variable = scope.define(declaration.name.name, true, type, true, this)

				if kind != DependencyKind::Extern {
					type.flagRequired()
				}

				if	kind == DependencyKind::Extern ||
					kind == DependencyKind::ExternOrRequire ||
					kind == DependencyKind::RequireOrExtern
				{
					type = type.flagAlien()
				}

				if @options.rules.nonExhaustive {
					type.setExhaustive(false)
				}

				return variable
			}
			NodeKind::NamespaceDeclaration => {
				let type = new NamespaceType(scope)
				const variable = scope.define(declaration.name.name, true, type, this)

				if kind != DependencyKind::Extern {
					type.flagRequired()
				}

				if	kind == DependencyKind::Extern ||
					kind == DependencyKind::ExternOrRequire ||
					kind == DependencyKind::RequireOrExtern
				{
					type = type.flagAlien()
				}

				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Sealed {
						type.flagSealed()
					}
					else if modifier.kind == ModifierKind::Systemic {
						type.flagSystemic()
					}
				}

				if declaration.statements.length != 0 {
					for statement in declaration.statements {
						type.addPropertyFromAST(statement, this)
					}

					type.setExhaustive(true)
				}

				if @options.rules.nonExhaustive {
					type.setExhaustive(false)
				}

				return variable
			}
			NodeKind::VariableDeclarator => {
				let type = Type.fromAST(declaration.type, this)

				let instance = type is ClassType

				if type is ReferenceType && type.isClass() {
					type = new ClassType(scope)
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

				if	kind == DependencyKind::Extern ||
					kind == DependencyKind::ExternOrRequire ||
					kind == DependencyKind::RequireOrExtern
				{
					type = type.flagAlien()
				}

				if instance {
					type = @scope.reference(type)
				}

				const variable = scope.define(declaration.name.name, true, type, true, this)

				if kind != DependencyKind::Extern {
					type.flagRequired()
				}

				return variable
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
	analyse() { // {{{
		const module = this.module()

		let variable
		for const declaration in @data.declarations {
			if (variable ?= @scope.getVariable(declaration.name.name)) && !variable.isPredefined() {
				if declaration.kind == NodeKind::FunctionDeclaration {
					let parameters
					if declaration.parameters?.length != 0 {
						parameters = [Type.fromAST(parameter, this) for parameter in declaration.parameters]
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
					}
					else if variable.getDeclaredType() is OverloadedFunctionType {
						variable.getDeclaredType().addFunction(type)
					}
					else {
						SyntaxException.throwAlreadyDeclared(declaration.name.name, this)
					}
				}
				else if @parent.includePath() == null {
					variable = this.define(declaration, DependencyKind::Extern)

					if variable.getDeclaredType().isSealed() && variable.getDeclaredType().isExtendable() {
						@lines.push(`var \(variable.getDeclaredType().getSealedName()) = {}`)
					}
				}
				else {
					// TODO: check & merge type
				}
			}
			else {
				variable = this.define(declaration, DependencyKind::Extern)

				if variable.getDeclaredType().isSealed() && variable.getDeclaredType().isExtendable() {
					@lines.push(`var \(variable.getDeclaredType().getSealedName()) = {}`)
				}
			}

			module.addAlien(variable.name(), variable.getDeclaredType())
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
		for line in @lines {
			fragments.line(line)
		}
	} // }}}
}

class RequireDeclaration extends DependencyStatement {
	analyse() { // {{{
		const module = this.module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('require', this)
		}

		let variable
		for declaration in @data.declarations {
			if variable ?= @scope.getVariable(declaration.name.name) {
				if declaration.kind == NodeKind::FunctionDeclaration {
					const requirement = module.getRequirement(declaration.name.name)

					let parameters
					if declaration.parameters?.length != 0 {
						parameters = [Type.fromAST(parameter, this) for parameter in declaration.parameters]
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
					module.addRequirement(new StaticRequirement(declaration, this))
				}
				else {
					// TODO: check & merge type
				}
			}
			else {
				module.addRequirement(new StaticRequirement(declaration, this))
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode)
}

class ExternOrRequireDeclaration extends DependencyStatement {
	analyse() { // {{{
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
					module.addRequirement(new EORDynamicRequirement(declaration, this))
				}
			}
		}
		else {
			for declaration in @data.declarations {
				module.addRequirement(new EORDynamicRequirement(declaration, this))
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode)
}

class RequireOrExternDeclaration extends DependencyStatement {
	private {
		_requirements: Array<ROEDynamicRequirement>		= []
	}
	analyse() { // {{{
		const module = this.module()

		if module.isBinary() {
			SyntaxException.throwNotBinary('require|extern', this)
		}

		module.flag('Type')

		if @parent.includePath() != null {
			let variable
			for const data in @data.declarations {
				if variable ?= @scope.getVariable(data.name.name) {
					// TODO: check & merge type
				}
				else {
					const requirement = new ROEDynamicRequirement(data, this)

					@requirements.push(requirement)

					module.addRequirement(requirement)
				}
			}
		}
		else {
			for const data in @data.declarations {
				const requirement = new ROEDynamicRequirement(data, this)

				@requirements.push(requirement)

				module.addRequirement(requirement)
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode)
}

class RequireOrImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	analyse() { // {{{
		if this.module().isBinary() {
			SyntaxException.throwNotBinary('require|import', this)
		}

		for const data in @data.declarations {
			const declarator = new RequireOrImportDeclarator(data, this)

			declarator.analyse()

			@declarators.push(declarator)
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

class RequireOrImportDeclarator extends Importer {
	private {
		_requirements: Array	= []
	}
	prepare() { // {{{
		super.prepare()

		const module = this.module()

		if @count != 0 {
			if @parent.includePath() == null {
				const line = this.line()

				for const var of @variables {
					const variable = @scope.getVariable(var.name)

					if @scope.hasDefinedVariableBefore(var.name, line) {
						variable.declaration().flagForcefullyRebinded()
					}
					else {
						const requirement = new ROIDynamicRequirement(@scope.getVariable(var.name), this)

						@requirements.push(requirement)
						module.addRequirement(requirement)
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
	metadata() => @metadata
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

					if requirement.isFlexible() {
						control.line(`\(requirement.getSealedName()) = __ks__.\(requirement.getSealedName())`)
					}
				}

				control.done()
			}

			ctrl.done()
		}
	} // }}}
}

class ExternOrImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	analyse() { // {{{
		if this.module().isBinary() {
			SyntaxException.throwNotBinary('extern|import', this)
		}

		for let declarator in @data.declarations {
			@declarators.push(declarator = new ExternOrImportDeclarator(declarator, this))

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
			const variable = @scope.getVariable(var.name)

			const requirement = new ROIDynamicRequirement(variable, this)

			@requirements.push(requirement)

			module.addAlien(var.name, variable.getDeclaredType())
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
	metadata() => @metadata
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

					if requirement.isFlexible() {
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
	constructor(data, kind: DependencyKind, @node) { // {{{
		this(node.define(data, kind), node)
	} // }}}
	getSealedName() => @type.getSealedName()
	isAlien() => false
	isFlexible() => @type.isFlexible()
	abstract isRequired(): Boolean
	isSystemic() => @type.isSystemic()
	name() => @name
	toNameFragments(fragments) { // {{{
		if @type.isFlexible() {
			fragments.code(@type.getSealedName())
		}
		else {
			fragments.code(@name)
		}
	} // }}}
	type() => @type
	type(@type) => this
}

class StaticRequirement extends Requirement {
	constructor(@name, @type, @node) { // {{{
		super(name, type, node)
	} // }}}
	constructor(data, @node) { // {{{
		super(data, DependencyKind::Require, node)
	} // }}}
	constructor(variable: Variable, @node) { // {{{
		super(variable, node)
	} // }}}
	isRequired() => true
	toFragments(fragments)
	toParameterFragments(fragments) { // {{{
		if @type.isSystemic() {
			fragments.code(@type.getSealedName())
		}
		else {
			fragments.code(@name)

			if @type.isFlexible() {
				fragments.code(`, __ks_\(@name)`)
			}
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
	isRequired() => false
	toParameterFragments(fragments) { // {{{
		if @type.isSystemic() {
			fragments.code(@type.getSealedName())
		}
		else {
			fragments.code(@parameter)

			if @type.isFlexible() {
				fragments.code(`, __ks_\(@parameter)`)
			}
		}
	} // }}}
}

class EORDynamicRequirement extends DynamicRequirement {
	constructor(data, @node) { // {{{
		super(data, DependencyKind::ExternOrRequire, node)

		if !@type.isSystemic() {
			@parameter = @node.module().scope().acquireTempName(false)
		}
	} // }}}
	isAlien() => true
	toFragments(fragments) { // {{{
		if @type.isSystemic() {
			const ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', this.getSealedName(), '))').step()

			ctrl.line(`\(this.getSealedName()) = {}`)

			ctrl.done()
		}
		else {
			const ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', @name, '))').step()

			ctrl.line(`\(@name) = \(@parameter)`)

			if @type.isFlexible() {
				ctrl.line(`__ks_\(@name) = {}`)

				ctrl.step().code('else').step()

				ctrl.line(`__ks_\(@name) = __ks_\(@parameter)`)
			}

			ctrl.done()
		}
	} // }}}
}

class ROEDynamicRequirement extends DynamicRequirement {
	constructor(data, @node) { // {{{
		super(data, DependencyKind::RequireOrExtern, node)

		if !@type.isSystemic() {
			@parameter = @node.module().scope().acquireTempName(false)
		}
	} // }}}
	isAlien() => true
	toFragments(fragments) { // {{{
		if @type.isSystemic() {
			const ctrl = fragments.newControl().code('if(!', $runtime.type(@node), '.isValue(', this.getSealedName(), '))').step()

			ctrl.line(`\(this.getSealedName()) = {}`)

			ctrl.done()
		}
		else {
			const ctrl = fragments.newControl().code('if(', $runtime.type(@node), '.isValue(', @parameter, '))').step()

			ctrl.line(`\(@name) = \(@parameter)`)

			if @type.isFlexible() {
				ctrl.line(`__ks_\(@name) = __ks_\(@parameter)`)

				ctrl.step().code('else').step()

				ctrl.line(`__ks_\(@name) = {}`)
			}

			ctrl.done()
		}
	} // }}}
}

class ROIDynamicRequirement extends StaticRequirement {
	private lateinit {
		_importer
		_tempName: String
	}
	constructor(variable: Variable, importer) { // {{{
		super(variable, @importer = importer)

		variable.getDeclaredType().condense()
	} // }}}
	acquireTempName() { // {{{
		@tempName = @node.module().scope().acquireTempName(false)
	} // }}}
	isRequired() => false
	tempName() => @tempName
}