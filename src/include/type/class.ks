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
		_alterations						= {
			classMethods: {}
			classVariables: {}
			constructors: {}
			instanceMethods: {}
			instanceVariables: {}
		}
		_altering: Boolean					= false
		_classAssessments: Dictionary		= {}
		_classMethods: Dictionary			= {}
		_classVariables: Dictionary			= {}
		_constructors: Array				= []
		_constructorAssessment				= null
		_exhaustiveness						= {
			constructor: false
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
		_level: Number						= 0
		_majorOriginal: ClassType?
		_minorOriginal: ClassType?
		_overwritten						= {
			constructors: null
			classMethods: {}
			instanceMethods: {}
		}
		_predefined: Boolean				= false
		_sharedMethods: Dictionary<Number>	= {}
		_seal								= {
			constructors: false
			classMethods: {}
			classVariables: {}
			instanceMethods: {}
			instanceVariables: {}
		}
		_sequences	 						= {
			constructors:		-1
			defaults:			-1
			destructors:		-1
			initializations:	-1
			classMethods:		{}
			instanceMethods:	{}
		}
	}
	static {
		getExternReference(...types?): Number? { # {{{
			for var type in types when ?type {
				if type.isAlien() && !type.isRequirement() && type.referenceIndex() != -1 {
					return type.referenceIndex()
				}

				if ?type._majorOriginal {
					if var reference = ClassType.getExternReference(type._majorOriginal) {
						return reference
					}
					else if ?type._minorOriginal {
						return ClassType.getExternReference(type._minorOriginal)
					}
				}
			}

			return null
		} # }}}
		getOriginReference(type: ClassType): Number? { # {{{
			if type.origin()? {
				return type.referenceIndex()
			}

			if ?type._majorOriginal {
				return ClassType.getOriginReference(type._majorOriginal)
			}
			else {
				return null
			}
		} # }}}
		getRequireReference(type: ClassType): Number? { # {{{
			if type.isRequirement() && type.referenceIndex() != -1 {
				return type.referenceIndex()
			}

			if ?type._majorOriginal {
				return ClassType.getRequireReference(type._majorOriginal)
			}
			else {
				return null
			}
		} # }}}
		import(index, data, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode): ClassType { # {{{
			var type = new ClassType(scope)

			type._sequences.initializations = data.sequences[0]
			type._sequences.defaults = data.sequences[1]
			type._sequences.destructors = data.sequences[2]

			type._exhaustive = data.exhaustive

			if data.exhaustiveness? {
				if data.exhaustiveness.constructor? {
					type._exhaustiveness.constructor = data.exhaustiveness.constructor
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

			if data.origin? {
				type._origin = TypeOrigin(data.origin)
			}

			if data.original? {
				queue.push(() => {
					var original = references[data.original].discardName()

					ClassType.importFromOriginal(data, type, original, alterations[data.original], metadata, references, alterations, queue, scope, node)

					references[data.original].reference().reset()
				})
			}
			else if data.originals? {

				queue.push(() => {
					var first = references[data.originals[0]].discardName()
					var second = references[data.originals[1]].discardName()

					var [major, minor] = first.origin() ~~ TypeOrigin::Require ? [first, second] : [second, first]
					var isArgument = alterations[major == first ? data.originals[0] : data.originals[1]]

					ClassType.importFromOriginal(data, type, major, isArgument, metadata, references, alterations, queue, scope, node)

					type._minorOriginal = minor

					references[data.originals[0]].reference().reset()
					references[data.originals[1]].reference().reset()
				})
			}
			else {
				type._abstract = data.abstract
				type._alien = data.alien
				type._hybrid = data.hybrid

				if data.systemic {
					type.flagSystemic()
				}
				else if data.sealed {
					type.flagSealed()
				}

				queue.push(() => {
					if data.extends? {
						type.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
					}

					if data.abstract {
						for var methods, name of data.abstractMethods {
							for method in methods {
								type.dedupAbstractMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
							}
						}
					}

					for method in data.constructors {
						type.addConstructor(ClassConstructorType.import(method, metadata, references, alterations, queue, scope, node))
					}

					for var vtype, name of data.instanceVariables {
						if !type.hasInstanceVariable(name) {
							type.addInstanceVariable(name, ClassVariableType.import(vtype, metadata, references, alterations, queue, scope, node))
						}
					}

					for var vtype, name of data.classVariables {
						if !type.hasClassVariable(name) {
							type.addClassVariable(name, ClassVariableType.import(vtype, metadata, references, alterations, queue, scope, node))
						}
					}

					for var methods, name of data.instanceMethods {
						for method in methods {
							type.dedupInstanceMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
						}
					}

					for var methods, name of data.classMethods {
						for method in methods {
							type.dedupClassMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
						}
					}

					type.setExhaustive(data.exhaustive)
				})
			}

			return type
		} # }}}
		importFromOriginal(data, type: ClassType, original: ClassType, isArgument: Boolean?, metadata: Array, references: Dictionary, alterations: Dictionary, queue: Array, scope: Scope, node: AbstractNode) { # {{{
			type.copyFrom(original)

			if type.isAbstract() {
				for var methods, name of data.abstractMethods {
					for method in methods {
						type.dedupAbstractMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
					}
				}
			}

			for var constructor in data.constructors {
				type.addConstructor(ClassConstructorType.import(constructor, metadata, references, alterations, queue, scope, node))
			}

			for var vtype, name of data.instanceVariables {
				if !type.hasInstanceVariable(name) {
					type.addInstanceVariable(name, ClassVariableType.import(vtype, metadata, references, alterations, queue, scope, node))
				}
			}

			for var vtype, name of data.classVariables {
				if !type.hasClassVariable(name) {
					type.addClassVariable(name, ClassVariableType.import(vtype, metadata, references, alterations, queue, scope, node))
				}
			}

			for var methods, name of data.instanceMethods {
				for var method in methods {
					type.dedupInstanceMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
				}
			}

			for var methods, name of data.classMethods {
				for var method in methods {
					type.dedupClassMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
				}
			}

			type.setExhaustive(data.exhaustive)
		} # }}}
	}
	addAbstractMethod(name: String, type: ClassMethodType): Number { # {{{
		var sequences = @sequences.instanceMethods
		sequences[name] = sequences[name] ?? -1

		var mut index = type.index()

		if index == -1 {
			index = ++sequences[name]

			type.index(index)
		}
		else {
			if index > sequences[name] {
				sequences[name] = index
			}
		}

		if @abstractMethods[name] is Array {
			@abstractMethods[name].push(type)
		}
		else {
			@abstractMethods[name] = [type]
		}

		type.flagAbstract()
		type.flagInstance()

		return index
	} # }}}
	addClassMethod(name: String, type: ClassMethodType): Number? { # {{{
		var root = this.ancestor()
		var sequences = root._sequences.classMethods

		@classMethods[name] = @classMethods[name] ?? []
		sequences[name] = sequences[name] ?? -1

		var mut index = type.index()

		if index == -1 {
			index = ++sequences[name]

			type.index(index)
		}
		else {
			if index > sequences[name] {
				sequences[name] = index
			}
		}

		@classMethods[name].push(type)

		if type.isSealed() {
			@seal.classMethods[name] = true
		}
		else if @alien {
			type.flagAlien()
		}

		@alterations.classMethods[name] ??= {}
		@alterations.classMethods[name][index] = true

		return index
	} # }}}
	addClassVariable(name: String, type: ClassVariableType) { # {{{
		@classVariables[name] = type

		if type.isSealed() {
			@seal.classVariables[name] = true
		}

		@alterations.classVariables[name] = true
	} # }}}
	addConstructor(type: ClassConstructorType) { # {{{
		var mut index = type.index()
		if index == -1 {
			index = ++@sequences.constructors

			type.index(index)
		}
		else {
			if index > @sequences.constructors {
				@sequences.constructors = index
			}
		}

		type.setClass(this)

		@constructors.push(type)

		if type.isSealed() {
			@seal.constructors = true
		}

		@alterations.constructors[index] = true

		return index
	} # }}}
	addInstanceMethod(name: String, type: ClassMethodType): Number? { # {{{
		var root = this.ancestor()
		var sequences = root._sequences.instanceMethods

		@instanceMethods[name] = @instanceMethods[name] ?? []
		sequences[name] = sequences[name] ?? -1

		var mut index = type.index()
		if index == -1 {
			index = ++sequences[name]

			type.index(index)
		}
		else {
			if index > sequences[name] {
				sequences[name] = index
			}
		}

		@instanceMethods[name].push(type)

		type.flagInstance()

		if type.isSealed() {
			@seal.instanceMethods[name] = true
		}
		else if @alien {
			type.flagAlien()
		}

		@alterations.instanceMethods[name] ??= {}
		@alterations.instanceMethods[name][index] = true

		return index
	} # }}}
	addInstanceVariable(name: String, type: ClassVariableType) { # {{{
		@instanceVariables[name] = type

		if @alien {
			type.flagAlien()
		}

		if type.isSealed() {
			@seal.instanceVariables[name] = true
		}

		@alterations.instanceVariables[name] = true
	} # }}}
	addPropertyFromAST(data, node) { # {{{
		var options = Attribute.configure(data, null, AttributeTarget::Property, node.file())

		switch data.kind {
			NodeKind::FieldDeclaration => {
				var mut instance = true
				for i from 0 til data.modifiers.length while instance {
					instance = false if data.modifiers[i].kind == ModifierKind::Static
				}

				var type = ClassVariableType.fromAST(data, node)

				if instance {
					this.addInstanceVariable(data.name.name, type)
				}
				else {
					this.addClassVariable(data.name.name, type)
				}
			}
			NodeKind::MethodDeclaration => {
				if this.isConstructor(data.name.name) {
					var type = ClassConstructorType.fromAST(data, node)

					if options.rules.nonExhaustive {
						@exhaustiveness.constructor = false
					}

					this.addConstructor(type)
				}
				else if this.isDestructor(data.name.name) {
					throw new NotImplementedException(node)
				}
				else {
					var mut instance = true
					for i from 0 til data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == ModifierKind::Static
					}

					var type = ClassMethodType.fromAST(data, node)

					if options.rules.nonExhaustive {
						if instance {
							@exhaustiveness.instanceMethods[data.name.name] = false
						}
						else {
							@exhaustiveness.classMethods[data.name.name] = false
						}
					}

					if this.isAlien() {
						type.flagAlien()
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
	} # }}}
	ancestor() { # {{{
		if @extending {
			return @extends.type().ancestor()
		}
		else {
			return this
		}
	} # }}}
	checkVariablesInitializations(node) { # {{{
		return if @alien

		for var variable, name of @instanceVariables {
			if variable.isRequiringInitialization() {
				SyntaxException.throwNotInitializedField(name, node)
			}
		}

		if @extending {
			@extends.type().checkVariablesInitializations(node)
		}
	} # }}}
	clone() { # {{{
		var that = new ClassType(@scope)

		that.copyFrom(this)

		if @requirement || @alien {
			that.originals(this)
		}

		return that
	} # }}}
	copyFrom(src: ClassType) { # {{{
		@abstract = src._abstract
		@alien = src._alien
		@extending = src._extending
		@extends = src._extends
		@hybrid = src._hybrid
		@sealed = src._sealed
		@systemic = src._systemic

		for var methods, name of src._abstractMethods {
			@abstractMethods[name] = [].concat(methods)
		}
		for var methods, name of src._classMethods {
			@classMethods[name] = [].concat(methods)
		}
		for var methods, name of src._instanceMethods {
			@instanceMethods[name] = [].concat(methods)
		}

		for var variable, name of src._classVariables {
			@classVariables[name] = variable
		}
		for var variable, name of src._instanceVariables {
			@instanceVariables[name] = variable
		}

		@constructors.push(...src._constructors)

		if src._sealed {
			@seal = Dictionary.clone(src._seal)
		}

		@exhaustive = src._exhaustive
		@exhaustiveness = Dictionary.clone(src._exhaustiveness)
		@sequences = Dictionary.clone(src._sequences)

		if src._requirement || src._alien {
			this.originals(src)
		}

		return this
	} # }}}
	dedupAbstractMethod(name: String, type: ClassMethodType): Number? { # {{{
		if var id = type.index() {
			if @abstractMethods[name] is Array {
				for var method in @abstractMethods[name] {
					if method.index() == id {
						return id
					}
				}
			}
		}

		return this.addAbstractMethod(name, type)
	} # }}}
	dedupClassMethod(name: String, type: ClassMethodType): Number? { # {{{
		if var id = type.index() {
			if @classMethods[name] is Array {
				for var method in @classMethods[name] {
					if method.index() == id {
						return id
					}
				}
			}
		}

		if var overwrite = type.overwrite() {
			var methods = @classMethods[name]

			for var data in overwrite {
				for var i from methods.length - 1 to 0 by -1 when methods[i].index() == data {
					methods.splice(i, 1)
					break
				}
			}

			type.overwrite(null)
		}

		return this.addClassMethod(name, type)
	} # }}}
	dedupInstanceMethod(name: String, type: ClassMethodType): Number? { # {{{
		if var id = type.index() {
			if @instanceMethods[name] is Array {
				for var method in @instanceMethods[name] {
					if method.index() == id {
						return id
					}
				}
			}
		}

		if var overwrite = type.overwrite() {
			if var methods = @instanceMethods[name] {
				for var data in overwrite {
					for var i from methods.length - 1 to 0 by -1 when methods[i].index() == data {
						methods.splice(i, 1)
						break
					}
				}
			}
		}

		return this.addInstanceMethod(name, type)
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{

		var exhaustive = this.isExhaustive()

		var mut export

		var mut exportSuper = false
		if @majorOriginal? {
			if mode ~~ ExportMode::Export {
				exportSuper = this.hasExportableOriginals()
			}
			else if mode ~~ ExportMode::Requirement {
				// TODO shorten `original?`
				var mut original: ClassType? = @majorOriginal
				// var mut original? = @majorOriginal

				while ?original {
					if original.isRequirement() || original.referenceIndex() != -1 {
						exportSuper = true
						break
					}
					else {
						original = original._majorOriginal
					}
				}
			}
		}

		if exportSuper {
			export = {
				kind: TypeKind::Class
			}

			if mode ~~ ExportMode::Export {
				var origin = this.origin()
				var extern = ClassType.getExternReference(@majorOriginal, @minorOriginal)
				var require = ClassType.getRequireReference(@majorOriginal)

				if extern? {
					if require? {
						if origin ~~ TypeOrigin::ExternOrRequire {
							export.originals = [extern, require]
						}
						else if origin ~~ TypeOrigin::RequireOrExtern {
							export.originals = [require, extern]
						}
						else {
							export.original = require
						}
					}
					else {
						export.original = extern
					}
				}
				else {
					export.original = require
				}
			}
			else {
				export.original = ClassType.getRequireReference(@majorOriginal) ?? ClassType.getExternReference(@majorOriginal)
			}

			export.exhaustive = exhaustive
			export.constructors = []
			export.instanceVariables = {}
			export.classVariables = {}
			export.instanceMethods = {}
			export.classMethods = {}

			@majorOriginal.exportProperties(export, references, indexDelta, mode, module, @overwritten)

			var mut original = @majorOriginal
			while original.referenceIndex() == -1 {
				original = original.majorOriginal()
			}

			var originalConstructors = original?.listConstructors()?.map((method, _, _) => method.index())
			for var constructor in @constructors when constructor.isExportable(mode) {
				if @alterations.constructors[constructor.index()] {
					export.constructors.push(constructor.export(references, indexDelta, mode, module, originalConstructors))
				}
			}

			for var variable, name of @instanceVariables {
				if @alterations.instanceVariables[name] {
					export.instanceVariables[name] = variable.export(references, indexDelta, mode, module)
				}
			}

			for var variable, name of @classVariables {
				if @alterations.classVariables[name] {
					export.classVariables[name] = variable.export(references, indexDelta, mode, module)
				}
			}

			for var methods, name of @instanceMethods {
				var exportedMethods = export.instanceMethods[name] ?? []
				var originalMethods = original?.listInstanceMethods(name)?.map((method, _, _) => method.index())

				for var method in methods when method.isExportable(mode) {
					if @alterations.instanceMethods[name]?[method.index()] {
						exportedMethods.push(method.export(references, indexDelta, mode, module, originalMethods))
					}
				}

				if exportedMethods.length != 0 {
					export.instanceMethods[name] = exportedMethods
				}
			}

			for var methods, name of @classMethods {
				var exportedMethods = export.classMethods[name] ?? []
				var originalMethods = original?.listClassMethods(name)?.map((method, _, _) => method.index())

				for var method in methods when method.isExportable(mode) {
					if @alterations.classMethods[name]?[method.index()] {
						exportedMethods.push(method.export(references, indexDelta, mode, module, originalMethods))
					}
				}

				if exportedMethods.length != 0 {
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
				constructors: [constructor.export(references, indexDelta, mode, module, null) for var constructor in @constructors]
				instanceVariables: {}
				classVariables: {}
				instanceMethods: {}
				classMethods: {}
			}

			for var variable, name of @instanceVariables {
				export.instanceVariables[name] = variable.export(references, indexDelta, mode, module)
			}

			for var variable, name of @classVariables {
				export.classVariables[name] = variable.export(references, indexDelta, mode, module)
			}

			for var methods, name of @instanceMethods {
				var exportedMethods = [method.export(references, indexDelta, mode, module, null) for var method in methods when method.isExportable(mode)]

				if exportedMethods.length != 0 {
					export.instanceMethods[name] = exportedMethods
				}
			}

			for var methods, name of @classMethods {
				var exportedMethods = [method.export(references, indexDelta, mode, module, null) for var method in methods when method.isExportable(mode)]

				if exportedMethods.length != 0 {
					export.classMethods[name] = exportedMethods
				}
			}

			if @abstract {
				export.abstractMethods = {}

				for var methods, name of @abstractMethods {
					var exportedMethods = [method.export(references, indexDelta, mode, module, null) for var method in methods when method.isExportable(mode)]

					if exportedMethods.length != 0 {
						export.abstractMethods[name] = exportedMethods
					}
				}
			}

			if @extending {
				export.extends = @extends.metaReference(references, indexDelta, mode, module)
			}
		}

		if mode !~ ExportMode::Export && @origin? && @origin ~~ TypeOrigin::Extern && @origin !~ TypeOrigin::Import {
			var origin = @origin - TypeOrigin::Extern - TypeOrigin::Require

			if origin != 0 {
				export.origin = origin
			}
		}

		export.sequences = [
			@sequences.initializations
			@sequences.defaults
			@sequences.destructors
		]

		var exhaustiveness = {}

		if @exhaustiveness.constructor != exhaustive {
			exhaustiveness.constructor = @exhaustiveness.constructor
		}

		for var value, name of @exhaustiveness.classMethods when value != exhaustive {
			exhaustiveness.classMethods ??= {}
			exhaustiveness.classMethods[name] = value
		}

		for var value, name of @exhaustiveness.instanceMethods when value != exhaustive {
			exhaustiveness.instanceMethods ??= {}
			exhaustiveness.instanceMethods[name] = value
		}

		if !Dictionary.isEmpty(exhaustiveness) {
			export.exhaustiveness = exhaustiveness
		}

		if @sealed {
			export.sharedMethods = {...@sharedMethods}
		}

		return export
	} # }}}
	exportProperties(export, references, indexDelta, mode, module, overwritten) { # {{{
		return unless @referenceIndex == -1

		@majorOriginal?.exportProperties(export, references, indexDelta, mode, module, overwritten)

		for var variable, name of @instanceVariables {
			if @alterations.instanceVariables[name] {
				export.instanceVariables[name] = variable.export(references, indexDelta, mode, module)
			}
		}

		for var variable, name of @classVariables {
			if @alterations.classVariables[name] {
				export.classVariables[name] = variable.export(references, indexDelta, mode, module)
			}
		}

		var ignoredConstructors = overwritten.constructors ?? []
		for var constructor in @constructors when constructor.isExportable(mode) {
			if @alterations.constructors[constructor.index()] && !ignoredConstructors:Array.contains(constructor.index()) {
				export.constructors.push(constructor.export(references, indexDelta, mode, module, true))
			}
		}

		for var methods, name of @instanceMethods {
			var exportedMethods = export.instanceMethods[name] ?? []
			var ignoredMethods = overwritten.instanceMethods[name] ?? []

			for var method in methods when method.isExportable(mode) {
				if @alterations.instanceMethods[name]?[method.index()] && !ignoredMethods:Array.contains(method.index()) {
					exportedMethods.push(method.export(references, indexDelta, mode, module, true))
				}
			}

			if exportedMethods.length != 0 {
				export.instanceMethods[name] = exportedMethods
			}
		}

		for var methods, name of @classMethods {
			var exportedMethods = export.classMethods[name] ?? []

			for var method in methods when method.isExportable(mode) {
				if @alterations.classMethods[name]?[method.index()] {
					exportedMethods.push(method.export(references, indexDelta, mode, module, true))
				}
			}

			if exportedMethods.length != 0 {
				export.classMethods[name] = exportedMethods
			}
		}
	} # }}}
	extends() => @extends
	extends(@extends) { # {{{
		@extending = true

		var type = @extends.type()

		if type.isAlien() || type.isHybrid() {
			@hybrid = true
		}

		@sequences.classMethods = Dictionary.clone(type._sequences.classMethods)
		@sequences.instanceMethods = Dictionary.clone(type._sequences.instanceMethods)

		@level = type.level():Number + 1
	} # }}}
	flagAbstract() { # {{{
		@abstract = true
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if @exported && (@explicitlyExported || !explicitly) {
			return this
		}

		@exported = true
		@explicitlyExported = explicitly

		for method in @constructors {
			method.flagExported(false)
		}

		for var variable of @instanceVariables {
			variable.type().flagExported(false)
		}

		for var variable of @classVariables {
			variable.type().flagExported(false)
		}

		for var methods of @instanceMethods when methods is Array {
			for method in methods {
				method.flagExported(false)
			}
		}

		for var methods of @classMethods when methods is Array {
			for method in methods {
				method.flagExported(false)
			}
		}

		if @extending {
			@extends.flagExported(explicitly)
		}

		return this
	} # }}}
	filterAbstractMethods(abstractMethods) { # {{{
		if @extending {
			@extends.type().filterAbstractMethods(abstractMethods)
		}

		if @abstract {
			for var methods, name of @abstractMethods {
				if abstractMethods[name] is not Array {
					abstractMethods[name] = []
				}

				abstractMethods[name]:Array.append(methods)
			}
		}

		var matchables = []

		var mut method, index
		for var methods, name of abstractMethods when @instanceMethods[name] is Array {
			for method, index in methods desc {
				if method.isSubsetOf(@instanceMethods[name], MatchingMode::FunctionSignature) {
					methods.splice(index, 1)
				}
			}

			if methods.length == 0 {
				delete abstractMethods[name]
			}
		}
	} # }}}
	flagAltering(): this { # {{{
		if ?@majorOriginal {
			@altering = true
		}
	} # }}}
	flagPredefined() { # {{{
		@predefined = true
	} # }}}
	flagRequirement(): this { # {{{
		super()

		@majorOriginal?.unflagRequired()
	} # }}}
	flagSealed() { # {{{
		@sealed = true

		return this
	} # }}}
	forEachInstanceVariables(fn) { # {{{
		for var variable, name of @instanceVariables {
			fn(name, variable)
		}

		if @extending {
			@extends.type().forEachInstanceVariables(fn)
		}
	} # }}}
	getAbstractMethod(name: String, type: Type) { # {{{
		if @abstractMethods[name] is Array {
			for method in @abstractMethods[name] {
				if type.isMatching(method, MatchingMode::FunctionSignature) {
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
	} # }}}
	getClassAssessment(name: String, node: AbstractNode) { # {{{
		if @classMethods[name] is not Array {
			if @extending {
				return @extends.type().getClassAssessment(name, node)
			}
			else {
				return null
			}
		}

		if @classAssessments[name] is not Dictionary {
			var methods = [...@classMethods[name]]

			var mut that = this
			while methods.length == 0 && that.isExtending() {
				that = that.extends().type()

				if var m = that.listClassMethods(name) {
					for var method in m {
						method.pushTo(methods)
					}
				}
			}

			@classAssessments[name] = Router.assess(methods, name, node)
		}

		return @classAssessments[name]
	} # }}}
	getClassProperty(name: String): Type { # {{{
		if @classMethods[name] is Array {
			return @scope.reference('Function')
		}
		else {
			return @classVariables[name] ?? Type.Any
		}
	} # }}}
	getClassVariable(name: String) { # {{{
		if var variable = @classVariables[name] {
			return variable
		}

		return null
	} # }}}
	getClassWithInstanceMethod(name: String, that: NamedType): NamedType { # {{{
		if @instanceMethods[name] is Array {
			return that
		}

		return @extends.type().getClassWithInstanceMethod(name, @extends)
	} # }}}
	getConstructor(type: FunctionType, mode: MatchingMode) { # {{{
		if @constructors.length == 0 && @extending {
			return @extends.type().getConstructor(type)
		}

		var result = []

		for method in @constructors {
			if method.isSubsetOf(type, mode) {
				return method
			}
		}

		if result.length == 1 {
			return result[0]
		}
		else {
			return null
		}
	} # }}}
	getConstructorAssessment(name: String, node: AbstractNode) { # {{{
		if @constructorAssessment == null {
			var methods = this.listAccessibleConstructors()

			@constructorAssessment = Router.assess(methods, name, node)
		}

		return @constructorAssessment
	} # }}}
	getConstructorCount() => @sequences.constructors + 1
	getDestructorCount() => @sequences.destructors + 1
	getHierarchy(name) { # {{{
		if @extending {
			var mut class = this.extends()

			var hierarchy = [name, class.name()]

			while class.type().isExtending() {
				hierarchy.push((class = class.type().extends()).name())
			}

			return hierarchy
		}
		else {
			return [name]
		}
	} # }}}
	getHybridConstructor(namedClass: NamedType<ClassType>): NamedType<ClassType>? { # {{{
		if @sealed {
			if @seal.constructors {
				return namedClass
			}
		}
		else if @extending {
			return @extends.type().getHybridConstructor(@extends)
		}

		return null
	} # }}}
	getHybridMethod(name: String, namedClass: NamedType<ClassType>): NamedType<ClassType>? { # {{{
		if @sealed {
			if @seal.instanceMethods[name] {
				return namedClass
			}
		}
		else if @extending {
			return @extends.type().getHybridMethod(name, @extends)
		}

		return null
	} # }}}
	getInstanceProperty(name: String) { # {{{
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
	} # }}}
	getInstanceVariable(name: String) { # {{{
		if @instanceVariables[name]? {
			return @instanceVariables[name]
		}
		else if @extending {
			return @extends.type().getInstanceVariable(name)
		}

		return null
	} # }}}
	getInstantiableAssessment(name: String, node: AbstractNode) { # {{{
		if var assessment = @instanceAssessments[name] {
			return assessment
		}

		var methods = this.listInstantiableMethods(name)

		var mut that = this
		while methods.length == 0 && that.isExtending() {
			that = that.extends().type()

			for var method in that.listInstantiableMethods(name) {
				method.pushTo(methods)
			}
		}

		var assessment = Router.assess(methods, name, node)

		@instanceAssessments[name] = assessment

		return assessment
	} # }}}
	getMajorReferenceIndex() => @referenceIndex == -1 && @majorOriginal? ? @majorOriginal.getMajorReferenceIndex() : @referenceIndex
	getMatchingInstanceMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @instanceMethods[name] is Array {
			for var method in @instanceMethods[name] {
				if method.isSubsetOf(type, mode) {
					return method
				}
			}
		}

		if @abstract && @abstractMethods[name] is Array {
			for var method in @abstractMethods[name] {
				if method.isSubsetOf(type, mode) {
					return method
				}
			}
		}

		if @extending && mode ~~ MatchingMode::Superclass {
			return @extends.type().getMatchingInstanceMethod(name, type, mode)
		}

		return null
	} # }}}
	getProperty(name: String) => this.getClassProperty(name)
	getSharedMethodIndex(name: String): Number? => @sharedMethods[name]
	hasAbstractMethod(name) { # {{{
		if @abstractMethods[name] is Array {
			return true
		}

		if @extending {
			return @extends.type().hasAbstractMethod(name)
		}
		else {
			return false
		}
	} # }}}
	hasClassMethod(name) { # {{{
		if @classMethods[name] is Array {
			return true
		}

		if @extending {
			return @extends.type().hasClassMethod(name)
		}
		else {
			return false
		}
	} # }}}
	hasClassVariable(name) { # {{{
		if @classVariables[name] is ClassVariableType {
			return true
		}

		if @extending {
			return @extends.type().hasClassVariable(name)
		}
		else {
			return false
		}
	} # }}}
	hasConstructors() => @constructors.length != 0
	hasDestructors() => @sequences.destructors != -1
	hasExportableOriginals() { # {{{
		if @minorOriginal? {
			return true if @minorOriginal._referenceIndex != -1 || @minorOriginal.hasExportableOriginals()
		}

		if ?@majorOriginal {
			return @majorOriginal._referenceIndex != -1 || @majorOriginal.hasExportableOriginals()
		}
		else {
			return false
		}
	} # }}}
	hasInstanceMethod(name) { # {{{
		if @instanceMethods[name] is Array {
			return true
		}

		if @extending {
			return @extends.type().hasInstanceMethod(name)
		}
		else {
			return false
		}
	} # }}}
	hasInstanceVariable(name) { # {{{
		if @instanceVariables[name] is ClassVariableType {
			return true
		}

		if @extending {
			return @extends.type().hasInstanceVariable(name)
		}
		else {
			return false
		}
	} # }}}
	hasInstantiableMethod(name) { # {{{
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
	} # }}}
	hasMatchingClassMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @classMethods[name] is Array {
			for var method in @classMethods[name] {
				if method.isSubsetOf(type, mode) {
					return true
				}
			}
		}

		if @extending && mode ~~ MatchingMode::Superclass {
			return @extends.type().hasMatchingClassMethod(name, type, mode)
		}

		return false
	} # }}}
	hasMatchingConstructor(type: FunctionType, mode: MatchingMode) { # {{{
		if @constructors.length != 0 {
			for var constructor in @constructors {
				if constructor.isSubsetOf(type, mode) {
					return true
				}
			}
		}

		return false
	} # }}}
	hasMatchingInstanceMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @instanceMethods[name] is Array {
			for var method in @instanceMethods[name] {
				if method.isSubsetOf(type, mode) {
					return true
				}
			}
		}

		if @abstract && @abstractMethods[name] is Array {
			for var method in @abstractMethods[name] {
				if method.isSubsetOf(type, mode) {
					return true
				}
			}
		}

		if @extending && mode ~~ MatchingMode::Superclass {
			return @extends.type().hasMatchingInstanceMethod(name, type, mode)
		}

		return false
	} # }}}
	hasSealedConstructors(): Boolean => @seal?.constructors
	hasSealedInstanceMethod(name) { # {{{
		if @seal.instanceMethods[name] {
			return true
		}

		if @extending {
			return @extends.type().hasSealedInstanceMethod(name)
		}
		else {
			return false
		}
	} # }}}
	incDefaultSequence() { # {{{
		return ++@sequences.defaults
	} # }}}
	incDestructorSequence() { # {{{
		return ++@sequences.destructors
	} # }}}
	incInitializationSequence() { # {{{
		return ++@sequences.initializations
	} # }}}
	incSharedMethod(name: String): Number { # {{{
		if var value = @sharedMethods[name] {
			@sharedMethods[name] = ++value
		}
		else {
			@sharedMethods[name] = 0
		}

		return @sharedMethods[name]
	} # }}}
	isAbstract() => @abstract
	isAltering() => @altering
	isAsyncClassMethod(name) { # {{{
		if @classMethods[name] is Array {
			return @classMethods[name][0].isAsync()
		}
		else if @extending {
			return @extends.type().isAsyncClassMethod(name)
		}
		else {
			return null
		}
	} # }}}
	isAsyncInstanceMethod(name) { # {{{
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
	} # }}}
	isClass() => true
	isConstructor(name: String) => name == 'constructor'
	isDestructor(name: String) => name == 'destructor'
	isExhaustive() { # {{{
		if @exhaustive {
			return true
		}

		if @altering {
			return @majorOriginal.isExhaustive()
		}

		if @extending {
			return @extends.isExhaustive()
		}
		else {
			return super.isExhaustive()
		}
	} # }}}
	isExhaustiveConstructor() => @exhaustiveness.constructor
	isExhaustiveConstructor(node) => this.isExhaustive(node) && this.isExhaustiveConstructor()
	isExhaustiveClassMethod(name) { # {{{
		if @exhaustiveness.classMethods[name]? {
			return @exhaustiveness.classMethods[name]
		}
		else if @extending {
			return @extends.type().isExhaustiveClassMethod(name)
		}
		else {
			return @exhaustive
		}
	} # }}}
	isExhaustiveClassMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveClassMethod(name)
	isExhaustiveInstanceMethod(name) { # {{{
		if @exhaustiveness.instanceMethods[name]? {
			return @exhaustiveness.instanceMethods[name]
		}
		else if @abstract && this.hasAbstractMethod(name) {
			return true
		}
		else if @extending {
			return @extends.type().isExhaustiveInstanceMethod(name)
		}
		else {
			return @exhaustive
		}
	} # }}}
	isExhaustiveInstanceMethod(name, node) => this.isExhaustive(node) && this.isExhaustiveInstanceMethod(name)
	isExplicitlyExported() => @explicitlyExported
	isExtendable() => true
	isExtending() => @extending
	isFlexible() => @sealed
	isHybrid() => @hybrid
	isInitializing() => @sequences.initializations != -1
	// TODO rename to `isSubclassOf`
	isInstanceOf(value: ClassType) { # {{{
		if this == value {
			return true
		}

		if @extending && @extends.type().isInstanceOf(value) {
			return true
		}

		return false
	} # }}}
	isInstanceOf(value: NamedType) => this.isInstanceOf(value.type())
	isMergeable(type) => type.isClass()
	isPredefined() => @predefined
	isSealable() => true
	isSealedInstanceMethod(name: String) => @seal.instanceMethods[name] ?? false
	isSubsetOf(value: ClassType, mode: MatchingMode) { # {{{
		if this == value {
			return true
		}

		if mode ~~ MatchingMode::Subclass && @extending && @extends.type().isInstanceOf(value) {
			return true
		}

		if mode ~~ MatchingMode::Exact {
			return false
		}

		if mode ~~ MatchingMode::Similar {
			for var variable, name of value._instanceVariables {
				if !@instanceVariables[name]?.isSubsetOf(variable, mode) {
					return false
				}
			}

			for var variable, name of value._classVariables {
				if !@classVariables[name]?.isSubsetOf(variable, mode) {
					return false
				}
			}

			var mut functionMode = MatchingMode::FunctionSignature + MatchingMode::Similar
			functionMode += MatchingMode::Renamed if mode ~~ MatchingMode::Renamed

			for var methods, name of value._instanceMethods {
				if @instanceMethods[name] is not Array {
					return false
				}

				for var method in methods {
					if !method.isSupersetOf(@instanceMethods[name], functionMode) {
						return false
					}
				}
			}

			for var methods, name of value._classMethods {
				if @classMethods[name] is not Array {
					return false
				}

				for var method in methods {
					if !method.isSupersetOf(@classMethods[name], functionMode) {
						return false
					}
				}
			}

			return true
		}

		return false
	} # }}}
	isSubsetOf(value: DictionaryType, mode: MatchingMode) { # {{{
		if value.hasRest() {
			return false unless value.getRestType().isNullable()
		}

		for var type, name of value.properties() {
			if var prop = @getInstanceProperty(name) {
				return false unless prop.isSubsetOf(type, mode)
			}
			else {
				return false unless type.isNullable()
			}
		}

		return true
	} # }}}
	isSubsetOf(value: NamedType, mode: MatchingMode) => this.isSubsetOf(value.type(), mode)
	level() => @level
	listAccessibleConstructors() { # {{{
		if @constructors.length != 0 {
			return @constructors
		}
		else if @extending {
			return @extends.type().listAccessibleConstructors()
		}
		else {
			return []
		}
	} # }}}
	listClassMethods(name: String) { # {{{
		if @classMethods[name] is Array {
			return @classMethods[name]
		}

		return null
	} # }}}
	listClassMethods(name: String, type: FunctionType, mode: MatchingMode): Array { # {{{
		var result = []

		if var methods = @classMethods[name] {
			for method in methods {
				if method.isSubsetOf(type, mode) {
					result.push(method)
				}
			}
		}

		if result.length > 0 {
			return result
		}

		if @extending {
			return @extends.type().listClassMethods(name, type, mode)
		}

		return result
	} # }}}
	listConstructors() => @constructors
	listConstructors(type: FunctionType, mode: MatchingMode): Array { # {{{
		var result = []

		for var method in @constructors {
			if method.isSubsetOf(type, mode) {
				result.push(method)
			}
		}

		if result.length > 0 {
			return result
		}

		if @extending {
			return @extends.type().listConstructors(type, mode)
		}

		return result
	} # }}}
	listInstanceMethods(name: String) { # {{{
		if @instanceMethods[name] is Array {
			return @instanceMethods[name]
		}

		return null
	} # }}}
	listInstantiableMethods(name: String) { # {{{
		var methods = []

		if var functions = @instanceMethods[name] {
			methods.push(...functions)
		}

		if @abstract {
			if var functions = @abstractMethods[name] {
				methods.push(...functions)
			}
		}

		return methods
	} # }}}
	listInstantiableMethods(name: String, type: FunctionType, mode: MatchingMode): Array { # {{{
		var result = []

		if var methods = @instanceMethods[name] {
			for method in methods {
				if method.isSubsetOf(type, mode) {
					result.push(method)
				}
			}
		}

		if result.length > 0 {
			return result
		}

		if @abstract {
			if var methods = @abstractMethods[name] {
				for method in methods {
					if method.isSubsetOf(type, mode) {
						result.push(method)
					}
				}
			}
		}

		if result.length > 0 {
			return result
		}

		if @extending {
			return @extends.type().listInstantiableMethods(name, type, mode)
		}

		return result
	} # }}}
	listMatchingConstructors(type: FunctionType, mode: MatchingMode) { # {{{
		var results: Array = []

		for var constructor in @constructors {
			if constructor.isSubsetOf(type, mode) {
				results.push(constructor)
			}
		}

		return results
	} # }}}
	listMatchingInstanceMethods(name, type: FunctionType, mode: MatchingMode) { # {{{
		var results: Array = []

		if @instanceMethods[name] is Array {
			for var method in @instanceMethods[name] {
				if method.isSubsetOf(type, mode) {
					results.push(method)
				}
			}
		}

		if @abstract && @abstractMethods[name] is Array {
			for var method in @abstractMethods[name] {
				if method.isSubsetOf(type, mode) {
					results.push(method)
				}
			}
		}

		return results
	} # }}}
	listMissingAbstractMethods() { # {{{
		unless @extending {
			return []
		}

		var abstractMethods = {}

		@extends.type().filterAbstractMethods(abstractMethods)

		var mode = MatchingMode::Signature - MatchingMode::MissingParameterType

		var matchables = []

		var mut method, index
		for var methods, name of abstractMethods when @instanceMethods[name] is Array {
			for method, index in methods desc {
				if method.isSubsetOf(@instanceMethods[name], mode) {
					methods.splice(index, 1)
				}
			}

			if methods.length == 0 {
				delete abstractMethods[name]
			}
		}

		return abstractMethods
	} # }}}
	majorOriginal() => @majorOriginal
	matchArguments(arguments: Array<Type>, node: AbstractNode) { # {{{
		if @constructors.length == 0 {
			if @extending {
				return @extends.type().matchArguments(arguments, node)
			}
			else {
				return @alien || arguments.length == 0
			}
		}
		else {
			for constructor in @constructors {
				if constructor.matchArguments(arguments, node) {
					return true
				}
			}

			return false
		}
	} # }}}
	matchInstanceWith(object: DictionaryType, matchables) { # {{{
		for var property, name of object._properties {
			if @instanceVariables[name]?.isSubsetOf(property, MatchingMode::Signature) {
			}
			else if @instanceMethods[name] is Array {
				var mut nf = true

				for method in @instanceMethods[name] while nf {
					if method.isSubsetOf(property, MatchingMode::FunctionSignature) {
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
	} # }}}
	metaReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module, name: String) { # {{{
		if @predefined {
			return name
		}
		else {
			return [this.toMetadata(references, indexDelta, mode, module), name]
		}
	} # }}}
	minorOriginal() => @minorOriginal ?? @majorOriginal
	origin() { # {{{
		if @origin? {
			return @origin
		}
		else if @majorOriginal? {
			return @majorOriginal.origin()
		}
		else {
			return null
		}
	} # }}}
	originals(@majorOriginal, @minorOriginal = null): this { # {{{
		@altering = true
	} # }}}
	overwriteConstructor(type, methods) { # {{{
		@constructors.remove(...methods)

		if var alterMethods = @majorOriginal?._constructors {
			var indexes = [method.index() for var method in alterMethods]
			var overwrite = [method.index() for var method in methods when indexes.contains(method.index())]

			if overwrite.length != 0 {
				type.overwrite(overwrite)

				@overwritten.constructors = overwrite
			}
		}

		return this.addConstructor(type)
	} # }}}
	overwriteInstanceMethod(name: String, type, methods) { # {{{
		@instanceMethods[name]:Array.remove(...methods)

		if var alterMethods = @majorOriginal?._instanceMethods[name] {
			var indexes = [method.index() for var method in alterMethods]
			var overwrite = [method.index() for var method in methods when indexes.contains(method.index())]

			if overwrite.length != 0 {
				type.overwrite(overwrite)

				@overwritten.instanceMethods[name] = overwrite
			}
		}

		return this.addInstanceMethod(name, type)
	} # }}}
	parameter() => AnyType.NullableUnexplicit
	setExhaustive(@exhaustive) { # {{{
		if @exhaustive {
			if @extending {
				var extends = @extends.type()

				@exhaustiveness.constructor = @constructors.length != 0 || extends.isExhaustiveConstructor()

				for var _, name of @instanceMethods {
					@exhaustiveness.instanceMethods[name] = extends.isExhaustiveInstanceMethod(name)
				}

				for var _, name of @classMethods {
					@exhaustiveness.classMethods[name] = extends.isExhaustiveClassMethod(name)
				}
			}
			else {
				if @alien {
					@exhaustiveness.constructor = @constructors.length != 0
				}
				else {
					@exhaustiveness.constructor = true
				}

				for var _, name of @instanceMethods {
					@exhaustiveness.instanceMethods[name] ??= true
				}

				for var _, name of @classMethods {
					@exhaustiveness.classMethods[name] ??= true
				}
			}
		}
		else {
			@exhaustiveness.constructor = false

			for var _, name of @instanceMethods {
				@exhaustiveness.instanceMethods[name] ??= false
			}

			for var _, name of @classMethods {
				@exhaustiveness.classMethods[name] ??= false
			}
		}

		return this
	} # }}}
	shallBeNamed() => true
	toAlterationReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if @referenceIndex != -1 {
			return {
				reference: @referenceIndex
			}
		}
		else if ?@majorOriginal {
			return @majorOriginal.toAlterationReference(references, indexDelta, mode, module)
		}
		else {
			return this.toReference(references, indexDelta, mode, module)
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	toMetadata(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if mode ~~ ExportMode::Export {
			if !?@minorOriginal && ?@origin && @origin ~~ TypeOrigin::ExternOrRequire | TypeOrigin::RequireOrExtern {
				var require = ClassType.getRequireReference(this)
				var extern = ClassType.getExternReference(this)

				if require? && extern? {
					var referenceIndex = references.length + indexDelta

					references.push({
						originals: @origin ~~ TypeOrigin::ExternOrRequire ? [extern, require] : [require, extern]
					})

					@referenceIndex = referenceIndex

					return @referenceIndex
				}
				else {
					return require ?? extern
				}
			}

			if ?@majorOriginal && !(@exported || @alien) {
				return @majorOriginal.toMetadata(references, indexDelta, mode, module)
			}
		}

		return super(references, indexDelta, mode, module)
	} # }}}
	toReference(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if mode ~~ ExportMode::Alien {
			if @minorOriginal? {
				return @minorOriginal.toReference(references, indexDelta, mode, module)
			}
			else if @majorOriginal? && !@majorOriginal.isPredefined() {
				return @majorOriginal.toReference(references, indexDelta, mode, module)
			}
		}
		else if mode ~~ ExportMode::Requirement {
			if @majorOriginal? && !this.isRequirement() {
				return @majorOriginal.toReference(references, indexDelta, mode, module)
			}
		}

		return super(references, indexDelta, mode, module)
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw new NotImplementedException(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('class', @sequences.initializations, @sequences.defaults, @sequences.constructors, @sequences.destructors)

		for var sequence, name of @sequences.classMethods {
			variations.push(name, sequence)
		}

		for var sequence, name of @sequences.instanceMethods {
			variations.push(name, sequence)
		}
	} # }}}
	unflagAltering(): this { # {{{
		for var methods of this._abstractMethods {
			for var method in methods {
				method.unflagAltering()
			}
		}
		for var methods of this._classMethods {
			for var method in methods {
				method.unflagAltering()
			}
		}
		for var methods of this._instanceMethods {
			for var method in methods {
				method.unflagAltering()
			}
		}

		for var variable of this._classVariables {
			variable.unflagAltering()
		}
		for var variable of this._instanceVariables {
			variable.unflagAltering()
		}

		@altering = false
	} # }}}
	updateInstanceMethodIndex(name: String, type: ClassMethodType): Number? { # {{{
		var root = this.ancestor()
		var index = ++root._sequences.instanceMethods[name]

		type.setForkedIndex(index)

		return index
	} # }}}
}

class ClassMethodSetType extends OverloadedFunctionType {
	constructor(@scope, @functions) { # {{{
		super(scope)

		for function in functions {
			if function.isAsync() {
				@async = true
				break
			}
		}
	} # }}}
	isMethod() => true
}
