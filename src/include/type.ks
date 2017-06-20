const $natives = { // {{{
	Any: true
	any: true
	Array: true
	array: true
	Boolean: true
	bool: true
	Class: true
	class: true
	Enum: true
	enum: true
	Function: true
	func: true
	Number: true
	number: true
	Object: true
	object: true
	RegExp: true
	regex: true
	String: true
	string: true
	Void: true
	void: true
} // }}}

const $types = { // {{{
	any: 'Any'
	array: 'Array'
	bool: 'Boolean'
	class: 'Class'
	enum: 'Enum'
	func: 'Function'
	number: 'Number'
	object: 'Object'
	string: 'String'
} // }}}

enum Accessibility {
	Private = 1
	Protected
	Public
}

enum EnumKind {
	Flags
	Number
	String
}

abstract class Domain {
	abstract hasVariable(name: String): Boolean
	abstract getVariable(name: String): Type
	reference(name: String) => new ReferenceType(name, this)
}

class ScopeDomain extends Domain {
	private {
		_scope: AbstractScope
	}
	constructor(@scope)
	hasVariable(name: String) => @scope.hasVariable(name) || $natives[name] == true
	getVariable(name: String) { // {{{
		if variable ?= @scope.getVariable(name) {
			return variable.type()
		}
		else if $natives[name] == true {
			return @scope.reference(name)
		}
		else {
			return null
		}
	} // }}}
}

class ImportDomain extends Domain {
	private {
		_scope: AbstractScope
		_temporaries	= {}
		_types			= {}
	}
	constructor(metadata, node) { // {{{
		super()
		
		@scope = node.scope()
		
		for i from 0 til metadata.exports.length by 2 {
			if metadata.exports[i] == -1 {
				@temporaries[metadata.exports[i + 1]] = Type.Any
			}
			else {
				@temporaries[metadata.exports[i + 1]] = Type.import(metadata.exports[i + 1], metadata.references[metadata.exports[i]], metadata.references, this, node)
			}
		}
	} // }}}
	commit() { // {{{
		for name, type of @temporaries {
			@types[name] = @temporaries[name]
		}
		
		delete this._temporaries
	} // }}}
	commit(name: String) { // {{{
		@types[name] = @temporaries[name]
		
		return @types[name]
	} // }}}
	commit(tempName: String, name: String) { // {{{
		@types[name] = @temporaries[tempName]
		
		return @types[name]
	} // }}}
	hasTemporary(name: String) => @temporaries[name] is Type
	hasVariable(name: String) => @types[name] is Type || $natives[name] == true
	getVariable(name: String) { // {{{
		if @types[name] is Type {
			return @types[name]
		}
		else if $natives[name] == true {
			return @scope.reference(name)
		}
		else {
			return null
		}
	} // }}}
}

