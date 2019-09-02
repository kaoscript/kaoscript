enum DependencyKind {
	Extern
	ExternOrRequire
	Require
	RequireOrExtern
	RequireOrImport
}

abstract class DependencyStatement extends Statement {
	define(declaration, kind) { // {{{
		const scope = this.greatScope()

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
					const parameters: Array<ParameterType> = [Type.fromAST(parameter, this) for parameter in declaration.parameters]

					type = new FunctionType(parameters, declaration, this)
					type.setExhaustive(true)
				}
				else {
					type = this.scope().reference('Function')
				}

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

				if declaration.sealed {
					if type is ReferenceType && type.isClass() {
						type = new ClassType(scope)
					}
					else if !type.isSealable() {
						type = new SealableType(scope, type)
					}

					type.flagSealed()
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

				const variable = scope.define(declaration.name.name, true, type, this)

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
		for declaration in @data.declarations {
			if (variable ?= @scope.getVariable(declaration.name.name)) && !variable.isPredefined() {
				if declaration.kind == NodeKind::FunctionDeclaration {
					let parameters
					if declaration.parameters?.length != 0 {
						parameters = [Type.fromAST(parameter, this) for parameter in declaration.parameters]
					}
					else {
						parameters = [new ParameterType(@scope, Type.Any, 0, Infinity)]
					}

					const type = new FunctionType(parameters as Array<ParameterType>, declaration, this)

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

					const type = new FunctionType(parameters as Array<ParameterType>, declaration, this)

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
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class ExternOrRequireDeclaration extends DependencyStatement {
	analyse() { // {{{
		const module = this.module()

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
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrExternDeclaration extends DependencyStatement {
	analyse() { // {{{
		const module = this.module()

		module.flag('Type')

		if @parent.includePath() != null {
			let variable
			for declaration in @data.declarations {
				if variable ?= @scope.getVariable(declaration.name.name) {
					// TODO: check & merge type
				}
				else {
					module.addRequirement(new ROEDynamicRequirement(declaration, this))
				}
			}
		}
		else {
			for declaration in @data.declarations {
				module.addRequirement(new ROEDynamicRequirement(declaration, this))
			}
		}
	} // }}}
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	analyse() { // {{{
		for let declarator in @data.declarations {
			@declarators.push(declarator = new RequireOrImportDeclarator(declarator, this))

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
	} // }}}
}

class RequireOrImportDeclarator extends Importer {
	private {
		_printed: Boolean		= false
		_requirements: Array	= []
	}
	prepare() { // {{{
		super.prepare()

		const module = this.module()

		if @count != 0 {
			if @parent.includePath() == null {
				for const alias of @variables {
					const requirement = new ROIDynamicRequirement(@scope.getVariable(alias), this)

					@requirements.push(requirement)
					module.addRequirement(requirement)
				}
			}
			else {
				throw new NotImplementedException(this)
			}
		}

		if @alias != null {
			throw new NotImplementedException(this)
		}
	} // }}}
	metadata() => @metadata
	toAltFragments(fragments) { // {{{
		return if this._printed

		if this._requirements.length == 1 {
			const requirement = this._requirements[0]

			const ctrl = fragments.newControl().code(`if(\($runtime.type(this)).isValue(\(requirement.parameter())))`).step()

			if requirement.isFlexible() {
				ctrl
					.line(`req.push(\(requirement.parameter()), __ks_\(requirement.parameter()))`)
					.step()
					.code('else')
					.step()

				this.toImportFragments(ctrl)

				ctrl.line(`req.push(\(requirement.name()), __ks_\(requirement.name()))`)

				ctrl.done()
			}
			else {
				ctrl
					.line(`req.push(\(requirement.parameter()))`)
					.step()
					.code('else')
					.step()

				this.toImportFragments(ctrl)

				ctrl.line(`req.push(\(requirement.name()))`)

				ctrl.done()
			}
		}
		else {
			for const requirement in this._requirements {
				fragments.line(`var \(requirement.parameter())_valuable = \($runtime.type(this)).isValue(\(requirement.parameter()))`)
			}

			const ctrl = fragments.newControl().code(`if(`)

			for const requirement, index in this._requirements {
				if index != 0 {
					ctrl.code(' || ')
				}

				ctrl.code(`!\(requirement.parameter())_valuable`)
			}

			ctrl.code(')').step()

			this.toImportFragments(ctrl)

			for const requirement in this._requirements {
				if requirement.isFlexible() {
					const control = ctrl.newControl().code(`if(\(requirement.parameter())_valuable)`).step()

					control.line(`req.push(\(requirement.parameter()), __ks_\(requirement.parameter()))`).step()

					control.code('else').step()

					control.line(`req.push(\(requirement.name()), \(requirement.type().getSealedName()))`)

					control.done()
				}
				else {
					ctrl.line(`req.push(\(requirement.parameter())_valuable ? \(requirement.parameter()) : \(requirement.name()))`)
				}
			}

			ctrl.step().code('else').step()

			const line = ctrl.newLine().code('req.push(')

			for const requirement, index in this._requirements {
				if index != 0 {
					line.code($comma)
				}

				if requirement.isFlexible() {
					line.code(`\(requirement.parameter()), __ks_\(requirement.parameter())`)
				}
				else {
					line.code(requirement.parameter())
				}
			}

			line.code(')').done()

			ctrl.done()
		}

		this._printed = true
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

abstract class Requirement {
	private {
		_name: String
		_type: Type
	}
	constructor(@name, @type)
	constructor(variable: Variable) { // {{{
		@name = variable.name()
		@type = variable.getDeclaredType()
	} // }}}
	constructor(data, kind: DependencyKind, node) { // {{{
		this(node.define(data, kind))
	} // }}}
	isAlien() => false
	isFlexible() => @type.isFlexible()
	abstract isRequired(): Boolean
	name() => @name
	toNameFragments(fragments) { // {{{
		fragments.code(@name)

		if @type.isFlexible() {
			fragments.code(`, __ks_\(@name)`)
		}
	} // }}}
	type() => @type
	type(@type) => this
}

class StaticRequirement extends Requirement {
	constructor(@name, @type) { // {{{
		super(name, type)
	} // }}}
	constructor(data, node) { // {{{
		super(data, DependencyKind::Require, node)
	} // }}}
	isRequired() => true
	parameter() => @name
	toParameterFragments(fragments) { // {{{
		fragments.code(@name)

		if @type.isFlexible() {
			fragments.code(`, __ks_\(@name)`)
		}
	} // }}}
}

class ImportingRequirement extends StaticRequirement {
	constructor(@name, @type) { // {{{
		super(name, type)
	} // }}}
	isRequired() => false
}

abstract class DynamicRequirement extends Requirement {
	private {
		_parameter: String
		_node: AbstractNode
	}
	constructor(variable: Variable, @node) { // {{{
		super(variable)

		@parameter = @node.module().scope().acquireTempName(false)
	} // }}}
	constructor(data, kind, @node) { // {{{
		super(data, kind, node)

		@node = node
		@parameter = node.module().scope().acquireTempName(false)
	} // }}}
	isRequired() => false
	parameter() => @parameter
	toAssignmentFragments(fragments, index) { // {{{
		fragments.code(`\(@name) = __ks__[\(++index)]`)

		if @type.isFlexible() {
			fragments.code(`, __ks_\(@name) = __ks__[\(++index)]`)
		}

		return index
	} // }}}
	toParameterFragments(fragments) { // {{{
		fragments.code(@parameter)

		if @type.isFlexible() {
			fragments.code(`, __ks_\(@parameter)`)
		}
	} // }}}
}

class EORDynamicRequirement extends DynamicRequirement {
	constructor(data, @node) { // {{{
		super(data, DependencyKind::ExternOrRequire, node)
	} // }}}
	isAlien() => true
	toAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(\($runtime.type(@node)).isValue(\(@name)))`)
			.step()

		if @type.isFlexible() {
			ctrl
				.line(`req.push(\(@name), typeof __ks_\(@name) === "undefined" ? {} : __ks_\(@name))`)
				.step()
				.code('else')
				.step()
				.line(`req.push(\(@parameter), __ks_\(@parameter))`)
		}
		else {
			ctrl
				.line(`req.push(\(@name))`)
				.step()
				.code('else')
				.step()
				.line(`req.push(\(@parameter))`)
		}

		ctrl.done()
	} // }}}
}

class ROEDynamicRequirement extends DynamicRequirement {
	constructor(data, @node) { // {{{
		super(data, DependencyKind::RequireOrExtern, node)
	} // }}}
	isAlien() => true
	toAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(\($runtime.type(@node)).isValue(\(@parameter)))`)
			.step()

		if @type.isFlexible() {
			ctrl
				.line(`req.push(\(@parameter), __ks_\(@parameter))`)
				.step()
				.code('else')
				.step()
				.line(`req.push(\(@name), typeof __ks_\(@name) === "undefined" ? {} : __ks_\(@name))`)
		}
		else {
			ctrl
				.line(`req.push(\(@parameter))`)
				.step()
				.code('else')
				.step()
				.line(`req.push(\(@name))`)
		}

		ctrl.done()
	} // }}}
}

class ROIDynamicRequirement extends DynamicRequirement {
	private {
		_importer
	}
	constructor(variable: Variable, importer) { // {{{
		super(variable, @importer = importer)

		variable.getDeclaredType().condense()
	} // }}}
	toAltFragments(fragments) => @importer.toAltFragments(fragments)
}