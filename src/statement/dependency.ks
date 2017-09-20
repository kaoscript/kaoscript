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
				const type = new ClassType(declaration.name.name, scope)
				const variable = scope.define(declaration.name.name, true, type, this)
				
				if declaration.extends? {
					if superVar !?= @scope.getVariable(declaration.extends.name) {
						ReferenceException.throwNotDefined(declaration.extends.name, this)
					}
					else if superVar.type() is not ClassType {
						TypeException.throwNotClass(declaration.extends.name, this)
					}
					
					type.extends(superVar.type())
				}
				
				if kind != DependencyKind::Extern {
					variable.require()
				}
				
				if	kind == DependencyKind::Extern ||
					kind == DependencyKind::ExternOrRequire ||
					kind == DependencyKind::RequireOrExtern
				{
					type.alienize()
				}
				
				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Abstract {
						type.abstract()
					}
					else if modifier.kind == ModifierKind::Sealed {
						type.seal()
					}
				}
				
				for member in declaration.members {
					type.addPropertyFromAST(member, this)
				}
				
				return variable
			}
			NodeKind::EnumDeclaration => {
				let kind = EnumKind::Number
				
				if declaration.type? {
					if Type.fromAST(declaration.type, this).isString() {
						kind = EnumKind::String
					}
				}
				
				const type = new EnumType(declaration.name.name, kind, scope)
				const variable = scope.define(declaration.name.name, true, type, this)
				
				if kind != DependencyKind::Extern {
					variable.require()
				}
				
				for member in declaration.members {
					type.addElement(member.name.name)
				}
				
				return variable
			}
			NodeKind::NamespaceDeclaration => {
				const type = new NamespaceType(declaration.name.name, scope)
				const variable = scope.define(declaration.name.name, true, type, this)
				
				if kind != DependencyKind::Extern {
					variable.require()
				}
				
				for modifier in declaration.modifiers {
					if modifier.kind == ModifierKind::Sealed {
						type.seal()
					}
				}
				
				for statement in declaration.statements {
					type.addPropertyFromAST(statement, this)
				}
				
				return variable
			}
			NodeKind::VariableDeclarator => {
				let type = Type.fromAST(declaration.type, this)
				
				let referenced = false
				
				if type is ReferenceType {
					if type.name() == 'Class' {
						type = new ClassType(declaration.name.name, scope)
					}
				}
				else if type is ClassType {
					referenced = true
				}
				
				if declaration.sealed {
					if type == Type.Any {
						type = new SealedReferenceType(this)
					}
					else if type is ReferenceType {
						type = new SealedReferenceType(type)
					}
					else {
						type.seal()
					}
				}
				
				if	type is ClassType &&
					(
						kind == DependencyKind::Extern ||
						kind == DependencyKind::ExternOrRequire ||
						kind == DependencyKind::RequireOrExtern
					)
				{
					type.alienize()
				}
				
				if referenced {
					type = type.reference()
				}
				
				const variable = scope.define(declaration.name.name, true, type, this)
				
				if kind != DependencyKind::Extern {
					variable.require()
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
		let variable
		if @parent.includePath() != null {
			for declaration in @data.declarations {
				if variable ?= @scope.getVariable(declaration.name.name) {
					// TODO: check & merge type
				}
				else {
					variable = this.define(declaration, DependencyKind::Extern)
					
					if variable.type().isSealed() && variable.type().isExtendable() {
						@lines.push(`var \(variable.type().sealName()) = {}`)
					}
				}
			}
		}
		else {
			for declaration in @data.declarations {
				variable = this.define(declaration, DependencyKind::Extern)
				
				if variable.type().isSealed() && variable.type().isExtendable() {
					@lines.push(`var \(variable.type().sealName()) = {}`)
				}
			}
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
		
		if @parent.includePath() != null {
			let variable
			for declaration in @data.declarations {
				if variable ?= @scope.getVariable(declaration.name.name) {
					// TODO: check & merge type
				}
				else {
					module.require(new StaticRequirement(declaration, this))
				}
			}
		}
		else {
			for declaration in @data.declarations {
				module.require(new StaticRequirement(declaration, this))
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
					module.require(new EORDynamicRequirement(declaration, this))
				}
			}
		}
		else {
			for declaration in @data.declarations {
				module.require(new EORDynamicRequirement(declaration, this))
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
					module.require(new ROEDynamicRequirement(declaration, this))
				}
			}
		}
		else {
			for declaration in @data.declarations {
				module.require(new ROEDynamicRequirement(declaration, this))
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
	prepare()
	translate()
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}

class RequireOrImportDeclarator extends Importer {
	analyse() { // {{{
		const module = this.module()
		
		this.resolve()
		
		if @count != 0 {
			if @parent.includePath() != null {
				let variable
				for :alias of @variables {
					if variable ?= @scope.getVariable(alias) {
						// TODO: check & merge type
					}
					else {
						module.require(new ROIDynamicRequirement(variable, this))
					}
				}
			}
			else {
				for :alias of @variables {
					module.require(new ROIDynamicRequirement(@scope.getVariable(alias), this))
				}
			}
		}
		
		if @alias != null {
			throw new NotImplementedException(this)
		}
	} // }}}
	prepare()
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
	constructor(variable: Variable) { // {{{
		@name = variable.name()
		@type = variable.type()
	} // }}}
	constructor(data, kind: DependencyKind, node) { // {{{
		this(node.define(data, kind))
	} // }}}
	abstract isRequired(): Boolean
	name() => @name
	toMetadata(metadata) { // {{{
		metadata.requirements.push(@type.toMetadata(metadata.references), @name, this.isRequired())
	} // }}}
	toNameFragments(fragments) { // {{{
		fragments.code(@name)
		
		if @type.isFlexible() {
			fragments.code(`, __ks_\(@name)`)
		}
	} // }}}
	type() => @type
}

class StaticRequirement extends Requirement {
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

abstract class DynamicRequirement extends Requirement {
	private {
		_parameter: String
	}
	constructor(variable: Variable, node) { // {{{
		super(variable)
		
		@parameter = node.module().scope().acquireTempName()
	} // }}}
	constructor(data, kind, node) { // {{{
		super(data, kind, node)
		
		@parameter = node.module().scope().acquireTempName()
	} // }}}
	isRequired() => false
	parameter() => @name
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
		
		variable.require()
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