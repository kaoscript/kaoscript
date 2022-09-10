class ClassDestructorType extends FunctionType {
	private {
		@access: Accessibility	= Accessibility::Public
	}
	constructor(data, node) { # {{{
		super([], data, node)

		@min = 1
		@max = 1
	} # }}}
	access(@access) => this
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => { # {{{
		access: @access
		errors: [error.toReference(references, indexDelta, mode, module) for error in @errors]
	} # }}}
	private processModifiers(modifiers) { # {{{
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
	} # }}}
}