abstract class Type {
	private {
		_referenceIndex: Number	= -1
	}
	static {
		arrayOf(parameter: Type, scope: AbstractScope) => new ReferenceType('Array', false, [parameter], scope.domain())
		fromAST(data?, node: AbstractNode): Type => Type.fromAST(data, node.scope().domain(), true, node)
		fromAST(data?, domain: Domain, defined: Boolean, node: AbstractNode): Type { // {{{
			if !?data {
				return Type.Any
			}
			else if data is Type {
				return data:Type
			}
			
			switch data.kind {
				NodeKind::ClassDeclaration => {
					const type = new ClassType(data.name.name, domain)
					
					for modifier in data.modifiers {
						if modifier.kind == ModifierKind::Abstract {
							type._abstract = data.abstract
						}
						else if modifier.kind == ModifierKind::Sealed {
							type.seal()
						}
					}
					
					return type
				}
				NodeKind::FunctionDeclaration => {
					return new FunctionType([Type.fromAST(parameter, domain, defined, node) for parameter in data.parameters], data, node)
				}
				NodeKind::FunctionExpression => {
					return new FunctionType([Type.fromAST(parameter, domain, defined, node) for parameter in data.parameters], data, node)
				}
				NodeKind::Identifier => {
					if type ?= domain.getVariable(data.name) {
						return type
					}
					else {
						ReferenceException.throwNotDefined(data.name, node)
					}
				}
				NodeKind::MemberExpression => {
					const object = Type.fromAST(data.object, domain, defined, node)
					
					if object.isAny() {
						return Type.Any
					}
					else {
						return object.getProperty(data.property.name)
					}
				}
				NodeKind::Parameter => {
					const type = Type.fromAST(data.type, domain, defined, node)
					
					let min: Number = data.defaultValue? ? 0 : 1
					let max: Number = 1
					
					let nf = true
					for modifier in data.modifiers while nf {
						if modifier.kind == ModifierKind::Rest {
							if modifier.arity {
								min = modifier.arity.min
								max = modifier.arity.max
							}
							else {
								min = 0
								max = Infinity
							}
							
							nf = true
						}
					}
					
					return new ParameterType(type, min, max)
				}
				NodeKind::TypeReference => {
					if data.properties? {
						const scope = node.scope()
						const name = scope.getAnomynousClassName()
						
						const type = new ClassType(name, domain)
						const variable = scope.define(name, true, type, node)
						
						type.anonymize()
						
						let ref
						for property in data.properties {
							if property.type.kind == NodeKind::FunctionExpression {
								type.addInstanceMethod(property.name.name, new ClassMethodType([Type.fromAST(parameter, domain, defined, node) for parameter in property.type.parameters], property.type, node))
							}
							else if property.type.kind == NodeKind::TypeReference {
								ref = Type.fromAST(property.type, domain, defined, node)
								if ref.isAnonymous() {
									ref = ref.reference()
								}
								
								type.addInstanceVariable(property.name.name, new ClassVariableType(ref))
							}
							else {
								console.log(property)
								throw new NotImplementedException(node)
							}
						}
						
						return type
					}
					else if data.typeName? {
						if data.typeName.kind == NodeKind::Identifier {
							if !defined || domain.hasVariable(data.typeName.name) {
								const type = new ReferenceType(data.typeName.name, data.nullable, domain)
								
								if data.typeParameters? {
									for parameter in data.typeParameters {
										type._parameters.push(Type.fromAST(parameter, domain, defined, node))
									}
								}
								
								return type
							}
							else {
								ReferenceException.throwNotDefined(data.typeName.name, node)
							}
						}
						else if data.typeName.kind == NodeKind::MemberExpression && !data.typeName.computed {
							const type = new ReferenceType(data.typeName.property.name, data.nullable, domain)
							
							type.namespace(Type.fromAST(data.typeName.object, domain, defined, node).reference())
							
							if data.typeParameters? {
								for parameter in data.typeParameters {
									type._parameters.push(Type.fromAST(parameter, domain, defined, node))
								}
							}
							
							return type
						}
					}
				}
				NodeKind::UnionType => {
					return new UnionType([Type.fromAST(type, domain, defined, node) for type in data.types])
				}
				NodeKind::VariableDeclarator => {
					return Type.fromAST(data.type, domain, defined, node)
				}
			}
			
			console.log(data)
			throw new NotImplementedException(node)
		} // }}}
		import(...{4,4}args) { // {{{
			if args[2] is Domain {
				return Type.import(null, args[0], args[1], args[2], args[3])
			}
			else {
				return Type.import(args[0], args[1], args[2], args[3].scope().domain(), args[3])
			}
		} // }}}
		import(name: String?, data, references, domain: Domain, node: AbstractNode): Type { // {{{
			//console.log('-- import --')
			//console.log(name)
			//console.log(JSON.stringify(data, null, 2))
			
			if data is String {
				return data == 'Any' ? Type.Any : new ReferenceType(data, domain)
			}
			else if data is Array {
				if data[0] is Number {
					return Type.import(data[1], references[data[0]], references, domain, node)
				}
				else {
					return new UnionType([Type.import(null, type, references, domain, node) for type in data])
				}
			}
			else if data.constructors? {
				if name == null {
					throw new NotImplementedException(node)
				}
				else {
					const type = new ClassType(name, domain)
					
					if data.extends? {
						type.extends(Type.import(null, data.extends, references, domain, node), data.extends[1])
					}
					
					type._abstract = data.abstract
					type._alien = data.alien
					type._hybrid = data.hybrid
					
					if data.sealed {
						type.seal()
					}
					
					for method in data.constructors {
						type.addConstructor(ClassConstructorType.import(method, references, domain, node))
					}
					
					for name, vtype of data.instanceVariables {
						type.addInstanceVariable(name, ClassVariableType.import(vtype, references, domain, node))
					}
					
					for name, methods of data.instanceMethods {
						for method in methods {
							type.addInstanceMethod(name, ClassMethodType.import(method, references, domain, node))
						}
					}
					
					for name, methods of data.classMethods {
						for method in methods {
							type.addClassMethod(name, ClassMethodType.import(method, references, domain, node))
						}
					}
					
					return type
				}
			}
			else if data.parameters? {
				const type = new FunctionType()
				
				type._async = data.async
				type._min = data.min
				type._max = data.max
				type._throws = [Type.import(null, throw, references, domain, node) for throw in data.throws]
				
				type._returnType = Type.import(null, data.returns, references, domain, node)
				
				type._parameters = [Type.import(null, parameter, references, domain, node) for parameter in data.parameters]
				
				type.updateArguments()
				
				return type
			}
			else if data.properties? {
				const type = new NamespaceType(name, domain)
				
				if data.sealed {
					type.seal()
				}
				
				for name, property of data.properties {
					type.addPropertyFromMetadata(name, property, references, domain, node)
				}
				
				return type
			}
			else if data.min? {
				return new ParameterType(Type.import(null, data.type, references, domain, node), data.min, data.max)
			}
			else if data.elements? {
				const type = new EnumType(name, data.kind, domain)
				
				type._elements = data.elements
				type._index = data.index
				
				return type
			}
			else if data.methods? {
				const scope = node.scope()
				const name = scope.getAnomynousClassName()
				
				const type = new ClassType(name, domain)
				
				scope.define(name, true, type, node)
				
				type.anonymize()
				
				for let name, variable of data.variables {
					type.addInstanceVariable(name, ClassVariableType.import(variable, references, domain, node))
				}
				
				for let name, methods of data.methods {
					for method in methods {
						type.addInstanceMethod(name, ClassMethodType.import(method, references, domain, node))
					}
				}
				
				return type
			}
			else if data.type? {
				return new AliasType(Type.import(null, data.type, references, domain, node))
			}
			else if data.name? {
				const type = new ReferenceType(data.name, data.nullable, domain)
				
				return type
			}
			else if data.functions? {
				const type = new OverloadedFunctionType()
				
				for function in data.functions {
					type.addFunction(Type.import(null, function, references, domain, node))
				}
				
				return type
			}
			else {
				console.log(data)
				throw new NotImplementedException(node)
			}
		} // }}}
	}
	abstract equals(b?): Boolean
	abstract export()
	abstract toQuote(): String
	abstract toFragments(fragments, node)
	abstract toTestFragments(fragments, node)
	alienize() => this
	dereference(): Type? => this
	isAny() => false
	isAnonymous() => false
	isArray() => false
	isContainedIn(types) { // {{{
		for type in types {
			if this.equals(type) {
				return true
			}
		}
		
		return false
	} // }}}
	isExtendable() => false
	isFlexible() => false
	isFunction() => false
	isNumber() => false
	isObject() => false
	isSealed() => false
	isString() => false
	matchArgument(argument: Type) => this.equals(argument)
	metaReference(name) => [@referenceIndex, name]
	toMetadata(references) { // {{{
		if @referenceIndex == -1 {
			this.toReference(references)
			
			@referenceIndex = references.length - 1
		}
		
		return @referenceIndex
	} // }}}
	toReference(references) { // {{{
		references.push(this.export())
	} // }}}
	unalias(): Type => this
}

class AliasType extends Type {
	private {
		_type: Type
	}
	constructor(@type)
	dereference(): Type? => @type.unalias()
	equals(b?): Boolean { // {{{
		throw new NotImplementedException()
	} // }}}
	export() { // {{{
		return {
			type: @type.export()
		}
	} // }}}
	type() => @type
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote(): String { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		@type.toTestFragments(fragments, node)
	} // }}}
	unalias(): Type => @type.unalias()
}

class AnyType extends Type {
	equals(b?): Boolean => b is AnyType
	export() => 'Any'
	getProperty(name) => Type.Any
	hashCode() => 'Any'
	isAny() => true
	isInstanceOf(target: Type) => true
	isNullable() => false
	match(b: Type) => true
	merge(type: Type, node) { // {{{
		if !type.isAny() {
			throw new NotSupportedException(node)
		}
	} // }}}
	parameter() => Type.Any
	toFragments(fragments, node) { // {{{
		fragments.code('Any')
	} // }}}
	toMetadata(references) => -1
	toQuote(): String => `'Any'`
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
}

