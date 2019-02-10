class ClassType extends Type {
	private {
		_abstract: Boolean			= false
		_abstractMethods: Object	= {}
		_alterationReference: ClassType
		_classMethods: Object		= {}
		_classVariables: Object		= {}
		_constructors: Array		= []
		_destructors: Number		= 0
		_extending: Boolean			= false
		_extends: NamedType<ClassType>
		_hybrid: Boolean			= false
		_init: Number				= 0
		_instanceMethods: Object	= {}
		_instanceVariables: Object	= {}
		_predefined: Boolean		= false
		_seal: Object
	}
	static {
		fromMetadata(data, references: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new ClassType(scope)

			type._abstract = data.abstract
			type._alien = data.alien
			type._hybrid = data.hybrid
			type._init = data.init

			if data.sealed {
				type.flagSealed()
			}

			if data.extends? {
				type.extends(Type.fromMetadata(data.extends, references, scope, node).discardReference())
			}

			for method in data.constructors {
				type.addConstructor(ClassConstructorType.fromMetadata(method, references, scope, node))
			}

			for name, vtype of data.instanceVariables {
				type.addInstanceVariable(name, ClassVariableType.fromMetadata(vtype, references, scope, node))
			}

			for name, vtype of data.classVariables {
				type.addClassVariable(name, ClassVariableType.fromMetadata(vtype, references, scope, node))
			}

			for name, methods of data.instanceMethods {
				for method in methods {
					type.addInstanceMethod(name, ClassMethodType.fromMetadata(method, references, scope, node))
				}
			}

			for name, methods of data.classMethods {
				for method in methods {
					type.addClassMethod(name, ClassMethodType.fromMetadata(method, references, scope, node))
				}
			}

			return type
		} // }}}
		import(data, references: Array, queue: Array, scope: AbstractScope, node: AbstractNode) { // {{{
			const type = new ClassType(scope)

			if data.class? {
				queue.push(() => {
					const source = references[data.class.reference]

					type.copyFrom(source.type())

					for name, vtype of data.instanceVariables {
						type.addInstanceVariable(name, ClassVariableType.fromMetadata(vtype, references, scope, node).flagAlteration())
					}

					for name, vtype of data.classVariables {
						type.addClassVariable(name, ClassVariableType.fromMetadata(vtype, references, scope, node).flagAlteration())
					}

					for name, methods of data.instanceMethods {
						for method in methods {
							type.addInstanceMethod(name, ClassMethodType.fromMetadata(method, references, scope, node).flagAlteration())
						}
					}

					for name, methods of data.classMethods {
						for method in methods {
							type.addClassMethod(name, ClassMethodType.fromMetadata(method, references, scope, node).flagAlteration())
						}
					}
				})
			}
			else {
				type._abstract = data.abstract
				type._alien = data.alien
				type._hybrid = data.hybrid
				type._init = data.init

				if data.sealed {
					type.flagSealed()
				}

				queue.push(() => {
					if data.extends? {
						type.extends(Type.fromMetadata(data.extends, references, scope, node).discardReference())
					}

					for method in data.constructors {
						type.addConstructor(ClassConstructorType.fromMetadata(method, references, scope, node))
					}

					for name, vtype of data.instanceVariables {
						type.addInstanceVariable(name, ClassVariableType.fromMetadata(vtype, references, scope, node))
					}

					for name, vtype of data.classVariables {
						type.addClassVariable(name, ClassVariableType.fromMetadata(vtype, references, scope, node))
					}

					for name, methods of data.instanceMethods {
						for method in methods {
							type.addInstanceMethod(name, ClassMethodType.fromMetadata(method, references, scope, node))
						}
					}

					for name, methods of data.classMethods {
						for method in methods {
							type.addClassMethod(name, ClassMethodType.fromMetadata(method, references, scope, node))
						}
					}
				})
			}

			return type
		} // }}}
	}
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
	clone() { // {{{
		const that = new ClassType(@scope)

		return that.copyFrom(this)
	} // }}}
	condense() { // {{{
		for :methods of this._abstractMethods {
			for method in methods {
				method.unflagAlteration()
			}
		}
		for :methods of this._classMethods {
			for method in methods {
				method.unflagAlteration()
			}
		}
		for :methods of this._instanceMethods {
			for method in methods {
				method.unflagAlteration()
			}
		}

		for :variable of this._classVariables {
			variable.unflagAlteration()
		}
		for :variable of this._instanceVariables {
			variable.unflagAlteration()
		}

		@alterationReference = null

		return this
	} // }}}
	copyFrom(src: ClassType) { // {{{
		@abstract = src._abstract
		@alien = src._alien
		@destructors = src._destructors
		@extending = src._extending
		@extends = src._extends
		@hybrid = src._hybrid
		@init = src._init
		@sealed = src._sealed

		for name, methods of src._abstractMethods {
			@abstractMethods[name] = [].concat(methods)
		}
		for name, methods of src._classMethods {
			@classMethods[name] = [].concat(methods)
		}
		for name, methods of src._instanceMethods {
			@instanceMethods[name] = [].concat(methods)
		}

		for name, variable of src._classVariables {
			@classVariables[name] = variable
		}
		for name, variable of src._instanceVariables {
			@instanceVariables[name] = variable
		}

		@constructors.concat(src._constructors)

		if src._sealed {
			@seal = Object.clone(src._seal)
		}

		if src.isRequired() || src.isAlien() {
			this.setAlterationReference(src)
		}

		return this
	} // }}}
	destructors() => @destructors
	equals(b?): Boolean { // {{{
		return this == b
	} // }}}
	export(references, ignoreAlteration) { // {{{
		if this.hasExportableAlteration() {
			const export = {
				type: TypeKind::Class
				class: @alterationReference.toAlterationReference()
				init: @init
				instanceVariables: {}
				classVariables: {}
				instanceMethods: {}
				classMethods: {}
			}

			for name, variable of @instanceVariables when variable.isAlteration() {
				export.instanceVariables[name] = variable.export(references, ignoreAlteration)
			}

			for name, variable of @classVariables when variable.isAlteration() {
				export.classVariables[name] = variable.export(references, ignoreAlteration)
			}

			for name, methods of @instanceMethods {
				const exportedMethods = [method.export(references, ignoreAlteration) for method in methods when method.isAlteration()]
				if exportedMethods.length > 0 {
					export.instanceMethods[name] = exportedMethods
				}
			}

			for name, methods of @classMethods {
				const exportedMethods = [method.export(references, ignoreAlteration) for method in methods when method.isAlteration()]
				if exportedMethods.length > 0 {
					export.classMethods[name] = exportedMethods
				}
			}

			return export
		}
		else {
			const export = {
				type: TypeKind::Class
				abstract: @abstract
				alien: @alien
				hybrid: @hybrid
				sealed: @sealed
				init: @init
				constructors: [constructor.export(references, ignoreAlteration) for constructor in @constructors]
				destructors: @destructors
				instanceVariables: {}
				classVariables: {}
				instanceMethods: {}
				classMethods: {}
			}

			for name, variable of @instanceVariables {
				export.instanceVariables[name] = variable.export(references, ignoreAlteration)
			}

			for name, variable of @classVariables {
				export.classVariables[name] = variable.export(references, ignoreAlteration)
			}

			for name, methods of @instanceMethods {
				export.instanceMethods[name] = [method.export(references, ignoreAlteration) for method in methods]
			}

			for name, methods of @classMethods {
				export.classMethods[name] = [method.export(references, ignoreAlteration) for method in methods]
			}

			if @abstract {
				export.abstractMethods = {}

				for name, methods of @abstractMethods {
					export.abstractMethods[name] = [method.export(references, ignoreAlteration) for method in methods]
				}
			}

			if @extending {
				export.extends = @extends.metaReference(references, ignoreAlteration)
			}

			return export
		}
	} // }}}
	flagAbstract() { // {{{
		@abstract = true
	} // }}}
	flagExported() { // {{{
		if @exported {
			return this
		}
		else {
			@exported = true
		}

		for method in @constructors {
			method.flagExported()
		}

		for :variable of @instanceVariables {
			variable.type().flagExported()
		}

		for :variable of @classVariables {
			variable.type().flagExported()
		}

		for :methods of @instanceMethods when methods is Array {
			for method in methods {
				method.flagExported()
			}
		}

		for :methods of @classMethods when methods is Array {
			for method in methods {
				method.flagExported()
			}
		}

		if @extending {
			@extends.flagExported()
		}

		return this
	} // }}}
	hasExportableAlteration() { // {{{
		if ?@alterationReference {
			return @alterationReference._referenceIndex != -1 || @alterationReference.hasExportableAlteration()
		}
		else {
			return false
		}
	} // }}}
	extends() => @extends
	extends(@extends) { // {{{
		@extending = true

		const type = @extends.type()

		if type.isAlien() || type.isHybrid() {
			@hybrid = true
		}
	} // }}}
	filterAbstractMethods(abstractMethods) { // {{{
		if @extending {
			@extends.type().filterAbstractMethods(abstractMethods)
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
	flagPredefined() { // {{{
		@predefined = true
	} // }}}
	flagSealed() { // {{{
		@sealed = true

		@seal = {
			constructors: false
			instanceMethods: {}
			classMethods: {}
		}

		return this
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
			return @extends.type().getAsbtractMethod(name, arguments)
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
			return @scope.reference('Function')
		}
		else {
			return @classVariables[name] ?? Type.Any
		}
	} // }}}
	getHierarchy(name) { // {{{
		if @extending {
			let class = this.extends()

			const hierarchy = [name, class.name()]

			while class.type().isExtending() {
				hierarchy.push((class = class.type().extends()).name())
			}

			return hierarchy
		}
		else {
			return [name]
		}
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
			return @extends.type().getInstanceMethod(name, arguments)
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
			return new ClassMethodSetType(@scope, @instanceMethods[name])
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
			return @extends.type().getInstanceVariable(name)
		}

		return null
	} // }}}
	getMissingAbstractMethods() { // {{{
		const abstractMethods = {}

		if @extending {
			@extends.type().filterAbstractMethods(abstractMethods)
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
			return @extends.type().getPropertyGetter(name)
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
			return @extends.type().getPropertySetter(name)
		}

		return null
	} // }}}
	hasClassMethod(name) { // {{{
		if @classMethods[name] is Array {
			return true
		}

		if @extending {
			return @extends.type().hasClassMethod(name)
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
			return @extends.type().hasClassVariable(name)
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
			return @extends.type().hasInstanceMethod(name)
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
			return @extends.type().hasInstanceVariable(name)
		}
		else {
			return false
		}
	} // }}}
	init() => @init
	init(@init) => this
	isAbstract() => @abstract
	isAlteration() => @alterationReference?
	isClass() => true
	isConstructor(name: String) => name == 'constructor'
	isDestructor(name: String) => name == 'destructor'
	isExtendable() => true
	isExtending() => @extending
	isFlexible() => @sealed
	isHybrid() => @hybrid
	isInstanceOf(target: ClassType) { // {{{
		if this.equals(target) {
			return true
		}
		else if @extending {
			return @extends.type().isInstanceOf(target)
		}
		else {
			return false
		}
	} // }}}
	isMergeable(type) => type.isClass()
	isPredefined() => @predefined
	matchArguments(arguments: Array<Type>) { // {{{
		if @constructors.length == 0 {
			if @extending {
				return @extends.type().matchArguments(arguments)
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
	matchClassMethod(name: String, type: ClassMethodType) { // {{{
		if @classMethods[name] is Array {
			for method, index in @classMethods[name] {
				if method.matchSignatureOf(type) {
					return index
				}
			}
		}

		if @extending {
			return @extends.type().matchClassMethod(name, type)
		}
		else {
			return null
		}
	} // }}}
	matchInstanceMethod(name: String, type: ClassMethodType) { // {{{
		if @instanceMethods[name] is Array {
			for method, index in @instanceMethods[name] {
				if method.matchSignatureOf(type) {
					return index
				}
			}
		}

		if @extending {
			return @extends.type().matchInstanceMethod(name, type)
		}
		else {
			return null
		}
	} // }}}
	matchSignatureOf(that) { // {{{
		if that is ClassType {
			if @sealed != that._sealed {
				return false
			}

			for name, variable of that._instanceVariables {
				if !@instanceVariables[name]?.matchSignatureOf(variable) {
					return false
				}
			}

			for name, variable of that._classVariables {
				if !@classVariables[name]?.matchSignatureOf(variable) {
					return false
				}
			}

			for name, methods of @instanceMethods {
				for method in methods {

				}
			}

			return true
		}

		return false
	} // }}}
	metaReference(references, name, ignoreAlteration) { // {{{
		if @predefined {
			return name
		}
		else {
			return [this.toMetadata(references, ignoreAlteration), name]
		}
	} // }}}
	setAlterationReference(@alterationReference)
	toAlterationReference() { // {{{
		if @referenceIndex != -1 {
			return {
				reference: @referenceIndex
			}
		}
		else if ?@alterationReference {
			return @alterationReference.toAlterationReference()
		}
		else {
			throw new NotImplementedException()
		}
	} // }}}
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

class ClassVariableType extends Type {
	private {
		_access: Accessibility	= Accessibility::Public
		_alteration: Boolean	= false
		_type: Type
	}
	static {
		fromAST(data, node: AbstractNode) { // {{{
			const scope = node.scope()

			let type: ClassVariableType

			if data.type? {
				if data.type.typeName? {
					if data.type.properties? {
						throw new NotImplementedException(node)
					}
					else {
						type = new ClassVariableType(scope, new ReferenceType(scope, data.type.typeName.name, data.type.nullable))
					}
				}
				else {
					throw new NotImplementedException(node)
				}
			}
			else {
				type = new ClassVariableType(scope, new ReferenceType(scope, 'Any'))
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
		fromMetadata(data, references, scope: AbstractScope, node: AbstractNode): ClassVariableType { // {{{
			const type = new ClassVariableType(scope, Type.fromMetadata(data.type, references, scope, node))

			type._access = data.access

			return type
		} // }}}
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	discardVariable() => @type
	equals(b?) { // {{{
		if b is ClassVariableType {
			return @type.equals(b.type())
		}
		else {
			return false
		}
	} // }}}
	access(@access) => this
	export(references, ignoreAlteration) => { // {{{
		access: @access
		type: @type.toReference(references, ignoreAlteration)
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
	matchSignatureOf(b: Type): Boolean { // {{{
		if b is ClassVariableType {
			return true
		}

		return false
	} // }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote() => @type.toQuote()
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
	type() => @type
	unflagAlteration() { // {{{
		@alteration = false
	} // }}}
}

class ClassMethodType extends FunctionType {
	private {
		_access: Accessibility	= Accessibility::Public
		_alteration: Boolean		= false
	}
	static {
		fromAST(data, node: AbstractNode) { // {{{
			const scope = node.scope()

			return new ClassMethodType([Type.fromAST(parameter, scope, false, node) for parameter in data.parameters], data, node)
		} // }}}
		fromMetadata(data, references, scope: AbstractScope, node: AbstractNode): ClassMethodType { // {{{
			const type = new ClassMethodType(scope)

			type._access = data.access
			type._async = data.async
			type._min = data.min
			type._max = data.max
			type._sealed = data.sealed
			type._throws = [Type.fromMetadata(throw, references, scope, node) for throw in data.throws]

			type._returnType = Type.fromMetadata(data.returns, references, scope, node)

			type._parameters = [ParameterType.fromMetadata(parameter, references, scope, node) for parameter in data.parameters]

			type.updateArguments()

			return type
		} // }}}
	}
	access(@access) => this
	export(references, ignoreAlteration) => { // {{{
		access: @access
		async: @async
		min: @min
		max: @max
		parameters: [parameter.export(references, ignoreAlteration) for parameter in @parameters]
		returns: @returnType.toReference(references, ignoreAlteration)
		sealed: @sealed
		throws: [throw.toReference(references, ignoreAlteration) for throw in @throws]
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
	isMatched(methods: Array<ClassMethodType>): Boolean { // {{{
		for method in methods {
			if method.matchSignatureOf(this) {
				return true
			}
		}

		return false
	} // }}}
	matchSignatureOf(b: ClassMethodType) { // {{{
		if @min != b._min || @max != b._max || @async != b._async || @parameters.length != b._parameters.length {
			return false
		}

		for parameter, i in @parameters {
			if !parameter.matchSignatureOf(b._parameters[i]) {
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
	unflagAlteration() { // {{{
		@alteration = false
	} // }}}
}

class ClassMethodSetType extends OverloadedFunctionType {
	constructor(@scope, @functions) { // {{{
		super(scope)

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
	static fromMetadata(data, references, scope: AbstractScope, node: AbstractNode): ClassConstructorType { // {{{
		const type = new ClassConstructorType(scope)

		type._access = data.access
		type._min = data.min
		type._max = data.max

		type._throws = [Type.fromMetadata(throw, references, scope, node) for throw in data.throws]
		type._parameters = [ParameterType.fromMetadata(parameter, references, scope, node) for parameter in data.parameters]

		type.updateArguments()

		return type
	} // }}}
	access(@access) => this
	export(references, ignoreAlteration) => { // {{{
		access: @access
		min: @min
		max: @max
		parameters: [parameter.export(references, ignoreAlteration) for parameter in @parameters]
		throws: [throw.toReference(references, ignoreAlteration) for throw in @throws]
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
	export(references, ignoreAlteration) => { // {{{
		access: @access
		throws: [throw.toReference(references, ignoreAlteration) for throw in @throws]
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