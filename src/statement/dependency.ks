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

				for member in declaration.members {
					type.addPropertyFromAST(member, this)
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

				for member in declaration.members {
					type.addElement(member.name.name)
				}

				return variable
			}
			NodeKind::FunctionDeclaration => {
				let type
				if declaration.parameters? {
					const parameters = [Type.fromAST(parameter, this) for parameter in declaration.parameters]
					type = new FunctionType(parameters, declaration, this)
				}
				else {
					type = this.scope().reference('Function')
				}

				const variable = scope.define(declaration.name.name, true, type, this)

				if kind != DependencyKind::Extern {
					type.flagRequired()
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

				for statement in declaration.statements {
					type.addPropertyFromAST(statement, this)
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
		for declarator in @data.declarations {
			@declarators.push(declarator = new RequireOrImportDeclarator(declarator, this))

			declarator.analyse()
		}
	} // }}}
	prepare() { // {{{
		for declarator in @declarators {
			declarator.prepare()
		}
	} // }}}
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrImportDeclarator extends Importer {
	prepare() { // {{{
		super.prepare()

		const module = this.module()

		if @count != 0 {
			if @parent.includePath() != null {
				let variable
				for :alias of @variables {
					if variable ?= @scope.getVariable(alias) {
						// TODO: check & merge type
					}
					else {
						module.addRequirement(new ROIDynamicRequirement(variable, this))
					}
				}
			}
			else {
				for :alias of @variables {
					module.addRequirement(new ROIDynamicRequirement(@scope.getVariable(alias), this))
				}
			}
		}

		if @alias != null {
			throw new NotImplementedException(this)
		}
	} // }}}
	translate()
	metadata() => @metadata
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

class SeepedRequirement extends StaticRequirement {
	constructor(@name, @type) { // {{{
		super(name, type)
	} // }}}
	isRequired() => false
}

abstract class DynamicRequirement extends Requirement {
	private {
		_parameter: String
	}
	constructor(variable: Variable, node) { // {{{
		super(variable)

		@parameter = node.module().scope().acquireTempName(false)
	} // }}}
	constructor(data, kind, node) { // {{{
		super(data, kind, node)

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
	constructor(data, node) { // {{{
		super(data, DependencyKind::ExternOrRequire, node)
	} // }}}
	isAlien() => true
	toLoneAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(Type.isValue(\(@name)))`)
			.step()

		if @type.isFlexible() {
			ctrl
				.line(`return [\(@name), typeof __ks_\(@name) === "undefined" ? {} : __ks_\(@name)]`)
				.step()
				.code('else')
				.step()
				.line(`return [\(@parameter), __ks_\(@parameter)]`)
		}
		else {
			ctrl
				.line(`return [\(@name)]`)
				.step()
				.code('else')
				.step()
				.line(`return [\(@parameter)]`)
		}

		ctrl.done()
	} // }}}
	toManyAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(Type.isValue(\(@name)))`)
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
	constructor(data, node) { // {{{
		super(data, DependencyKind::RequireOrExtern, node)
	} // }}}
	isAlien() => true
	toLoneAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(Type.isValue(\(@parameter)))`)
			.step()

		if @type.isFlexible() {
			ctrl
				.line(`return [\(@parameter), __ks_\(@parameter)]`)
				.step()
				.code('else')
				.step()
				.line(`return [\(@name), typeof __ks_\(@name) === "undefined" ? {} : __ks_\(@name)]`)
		}
		else {
			ctrl
				.line(`return [\(@parameter)]`)
				.step()
				.code('else')
				.step()
				.line(`return [\(@name)]`)
		}

		ctrl.done()
	} // }}}
	toManyAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(Type.isValue(\(@parameter)))`)
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
	toLoneAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(Type.isValue(\(@parameter)))`)
			.step()

		if @type.isFlexible() {
			ctrl
				.line(`return [\(@parameter), __ks_\(@parameter)]`)
				.step()
				.code('else')
				.step()

			@importer.toImportFragments(ctrl)

			ctrl.line(`return [\(@name), __ks_\(@name)]`).done()
		}
		else {
			ctrl
				.line(`return [\(@parameter)]`)
				.step()
				.code('else')
				.step()

			@importer.toImportFragments(ctrl)

			ctrl.line(`return [\(@name)]`).done()
		}

		ctrl.done()
	} // }}}
	toManyAltFragments(fragments) { // {{{
		const ctrl = fragments
			.newControl()
			.code(`if(Type.isValue(\(@parameter)))`)
			.step()

		if @type.isFlexible() {
			ctrl
				.line(`req.push(\(@parameter), __ks_\(@parameter))`)
				.step()
				.code('else')
				.step()

			@importer.toImportFragments(ctrl)

			ctrl.line(`req.push(\(@name), __ks_\(@name))`).done()
		}
		else {
			ctrl
				.line(`req.push(\(@parameter))`)
				.step()
				.code('else')
				.step()

			@importer.toImportFragments(ctrl)

			ctrl.line(`req.push(\(@name))`).done()
		}

		ctrl.done()
	} // }}}
}