class ClassType extends Type {
	private {
		_abstract: Boolean			= false
		_abstractMethods: Object	= {}
		_alien: Boolean				= false
		_anonymous: Boolean			= false
		_classMethods: Object		= {}
		_classVariables: Object		= {}
		_constructors: Array		= []
		_destructors: Number		= 0
		_domain: Domain
		_extending: Boolean			= false
		_extends: ClassType
		_hybrid: Boolean			= false
		_instanceMethods: Object	= {}
		_instanceVariables: Object	= {}
		_name: String
		_namespace: ReferenceType
		_parentName: String
		_seal
		_sealed: Boolean			= false
	}
	constructor(@name, @domain)
	constructor(@name, scope: AbstractScope) { // {{{
		this(name, scope.domain())
	} // }}}
	abstract() { // {{{
		@abstract = true
	} // }}}
	addAbstractMethod(name: String, type: ClassMethodType): Number { // {{{
		let index: Number = 0
		
		if @abstractMethods[name] is Array {
			index = @abstractMethods[name].length
			
			@abstractMethods[name].push(type)
		}
		else {
			@abstractMethods[name] = [type]
		}
		
		return index
	} // }}}
	addClassMethod(name: String, type: ClassMethodType): Number { // {{{
		let index: Number = 0
		
		if @classMethods[name] is Array {
			index = @classMethods[name].length
			
			@classMethods[name].push(type)
		}
		else {
			@classMethods[name] = [type]
		}
		
		if type.isSealed() {
			@seal.classMethods[name] = true
		}
		
		return index
	} // }}}
	addClassVariable(name: String, type: ClassVariableType) { // {{{
		@classVariables[name] = type
	} // }}}
	addConstructor(type: ClassConstructorType) { // {{{
		@constructors.push(type)
	} // }}}
	addDestructor() { // {{{
		@destructors++
	} // }}}
	addInstanceMethod(name: String, type: ClassMethodType): Number { // {{{
		let index: Number = 0
		
		if @instanceMethods[name] is Array {
			index = @instanceMethods[name].length
			
			@instanceMethods[name].push(type)
		}
		else {
			@instanceMethods[name] = [type]
		}
		
		if type.isSealed() {
			@seal.instanceMethods[name] = true
		}
		
		return index
	} // }}}
	addInstanceVariable(name: String, type: ClassVariableType) { // {{{
		@instanceVariables[name] = type
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		switch(data.kind) {
			NodeKind::FieldDeclaration => {
				throw new NotImplementedException(node)
			}
			NodeKind::MethodDeclaration => {
				if this.isConstructor(data.name.name) {
					throw new NotImplementedException(node)
				}
				else if this.isDestructor(data.name.name) {
					throw new NotImplementedException(node)
				}
				else {
					let instance = true
					for i from 0 til data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == ModifierKind::Static
					}
					
					const type = ClassMethodType.fromAST(data, node)
					
					if instance {
						this.addInstanceMethod(data.name.name, type)
					}
					else {
						this.addClassMethod(data.name.name, type)
					}
				}
			}
			=> {
				throw new NotSupportedException(`Unexpected kind \(data.kind)`, node)
			}
		}
	} // }}}
	alienize() { // {{{
		@alien = true
		
		return this
	} // }}}
	anonymize() { // {{{
		@anonymous = true
	} // }}}
	destructors() => @destructors
	equals(b?): Boolean { // {{{
		if b is ReferenceType || b is ClassType {
			return b.name() == @name
		}
		else {
			return false
		}
	} // }}}
	export() { // {{{
		if @anonymous {
			const export = {
				alien: @alien
				sealed: @sealed
				variables: {}
				methods: {}
			}
			
			for name, variable of @instanceVariables {
				export.variables[name] = variable.export()
			}
			
			for name, methods of @instanceMethods {
				export.methods[name] = [method.export() for method in methods]
			}
			
			return export
		}
		else {
			const export = {
				abstract: @abstract
				alien: @alien
				hybrid: @hybrid
				sealed: @sealed
				constructors: [constructor.export() for constructor in @constructors]
				destructors: @destructors
				instanceVariables: {}
				classVariables: {}
				instanceMethods: {}
				classMethods: {}
			}
			
			for name, variable of @instanceVariables {
				export.instanceVariables[name] = variable.export()
			}
			
			for name, variable of @classVariables {
				export.classVariables[name] = variable.export()
			}
			
			for name, methods of @instanceMethods {
				export.instanceMethods[name] = [method.export() for method in methods]
			}
			
			for name, methods of @classMethods {
				export.classMethods[name] = [method.export() for method in methods]
			}
			
			if @abstract {
				export.abstractMethods = {}
				
				for name, methods of @abstractMethods {
					export.abstractMethods[name] = [method.export() for method in methods]
				}
			}
			
			if @extending {
				export.extends = @extends.metaReference(@parentName)
			}
			
			return export
		}
	} // }}}
	extends() => @extends
	extends(@extends, @parentName = extends.name()) { // {{{
		@extending = true
		
		if @extends.isAlien() || @extends.isHybrid() {
			@hybrid = true
		}
	} // }}}
	filterAbstractMethods(abstractMethods) { // {{{
		if @extending {
			@extends.filterAbstractMethods(abstractMethods)
		}
		
		if @abstract {
			for name, methods of @abstractMethods {
				if abstractMethods[name] is not Array {
					abstractMethods[name] = []
				}
				
				abstractMethods[name]:Array.append(methods)
			}
		}
		
		let method, index
		for name, methods of abstractMethods when @instanceMethods[name] is Array {
			for method, index in methods desc {
				if method.isMatched(@instanceMethods[name]) {
					methods.splice(index, 1)
				}
			}
			
			if methods.length == 0 {
				delete abstractMethods[name]
			}
		}
	} // }}}
	getAsbtractMethod(name: String, arguments: Array) { // {{{
		if @abstractMethods[name] is Array {
			for method in @abstractMethods[name] {
				if method.matchArguments(arguments) {
					return method
				}
			}
		}
		
		if @extending {
			return @extends.getAsbtractMethod(name, arguments)
		}
		else {
			return null
		}
	} // }}}
	getClassMethods(name: String) { // {{{
		if @classMethods[name] is Array {
			return @classMethods[name]
		}
		
		return null
	} // }}}
	getClassProperty(name: String): Type { // {{{
		if @classMethods[name] is Array {
			return @domain.reference('Function')
		}
		else {
			return @classVariables[name] ?? Type.Any
		}
	} // }}}
	getHierarchy() { // {{{
		const hierarchy = [@name]
		
		let class = this
		while(class.isExtending()) {
			hierarchy.push((class = class.extends()).name())
		}
		
		return hierarchy
	} // }}}
	getInstanceMethod(name: String, arguments: Array) { // {{{
		if @instanceMethods[name] is Array {
			for method in @instanceMethods[name] {
				if method.matchArguments(arguments) {
					return method
				}
			}
		}
		
		if @extending {
			return @extends.getInstanceMethod(name, arguments)
		}
		else {
			return null
		}
	} // }}}
	getInstanceMethods(name: String) { // {{{
		if @instanceMethods[name] is Array {
			return @instanceMethods[name]
		}
		
		return null
	} // }}}
	getInstanceProperty(name: String): Type { // {{{
		if @instanceMethods[name] is Array {
			return new ClassMethodSetType(@instanceMethods[name])
		}
		else if @instanceVariables[name] is ClassVariableType {
			return @instanceVariables[name]
		}
		else {
			return Type.Any
		}
	} // }}}
	getInstanceVariable(name: String) { // {{{
		if @instanceVariables[name]? {
			return @instanceVariables[name]
		}
		else if @extending {
			return @extends.getInstanceVariable(name)
		}
		
		return null
	} // }}}
	getMissingAbstractMethods() { // {{{
		const abstractMethods = {}
		
		if @extending {
			@extends.filterAbstractMethods(abstractMethods)
		}
		
		let method, index
		for name, methods of abstractMethods when @instanceMethods[name] is Array {
			for method, index in methods desc {
				if method.isMatched(@instanceMethods[name]) {
					methods.splice(index, 1)
				}
			}
			
			if methods.length == 0 {
				delete abstractMethods[name]
			}
		}
		
		return Object.keys(abstractMethods)
	} // }}}
	getProperty(name: String) => this.getClassProperty(name)
	getPropertyGetter(name: String) { // {{{
		if @instanceMethods[name] is Array {
			for method in @instanceMethods[name] {
				if method.min() == 0 && method.max() == 0 {
					return method.returnType()
				}
			}
		}
		else if @extending {
			return @extends.getPropertyGetter(name)
		}
		
		return null
	} // }}}
	getPropertySetter(name: String) { // {{{
		if @instanceMethods[name] is Array {
			for method in @instanceMethods[name] {
				if method.min() == 1 && method.max() == 1 {
					return method.parameter(0).type()
				}
			}
		}
		else if @extending {
			return @extends.getPropertySetter(name)
		}
		
		return null
	} // }}}
	getSealedPath(): String { // {{{
		if @namespace? {
			return `\(@namespace.path()).\(@seal.name)`
		}
		else {
			return @seal.name
		}
	} // }}}
	hasClassMethod(name) { // {{{
		if @classMethods[name] is Array {
			return true
		}
		
		if @extending {
			return @extends.hasClassMethod(name)
		}
		else {
			return false
		}
	} // }}}
	hasClassVariable(name) { // {{{
		if @classVariables[name] is ClassVariableType {
			return true
		}
		
		if @extending {
			return @extends.hasClassVariable(name)
		}
		else {
			return false
		}
	} // }}}
	hasConstructors() => @constructors.length != 0
	hasDestructors() => @destructors != 0
	hasInstanceMethod(name) { // {{{
		if @instanceMethods[name] is Array {
			return true
		}
		
		if @extending {
			return @extends.hasInstanceMethod(name)
		}
		else {
			return false
		}
	} // }}}
	hasInstanceVariable(name) { // {{{
		if @instanceVariables[name] is ClassVariableType {
			return true
		}
		
		if @extending {
			return @extends.hasInstanceVariable(name)
		}
		else {
			return false
		}
	} // }}}
	isAbstract() => @abstract
	isAlien() => @alien
	isAnonymous() => @anonymous
	isConstructor(name: String) => name == 'constructor'
	isDestructor(name: String) => name == 'destructor'
	isExtendable() => !@anonymous
	isExtending() => @extending
	isFlexible() => true
	isHybrid() => @hybrid
	isInstanceOf(target: ClassType) { // {{{
		if this.equals(target) {
			return true
		}
		else if @extending {
			return @extends.isInstanceOf(target)
		}
		else {
			return false
		}
	} // }}}
	isSealed() => @sealed
	isSealedAlien() => @alien && @sealed
	match(b): Boolean { // {{{
		if @name == b.name() {
			return true
		}
		else if b.isExtending() {
			return this.match(b.extends())
		}
		else {
			return false
		}
	} // }}}
	matchArguments(arguments: Array<Type>) { // {{{
		if @constructors.length == 0 {
			if @extending {
				return @extends.matchArguments(arguments)
			}
			else {
				return @alien || arguments.length == 0
			}
		}
		else {
			for constructor in @constructors {
				if constructor.matchArguments(arguments) {
					return true
				}
			}
			
			return false
		}
	} // }}}
	merge(type: Type, node) { // {{{
		if type is not ClassType {
			throw new NotSupportedException(node)
		}
		
		for constructor in type._constructors {
			this.addConstructor(constructor)
		}
		
		for name, methods of type._instanceMethods {
			for method in methods {
				this.addInstanceMethod(name, method)
			}
		}
		
		for name, methods of type._classMethods {
			for method in methods {
				this.addClassMethod(name, method)
			}
		}
	} // }}}
	name() => @name
	namespace() => @namespace
	namespace(@namespace) => this
	parentName() => @parentName
	toReference(references) { // {{{
		if @extending {
			@extends.toMetadata(references)
		}
		
		references.push(this.export())
	} // }}}
	reference() => new ReferenceType(this, @domain)
	seal() { // {{{
		@sealed = true
		
		@seal = {
			name: `__ks_\(@name)`
			constructors: false
			instanceMethods: {}
			classMethods: {}
		}
	} // }}}
	sealName() => @seal.name
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote(): String { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
}

