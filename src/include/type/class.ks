enum Accessibility {
	Private = 1
	Protected
	Public
}

class ClassType extends Type {
	private {
		_abstract: Boolean				= false
		_abstractMethods: Object		= {}
		_alteration: Boolean			= false
		_alterationReference: ClassType
		_classAssessments: Object		= {}
		_classMethods: Object			= {}
		_classMethodNextId: Object		= {}
		_classVariables: Object			= {}
		_constructors: Array			= []
		_destructors: Number			= 0
		_exhaustiveness					= {
			constructor: null
			classMethods: {}
			instanceMethods: {}
		}
		_explicitlyExported: Boolean	= false
		_extending: Boolean				= false
		_extends: NamedType<ClassType>?	= null
		_hybrid: Boolean				= false
		_init: Number					= 0
		_instanceAssessments: Object	= {}
		_instanceMethods: Object		= {}
		_instanceMethodNextId: Object	= {}
		_instanceVariables: Object		= {}
		_predefined: Boolean			= false
		_seal: Object
	}
	static {
		fromMetadata(data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new ClassType(scope)

			type._abstract = data.abstract
			type._alien = data.alien
			type._hybrid = data.hybrid
			type._init = data.init

			type._exhaustive = data.exhaustive

			if data.exhaustive && data.exhaustiveness? {
				if data.exhaustive.constructor {
					type._exhaustiveness.constructor = true
				}

				if data.exhaustiveness.classMethods? {
					type._exhaustiveness.classMethods = data.exhaustiveness.classMethods
				}

				if data.exhaustiveness.instanceMethods? {
					type._exhaustiveness.instanceMethods = data.exhaustiveness.instanceMethods
				}
			}

			if data.sealed {
				type.flagSealed()
			}

			if data.extends? {
				type.extends(Type.fromMetadata(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
			}

			for method in data.constructors {
				type.addConstructor(ClassConstructorType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
			}

			for const vtype, name of data.instanceVariables {
				type.addInstanceVariable(name, ClassVariableType.fromMetadata(vtype, metadata, references, alterations, queue, scope, node))
			}

			for const vtype, name of data.classVariables {
				type.addClassVariable(name, ClassVariableType.fromMetadata(vtype, metadata, references, alterations, queue, scope, node))
			}

			for const methods, name of data.instanceMethods {
				for method in methods {
					type.dedupInstanceMethod(name, ClassMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
				}
			}

			for const methods, name of data.classMethods {
				for method in methods {
					type.dedupClassMethod(name, ClassMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
				}
			}

			return type
		} // }}}
		import(index, data, metadata, references: Array, alterations, queue: Array, scope: Scope, node: AbstractNode) { // {{{
			const type = new ClassType(scope)

			type._exhaustive = data.exhaustive

			if data.exhaustive && data.exhaustiveness? {
				if data.exhaustiveness.constructor {
					type._exhaustiveness.constructor = true
				}

				if data.exhaustiveness.classMethods? {
					type._exhaustiveness.classMethods = data.exhaustiveness.classMethods
				}

				if data.exhaustiveness.instanceMethods? {
					type._exhaustiveness.instanceMethods = data.exhaustiveness.instanceMethods
				}
			}

			if data.class? {
				alterations[data.class.reference] = index

				queue.push(() => {
					const source = references[data.class.reference]

					type.copyFrom(source.type())

					for const vtype, name of data.instanceVariables {
						type.addInstanceVariable(name, ClassVariableType.fromMetadata(vtype, metadata, references, alterations, queue, scope, node))
					}

					for const vtype, name of data.classVariables {
						type.addClassVariable(name, ClassVariableType.fromMetadata(vtype, metadata, references, alterations, queue, scope, node))
					}

					for const methods, name of data.instanceMethods {
						for method in methods {
							type.dedupInstanceMethod(name, ClassMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
						}
					}

					for const methods, name of data.classMethods {
						for method in methods {
							type.dedupClassMethod(name, ClassMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
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
						type.extends(Type.fromMetadata(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
					}

					for method in data.constructors {
						type.addConstructor(ClassConstructorType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
					}

					for const vtype, name of data.instanceVariables {
						type.addInstanceVariable(name, ClassVariableType.fromMetadata(vtype, metadata, references, alterations, queue, scope, node))
					}

					for const vtype, name of data.classVariables {
						type.addClassVariable(name, ClassVariableType.fromMetadata(vtype, metadata, references, alterations, queue, scope, node))
					}

					for const methods, name of data.instanceMethods {
						for method in methods {
							type.dedupInstanceMethod(name, ClassMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
						}
					}

					for const methods, name of data.classMethods {
						for method in methods {
							type.dedupClassMethod(name, ClassMethodType.fromMetadata(method, metadata, references, alterations, queue, scope, node))
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
	addClassMethod(name: String, type: ClassMethodType): Number? { // {{{
		if @classMethods[name] is not Array {
			@classMethods[name] = []
			@classMethodNextId[name] = 0
		}

		let id = type.id()
		if id == -1 {
			id = @classMethodNextId[name]++

			type.id(id)
		}
		else {
			if id >= @classMethodNextId[name] {
				@classMethodNextId[name] = id + 1
			}
		}

		@classMethods[name].push(type)

		if @alteration {
			type.flagAlteration()
		}

		if type.isSealed() {
			@seal.classMethods[name] = true
		}

		return id
	} // }}}
	addClassVariable(name: String, type: ClassVariableType) { // {{{
		@classVariables[name] = type

		if @alteration {
			type.flagAlteration()
		}
	} // }}}
	addConstructor(type: ClassConstructorType) { // {{{
		@constructors.push(type)
	} // }}}
	addDestructor() { // {{{
		@destructors++
	} // }}}
	addInstanceMethod(name: String, type: ClassMethodType): Number? { // {{{
		if @instanceMethods[name] is not Array {
			@instanceMethods[name] = []
			@instanceMethodNextId[name] = 0
		}

		let id = type.id()
		if id == -1 {
			id = @instanceMethodNextId[name]++

			type.id(id)
		}
		else {
			if id >= @instanceMethodNextId[name] {
				@instanceMethodNextId[name] = id + 1
			}
		}

		@instanceMethods[name].push(type)

		if @alteration {
			type.flagAlteration()
		}

		if type.isSealed() {
			@seal.instanceMethods[name] = true
		}

		return id
	} // }}}
	addInstanceVariable(name: String, type: ClassVariableType) { // {{{
		@instanceVariables[name] = type

		if @alteration {
			type.flagAlteration()
		}
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		const options = Attribute.configure(data, null, AttributeTarget::Property)

		switch data.kind {
			NodeKind::FieldDeclaration => {
				let instance = true
				for i from 0 til data.modifiers.length while instance {
					instance = false if data.modifiers[i].kind == ModifierKind::Static
				}

				const type = ClassVariableType.fromAST(data, node)

				if instance {
					this.addInstanceVariable(data.name.name, type)
				}
				else {
					this.addClassVariable(data.name.name, type)
				}
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

					if options.rules.nonExhaustive {
						if instance {
							@exhaustiveness.instanceMethods[data.name.name] = false
						}
						else {
							@exhaustiveness.classMethods[data.name.name] = false
						}
					}

					if instance {
						this.dedupInstanceMethod(data.name.name:String, type)
					}
					else {
						this.dedupClassMethod(data.name.name:String, type)
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
		for const methods of this._abstractMethods {
			for const method in methods {
				method.unflagAlteration()
			}
		}
		for const methods of this._classMethods {
			for const method in methods {
				method.unflagAlteration()
			}
		}
		for const methods of this._instanceMethods {
			for const method in methods {
				method.unflagAlteration()
			}
		}

		for const variable of this._classVariables {
			variable.unflagAlteration()
		}
		for const variable of this._instanceVariables {
			variable.unflagAlteration()
		}

		@alteration = false
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

		for const methods, name of src._abstractMethods {
			@abstractMethods[name] = [].concat(methods)
		}
		for const methods, name of src._classMethods {
			@classMethods[name] = [].concat(methods)
			@classMethodNextId[name] = src._classMethodNextId[name]
		}
		for const methods, name of src._instanceMethods {
			@instanceMethods[name] = [].concat(methods)
			@instanceMethodNextId[name] = src._instanceMethodNextId[name]
		}

		for const variable, name of src._classVariables {
			@classVariables[name] = variable
		}
		for const variable, name of src._instanceVariables {
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
	dedupClassMethod(name: String, type: ClassMethodType): Number? { // {{{
		if const id = type.id() {
			if @classMethods[name] is Array {
				for const method in @classMethods[name] {
					if method.id() == id {
						return id
					}
				}
			}
		}

		if const overwrite = type.overwrite() {
			const methods = @classMethods[name]

			for const id in overwrite {
				for const i from methods.length - 1 to 0 by -1 when methods[i].id() == id {
					methods.splice(i, 1)
					break
				}
			}

			type.overwrite(null)
		}

		return this.addClassMethod(name, type)
	} // }}}
	dedupInstanceMethod(name: String, type: ClassMethodType): Number? { // {{{
		if const id = type.id() {
			if @instanceMethods[name] is Array {
				for const method in @instanceMethods[name] {
					if method.id() == id {
						return id
					}
				}
			}
		}

		if const overwrite = type.overwrite() {
			const methods = @instanceMethods[name]

			for const id in overwrite {
				for const i from methods.length - 1 to 0 by -1 when methods[i].id() == id {
					methods.splice(i, 1)
					break
				}
			}

			type.overwrite(null)
		}

		return this.addInstanceMethod(name, type)
	} // }}}
	destructors() => @destructors
	export(references, mode) { // {{{
		const exhaustive = this.isExhaustive()

		let export

		if this.hasExportableAlteration() {
			export = {
				kind: TypeKind::Class
				class: @alterationReference.toAlterationReference(references, mode)
				exhaustive
				init: @init
				instanceVariables: {}
				classVariables: {}
				instanceMethods: {}
				classMethods: {}
			}

			for const variable, name of @instanceVariables when variable.isAlteration() {
				export.instanceVariables[name] = variable.export(references, mode)
			}

			for const variable, name of @classVariables when variable.isAlteration() {
				export.classVariables[name] = variable.export(references, mode)
			}

			for const methods, name of @instanceMethods {
				const exportedMethods = [method.export(references, mode) for method in methods when method.isAlteration()]
				if exportedMethods.length > 0 {
					export.instanceMethods[name] = exportedMethods
				}
			}

			for const methods, name of @classMethods {
				const exportedMethods = [method.export(references, mode) for method in methods when method.isAlteration()]
				if exportedMethods.length > 0 {
					export.classMethods[name] = exportedMethods
				}
			}
		}
		else {
			export = {
				kind: TypeKind::Class
				abstract: @abstract
				alien: @alien
				hybrid: @hybrid
				sealed: @sealed
				exhaustive
				init: @init
				constructors: [constructor.export(references, mode) for constructor in @constructors]
				destructors: @destructors
				instanceVariables: {}
				classVariables: {}
				instanceMethods: {}
				classMethods: {}
			}

			for const variable, name of @instanceVariables {
				export.instanceVariables[name] = variable.export(references, mode)
			}

			for const variable, name of @classVariables {
				export.classVariables[name] = variable.export(references, mode)
			}

			for const methods, name of @instanceMethods {
				const m = [method.export(references, mode) for const method in methods when method.isExportable()]

				if m.length != 0 {
					export.instanceMethods[name] = m
				}
			}

			for const methods, name of @classMethods {
				export.classMethods[name] = [method.export(references, mode) for method in methods]
			}

			if @abstract {
				export.abstractMethods = {}

				for const methods, name of @abstractMethods {
					export.abstractMethods[name] = [method.export(references, mode) for method in methods]
				}
			}

			if @extending {
				export.extends = @extends.metaReference(references, mode)
			}
		}

		if exhaustive {
			const exhaustiveness = {}
			let notEmpty = false

			if @exhaustiveness.constructor == false {
				exhaustiveness.constructor = false
				notEmpty = true
			}

			if !Object.isEmpty(@exhaustiveness.classMethods) {
				exhaustiveness.classMethods = @exhaustiveness.classMethods
				notEmpty = true
			}

			if !Object.isEmpty(@exhaustiveness.instanceMethods) {
				exhaustiveness.instanceMethods = @exhaustiveness.instanceMethods
				notEmpty = true
			}

			if notEmpty {
				export.exhaustiveness = exhaustiveness
			}
		}

		return export
	} // }}}
	flagAbstract() { // {{{
		@abstract = true
	} // }}}
	flagExported(explicitly: Boolean) { // {{{
		if @exported && (@explicitlyExported || !explicitly) {
			return this
		}

		@exported = true
		@explicitlyExported = explicitly

		for method in @constructors {
			method.flagExported(false)
		}

		for const variable of @instanceVariables {
			variable.type().flagExported(false)
		}

		for const variable of @classVariables {
			variable.type().flagExported(false)
		}

		for const methods of @instanceMethods when methods is Array {
			for method in methods {
				method.flagExported(false)
			}
		}

		for const methods of @classMethods when methods is Array {
			for method in methods {
				method.flagExported(false)
			}
		}

		if @extending {
			@extends.flagExported(explicitly)
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
			for const methods, name of @abstractMethods {
				if abstractMethods[name] is not Array {
					abstractMethods[name] = []
				}

				abstractMethods[name]:Array.append(methods)
			}
		}

		const matchables = []

		let method, index
		for const methods, name of abstractMethods when @instanceMethods[name] is Array {
			for method, index in methods desc {
				if method.isMatched(@instanceMethods[name], MatchingMode::Signature) {
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
	getAbstractMethod(name: String, arguments: Array) { // {{{
		if @abstractMethods[name] is Array {
			for method in @abstractMethods[name] {
				if method.matchArguments(arguments) {
					return method
				}
			}
		}

		if @extending {
			return @extends.type().getAbstractMethod(name, arguments)
		}
		else {
			return null
		}
	} // }}}
	getAbstractMethod(name: String, type: Type) { // {{{
		if @abstractMethods[name] is Array {
			for method in @abstractMethods[name] {
				if type.isMatching(method, MatchingMode::Signature) {
					return method
				}
			}
		}

		if @extending {
			return @extends.type().getAbstractMethod(name, type)
		}
		else {
			return null
		}
	} // }}}
	getClassAssessment(name: String) { // {{{
		if @classMethods[name] is not Array {
			if @extending {
				return @extends.type().getClassAssessment(name)
			}
			else {
				return null
			}
		}

		if @classAssessments[name] is not Object {
			const methods = [...@classMethods[name]]

			let that = this
			while that.isExtending() {
				that = that.extends().type()

				if const m = that.listClassMethods(name) {
					for const method in m {
						method.pushTo(methods)
					}
				}
			}

			@classAssessments[name] = Router.assess(methods, false)
		}

		return @classAssessments[name]
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
	getInstanceAssessment(name: String) { // {{{
		if @instanceMethods[name] is not Array {
			if @extending {
				return @extends.type().getInstanceAssessment(name)
			}
			else {
				return null
			}
		}

		if @instanceAssessments[name] is not Object {
			const methods = [...@instanceMethods[name]]

			let that = this
			while that.isExtending() {
				that = that.extends().type()

				if const m = that.listInstanceMethods(name) {
					for const method in m {
						method.pushTo(methods)
					}
				}
			}

			@instanceAssessments[name] = Router.assess(methods, false)
		}

		return @instanceAssessments[name]
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
	getInstanceProperty(name: String) { // {{{
		if @instanceMethods[name] is Array {
			if @instanceMethods[name].length == 1 {
				return @instanceMethods[name][0]
			}
			else {
				return new ClassMethodSetType(@scope, @instanceMethods[name])
			}
		}
		else if @instanceVariables[name] is ClassVariableType {
			return @instanceVariables[name]
		}
		else if @extending {
			return @extends.type().getInstanceProperty(name)
		}

		return null
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
	hasAbstractMethod(name) { // {{{
		if @abstractMethods[name] is Array {
			return true
		}

		if @extending {
			return @extends.type().hasAbstractMethod(name)
		}
		else {
			return false
		}
	} // }}}
	hasAbstractMethod(name: String, arguments: Array) { // {{{
		if @abstractMethods[name] is Array {
			for method in @abstractMethods[name] {
				if method.matchArguments(arguments) {
					return true
				}
			}
		}

		if @extending {
			return @extends.type().hasAbstractMethod(name, arguments)
		}
		else {
			return false
		}
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
	hasMatchingClassMethod(name, type: FunctionType, mode: MatchingMode) { // {{{
		if @classMethods[name] is Array {
			for const method in @classMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} // }}}
	hasMatchingConstructor(type: FunctionType, mode: MatchingMode) { // {{{
		if @constructors.length != 0 {
			for const constructor in @constructors {
				if constructor.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} // }}}
	hasMatchingInstanceMethod(name, type: FunctionType, mode: MatchingMode) { // {{{
		if @instanceMethods[name] is Array {
			for const method in @instanceMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		if @abstract && @abstractMethods[name] is Array {
			for const method in @abstractMethods[name] {
				if method.isMatching(type, mode) {
					return true
				}
			}
		}

		return false
	} // }}}
	init() => @init
	init(@init) => this
	isAbstract() => @abstract
	isAlteration() => @alteration
	isAsyncClassMethod(name) { // {{{
		if @classMethods[name] is Array {
			return @classMethods[name][0].isAsync()
		}
		else if @extending {
			return @extends.type().isAsyncClassMethod(name)
		}
		else {
			return null
		}
	} // }}}
	isAsyncInstanceMethod(name) { // {{{
		if @instanceMethods[name] is Array {
			return @instanceMethods[name][0].isAsync()
		}

		if @abstract && @abstractMethods[name] is Array {
			return @abstractMethods[name][0].isAsync()
		}

		if @extending {
			return @extends.type().isAsyncInstanceMethod(name)
		}

		return null
	} // }}}
	isClass() => true
	isConstructor(name: String) => name == 'constructor'
	isDestructor(name: String) => name == 'destructor'
	isExhaustive() { // {{{
		if @exhaustive {
			return true
		}

		if @alteration {
			return @alterationReference.isExhaustive()
		}

		if @extending {
			return @extends.isExhaustive()
		}
		else {
			return super.isExhaustive()
		}
	} // }}}
	isExhaustiveClassMethod(name) { // {{{
		if @exhaustiveness.classMethods[name] == false {
			return false
		}
		else if @extending {
			return @extends.type().isExhaustiveClassMethod(name)
		}
		else {
			return true
		}
	} // }}}
	isExhaustiveClassMethod(name, node) { // {{{
		if !this.isExhaustive(node) {
			return false
		}

		return this.isExhaustiveClassMethod(name)
	} // }}}
	isExhaustiveInstanceMethod(name) { // {{{
		if @exhaustiveness.instanceMethods[name] == false {
			return false
		}
		else if @extending {
			return @extends.type().isExhaustiveInstanceMethod(name)
		}
		else {
			return true
		}
	} // }}}
	isExhaustiveInstanceMethod(name, node) { // {{{
		if !this.isExhaustive(node) {
			return false
		}

		return this.isExhaustiveInstanceMethod(name)
	} // }}}
	isExplicitlyExported() => @explicitlyExported
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
	isMatching(value: ClassType, mode: MatchingMode) { // {{{
		if this == value {
			return true
		}
		if mode & MatchingMode::Exact != 0 {
			return false
		}

		for const variable, name of value._instanceVariables {
			if !@instanceVariables[name]?.isMatching(variable, mode) {
				return false
			}
		}

		for const variable, name of value._classVariables {
			if !@classVariables[name]?.isMatching(variable, mode) {
				return false
			}
		}

		for const methods, name of value._instanceMethods {
			if @instanceMethods[name] is not Array {
				return false
			}

			for method in methods {
				if !method.isMatched(@instanceMethods[name], MatchingMode::Signature) {
					return false
				}
			}
		}

		for const methods, name of value._classMethods {
			if @classMethods[name] is not Array {
				return false
			}

			for method in methods {
				if !method.isMatched(@classMethods[name], MatchingMode::Signature) {
					return false
				}
			}
		}

		return true
	} // }}}
	isMatching(value: NamedType, mode: MatchingMode) { // {{{
		return this.isMatching(value.type(), mode)
	} // }}}
	isMergeable(type) => type.isClass()
	isPredefined() => @predefined
	isSealable() => true
	listClassMethods(name: String) { // {{{
		if @classMethods[name] is Array {
			return @classMethods[name]
		}

		return null
	} // }}}
	listInstanceMethods(name: String) { // {{{
		if @instanceMethods[name] is Array {
			return @instanceMethods[name]
		}

		return null
	} // }}}
	listMatchingInstanceMethods(name, type: FunctionType, mode: MatchingMode) { // {{{
		const results: Array = []

		if @instanceMethods[name] is Array {
			for const method in @instanceMethods[name] {
				if method.isMatching(type, mode) {
					results.push(method)
				}
			}
		}

		if @abstract && @abstractMethods[name] is Array {
			for const method in @abstractMethods[name] {
				if method.isMatching(type, mode) {
					results.push(method)
				}
			}
		}

		return results
	} // }}}
	listMissingAbstractMethods() { // {{{
		unless @extending {
			return []
		}

		const abstractMethods = {}

		@extends.type().filterAbstractMethods(abstractMethods)

		const matchables = []

		let method, index
		for const methods, name of abstractMethods when @instanceMethods[name] is Array {
			for method, index in methods desc {
				if method.isMatched(@instanceMethods[name], MatchingMode::Signature) {
					methods.splice(index, 1)
				}
			}

			if methods.length == 0 {
				delete abstractMethods[name]
			}
		}

		return abstractMethods
	} // }}}
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
	matchInstanceWith(object: ObjectType, matchables) { // {{{
		for const property, name of object._properties {
			if @instanceVariables[name]?.isMatching(property, MatchingMode::Signature) {
			}
			else if @instanceMethods[name] is Array {
				let nf = true

				for method in @instanceMethods[name] while nf {
					if method.isMatching(property, MatchingMode::Signature) {
						nf = false
					}
				}

				if nf {
					return false
				}
			}
			else {
				return false
			}
		}

		return true
	} // }}}
	metaReference(references, name, mode) { // {{{
		if @predefined {
			return name
		}
		else {
			return [this.toMetadata(references, mode), name]
		}
	} // }}}
	overwriteInstanceMethod(name, type, methods) { // {{{
		@instanceMethods[name]:Array.remove(...methods)

		type.overwrite([method.id() for const method in methods])

		return this.addInstanceMethod(name, type)
	} // }}}
	parameter() => AnyType.NullableUnexplicit
	setAlterationReference(@alterationReference) { // {{{
		@alteration = true
	} // }}}
	toAlterationReference(references, mode) { // {{{
		if @referenceIndex != -1 {
			return {
				reference: @referenceIndex
			}
		}
		else if ?@alterationReference {
			return @alterationReference.toAlterationReference(references, mode)
		}
		else {
			return this.toReference(references, mode)
		}
	} // }}}
	toFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
	toReference(references, mode) { // {{{
		if @alteration && !@explicitlyExported {
			return @alterationReference.toReference(references, mode)
		}
		else {
			return super.toReference(references, mode)
		}
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
				type = new ClassVariableType(scope, Type.fromAST(data.type, node))
			}
			else {
				type = new ClassVariableType(scope, Type.Any)
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
		fromMetadata(data, metadata, references, alterations, queue, scope: Scope, node: AbstractNode): ClassVariableType { // {{{
			const type = new ClassVariableType(scope, Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node))

			type._access = data.access

			return type
		} // }}}
	}
	constructor(@scope, @type) { // {{{
		super(scope)
	} // }}}
	clone() { // {{{
		throw new NotSupportedException()
	} // }}}
	discardVariable() => @type
	access(@access) => this
	export(references, mode) => { // {{{
		access: @access
		type: @type.toReference(references, mode)
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	isAlteration() => @alteration
	isMatching(value: ClassVariableType, mode: MatchingMode) { // {{{
		if mode & MatchingMode::Exact != 0 {
			return @type.isMatching(value.type(), MatchingMode::Exact)
		}
		else {
			return true
		}
	} // }}}
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote(...args) => @type.toQuote(...args)
	toTestFragments(fragments, node) => @type.toTestFragments(fragments, node)
	type() => @type
	unflagAlteration() { // {{{
		@alteration = false
	} // }}}
}

class ClassMethodType extends FunctionType {
	private {
		_access: Accessibility	= Accessibility::Public
		_alteration: Boolean	= false
		_id: Number				= -1
		_overwrite: Array?		 = null
	}
	static {
		fromAST(data, node: AbstractNode): ClassMethodType { // {{{
			const scope = node.scope()

			return new ClassMethodType([Type.fromAST(parameter, scope, false, node) for parameter in data.parameters]!!, data, node)
		} // }}}
		fromMetadata(data, metadata, references, alterations, queue: Array, scope: Scope, node: AbstractNode): ClassMethodType { // {{{
			const type = new ClassMethodType(scope)

			type._id = data.id
			type._access = data.access
			type._async = data.async
			type._min = data.min
			type._max = data.max
			type._sealed = data.sealed
			type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]

			type._returnType = Type.fromMetadata(data.returns, metadata, references, alterations, queue, scope, node)

			type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

			if data.overwrite? {
				type._overwrite = data.overwrite
			}

			type.updateArguments()

			return type
		} // }}}
	}
	access(@access) => this
	export(references, mode) { // {{{
		const export = {
			id: @id
			access: @access
			async: @async
			min: @min
			max: @max
			parameters: [parameter.export(references, mode) for parameter in @parameters]
			returns: @returnType.toReference(references, mode)
			sealed: @sealed
			throws: [throw.toReference(references, mode) for throw in @throws]
		}

		if @overwrite != null {
			export.overwrite = @overwrite
		}

		return export
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	id() => @id
	id(@id)
	isAlteration() => @alteration
	isMatched(methods: Array<ClassMethodType>, mode: MatchingMode): Boolean { // {{{
		for const method in methods {
			if method.isMatching(this, mode) {
				return true
			}
		}

		return false
	} // }}}
	isMethod() => true
	isOverflowing(methods: Array<ClassMethodType>) { // {{{
		const mode = MatchingMode::SimilarParameters | MatchingMode::MissingParameters | MatchingMode::ShiftableParameters | MatchingMode::RequireAllParameters

		for const method in methods {
			if this.isMatching(method, mode) {
				return false
			}
		}

		return true
	} // }}}
	isSealable() => true
	overwrite() => @overwrite
	overwrite(@overwrite)
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
	isMethod() => true
}

class ClassConstructorType extends FunctionType {
	private {
		_access: Accessibility	= Accessibility::Public
	}
	static fromMetadata(data, metadata, references, alterations, queue, scope: Scope, node: AbstractNode): ClassConstructorType { // {{{
		const type = new ClassConstructorType(scope)

		type._access = data.access
		type._min = data.min
		type._max = data.max

		type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]
		type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

		type.updateArguments()

		return type
	} // }}}
	access(@access) => this
	export(references, mode) => { // {{{
		access: @access
		min: @min
		max: @max
		parameters: [parameter.export(references, mode) for parameter in @parameters]
		throws: [throw.toReference(references, mode) for throw in @throws]
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
	export(references, mode) => { // {{{
		access: @access
		throws: [throw.toReference(references, mode) for throw in @throws]
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