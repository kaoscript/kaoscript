enum Accessibility {
	Internal = 1
	Private
	Protected
	Public
}

class ClassType extends Type {
	private {
		_abstract: Boolean					= false
		_abstractMethods: Dictionary		= {}
		_alteration: Boolean				= false
		_alterationReference: ClassType?
		_classAssessments: Dictionary		= {}
		_classMethods: Dictionary			= {}
		_classVariables: Dictionary			= {}
		_constructors: Array				= []
		_destructors: Number				= 0
		_exhaustiveness						= {
			constructor: null
			classMethods: {}
			instanceMethods: {}
		}
		_explicitlyExported: Boolean		= false
		_extending: Boolean					= false
		_extends: NamedType<ClassType>?		= null
		_hybrid: Boolean					= false
		_init: Number						= 0
		_instanceAssessments: Dictionary	= {}
		_instanceMethods: Dictionary		= {}
		_instanceVariables: Dictionary		= {}
		_predefined: Boolean				= false
		_sharedMethods: Dictionary<Number>	= {}
		_seal								= {
			constructors: false
			instanceMethods: {}
			classVariables: {}
			classMethods: {}
			instanceVariables: {}
		}
		_sequences	 						= {
			constructor:		0
			classMethods:		{}
			instanceMethods:	{}
		}
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

			if data.sharedMethods? {
				type._sharedMethods = data.sharedMethods
			}

			if data.class? {
				alterations[data.class.reference] = index

				queue.push(() => {
					const source = references[data.class.reference]

					type.copyFrom(source.type())

					for const constructor in data.constructors {
						type.addConstructor(ClassConstructorType.fromMetadata(constructor, metadata, references, alterations, queue, scope, node))
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
			else {
				type._abstract = data.abstract
				type._alien = data.alien
				type._hybrid = data.hybrid
				type._init = data.init

				if data.systemic {
					type.flagSystemic()
				}
				else if data.sealed {
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
		@sequences.instanceMethods[name] ??= 0

		let id = type.identifier()
		if id == -1 {
			id = @sequences.instanceMethods[name]++

			type.identifier(id)
		}
		else {
			if id >= @sequences.instanceMethods[name] {
				@sequences.instanceMethods[name] = id + 1
			}
		}

		if @abstractMethods[name] is Array {
			@abstractMethods[name].push(type)
		}
		else {
			@abstractMethods[name] = [type]
		}

		return id
	} // }}}
	addClassMethod(name: String, type: ClassMethodType): Number? { // {{{
		if @classMethods[name] is not Array {
			@classMethods[name] = []
			@sequences.classMethods[name] = 0
		}

		let id = type.identifier()
		if id == -1 {
			id = @sequences.classMethods[name]++

			type.identifier(id)
		}
		else {
			if id >= @sequences.classMethods[name] {
				@sequences.classMethods[name] = id + 1
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

		if type.isSealed() {
			@seal.classVariables[name] = true
		}
	} // }}}
	addConstructor(type: ClassConstructorType) { // {{{
		let id = type.identifier()
		if id == -1 {
			id = @sequences.constructor++

			type.identifier(id)
		}
		else {
			if id >= @sequences.constructor {
				@sequences.constructor = id + 1
			}
		}

		type.setClass(this)

		@constructors.push(type)

		if @alteration {
			type.flagAlteration()
		}

		if type.isSealed() {
			@seal.constructors = true
		}

		return id
	} // }}}
	addDestructor() { // {{{
		@destructors++
	} // }}}
	addInstanceMethod(name: String, type: ClassMethodType): Number? { // {{{
		@sequences.instanceMethods[name] ??= 0

		let id = type.identifier()
		if id == -1 {
			id = @sequences.instanceMethods[name]++

			type.identifier(id)
		}
		else {
			if id >= @sequences.instanceMethods[name] {
				@sequences.instanceMethods[name] = id + 1
			}
		}

		if @instanceMethods[name] is Array {
			@instanceMethods[name].push(type)
		}
		else {
			@instanceMethods[name] = [type]
		}

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

		if @alien {
			type.flagAlien()
		}

		if type.isSealed() {
			@seal.instanceVariables[name] = true
		}
	} // }}}
	addPropertyFromAST(data, node) { // {{{
		const options = Attribute.configure(data, null, AttributeTarget::Property, node.file())

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
					const type = ClassConstructorType.fromAST(data, node)

					if options.rules.nonExhaustive {
						@exhaustiveness.constructor = false
					}

					this.addConstructor(type)
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
	checkVariablesInitializations(node) { // {{{
		return if @alien

		for const variable, name of @instanceVariables {
			if variable.isRequiringInitialization() {
				SyntaxException.throwNotInitializedField(name, node)
			}
		}

		if @extending {
			@extends.type().checkVariablesInitializations(node)
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
		@systemic = src._systemic

		for const methods, name of src._abstractMethods {
			@abstractMethods[name] = [].concat(methods)
		}
		for const methods, name of src._classMethods {
			@classMethods[name] = [].concat(methods)
		}
		for const methods, name of src._instanceMethods {
			@instanceMethods[name] = [].concat(methods)
		}

		for const variable, name of src._classVariables {
			@classVariables[name] = variable
		}
		for const variable, name of src._instanceVariables {
			@instanceVariables[name] = variable
		}

		@constructors.push(...src._constructors)

		if src._sealed {
			@seal = Dictionary.clone(src._seal)
		}

		@sequences = Dictionary.clone(src._sequences)

		if src.isRequired() || src.isAlien() {
			this.setAlterationReference(src)
		}

		return this
	} // }}}
	dedupClassMethod(name: String, type: ClassMethodType): Number? { // {{{
		if const id = type.identifier() {
			if @classMethods[name] is Array {
				for const method in @classMethods[name] {
					if method.identifier() == id {
						return id
					}
				}
			}
		}

		if const overwrite = type.overwrite() {
			const methods = @classMethods[name]

			for const data in overwrite {
				for const i from methods.length - 1 to 0 by -1 when methods[i].identifier() == data.id {
					methods.splice(i, 1)
					break
				}
			}

			type.overwrite(null)
		}

		return this.addClassMethod(name, type)
	} // }}}
	dedupInstanceMethod(name: String, type: ClassMethodType): Number? { // {{{
		if const id = type.identifier() {
			if @instanceMethods[name] is Array {
				for const method in @instanceMethods[name] {
					if method.identifier() == id {
						return id
					}
				}
			}
		}

		if const overwrite = type.overwrite() {
			const methods = @instanceMethods[name]

			for const data in overwrite {
				for const i from methods.length - 1 to 0 by -1 when methods[i].identifier() == data.id {
					methods.splice(i, 1)
					break
				}
			}
		}

		return this.addInstanceMethod(name, type)
	} // }}}
	destructors() => @destructors
	export(references, mode: ExportMode) { // {{{
		const exhaustive = this.isExhaustive()

		let export

		if this.hasExportableAlteration() {
			export = {
				kind: TypeKind::Class
				class: @alterationReference.toAlterationReference(references, mode)
				exhaustive
				init: @init
				constructors: [constructor.export(references, mode) for const constructor in @constructors when constructor.isAlteration() && constructor.isExportable()]
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
				const exportedMethods = [method.export(references, mode) for const method in methods when method.isAlteration() && method.isExportable()]
				if exportedMethods.length > 0 {
					export.instanceMethods[name] = exportedMethods
				}
			}

			for const methods, name of @classMethods {
				const exportedMethods = [method.export(references, mode) for const method in methods when method.isAlteration() && method.isExportable()]
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
				systemic: @systemic
				exhaustive
				init: @init
				constructors: [constructor.export(references, mode) for const constructor in @constructors]
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
				const m = [method.unflagAlteration().export(references, mode) for const method in methods when method.isExportable()]

				if m.length != 0 {
					export.instanceMethods[name] = m
				}
			}

			for const methods, name of @classMethods {
				export.classMethods[name] = [method.unflagAlteration().export(references, mode) for const method in methods when method.isExportable()]
			}

			if @abstract {
				export.abstractMethods = {}

				for const methods, name of @abstractMethods {
					export.abstractMethods[name] = [method.export(references, mode) for const method in methods when method.isExportable()]
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

			if !Dictionary.isEmpty(@exhaustiveness.classMethods) {
				exhaustiveness.classMethods = @exhaustiveness.classMethods
				notEmpty = true
			}

			if !Dictionary.isEmpty(@exhaustiveness.instanceMethods) {
				exhaustiveness.instanceMethods = @exhaustiveness.instanceMethods
				notEmpty = true
			}

			if notEmpty {
				export.exhaustiveness = exhaustiveness
			}
		}

		if @sealed {
			export.sharedMethods = {...@sharedMethods}
		}

		return export
	} // }}}
	extends() => @extends
	extends(@extends) { // {{{
		@extending = true

		const type = @extends.type()

		if type.isAlien() || type.isHybrid() {
			@hybrid = true
		}

		@sequences.classMethods = Dictionary.clone(type._sequences.classMethods)
		@sequences.instanceMethods = Dictionary.clone(type._sequences.instanceMethods)
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

		return this
	} // }}}
	forEachInstanceVariables(fn) { // {{{
		for const variable, name of @instanceVariables {
			fn(name, variable)
		}

		if @extending {
			@extends.type().forEachInstanceVariables(fn)
		}
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
	getClassAssessment(name: String, node: AbstractNode) { // {{{
		if @classMethods[name] is not Array {
			if @extending {
				return @extends.type().getClassAssessment(name, node)
			}
			else {
				return null
			}
		}

		if @classAssessments[name] is not Dictionary {
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

			@classAssessments[name] = Router.assess(methods, false, name, node)
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
	getClassVariable(name: String) { // {{{
		if const variable = @classVariables[name] {
			return variable
		}

		return null
	} // }}}
	getClassWithInstanceMethod(name: String, that: NamedType): NamedType { // {{{
		if @instanceMethods[name] is Array {
			return that
		}

		return @extends.type().getClassWithInstanceMethod(name, @extends)
	} // }}}
	getConstructor(arguments: Array) { // {{{
		if @constructors.length == 0 {
			if @extending {
				return @extends.type().getConstructor(arguments)
			}
		}
		else {
			for method in @constructors {
				if method.matchArguments(arguments) {
					return method
				}
			}
		}

		return null
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
	getHybridMethod(name: String, namedClass: NamedType<ClassType>): NamedType<ClassType>? { // {{{
		if @sealed {
			if @seal.instanceMethods[name] {
				return namedClass
			}
		}
		else if @extending {
			return @extends.type().getHybridMethod(name, @extends)
		}

		return null
	} // }}}
	getInstantiableMethod(name: String, arguments: Array) { // {{{
		if const methods = @instanceMethods[name] {
			for method in methods {
				if method.matchArguments(arguments) {
					return method
				}
			}
		}
		if @abstract {
			if const methods = @abstractMethods[name] {
				for method in methods {
					if method.matchArguments(arguments) {
						return method
					}
				}
			}
		}

		if @extending {
			return @extends.type().getInstantiableMethod(name, arguments)
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
	getInstantiableAssessment(name: String, node: AbstractNode) { // {{{
		if const assessment = @instanceAssessments[name] {
			return assessment
		}

		const methods = this.listInstantiableMethods(name)

		let that = this
		while that.isExtending() {
			that = that.extends().type()

			for const method in that.listInstantiableMethods(name) {
				method.pushTo(methods)
			}
		}

		const assessment = Router.assess(methods, false, name, node)

		@instanceAssessments[name] = assessment

		return assessment
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
	getSharedMethodIndex(name: String): Number? => @sharedMethods[name]
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
	hasExportableAlteration() { // {{{
		if ?@alterationReference {
			return @alterationReference._referenceIndex != -1 || @alterationReference.hasExportableAlteration()
		}
		else {
			return false
		}
	} // }}}
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
	hasInstantiableMethod(name) { // {{{
		if @instanceMethods[name] is Array {
			return true
		}
		else if @abstract && @abstractMethods[name] is Array {
			return true
		}
		else if @extending {
			return @extends.type().hasInstantiableMethod(name)
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
	hasSealedConstructors(): Boolean => @seal?.constructors
	incInitializer() { // {{{
		return ++@init
	} // }}}
	incSharedMethod(name: String): Number { // {{{
		if const value = @sharedMethods[name] {
			@sharedMethods[name] = ++value
		}
		else {
			@sharedMethods[name] = 0
		}

		return @sharedMethods[name]
	} // }}}
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
	isExhaustiveConstructor() { // {{{
		if @exhaustiveness.constructor == false {
			return false
		}
		else {
			return true
		}
	} // }}}
	isExhaustiveConstructor(node) => this.isExhaustive(node) && this.isExhaustiveConstructor()
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
	isExhaustiveClassMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveClassMethod(name)
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
	isExhaustiveInstanceMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveInstanceMethod(name)
	isExplicitlyExported() => @explicitlyExported
	isExtendable() => true
	isExtending() => @extending
	isFlexible() => @sealed
	isHybrid() => @hybrid
	isInitializing() => @init != 0
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
		if mode ~~ MatchingMode::Exact {
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
	listConstructors() => @constructors
	listInstanceMethods(name: String) { // {{{
		if @instanceMethods[name] is Array {
			return @instanceMethods[name]
		}

		return null
	} // }}}
	listInstantiableMethods(name: String) { // {{{
		const methods = []

		if const functions = @instanceMethods[name] {
			methods.push(...functions)
		}

		if @abstract {
			if const functions = @abstractMethods[name] {
				methods.push(...functions)
			}
		}

		return methods
	} // }}}
	listMatchingConstructors(type: FunctionType, mode: MatchingMode) { // {{{
		const results: Array = []

		for const constructor in @constructors {
			if constructor.isMatching(type, mode) {
				results.push(constructor)
			}
		}

		return results
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
	matchInstanceWith(object: DictionaryType, matchables) { // {{{
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
	overwriteConstructor(type, methods) { // {{{
		@constructors.remove(...methods)

		type.overwrite([{id: method.identifier(), export: !method.isAlteration()} for const method in methods])

		return this.addConstructor(type)
	} // }}}
	overwriteInstanceMethod(name, type, methods) { // {{{
		@instanceMethods[name]:Array.remove(...methods)

		type.overwrite([{id: method.identifier(), export: !method.isAlteration()} for const method in methods])

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
	toPositiveTestFragments(fragments, node) { // {{{
		throw new NotImplementedException(node)
	} // }}}
}

class ClassVariableType extends Type {
	private {
		_access: Accessibility	= Accessibility::Public
		_alteration: Boolean	= false
		_default: Boolean		= false
		_immutable: Boolean		= false
		_lateInit: Boolean		= false
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
				type = new ClassVariableType(scope, AnyType.NullableUnexplicit)
			}

			if data.modifiers? {
				for const modifier in data.modifiers {
					switch modifier.kind {
						ModifierKind::Immutable => {
							type._immutable = true
						}
						ModifierKind::Internal => {
							type.access(Accessibility::Internal)
						}
						ModifierKind::LateInit => {
							type._lateInit = true
						}
						ModifierKind::Private => {
							type.access(Accessibility::Private)
						}
						ModifierKind::Protected => {
							type.access(Accessibility::Protected)
						}
					}
				}
			}

			if data.value? {
				type._default = true
				type._lateInit = false
			}

			return type
		} // }}}
		fromMetadata(data, metadata, references, alterations, queue, scope: Scope, node: AbstractNode): ClassVariableType { // {{{
			const type = new ClassVariableType(scope, Type.fromMetadata(data.type, metadata, references, alterations, queue, scope, node))

			type._access = data.access
			type._default = data.default
			type._immutable = data.immutable
			type._lateInit = data.lateInit

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
	export(references, mode) { // {{{
		const data = {
			access: @access
			type: @type.toReference(references, mode)
			default: @default
			immutable: @immutable
			lateInit: @lateInit
			sealed: @sealed
		}

		return data
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	flagNullable() { // {{{
		@type = @type.setNullable(true)
	} // }}}
	hasDefaultValue() => @default
	isAlteration() => @alteration
	isImmutable() => @immutable
	isLateInit() => @lateInit
	isMatching(value: ClassVariableType, mode: MatchingMode) { // {{{
		if mode ~~ MatchingMode::Exact {
			return @type.isMatching(value.type(), MatchingMode::Exact)
		}
		else {
			return true
		}
	} // }}}
	isNullable() => @type.isNullable()
	isRequiringInitialization() => !(@lateInit || @default || @type.isNullable()) || (@lateInit && @immutable)
	isUsingGetter() => @sealed && @default
	isUsingSetter() => @sealed && @default
	toFragments(fragments, node) => @type.toFragments(fragments, node)
	toQuote(...args) => @type.toQuote(...args)
	toPositiveTestFragments(fragments, node) => @type.toPositiveTestFragments(fragments, node)
	type(): @type
	type(@type): this
	unflagAlteration() { // {{{
		@alteration = false

		return this
	} // }}}
}

class ClassMethodType extends FunctionType {
	private {
		_access: Accessibility					= Accessibility::Public
		_alteration: Boolean					= false
		_identifier: Number						= -1
		_initVariables: Dictionary<Boolean>		= {}
		_overwrite: Array?						= null
	}
	static {
		fromAST(data, node: AbstractNode): ClassMethodType { // {{{
			const scope = node.scope()

			return new ClassMethodType([Type.fromAST(parameter, scope, false, node) for parameter in data.parameters], data, node)
		} // }}}
		fromMetadata(data, metadata, references, alterations, queue: Array, scope: Scope, node: AbstractNode): ClassMethodType { // {{{
			const type = new ClassMethodType(scope)

			type._identifier = data.id
			type._access = data.access
			type._sealed = data.sealed
			type._async = data.async
			type._min = data.min
			type._max = data.max
			type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]

			type._returnType = Type.fromMetadata(data.returns, metadata, references, alterations, queue, scope, node)

			type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

			if data.overwrite? {
				type._overwrite = [{id: id, export: true} for id in data.overwrite]
			}

			if data.inits? {
				for const name in data.inits {
					type._initVariables[name] = true
				}
			}

			type.updateArguments()

			return type
		} // }}}
	}
	access(@access) => this
	addInitializingInstanceVariable(name: String) { // {{{
		@initVariables[name] = true
	} // }}}
	clone() { // {{{
		const clone = new ClassMethodType(@scope)

		FunctionType.clone(this, clone)

		clone._access = @access
		clone._alteration = @alteration
		clone._identifier = @identifier
		clone._initVariables = {...@initVariables}

		if @overwrite != null {
			clone._overwrite = [...@overwrite]
		}

		return clone
	} // }}}
	export(references, mode: ExportMode) { // {{{
		const export = {
			id: @identifier
			access: @access
			sealed: @sealed
			async: @async
			min: @min
			max: @max
			parameters: [parameter.export(references, mode) for parameter in @parameters]
			returns: @returnType.toReference(references, mode)
			throws: [throw.toReference(references, mode) for throw in @throws]
			inits: Dictionary.keys(@initVariables)
		}

		if @overwrite != null {
			const overwrite = [data.id for const data in @overwrite when data.export]

			if overwrite.length != 0 {
				export.overwrite = overwrite
			}
		}

		return export
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	identifier() => @identifier
	identifier(@identifier)
	isAlteration() => @alteration
	isExportable() { // {{{
		if !super() {
			return false
		}

		return @access != Accessibility::Internal
	} // }}}
	isInitializingInstanceVariable(name) => @initVariables[name]
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
		const mode = MatchingMode::SimilarParameters + MatchingMode::MissingParameters + MatchingMode::ShiftableParameters + MatchingMode::RequireAllParameters

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
			else if modifier.kind == ModifierKind::Internal {
				@access = Accessibility::Internal
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
	unflagAlteration(): this { // {{{
		@alteration = false
		@overwrite = null
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
	private lateinit {
		_access: Accessibility					= Accessibility::Public
		_alteration: Boolean					= false
		_class: ClassType
		_dependent: Boolean						= false
		_identifier: Number						= -1
		_initVariables: Dictionary<Boolean>		= {}
		_overwrite: Array?						= null
	}
	static {
		fromAST(data, node: AbstractNode): ClassConstructorType { // {{{
			const scope = node.scope()

			return new ClassConstructorType([Type.fromAST(parameter, scope, false, node) for parameter in data.parameters], data, node)
		} // }}}
		fromMetadata(data, metadata, references, alterations, queue, scope: Scope, node: AbstractNode): ClassConstructorType { // {{{
			const type = new ClassConstructorType(scope)

			type._identifier = data.id
			type._access = data.access
			type._sealed = data.sealed
			type._min = data.min
			type._max = data.max

			if data.dependent {
				type._dependent = true
			}

			type._throws = [Type.fromMetadata(throw, metadata, references, alterations, queue, scope, node) for throw in data.throws]
			type._parameters = [ParameterType.fromMetadata(parameter, metadata, references, alterations, queue, scope, node) for parameter in data.parameters]

			if data.inits? {
				for const name in data.inits {
					type._initVariables[name] = true
				}
			}

			type.updateArguments()

			return type
		} // }}}
	}
	access(@access) => this
	addInitializingInstanceVariable(name: String) { // {{{
		@initVariables[name] = true
	} // }}}
	checkVariablesInitializations(node: AbstractNode, class: ClassType = @class) { // {{{
		class.forEachInstanceVariables((name, variable) => {
			if variable.isRequiringInitialization() && !@initVariables[name] {
				SyntaxException.throwNotInitializedField(name, node)
			}
		})
	} // }}}
	export(references, mode) { // {{{
		const export = {
			id: @identifier
			access: @access
			sealed: @sealed
			min: @min
			max: @max
			parameters: [parameter.export(references, mode) for parameter in @parameters]
			throws: [throw.toReference(references, mode) for throw in @throws]
		}


		if @class.isAbstract() {
			export.inits = Dictionary.keys(@initVariables)
		}

		if @dependent {
			export.dependent = true
		}

		if @overwrite != null {
			const overwrite = [data.id for const data in @overwrite when data.export]

			if overwrite.length != 0 {
				export.overwrite = overwrite
			}
		}

		return export
	} // }}}
	flagAlteration() { // {{{
		@alteration = true

		return this
	} // }}}
	flagDependent() { // {{{
		@dependent = true

		return this
	} // }}}
	identifier() => @identifier
	identifier(@identifier)
	isAlteration() => @alteration
	isDependent() => @dependent
	isInitializingInstanceVariable(name) => @initVariables[name]
	isOverwritten() => @overwrite != null
	overwrite() => @overwrite
	overwrite(@overwrite)
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
	setClass(@class): this
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