class EnumType extends Type {
	private {
		_elements: Array	= []
		_index: Number		= -1
		_kind: EnumKind
		_name: String
		_type: Type
	}
	constructor(@name, @kind = EnumKind::Number, domain: Domain) { // {{{
		super()
		
		if @kind == EnumKind::String {
			@type = domain.reference('String')
		}
		else {
			@type = domain.reference('Number')
		}
	} // }}}
	addElement(name: String) { // {{{
		@elements.push(name)
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export() => { // {{{
		elements: @elements
		index: @index
		kind: @kind
	} // }}}
	getProperty(name: String) => null
	hasElement(name: String) { // {{{
		for element in @elements {
			if element == name {
				return true
			}
		}
		
		return false
	} // }}}
	index() => @index
	index(@index)
	kind() => @kind
	name() => @name
	step(): EnumType { // {{{
		@index++
		
		return this
	} // }}}
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	type() => @type
}

class FunctionType extends Type {
	private {
		_async: Boolean						= false
		_hasRest: Boolean					= false
		_index: Number
		_max: Number						= 0
		_maxBefore: Number					= 0
		_maxAfter: Number					= 0
		_min: Number						= 0
		_minBefore: Number					= 0
		_minAfter: Number					= 0
		_parameters: Array<ParameterType>	= []
		_restIndex: Number					= -1
		_returnType: Type
		_throws: Array<Type>				= []
	}
	constructor()
	constructor(parameters: Array<ParameterType>, data, node) { // {{{
		super()
		
		@returnType = Type.fromAST(data.type, node)
		
		let last: Type = null
		
		for parameter in parameters {
			if last == null || !parameter._type.equals(last._type) {
				if last != null {
					if last._max == Infinity {
						if @max == Infinity {
							SyntaxException.throwTooMuchRestParameter(node)
						}
						else {
							@max = Infinity
						}
					}
					else {
						@max += last._max
					}
					
					@min += last._min
				}
				
				@parameters.push(last = parameter.clone())
			}
			else {
				if parameter._max == Infinity {
					last._max = Infinity
				}
				else {
					last._max += parameter._max
				}
				
				last._min += parameter._min
			}
		}
		
		if last != null {
			if last._max == Infinity {
				if @max == Infinity {
					SyntaxException.throwTooMuchRestParameter(node)
				}
				else {
					@max = Infinity
				}
			}
			else {
				@max += last._max
			}
			
			@min += last._min
		}
		
		this.processModifiers(data.modifiers)
		
		if data.throws? {
			let type
			
			for throw in data.throws {
				if (type = Type.fromAST(throw, node)) is ClassType {
					@throws.push(type)
				}
				else {
					TypeException.throwNotClass(throw.name, node)
				}
			}
		}
		
		this.updateArguments()
	} // }}}
	absoluteMax() => @async ? @max + 1 : @max
	absoluteMin() => @async ? @min + 1 : @min
	async() { // {{{
		@async = true
	} // }}}
	equals(b?): Boolean { // {{{
		if b is ReferenceType {
			return b.name() == 'Function'
		}
		else if b is not FunctionType {
			return false
		}
		
		if @async != b._async || @hasRest != b._hasRest || @max != b._max || @min != b._min || @restIndex != b._restIndex || @parameters.length != b._parameters.length {
			return false
		}
		
		for parameter, index in @parameters {
			if !parameter.equals(b._parameters[index]) {
				return false
			}
		}
		
		return true
	} // }}}
	export() => { // {{{
		async: @async
		min: @min
		max: @max
		parameters: [parameter.export() for parameter in @parameters]
		returns: @returnType.export()
		throws: [throw.reference().export() for throw in @throws]
	} // }}}
	getProperty(name: String) => Type.Any
	index() => @index
	index(@index) => this
	isAsync() => @async
	isCatchingError(error): Boolean { // {{{
		for type in @throws {
			if type.match(error) {
				return true
			}
		}
		
		return false
	} // }}}
	isFunction() => true
	matchArguments(arguments: Array<Type>) { // {{{
		if arguments.length == 0 {
			return @min == 0
		}
		else if arguments[0] is ParameterType {
			if @parameters.length != arguments.length {
				return false
			}
			
			for parameter, i in @parameters {
				if !parameter.equals(arguments[i]) {
					return false
				}
			}
			
			return true
		}
		else {
			if !(@min <= arguments.length <= @max) {
				return false
			}
			
			if arguments.length == 0 {
				return true
			}
			else if @parameters.length == 1 {
				const parameter = @parameters[0]
				
				for argument in arguments {
					if !parameter.matchArgument(argument) {
						return false
					}
				}
				
				return true
			}
			else if @hasRest {
				let a = 0
				let b = arguments.length - 1
				
				for i from @parameters.length - 1 til @restIndex by -1 {
					parameter = @parameters[i]
					
					for j from 0 til parameter.min() {
						if !parameter.matchArgument(arguments[b]) {
							return false
						}
						
						--b
					}
				}
				
				let optional = @maxBefore - @minBefore
				
				for i from 0 til @restIndex {
					parameter = @parameters[i]
					
					for j from 0 til parameter.min() {
						if !parameter.matchArgument(arguments[a]) {
							return false
						}
						
						++a
					}
					
					for j from parameter.min() til parameter.max() while optional != 0 when parameter.matchArgument(arguments[a]) {
						++a
						--optional
					}
				}
				
				parameter = @parameters[@restIndex]
				for j from 0 til parameter.min() {
					if !parameter.matchArgument(arguments[a]) {
						return false
					}
					
					++a
				}
				
				return true
			}
			else if arguments.length == @parameters.length {
				for parameter, i in @parameters {
					if !parameter.matchArgument(arguments[i]) {
						return false
					}
				}
				
				return true
			}
			else if arguments.length == @max {
				let a = -1
				
				let p
				for parameter in @parameters {
					for p from 0 til parameter.max() {
						if !parameter.matchArgument(arguments[++a]) {
							return false
						}
					}
				}
				
				return true
			}
			else {
				let a = 0
				let optional = arguments.length - @min
				
				for parameter in @parameters {
					for i from 0 til parameter.min() {
						if !parameter.matchArgument(arguments[a]) {
							return false
						}
						
						++a
					}
					
					for i from parameter.min() til parameter.max() while optional > 0 when parameter.matchArgument(arguments[a]) {
						++a
						--optional
					}
				}
				
				return optional == 0
			}
		}
	} // }}}
	max() => @max
	min() => @min
	parameter(index) => @parameters[index]
	parameters() => @parameters
	private processModifiers(modifiers) { // {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				@async = true
			}
		}
	} // }}}
	returnType() => @returnType
	throws() => @throws
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote(): String { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	updateArguments() { // {{{
		for parameter, i in @parameters {
			if @hasRest {
				@minAfter += parameter.min()
				@maxAfter += parameter.max()
			}
			else if parameter.max() == Infinity {
				@restIndex = i
				@hasRest = true
			}
			else {
				@minBefore += parameter.min()
				@maxBefore += parameter.max()
			}
		}
	} // }}}
}

