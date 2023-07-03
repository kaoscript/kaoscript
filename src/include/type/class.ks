enum Accessibility {
	Internal = 1
	Private
	Protected
	Public

	static isLessAccessibleThan(source: Accessibility, target: Accessibility): Boolean { # {{{
		return match source {
			.Public => false
			.Protected => target == .Public
			.Private => target == .Protected | .Public
			.Internal => target == .Private | .Protected | .Public
		}
	} # }}}
}

bitmask ClassFeature {
	None

	Constructor
	Field
	InstanceMethod
	StaticMethod

	All = Constructor + Field + InstanceMethod + StaticMethod
}

class ClassType extends Type {
	private {
		@abstract: Boolean					= false
		@abstractMethods: Object			= {}
		@alterations						= {
			staticMethods:		{}
			staticVariables:	{}
			constructors:		{}
			instanceMethods:	{}
			instanceVariables:	{}
		}
		@altering: Boolean					= false
		@constructors: Array				= []
		@constructorAssessment				= null
		@exhaustiveness						= {
			constructor:		false
			staticMethods:		{}
			instanceMethods:	{}
		}
		@explicitlyExported: Boolean		= false
		@extending: Boolean					= false
		@extends: NamedType<ClassType>?		= null
		@features: ClassFeature				= ClassFeature.All
		@fullyImplementedMethods: Boolean{}	= {}
		@hybrid: Boolean					= false
		@implementing: Boolean				= false
		@init: Number						= 0
		@instanceAssessments: Object		= {}
		@instanceMethods: Object			= {}
		@instanceVariables: Object			= {}
		@interfaces	: NamedType[]			= []
		@level: Number						= 0
		@majorOriginal: ClassType?
		@minorOriginal: ClassType?
		@labelables							= {
			constructors:		null
			instanceMethods:	{}
			staticMethods:		{}
		}
		@overwritten						= {
			constructors:		null
			instanceMethods:	{}
			staticMethods:		{}
		}
		@predefined: Boolean				= false
		@sharedMethods: Object<Number>		= {}
		@seal								= {
			constructors:		false
			instanceMethods:	{}
			instanceVariables:	{}
			staticMethods:		{}
			staticVariables:	{}
		}
		@sequences	 						= {
			constructors:		-1
			defaults:			-1
			destructors:		-1
			initializations:	-1
			instanceMethods:	{}
			staticMethods:		{}
		}
		@staticAssessments: Object			= {}
		@staticMethods: Object				= {}
		@staticVariables: Object			= {}
	}
	static {
		getExternReference(...types?): Number? { # {{{
			for var type in types when ?type {
				if type.isAlien() && !type.isRequirement() && type.referenceIndex() != -1 {
					return type.referenceIndex()
				}

				if ?type._majorOriginal {
					if var reference ?= ClassType.getExternReference(type._majorOriginal) {
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
			if ?type.origin() {
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
		import(index, data, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode): ClassType { # {{{
			var type = ClassType.new(scope)

			type._sequences.initializations = data.sequences[0]
			type._sequences.defaults = data.sequences[1]
			type._sequences.destructors = data.sequences[2]

			type._exhaustive = data.exhaustive

			if ?data.exhaustiveness {
				if ?data.exhaustiveness.constructor {
					type._exhaustiveness.constructor = data.exhaustiveness.constructor
				}

				if ?data.exhaustiveness.staticMethods {
					type._exhaustiveness.staticMethods = data.exhaustiveness.staticMethods
				}

				if ?data.exhaustiveness.instanceMethods {
					type._exhaustiveness.instanceMethods = data.exhaustiveness.instanceMethods
				}
			}

			if ?data.sharedMethods {
				type._sharedMethods = data.sharedMethods
			}

			if ?data.origin {
				type._origin = TypeOrigin(data.origin)
			}

			if ?data.original {
				queue.push(() => {
					var original = references[data.original].discardName()

					ClassType.importFromOriginal(data, type, original, alterations[data.original], metadata, references, alterations, queue, scope, node)

					references[data.original].reference().reset()
				})
			}
			else if ?data.originals {

				queue.push(() => {
					var first = references[data.originals[0]].discardName()
					var second = references[data.originals[1]].discardName()

					var [major, minor] = first.origin() ~~ TypeOrigin.Require ? [first, second] : [second, first]
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

				if data.system {
					type.flagSystem()
				}
				else if data.sealed {
					type.flagSealed()
				}

				if data.features {
					type._features = data.features
				}

				queue.push(() => {
					if ?data.extends {
						type.extends(Type.import(data.extends, metadata, references, alterations, queue, scope, node).discardReference())
					}

					if ?data.implements {
						for var interface in data.implements {
							type.addInterface(Type.import(interface, metadata, references, alterations, queue, scope, node).discardReference())
						}
					}

					if data.abstract {
						for var methods, name of data.abstractMethods {
							for var method in methods {
								type.dedupAbstractMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
							}
						}
					}

					for var method in data.constructors {
						type.addConstructor(ClassConstructorType.import(method, metadata, references, alterations, queue, scope, node))
					}

					for var vtype, name of data.instanceVariables {
						if !type.hasInstanceVariable(name) {
							type.addInstanceVariable(name, ClassVariableType.import(vtype, metadata, references, alterations, queue, scope, node))
						}
					}

					for var vtype, name of data.staticVariables {
						if !type.hasStaticVariable(name) {
							type.addStaticVariable(name, ClassVariableType.import(vtype, metadata, references, alterations, queue, scope, node))
						}
					}

					for var methods, name of data.instanceMethods {
						for var method in methods {
							type.dedupInstanceMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
						}
					}

					for var methods, name of data.staticMethods {
						for var method in methods {
							type.dedupStaticMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
						}
					}

					type.setExhaustive(data.exhaustive)
				})
			}

			return type.flagComplete()
		} # }}}
		importFromOriginal(data, type: ClassType, original: ClassType, isArgument: Boolean?, metadata: Array, references: Object, alterations: Object, queue: Array, scope: Scope, node: AbstractNode) { # {{{
			type.copyFrom(original)

			if type.isAbstract() {
				for var methods, name of data.abstractMethods {
					for var method in methods {
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

			for var vtype, name of data.staticVariables {
				if !type.hasStaticVariable(name) {
					type.addStaticVariable(name, ClassVariableType.import(vtype, metadata, references, alterations, queue, scope, node))
				}
			}

			for var methods, name of data.instanceMethods {
				for var method in methods {
					type.dedupInstanceMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
				}
			}

			for var methods, name of data.staticMethods {
				for var method in methods {
					type.dedupStaticMethod(name, ClassMethodType.import(method, metadata, references, alterations, queue, scope, node))
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
			sequences[name] += 1

			index = sequences[name]

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
	addConstructor(type: ClassConstructorType) { # {{{
		var mut index = type.index()
		if index == -1 {
			@sequences.constructors += 1

			index = @sequences.constructors

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

		@labelables.constructors ||= type.hasOnlyLabeledParameter()

		return index
	} # }}}
	addInstanceMethod(name: String, type: ClassMethodType): Number? { # {{{
		var root = @ancestor()
		var sequences = root._sequences.instanceMethods

		@instanceMethods[name] = @instanceMethods[name] ?? []
		sequences[name] = sequences[name] ?? -1

		var mut index = type.index()
		if index == -1 {
			sequences[name] += 1

			index = sequences[name]

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

		@labelables.instanceMethods[name] ||= type.hasOnlyLabeledParameter()

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
	addInterface(type: NamedType) { # {{{
		@implementing = true

		@interfaces.push(type)
	} # }}}
	addPropertyFromAST(data, node) { # {{{
		var options = Attribute.configure(data, null, AttributeTarget.Property, node.file())

		match data.kind {
			NodeKind.FieldDeclaration {
				var mut instance = true
				for i from 0 to~ data.modifiers.length while instance {
					instance = false if data.modifiers[i].kind == ModifierKind.Static
				}

				var type = ClassVariableType.fromAST(data, node)

				if instance {
					@addInstanceVariable(data.name.name, type)
				}
				else {
					@addStaticVariable(data.name.name, type)
				}
			}
			NodeKind.MethodDeclaration {
				if @isConstructor(data.name.name) {
					var type = ClassConstructorType.fromAST(data, node)

					if options.rules.nonExhaustive {
						@exhaustiveness.constructor = false
					}

					@addConstructor(type)
				}
				else if @isDestructor(data.name.name) {
					throw NotImplementedException.new(node)
				}
				else {
					var mut instance = true
					for i from 0 to~ data.modifiers.length while instance {
						instance = false if data.modifiers[i].kind == ModifierKind.Static
					}

					var type = ClassMethodType.fromAST(data, node)

					if options.rules.nonExhaustive {
						if instance {
							@exhaustiveness.instanceMethods[data.name.name] = false
						}
						else {
							@exhaustiveness.staticMethods[data.name.name] = false
						}
					}

					if @isAlien() {
						type.flagAlien()
					}

					if instance {
						@dedupInstanceMethod(data.name.name:String, type)
					}
					else {
						@dedupStaticMethod(data.name.name:String, type)
					}
				}
			}
			else {
				throw NotSupportedException.new(`Unexpected kind \(data.kind)`, node)
			}
		}
	} # }}}
	addStaticMethod(name: String, type: ClassMethodType): Number? { # {{{
		var root = @ancestor()
		var sequences = root._sequences.staticMethods

		@staticMethods[name] = @staticMethods[name] ?? []
		sequences[name] = sequences[name] ?? -1

		var mut index = type.index()

		if index == -1 {
			sequences[name] += 1

			index = sequences[name]

			type.index(index)
		}
		else {
			if index > sequences[name] {
				sequences[name] = index
			}
		}

		@staticMethods[name].push(type)

		if type.isSealed() {
			@seal.staticMethods[name] = true
		}
		else if @alien {
			type.flagAlien()
		}

		@alterations.staticMethods[name] ??= {}
		@alterations.staticMethods[name][index] = true

		@labelables.staticMethods[name] ||= type.hasOnlyLabeledParameter()

		return index
	} # }}}
	addStaticVariable(name: String, type: ClassVariableType) { # {{{
		@staticVariables[name] = type

		if type.isSealed() {
			@seal.staticVariables[name] = true
		}

		@alterations.staticVariables[name] = true
	} # }}}
	ancestor() { # {{{
		if @extending {
			return @extends.type().ancestor()
		}
		else {
			return this
		}
	} # }}}
	clone() { # {{{
		var that = ClassType.new(@scope)

		that.copyFrom(this)

		if @requirement || @alien {
			that.originals(this)
		}

		return that
	} # }}}
	copyFrom(src: ClassType) { # {{{
		@abstract = src._abstract
		@alien = src._alien
		@complete = src._complete
		@extending = src._extending
		@extends = src._extends
		@features = src._features
		@hybrid = src._hybrid
		@sealed = src._sealed
		@system = src._system

		for var methods, name of src._abstractMethods {
			@abstractMethods[name] = [].concat(methods)
		}
		for var methods, name of src._staticMethods {
			@staticMethods[name] = [].concat(methods)
		}
		for var methods, name of src._instanceMethods {
			@instanceMethods[name] = [].concat(methods)
		}

		for var variable, name of src._staticVariables {
			@staticVariables[name] = variable
		}
		for var variable, name of src._instanceVariables {
			@instanceVariables[name] = variable
		}

		@constructors.push(...src._constructors)

		if src._sealed {
			@seal = Object.clone(src._seal)
		}

		@exhaustive = src._exhaustive
		@exhaustiveness = Object.clone(src._exhaustiveness)
		@sequences = Object.clone(src._sequences)

		if src._requirement || src._alien {
			@originals(src)
		}

		return this
	} # }}}
	dedupAbstractMethod(name: String, type: ClassMethodType): Number? { # {{{
		if var id ?= type.index() {
			if @abstractMethods[name] is Array {
				for var method in @abstractMethods[name] {
					if method.index() == id {
						return id
					}
				}
			}
		}

		return @addAbstractMethod(name, type)
	} # }}}
	dedupInstanceMethod(name: String, type: ClassMethodType): Number? { # {{{
		if var id ?= type.index() {
			if @instanceMethods[name] is Array {
				for var method in @instanceMethods[name] {
					if method.index() == id {
						return id
					}
				}
			}
		}

		if var overwrite ?= type.overwrite() {
			if var methods ?= @instanceMethods[name] {
				for var data in overwrite {
					for var i from methods.length - 1 to 0 step -1 when methods[i].index() == data {
						methods.splice(i, 1)
						break
					}
				}
			}
		}

		return @addInstanceMethod(name, type)
	} # }}}
	dedupStaticMethod(name: String, type: ClassMethodType): Number? { # {{{
		if var id ?= type.index() {
			if @staticMethods[name] is Array {
				for var method in @staticMethods[name] {
					if method.index() == id {
						return id
					}
				}
			}
		}

		if var overwrite ?= type.overwrite() {
			var methods = @staticMethods[name]

			for var data in overwrite {
				for var i from methods.length - 1 to 0 step -1 when methods[i].index() == data {
					methods.splice(i, 1)
					break
				}
			}

			type.overwrite(null)
		}

		return @addStaticMethod(name, type)
	} # }}}
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		var exhaustive = @isExhaustive()

		var late export

		var mut exportSuper = false
		if ?@majorOriginal {
			if mode ~~ ExportMode.Export {
				exportSuper = @hasExportableOriginals()
			}
			else if mode ~~ ExportMode.Requirement {
				var mut original? = @majorOriginal

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
				kind: TypeKind.Class
			}

			if mode ~~ ExportMode.Export {
				var origin = @origin()
				var extern = ClassType.getExternReference(@majorOriginal, @minorOriginal)
				var require = ClassType.getRequireReference(@majorOriginal)

				if ?extern {
					if ?require {
						if origin ~~ TypeOrigin.ExternOrRequire {
							export.originals = [extern, require]
						}
						else if origin ~~ TypeOrigin.RequireOrExtern {
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
			export.staticVariables = {}
			export.instanceMethods = {}
			export.staticMethods = {}

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

			for var variable, name of @staticVariables {
				if @alterations.staticVariables[name] {
					export.staticVariables[name] = variable.export(references, indexDelta, mode, module)
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

				if #exportedMethods {
					export.instanceMethods[name] = exportedMethods
				}
			}

			for var methods, name of @staticMethods {
				var exportedMethods = export.staticMethods[name] ?? []
				var originalMethods = original?.listStaticMethods(name)?.map((method, _, _) => method.index())

				for var method in methods when method.isExportable(mode) {
					if @alterations.staticMethods[name]?[method.index()] {
						exportedMethods.push(method.export(references, indexDelta, mode, module, originalMethods))
					}
				}

				if #exportedMethods {
					export.staticMethods[name] = exportedMethods
				}
			}
		}
		else {
			export = {
				kind: TypeKind.Class
				abstract: @abstract
				alien: @alien
				hybrid: @hybrid
				sealed: @sealed
				system: @system
				exhaustive
				constructors: [constructor.export(references, indexDelta, mode, module, null) for var constructor in @constructors]
				instanceVariables: {}
				staticVariables: {}
				instanceMethods: {}
				staticMethods: {}
			}

			for var variable, name of @instanceVariables {
				export.instanceVariables[name] = variable.export(references, indexDelta, mode, module)
			}

			for var variable, name of @staticVariables {
				export.staticVariables[name] = variable.export(references, indexDelta, mode, module)
			}

			for var methods, name of @instanceMethods {
				var exportedMethods = [method.export(references, indexDelta, mode, module, null) for var method in methods when method.isExportable(mode)]

				if exportedMethods.length != 0 {
					export.instanceMethods[name] = exportedMethods
				}
			}

			for var methods, name of @staticMethods {
				var exportedMethods = [method.export(references, indexDelta, mode, module, null) for var method in methods when method.isExportable(mode)]

				if exportedMethods.length != 0 {
					export.staticMethods[name] = exportedMethods
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

			if @implementing {
				export.implements = [interface.metaReference(references, indexDelta, mode, module) for var interface in @interfaces]
			}

			if @features != ClassFeature.All {
				export.features = @features
			}
		}

		if mode !~ ExportMode.Export && ?@origin && @origin ~~ TypeOrigin.Extern && @origin !~ TypeOrigin.Import {
			var origin = @origin - TypeOrigin.Extern - TypeOrigin.Require

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

		for var value, name of @exhaustiveness.staticMethods when value != exhaustive {
			exhaustiveness.staticMethods ??= {}
			exhaustiveness.staticMethods[name] = value
		}

		for var value, name of @exhaustiveness.instanceMethods when value != exhaustive {
			exhaustiveness.instanceMethods ??= {}
			exhaustiveness.instanceMethods[name] = value
		}

		if !Object.isEmpty(exhaustiveness) {
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

		for var variable, name of @staticVariables {
			if @alterations.staticVariables[name] {
				export.staticVariables[name] = variable.export(references, indexDelta, mode, module)
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

		for var methods, name of @staticMethods {
			var exportedMethods = export.staticMethods[name] ?? []

			for var method in methods when method.isExportable(mode) {
				if @alterations.staticMethods[name]?[method.index()] {
					exportedMethods.push(method.export(references, indexDelta, mode, module, true))
				}
			}

			if exportedMethods.length != 0 {
				export.staticMethods[name] = exportedMethods
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

		@sequences.staticMethods = Object.clone(type._sequences.staticMethods)
		@sequences.instanceMethods = Object.clone(type._sequences.instanceMethods)

		@level = type.level():Number + 1
	} # }}}
	features(): @features
	features(@features): this
	flagAbstract() { # {{{
		@abstract = true
	} # }}}
	flagExported(explicitly: Boolean) { # {{{
		if @exported && (@explicitlyExported || !explicitly) {
			return this
		}

		@exported = true
		@explicitlyExported = explicitly

		for var method in @constructors {
			method.flagExported(false)
		}

		for var variable of @instanceVariables {
			variable.type().flagExported(false)
		}

		for var variable of @staticVariables {
			variable.type().flagExported(false)
		}

		for var methods of @instanceMethods when methods is Array {
			for var method in methods {
				method.flagExported(false)
			}
		}

		for var methods of @staticMethods when methods is Array {
			for var method in methods {
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

		for var methods, name of abstractMethods when @instanceMethods[name] is Array {
			for var method, index in methods down {
				if method.isSubsetOf(@instanceMethods[name], MatchingMode.FunctionSignature) {
					methods.splice(index, 1)
				}
			}

			if methods.length == 0 {
				Object.delete(abstractMethods, name)
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
	getAbstractMethod(name: String, type: Type) { # {{{
		if @abstractMethods[name] is Array {
			for var method in @abstractMethods[name] {
				if type.isMatching(method, MatchingMode.FunctionSignature) {
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
	getClassWithInstantiableMethod(name: String, that: NamedType): NamedType { # {{{
		if @instanceMethods[name] is Array {
			return that
		}
		else if @abstract && @abstractMethods[name] is Array {
			return that
		}

		return @extends.type().getClassWithInstantiableMethod(name, @extends)
	} # }}}
	getConstructor(type: FunctionType, mode: MatchingMode) { # {{{
		if @constructors.length == 0 && @extending {
			return @extends.type().getConstructor(type)
		}

		var result = []

		for var method in @constructors {
			if method.isSubsetOf(type, mode) {
				result.push(method)
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
			var methods = @listAccessibleConstructors()

			@constructorAssessment = Router.assess(methods, name, node)
		}

		return @constructorAssessment
	} # }}}
	getConstructorCount() => @sequences.constructors + 1
	getDestructorCount() => @sequences.destructors + 1
	getHierarchy(name) { # {{{
		if @extending {
			var mut class = @extends()

			var hierarchy = [name, class.name()]

			while class.type().isExtending() {
				hierarchy.push((class <- class.type().extends()).name())
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
				return ClassMethodGroupType.new(@scope, @instanceMethods[name])
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
		if ?@instanceVariables[name] {
			return @instanceVariables[name]
		}
		else if @extending {
			return @extends.type().getInstanceVariable(name)
		}

		return null
	} # }}}
	getInstantiableAssessment(name: String, node: AbstractNode) { # {{{
		if var assessment ?= @instanceAssessments[name] {
			return assessment
		}

		var methods = @listInstantiableMethods(name)

		var assessment = Router.assess(methods, name, node)

		@instanceAssessments[name] = assessment

		return assessment
	} # }}}
	getInstantiableProperty(name: String) { # {{{
		if @instanceMethods[name] is Array {
			if @instanceMethods[name].length == 1 {
				return @instanceMethods[name][0]
			}
			else {
				return ClassMethodGroupType.new(@scope, @instanceMethods[name])
			}
		}

		if @abstract {
			if var functions ?= @abstractMethods[name] {
				if functions.length == 1 {
					return functions[0]
				}
				else {
					return ClassMethodGroupType.new(@scope, functions)
				}
			}
		}

		if @instanceVariables[name] is ClassVariableType {
			return @instanceVariables[name]
		}

		if @extending {
			return @extends.type().getInstanceProperty(name)
		}

		return null
	} # }}}
	getMajorReferenceIndex() => @referenceIndex == -1 && ?@majorOriginal ? @majorOriginal.getMajorReferenceIndex() : @referenceIndex
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

		if @extending && mode ~~ MatchingMode.Superclass {
			return @extends.type().getMatchingInstanceMethod(name, type, mode)
		}

		return null
	} # }}}
	getProperty(name: String) => @getStaticProperty(name)
	getSharedMethodIndex(name: String): Number? => @sharedMethods[name]
	getStaticAssessment(name: String, node: AbstractNode) { # {{{
		if @staticMethods[name] is not Array {
			if @extending {
				return @extends.type().getStaticAssessment(name, node)
			}
			else {
				return null
			}
		}

		if @staticAssessments[name] is not Object {
			var methods = [...@staticMethods[name]]

			var mut that = this
			while methods.length == 0 && that.isExtending() {
				that = that.extends().type()

				if var m ?= that.listStaticMethods(name) {
					for var method in m {
						method.pushTo(methods)
					}
				}
			}

			@staticAssessments[name] = Router.assess(methods, name, node)
		}

		return @staticAssessments[name]
	} # }}}
	getStaticProperty(name: String): Type { # {{{
		if @staticMethods[name] is Array {
			return @scope.reference('Function')
		}
		else {
			return @staticVariables[name] ?? Type.Any
		}
	} # }}}
	getStaticVariable(name: String) { # {{{
		if var variable ?= @staticVariables[name] {
			return variable
		}

		return null
	} # }}}
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
	hasConstructors() => @constructors.length != 0
	hasDestructors() => @sequences.destructors != -1
	hasExportableOriginals() { # {{{
		if ?@minorOriginal {
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

		if @extending && mode ~~ MatchingMode.Superclass {
			return @extends.type().hasMatchingInstanceMethod(name, type, mode)
		}

		return false
	} # }}}
	hasMatchingStaticMethod(name, type: FunctionType, mode: MatchingMode) { # {{{
		if @staticMethods[name] is Array {
			for var method in @staticMethods[name] {
				if method.isSubsetOf(type, mode) {
					return true
				}
			}
		}

		if @extending && mode ~~ MatchingMode.Superclass {
			return @extends.type().hasMatchingStaticMethod(name, type, mode)
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
	hasStaticMethod(name) { # {{{
		if @staticMethods[name] is Array {
			return true
		}

		if @extending {
			return @extends.type().hasStaticMethod(name)
		}
		else {
			return false
		}
	} # }}}
	hasStaticVariable(name) { # {{{
		if @staticVariables[name] is ClassVariableType {
			return true
		}

		if @extending {
			return @extends.type().hasStaticVariable(name)
		}
		else {
			return false
		}
	} # }}}
	incDefaultSequence() { # {{{
		@sequences.defaults += 1

		return @sequences.defaults
	} # }}}
	incDestructorSequence() { # {{{
		@sequences.destructors += 1

		return @sequences.destructors
	} # }}}
	incInitializationSequence() { # {{{
		@sequences.initializations += 1

		return @sequences.initializations
	} # }}}
	incSharedMethod(name: String): Number { # {{{
		if var value ?= @sharedMethods[name] {
			@sharedMethods[name] = value + 1
		}
		else {
			@sharedMethods[name] = 0
		}

		return @sharedMethods[name]
	} # }}}
	isAbstract() => @abstract
	isAltering() => @altering
	override isAssignableToVariable(value, anycast, nullcast, downcast, limited) { # {{{
		if value is ObjectType {
			var mut matchingMode = MatchingMode.Exact + MatchingMode.NonNullToNull + MatchingMode.Subclass + MatchingMode.AutoCast

			if anycast {
				matchingMode += MatchingMode.Anycast + MatchingMode.AnycastParameter
			}

			return @isSubsetOf(value, matchingMode)
		}

		return false
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
	isAsyncStaticMethod(name) { # {{{
		if @staticMethods[name] is Array {
			return @staticMethods[name][0].isAsync()
		}
		else if @extending {
			return @extends.type().isAsyncStaticMethod(name)
		}
		else {
			return null
		}
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
	isExhaustiveConstructor(node) => @isExhaustive(node) && @isExhaustiveConstructor()
	isExhaustiveInstanceMethod(name) { # {{{
		if ?@exhaustiveness.instanceMethods[name] {
			return @exhaustiveness.instanceMethods[name]
		}
		else if @abstract && @hasAbstractMethod(name) {
			return true
		}
		else if @extending {
			return @extends.type().isExhaustiveInstanceMethod(name)
		}
		else {
			return @exhaustive
		}
	} # }}}
	isExhaustiveInstanceMethod(name, node) => @isExhaustive(node) && @isExhaustiveInstanceMethod(name)
	isExhaustiveStaticMethod(name) { # {{{
		if ?@exhaustiveness.staticMethods[name] {
			return @exhaustiveness.staticMethods[name]
		}
		else if @extending {
			return @extends.type().isExhaustiveStaticMethod(name)
		}
		else {
			return @exhaustive
		}
	} # }}}
	isExhaustiveStaticMethod(name, node) => @isExhaustive(node) && @isExhaustiveStaticMethod(name)
	isExplicitlyExported() => @explicitlyExported
	isExtendable() => true
	isExtending() => @extending
	isFlexible() => @sealed
	isFullyImplementedMethods(name: String): Boolean { # {{{
		if ?@fullyImplementedMethods[name] {
			return @fullyImplementedMethods[name]
		}
		if !@extending {
			if @abstract && ?@abstractMethods[name] {
				return @fullyImplementedMethods[name] <- false
			}

			return @fullyImplementedMethods[name] <- ?@instanceMethods[name]
		}
		if !@abstract || !@hasAbstractMethod(name) {
			return @fullyImplementedMethods[name] <- @hasInstanceMethod(name)
		}
		if !?@abstractMethods[name] && @extends.type().isFullyImplementedMethods(name) {
			return @fullyImplementedMethods[name] <- true
		}

		@fullyImplementedMethods[name] = false

		var mode = MatchingMode.Signature - MatchingMode.MissingParameterType

		for var method in @listAbstractMethods(name, MatchingScope.Global) {
			return false unless method.isSubsetOf(@listInstanceMethods(name, MatchingScope.Global), mode)
		}

		return @fullyImplementedMethods[name] <- true
	} # }}}
	isHybrid() => @hybrid
	isImplementing() => @implementing
	isInitializing() => @sequences.initializations != -1
	// TODO rename to `isSubclassOf`
	isInstanceOf(value: AnyType) => false
	isInstanceOf(value: ClassType) { # {{{
		if this == value {
			return true
		}

		if @extending && @extends.type().isInstanceOf(value) {
			return true
		}

		return false
	} # }}}
	isInstanceOf(value: NamedType) => @isInstanceOf(value.type())
	isLabelableInstanceMethod(name: String): Boolean => @labelables.instanceMethods[name] ?? false
	isLabelableStaticMethod(name: String): Boolean => @labelables.staticMethods[name] ?? false
	isMergeable(type) => type.isClass()
	isPredefined() => @predefined
	isSealable() => true
	isSealedInstanceMethod(name: String) => @seal.instanceMethods[name] ?? false
	isSubsetOf(value: ClassType, mode: MatchingMode) { # {{{
		if this == value {
			return true
		}

		if mode ~~ MatchingMode.Subclass && @extending && @extends.type().isInstanceOf(value) {
			return true
		}

		if mode ~~ MatchingMode.Exact {
			return false
		}

		if mode ~~ MatchingMode.Similar {
			for var variable, name of value._instanceVariables {
				if !@instanceVariables[name]?.isSubsetOf(variable, mode) {
					return false
				}
			}

			for var variable, name of value._staticVariables {
				if !@staticVariables[name]?.isSubsetOf(variable, mode) {
					return false
				}
			}

			var mut functionMode = MatchingMode.FunctionSignature + MatchingMode.Similar
			functionMode += MatchingMode.Renamed if mode ~~ MatchingMode.Renamed

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

			for var methods, name of value._staticMethods {
				if @staticMethods[name] is not Array {
					return false
				}

				for var method in methods {
					if !method.isSupersetOf(@staticMethods[name], functionMode) {
						return false
					}
				}
			}

			return true
		}

		return false
	} # }}}
	isSubsetOf(value: ObjectType, mode: MatchingMode) { # {{{
		for var type, name of value.properties() {
			if var prop ?= @getInstanceProperty(name) {
				return false unless prop.type().isSubsetOf(type, mode)
			}
			else {
				return false unless type.isNullable()
			}
		}

		var variables = @listInstanceVariables((...) => true)

		if value.hasRest() {
			var rest = value.getRestType()

			for var name in variables when !value.hasProperty(name) {
				return false unless @getInstanceProperty(name).type().isSubsetOf(rest, mode)
			}
		}
		else {
			for var name in variables when !value.hasProperty(name) {
				return false
			}
		}

		return true
	} # }}}
	isSubsetOf(value: NamedType, mode: MatchingMode) => this.isSubsetOf(value.type(), mode)
	level() => @level
	listAbstractMethods(name: String, scope: MatchingScope, result: ClassMethodType[] = []): ClassMethodType[] { # {{{
		if scope == MatchingScope.Element {
			return @abstractMethods[name] ?? []
		}

		if ?@abstractMethods[name] {
			result.push(...@abstractMethods[name])
		}

		if @extending {
			@extends.type().listAbstractMethods(name, scope, result)
		}

		return result
	} # }}}
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
	listInstanceMethods(name: String, scope: MatchingScope, result: ClassMethodType[] = []): ClassMethodType[] { # {{{
		if scope == MatchingScope.Element {
			return @instanceMethods[name] ?? []
		}

		if ?@instanceMethods[name] {
			result.push(...@instanceMethods[name])
		}

		if @extending {
			@extends.type().listInstanceMethods(name, scope, result)
		}

		return result
	} # }}}
	listInstanceVariables(filter: (name: String, type: Type): Boolean, result: String[] = []): String[] { # {{{
		for var type, name of @instanceVariables {
			if filter(name, type) {
				result.push(name)
			}
		}

		if @extending {
			@extends.type().listInstanceVariables(filter, result)
		}

		return result
	} # }}}
	listInstantiableMethods(name: String): ClassMethodType[] { # {{{
		var methods = []

		if var functions ?= @instanceMethods[name] {
			methods.push(...functions)
		}

		if @abstract {
			if var functions ?= @abstractMethods[name] {
				methods.push(...functions)
			}
		}

		if @extending {
			var keys = {}

			for var method in methods {
				keys[method.index()] = true

				if var indexes ?= method.overload() {
					for var index in indexes {
						keys[index] = true
					}
				}
			}

			@extends.type().listInstantiableMethods(name, methods, keys)
		}

		return methods
	} # }}}
	// TODO
	// listInstantiableMethods(name: String, methods: ClassMethodType[], keys: Number{}): Void {
	listInstantiableMethods(name: String, methods: ClassMethodType[], keys): Void { # {{{
		if var functions ?= @instanceMethods[name] {
			for var method in functions {
				if !?keys[method.index()] {
					methods.push(method)

					keys[method.index()] = true
				}
			}
		}

		if @abstract {
			if var functions ?= @abstractMethods[name] {
				for var method in functions {
					if !?keys[method.index()] {
						methods.push(method)

						keys[method.index()] = true
					}
				}
			}
		}

		if @extending {
			@extends.type().listInstantiableMethods(name, methods, keys)
		}
	} # }}}
	listInstantiableMethods(name: String, type: FunctionType, mode: MatchingMode): Array { # {{{
		var result = []

		if var methods ?= @instanceMethods[name] {
			for var method in methods {
				if method.isSubsetOf(type, mode) {
					result.push(method)
				}
			}
		}

		if result.length > 0 {
			return result
		}

		if @abstract {
			if var methods ?= @abstractMethods[name] {
				for var method in methods {
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
	listInterfaces() => @interfaces
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

		var mode = MatchingMode.Signature - MatchingMode.MissingParameterType

		var matchables = []

		for var methods, name of abstractMethods when @instanceMethods[name] is Array {
			for var method, index in methods down {
				if method.isSubsetOf(@instanceMethods[name], mode) {
					methods.splice(index, 1)
				}
			}

			if methods.length == 0 {
				Object.delete(abstractMethods, name)
			}
		}

		return abstractMethods
	} # }}}
	listStaticMethods(name: String) { # {{{
		if @staticMethods[name] is Array {
			return @staticMethods[name]
		}

		return null
	} # }}}
	listStaticMethods(name: String, type: FunctionType, mode: MatchingMode): Array { # {{{
		var result = []

		if var methods ?= @staticMethods[name] {
			for var method in methods {
				if method.isSubsetOf(type, mode) {
					result.push(method)
				}
			}
		}

		if result.length > 0 {
			return result
		}

		if @extending {
			return @extends.type().listStaticMethods(name, type, mode)
		}

		return result
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
			for var constructor in @constructors {
				if constructor.matchArguments(arguments, node) {
					return true
				}
			}

			return false
		}
	} # }}}
	matchInstanceWith(object: ObjectType, matchables) { # {{{
		for var property, name of object._properties {
			if @instanceVariables[name]?.isSubsetOf(property, MatchingMode.Signature) {
			}
			else if @instanceMethods[name] is Array {
				var mut nf = true

				for var method in @instanceMethods[name] while nf {
					if method.isSubsetOf(property, MatchingMode.FunctionSignature) {
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
			return [@toMetadata(references, indexDelta, mode, module), name]
		}
	} # }}}
	minorOriginal() => @minorOriginal ?? @majorOriginal
	origin() { # {{{
		if ?@origin {
			return @origin
		}
		else if ?@majorOriginal {
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

		if var alterMethods ?= @majorOriginal?._constructors {
			var indexes = [method.index() for var method in alterMethods]
			var overwrite = [method.index() for var method in methods when indexes.contains(method.index())]

			if overwrite.length != 0 {
				type.overwrite(overwrite)

				@overwritten.constructors = overwrite
			}
		}

		return @addConstructor(type)
	} # }}}
	overwriteInstanceMethod(name: String, type, methods) { # {{{
		@instanceMethods[name]:Array.remove(...methods)

		if var alterMethods ?= @majorOriginal?._instanceMethods[name] {
			var indexes = [method.index() for var method in alterMethods]
			var overwrite = [method.index() for var method in methods when indexes.contains(method.index())]

			if overwrite.length != 0 {
				type.overwrite(overwrite)

				@overwritten.instanceMethods[name] = overwrite
			}
		}

		return @addInstanceMethod(name, type)
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

				for var _, name of @staticMethods {
					@exhaustiveness.staticMethods[name] = extends.isExhaustiveStaticMethod(name)
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

				for var _, name of @staticMethods {
					@exhaustiveness.staticMethods[name] ??= true
				}
			}
		}
		else {
			@exhaustiveness.constructor = false

			for var _, name of @instanceMethods {
				@exhaustiveness.instanceMethods[name] ??= false
			}

			for var _, name of @staticMethods {
				@exhaustiveness.staticMethods[name] ??= false
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
			return @toReference(references, indexDelta, mode, module)
		}
	} # }}}
	toFragments(fragments, node) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	toMetadata(references: Array, indexDelta: Number, mode: ExportMode, module: Module) { # {{{
		if mode ~~ ExportMode.Export {
			if !?@minorOriginal && ?@origin && @origin ~~ TypeOrigin.ExternOrRequire | TypeOrigin.RequireOrExtern {
				var require = ClassType.getRequireReference(this)
				var extern = ClassType.getExternReference(this)

				if ?require && ?extern {
					var referenceIndex = references.length + indexDelta

					references.push({
						originals: @origin ~~ TypeOrigin.ExternOrRequire ? [extern, require] : [require, extern]
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
		if mode ~~ ExportMode.Alien {
			if ?@minorOriginal {
				return @minorOriginal.toReference(references, indexDelta, mode, module)
			}
			else if ?@majorOriginal && !@majorOriginal.isPredefined() {
				return @majorOriginal.toReference(references, indexDelta, mode, module)
			}
		}
		else if mode ~~ ExportMode.Requirement {
			if ?@majorOriginal && !@isRequirement() {
				return @majorOriginal.toReference(references, indexDelta, mode, module)
			}
		}

		return super(references, indexDelta, mode, module)
	} # }}}
	override toPositiveTestFragments(fragments, node, junction) { # {{{
		throw NotImplementedException.new(node)
	} # }}}
	override toVariations(variations) { # {{{
		variations.push('class', @sequences.initializations, @sequences.defaults, @sequences.constructors, @sequences.destructors)

		for var sequence, name of @sequences.staticMethods {
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
		for var methods of this._staticMethods {
			for var method in methods {
				method.unflagAltering()
			}
		}
		for var methods of this._instanceMethods {
			for var method in methods {
				method.unflagAltering()
			}
		}

		for var variable of this._staticVariables {
			variable.unflagAltering()
		}
		for var variable of this._instanceVariables {
			variable.unflagAltering()
		}

		@altering = false
	} # }}}
	updateInstanceMethodIndex(name: String, type: ClassMethodType): Number? { # {{{
		var root = @ancestor()

		root._sequences.instanceMethods[name] += 1

		var index = root._sequences.instanceMethods[name]

		type.setForkedIndex(index)

		return index
	} # }}}
}

class ClassMethodGroupType extends OverloadedFunctionType {
	clone() { # {{{
		var that = ClassMethodGroupType.new(@scope, [function.clone() for var function in @functions])

		return that
	} # }}}
	isMethod() => true
	setProxy(proxyPath: String, proxyName: String) { # {{{
		for var function in @functions {
			function.setProxy(proxyPath, proxyName)
		}
	} # }}}
}
