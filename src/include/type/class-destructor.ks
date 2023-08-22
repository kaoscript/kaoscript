class ClassDestructorType extends FunctionType {
	private {
		@access: Accessibility	= Accessibility.Public
	}
	constructor(data, node) { # {{{
		super([], data, node)
	} # }}}
	access(@access) => this
	export(references: Array, indexDelta: Number, mode: ExportMode, module: Module) => { # {{{
		access: @access
		errors: [error.toReference(references, indexDelta, mode, module) for var error in @errors]
	} # }}}
	private processModifiers(modifiers) { # {{{
		for var modifier in modifiers {
			match modifier.kind {
				ModifierKind.Async {
					throw NotImplementedException.new()
				}
				ModifierKind.Private {
					@access = Accessibility.Private
				}
				ModifierKind.Protected {
					@access = Accessibility.Protected
				}
			}
		}
	} # }}}
}