class NamespaceType extends Type {
	private {
		_domain: Domain
		_name: String
		_namespace: ReferenceType
		_properties: Object			= {}
		_sealed: Boolean			= false
		_sealName: String
		_sealProperties: Object		= {}
	}
	constructor(@name, @domain)
	constructor(@name, scope: AbstractScope) { // {{{
		this(name, scope.domain())
	} // }}}
	addProperty(name: String, type: Type) { // {{{
		@properties[name] = type
		
		if @sealed {
			@sealProperties[name] = true
			
			type.seal()
		}
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		let type
		if data.kind == NodeKind::VariableDeclarator {
			type = NamespaceVariableType.fromAST(data, node)
		}
		else if data.kind == NodeKind::FunctionDeclaration {
			type = NamespaceFunctionType.fromAST(data, node)
		}
		else {
			throw new NotSupportedException(node)
		}
		
		@properties[data.name.name] = type
		
		if type.isSealed() {
			@sealProperties[data.name.name] = true
		}
	} // }}}
	addPropertyFromMetadata(name, data, references, domain, node) { // {{{
		let type
		if data is String {
			type = NamespaceVariableType.import(data, references, domain, node)
		}
		else if data.parameters? {
			type = NamespaceFunctionType.import(data, references, domain, node)
		}
		else {
			type = NamespaceVariableType.import(data, references, domain, node)
		}
		
		@properties[name] = type
		
		if type.isSealed() {
			@sealProperties[name] = true
		}
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export() { // {{{
		const export = {
			sealed: @sealed
			properties: {}
		}
		
		for name, value of @properties {
			export.properties[name] = value.export()
		}
		
		return export
	} // }}}
	getProperty(name: String): Type => @properties[name] ?? null
	isExtendable() => true
	isFlexible() => @sealed
	isSealed() => @sealed
	isSealedProperty(name: String) => @sealed && @sealProperties[name] == true
	name() => @name
	namespace() => @namespace
	namespace(@namespace) => this
	reference() => new ReferenceType(this, @domain)
	seal() { // {{{
		@sealed = true
		
		@sealName = `__ks_\(@name)`
	} // }}}
	sealName() => @sealName
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
}

class OverloadedFunctionType extends Type {
	private {
		_async: Boolean						= false
		_functions: Array<FunctionType>		= []
	}
	addFunction(type: FunctionType) { // {{{
		@functions.push(type)
		
		if @functions.length == 1 {
			@async = type.isAsync()
		}
	} // }}}
	equals(b?) { // {{{
		throw new NotImplementedException()
	} // }}}
	export() => ({ // {{{
		functions: [function.export() for function in @functions]
	}) // }}}
	functions() => @functions
	hasFunction(type: FunctionType) { // {{{
		for function in @functions {
			if function.equals(type) {
				return true
			}
		}
		
		return false
	} // }}}
	isAsync() => @async
	isFunction() => true
	toQuote() { // {{{
		throw new NotImplementedException()
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
	toTestFragments(fragments, node) { // {{{
		throw new NotImplementedException()
	} // }}}
}

class ParameterType extends Type {
	private {
		_min: Number
		_max: Number
		_type: Type
	}
	constructor(@type, @min = 1, @max = 1)
	clone() => new ParameterType(@type, @min, @max)
	equals(b?): Boolean { // {{{
		if b is not ParameterType {
			return false
		}
		
		return @min == b.min() && @max == b.max() && @type.equals(b.type())
	} // }}}
	export() => { // {{{
		type: @type.export()
		min: @min
		max: @max
	} // }}}
	isAny() => @type.isAny()
	match(b: ParameterType): Boolean { // {{{
		if @min != b._min || @max != b._max {
			return false
		}
		
		return @type.match(b._type)
	} // }}}
	matchArgument(argument: Type) { // {{{
		if @type.isAny() || argument.isAny() {
			return true
		}
		
		//console.log(@type)
		//console.log(argument)
		
		return @type.matchArgument(argument)
	} // }}}
	max() => @max
	min() => @min
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote() => @type.toQuote()
	toTestFragments(fragments, node) { // {{{
		@type.toTestFragments(fragments, node)
	} // }}}
	type() => @type
}

class ReferenceType extends Type {
	private {
		_domain: Domain
		_name: String
		_namespace: ReferenceType
		_nullable: Boolean			= false
		_parameters: Array<Type>
	}
	constructor() { // {{{
		super()
		
		@name = 'Any'
		@parameters = []
	} // }}}
	constructor(type: Type, @domain) { // {{{
		super()
		
		@namespace = type.namespace()
		
		@name = type.name()
		@parameters = []
	} // }}}
	constructor(name: String, @nullable = false, @parameters = [], @domain) { // {{{
		super()
		
		@name = $types[name] ?? name
	} // }}}
	dereference(): Type? { // {{{
		if @name == 'Any' {
			return null
		}
		else if @namespace? {
			return @namespace.getProperty(@name)
		}
		else if (variable ?= @domain.getVariable(@name)) && (variable is not ReferenceType || variable.name() != @name || variable.domain() != @domain) {
			return variable.dereference()
		}
		else {
			return null
		}
	} // }}}
	domain() => @domain
	equals(b?): Boolean { // {{{
		if b is not ReferenceType {
			return b.equals(this)
		}
		
		if @name != b._name || @nullable != b._nullable || @parameters.length != b._parameters.length {
			return false
		}
		
		// TODO: test @parameters
		
		return true
	} // }}}
	export() { // {{{
		if (type ?= this.dereference()) && type is ClassType && type.isAnonymous() {
			return type.export()
		}
		else if @nullable {
			return {
				nullable: @nullable
				name: @name
			}
		}
		else {
			return @name
		}
	} // }}}
	getProperty(name: String): Type { // {{{
		if type ?= this.dereference() {
			if type is ClassType {
				return type.getInstanceProperty(name)
			}
			else {
				return type.getProperty(name)
			}
		}
		else {
			return Type.Any
		}
	} // }}}
	hashCode(): String { // {{{
		let hash = @name
		
		if @parameters.length != 0 {
			hash += '<'
			
			for parameter, i in @parameters {
				if i {
					hash += ','
				}
				
				hash += parameter.hashCode()
			}
			
			hash += '>'
		}
		
		if @nullable {
			hash += '?'
		}
		
		return hash
	} // }}}
	isAny() => @name == 'Any'
	isArray() => @name == 'Array'
	isInstanceOf(target: AnyType) => true
	isInstanceOf(target: ReferenceType) { // {{{
		if @name == target._name || target.isAny() {
			return true
		}
		
		if (thisClass ?= this.dereference()) && thisClass is ClassType && (targetClass ?= target.dereference()) && targetClass is ClassType {
			return thisClass.isInstanceOf(targetClass)
		}
		
		return false
	} // }}}
	isNullable() => @nullable
	isNumber() => @name == 'Number'
	isObject() => @name == 'Object'
	isString() => @name == 'String'
	match(b: Type): Boolean { // {{{
		if b.isAny() {
			return this.isAny()
		}
		else if @nullable == b._nullable {
			a = this.unalias()
			b = b.unalias()
			
			if a is ReferenceType {
				if b is ReferenceType {
					return a._name == b._name
				}
				else {
					return false
				}
			}
			else if a is ClassType && b is ClassType {
				return a.match(b)
			}
			else {
				return a == b
			}
		}
		else {
			return false
		}
	} // }}}
	matchArgument(argument: Type) { // {{{
		const a = this.unalias()
		const b = argument.unalias()
		
		if a is ReferenceType {
			if b is ReferenceType {
				return a._name == b._name
			}
			else {
				return false
			}
		}
		else if a is ClassType && b is ClassType {
			return a.match(b)
		}
		else if a is EnumType {
			return a.type().matchArgument(argument)
		}
		else {
			return a == b
		}
	} // }}}
	name() => @name
	namespace() => @namespace
	namespace(@namespace) => this
	parameter(index: Number = 0) { // {{{
		if index >= @parameters.length {
			return Type.Any
		}
		else {
			return @parameters[index]
		}
	} // }}}
	parameters() => @parameters
	path(): String { // {{{
		if @namespace? {
			return `\(@namespace.path()).\(@name)`
		}
		else {
			return @name
		}
	} // }}}
	reference() => this
	toFragments(fragments, node) { // {{{
		fragments.code(@name)
	} // }}}
	toQuote() => `'\(@name)'`
	toTestFragments(fragments, node) { // {{{
		if (variable ?= node.scope().getVariable(@name)) && variable.type() is AliasType {
			variable.type().toTestFragments(fragments, node)
		}
		else {
			if tof ?= $runtime.typeof(@name, node) {
				fragments.code(`\(tof)(`).compile(node)
			}
			else {
				fragments
					.code(`\($runtime.type(node)).is(`)
					.compile(node)
					.code(`, \(@name)`)
			}
			
			for parameter in @parameters {
				fragments.code($comma)
				
				parameter.toFragments(fragments, node)
			}
			
			fragments.code(')')
		}
	} // }}}
	unalias(): Type => this.dereference() ?? this
}

class UnionType extends Type {
	private {
		_types: Array<Type>
	}
	constructor() { // {{{
		super()
		
		@types = []
	} // }}}
	constructor(@types)
	addType(type: Type) { // {{{
		throw new NotImplementedException()
	} // }}}
	equals(b?): Boolean { // {{{
		if !?b || b is not UnionType || @types.length != b._types.length {
			return false
		}
		
		let match = 0
		for aType in @types {
			for bType in b._types {
				if aType.equals(bType) {
					match++
					break
				}
			}
		}
		
		return match == @types.length
	} // }}}
	export() => [type.export() for type in @types]
	isInstanceOf(target) { // {{{
		for type in @types {
			if type.isInstanceOf(target) {
				return true
			}
		}
		
		return false
	} // }}}
	isNullable() { // {{{
		for type in @types {
			if type.isNullable() {
				return true
			}
		}
		
		return false
	} // }}}
	matchArgument(argument: Type) { // {{{
		for type in @types {
			if type.matchArgument(argument) {
				return true
			}
		}
		
		return false
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toQuote(): String { // {{{
		const elements = [type.toQuote() for type in @types]
		const last = elements.pop()
		
		return `\(elements.join(', ')) or \(last)`
	} // }}}
	toTestFragments(fragments, node) { // {{{
		fragments.code('(')
		
		for type, i in @types {
			if i {
				fragments.code(' || ')
			}
			
			type.toTestFragments(fragments, node)
		}
		
		fragments.code(')')
	} // }}}
	types() => @types
}

class VoidType extends Type {
	equals(b?): Boolean => b is VoidType
	export() => 'Void'
	toFragments(fragments, node) { // {{{
		fragments.code('Void')
	} // }}}
	toQuote(): String => `'Void'`
	toTestFragments(fragments, node) { // {{{
		throw new NotSupportedException(node)
	} // }}}
}

class ClassVariableType extends ReferenceType {
	private {
		_access: Accessibility	= Accessibility::Public
	}
	static fromAST(data, node: AbstractNode) { // {{{
		const domain = node.scope().domain()
		
		let type: ClassVariableType
		
		if data.type? {
			if data.type.typeName? {
				if data.type.properties? {
					throw new NotImplementedException(node)
				}
				else {
					type = new ClassVariableType(data.type.typeName.name, data.type.nullable, domain)
				}
			}
			else {
				throw new NotImplementedException(node)
			}
		}
		else {
			type = new ClassVariableType('Any', domain)
		}
		
		if data.modifiers? {
			for modifier in data.modifiers {
				if modifier.kind == ModifierKind::Private {
					type.access(Accessibility::Private)
				}
				else if modifier.kind == ModifierKind::Protected {
					type.access(Accessibility::Protected)
				}
			}
		}
		
		return type
	} // }}}
	static import(data, references, domain: Domain, node: AbstractNode): ClassVariableType { // {{{
		let type
		if data.type == 'Any' {
			type = new ClassVariableType('Any', null, domain)
		}
		else {
			type = new ClassVariableType(Type.import(data.type, references, domain, node))
		}
		
		type._access = data.access
		
		return type
	} // }}}
	constructor(ref: ReferenceType) { // {{{
		super(ref._name, ref._nullable, ref._parameters, ref._domain)
	} // }}}
	constructor(@name, @nullable = null, @domain) { // {{{
		super(name, nullable, domain)
	} // }}}
	access(@access) => this
	export() => { // {{{
		access: @access
		type: super.export()
	} // }}}
	reference() => new ReferenceType(@name, @nullable, @parameters, @domain)
}

class ClassMethodType extends FunctionType {
	private {
		_access: Accessibility	= Accessibility::Public
		_sealed: Boolean		= false
	}
	static fromAST(data, node: AbstractNode) { // {{{
		const domain = node.scope().domain()
		
		return new ClassMethodType([Type.fromAST(parameter, domain, false, node) for parameter in data.parameters], data, node)
	} // }}}
	static import(data, references, domain: Domain, node: AbstractNode): ClassMethodType { // {{{
		const type = new ClassMethodType()
		
		type._access = data.access
		type._async = data.async
		type._min = data.min
		type._max = data.max
		type._sealed = data.sealed
		type._throws = [Type.import(throw, references, domain, node) for throw in data.throws]
		
		type._returnType = Type.import(data.returns, references, domain, node)
		
		type._parameters = [Type.import(parameter, references, domain, node) for parameter in data.parameters]
		
		type.updateArguments()
		
		return type
	} // }}}
	access(@access) => this
	export() => { // {{{
		access: @access
		async: @async
		min: @min
		max: @max
		parameters: [parameter.export() for parameter in @parameters]
		returns: @returnType.export()
		sealed: @sealed
		throws: [throw.reference().export() for throw in @throws]
	} // }}}
	isMatched(methods: Array<ClassMethodType>): Boolean { // {{{
		for method in methods {
			if method.match(this) {
				return true
			}
		}
		
		return false
	} // }}}
	isSealed() => @sealed
	match(b: ClassMethodType) { // {{{
		if @min != b._min || @max != b._max || @async != b._async || @parameters.length != b._parameters.length {
			return false
		}
		
		for parameter, i in @parameters {
			if !parameter.match(b._parameters[i]) {
				return false
			}
		}
		
		return true
	} // }}}
	private processModifiers(modifiers) { // {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				this.async()
			}
			else if modifier.kind == ModifierKind::Private {
				@access = Accessibility::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				@access = Accessibility::Protected
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true
			}
		}
	} // }}}
	returnType(@returnType)
	seal() { // {{{
		@sealed = true
	} // }}}
}

class ClassMethodSetType extends OverloadedFunctionType {
	constructor(@functions) { // {{{
		super()
		
		for function in functions {
			if function.isAsync() {
				@async = true
				break
			}
		}
	} // }}}
}

class ClassConstructorType extends FunctionType {
	private {
		_access: Accessibility	= Accessibility::Public
	}
	static import(data, references, domain: Domain, node: AbstractNode): ClassConstructorType { // {{{
		const type = new ClassConstructorType()
		
		type._access = data.access
		type._min = data.min
		type._max = data.max
		
		type._throws = [Type.import(throw, references, domain, node) for throw in data.throws]
		type._parameters = [Type.import(parameter, references, domain, node) for parameter in data.parameters]
		
		type.updateArguments()
		
		return type
	} // }}}
	access(@access) => this
	export() => { // {{{
		access: @access
		min: @min
		max: @max
		parameters: [parameter.export() for parameter in @parameters]
		throws: [throw.reference().export() for throw in @throws]
	} // }}}
	private processModifiers(modifiers) { // {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				throw new NotImplementedException()
			}
			else if modifier.kind == ModifierKind::Private {
				@access = Accessibility::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				@access = Accessibility::Protected
			}
		}
	} // }}}
}

class ClassDestructorType extends FunctionType {
	private {
		_access: Accessibility	= Accessibility::Public
	}
	constructor(data, node) { // {{{
		super([], data, node)
		
		@min = 1
		@max = 1
	} // }}}
	access(@access) => this
	export() => { // {{{
		access: @access
		throws: [throw.reference().export() for throw in @throws]
	} // }}}
	private processModifiers(modifiers) { // {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				throw new NotImplementedException()
			}
			else if modifier.kind == ModifierKind::Private {
				@access = Accessibility::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				@access = Accessibility::Protected
			}
		}
	} // }}}
}

class NamespaceVariableType extends ReferenceType {
	private {
		_sealed: Bololean	= false
	}
	static fromAST(data, node: AbstractNode) { // {{{
		const type = new NamespaceVariableType(Type.fromAST(data.type, node):ReferenceType)
		
		if data.modifiers? {
			for modifier in data.modifiers {
				if modifier.kind == ModifierKind::Sealed {
					type._sealed = true
				}
			}
		}
		
		return type
	} // }}}
	static import(data, references, domain: Domain, node: AbstractNode): NamespaceVariableType { // {{{
		const type = new NamespaceVariableType(Type.import(data.type, references, domain, node))
		
		if data.sealed == true {
			type._sealed = true
		}
		
		return type
	} // }}}
	constructor(ref: ReferenceType) { // {{{
		super(ref._name, ref._nullable, ref._parameters, ref._domain)
	} // }}}
	export() => { // {{{
		sealed: @sealed
		type: super.export()
	} // }}}
	isSealed() => @sealed
	reference() => new ReferenceType(@name, @nullable, @parameters, @domain)
	seal() { // {{{
		@sealed = true
	} // }}}
}

class NamespaceFunctionType extends FunctionType {
	private {
		_sealed: Boolean		= false
	}
	static fromAST(data, node: AbstractNode) { // {{{
		const domain = node.scope().domain()
		
		return type = new NamespaceFunctionType([Type.fromAST(parameter, domain, false, node) for parameter in data.parameters], data, node)
	} // }}}
	static import(data, references, domain: Domain, node: AbstractNode): NamespaceFunctionType { // {{{
		const type = new NamespaceFunctionType()
		
		type._async = data.async
		type._min = data.min
		type._max = data.max
		type._sealed = data.sealed
		type._throws = [Type.import(throw, references, domain, node) for throw in data.throws]
		
		type._returnType = Type.import(data.returns, references, domain, node)
		
		type._parameters = [Type.import(parameter, references, domain, node) for parameter in data.parameters]
		
		type.updateArguments()
		
		return type
	} // }}}
	export() => { // {{{
		async: @async
		min: @min
		max: @max
		parameters: [parameter.export() for parameter in @parameters]
		returns: @returnType.export()
		sealed: @sealed
		throws: [throw.reference().export() for throw in @throws]
	} // }}}
	isSealed() => @sealed
	private processModifiers(modifiers) { // {{{
		for modifier in modifiers {
			if modifier.kind == ModifierKind::Async {
				this.async()
			}
			else if modifier.kind == ModifierKind::Sealed {
				@sealed = true
			}
		}
	} // }}}
	seal() { // {{{
		@sealed = true
	} // }}}
}

class SealedReferenceType extends ReferenceType {
	constructor(ref: ReferenceType) { // {{{
		super(ref._name, ref._nullable, ref._parameters, ref._domain)
	} // }}}
	constructor(node: AbstractNode) { // {{{
		super('Any', node.scope().domain())
	} // }}}
	export() => { // {{{
		sealed: true
		type: super.export()
	} // }}}
	isSealed() => true
}

Type.Any = new AnyType()
Type.Void = new VoidType()

ParameterType.Any = new ParameterType(Type.Any)