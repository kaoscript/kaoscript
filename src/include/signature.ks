enum Accessibility { // {{{
	Private		= 1
	Protected
	Public
} // }}}

class Signature {
	public {
		access: Accessibility		= Accessibility::Public
		async: Boolean				= false
		min: Number					= 0
		max: Number					= 0
		parameters					= []
		throws						= []
	}
	static fromAST(data, parent) { // {{{
		let that = new Signature()
		
		let signature, last
		for parameter in data.parameters {
			signature = {
				type: $signature.type(parameter.type, parent.scope())
				min: parameter.defaultValue? ? 0 : 1
				max: 1
			}
			
			let nf = true
			for modifier in parameter.modifiers while nf {
				if modifier.kind == ModifierKind::Rest {
					if modifier.arity {
						signature.min = modifier.arity.min
						signature.max = modifier.arity.max
					}
					else {
						signature.min = 0
						signature.max = Infinity
					}
					
					nf = true
				}
			}
			
			if !?last || !$method.sameType(signature.type, last.type) {
				if last? {
					if last.max == Infinity {
						if that.max == Infinity {
							SyntaxException.throwTooMuchRestParameter(parent)
						}
						else {
							that.max = Infinity
						}
					}
					else {
						that.max += last.max
					}
					
					that.min += last.min
				}
				
				that.parameters.push(last = Object.clone(signature))
			}
			else {
				if signature.max == Infinity {
					last.max = Infinity
				}
				else {
					last.max += signature.max
				}
				
				last.min += signature.min
			}
		}
		
		if last? {
			if last.max == Infinity {
				if that.max == Infinity {
					SyntaxException.throwTooMuchRestParameter(parent)
				}
				else {
					that.max = Infinity
				}
			}
			else {
				that.max += last.max
			}
			
			that.min += last.min
		}
		
		for modifier in data.modifiers {
			if modifier.kind == ModifierKind::Async {
				that.async = true
			}
			else if modifier.kind == ModifierKind::Private {
				that.access = Accessibility::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				that.access = Accessibility::Protected
			}
		}
		
		if that.async {
			if signature?.type == 'Function' {
				++signature.min
				++signature.max
			}
			else {
				that.parameters.push({
					type: 'Function'
					min: 1
					max: 1
				})
			}
			
			++that.min
			++that.max
		}
		
		if data.type? {
			that.type = $signature.type($type.type(data.type, parent.scope(), parent), parent.scope())
		}
		
		if data.throws? {
			that.throws = [t.name for t in data.throws]
		}
		
		return that
	} // }}}
	static fromNode(parent) { // {{{
		let that = new Signature()
		
		let signature, last
		for parameter in parent._parameters {
			signature = parameter._signature
			
			if !?last || !Type.equals(signature.type, last.type) {
				if last? {
					if last.max == Infinity {
						if that.max == Infinity {
							SyntaxException.throwTooMuchRestParameter(parent)
						}
						else {
							that.max = Infinity
						}
					}
					else {
						that.max += last.max
					}
					
					that.min += last.min
				}
				
				that.parameters.push(last = Object.clone(signature))
			}
			else {
				if signature.max == Infinity {
					last.max = Infinity
				}
				else {
					last.max += signature.max
				}
				
				last.min += signature.min
			}
		}
		
		if last? {
			if last.max == Infinity {
				if that.max == Infinity {
					SyntaxException.throwTooMuchRestParameter(parent)
				}
				else {
					that.max = Infinity
				}
			}
			else {
				that.max += last.max
			}
			
			that.min += last.min
		}
		
		for modifier in parent._data.modifiers {
			if modifier.kind == ModifierKind::Async {
				that.async = true
			}
			else if modifier.kind == ModifierKind::Private {
				that.access = Accessibility::Private
			}
			else if modifier.kind == ModifierKind::Protected {
				that.access = Accessibility::Protected
			}
		}
		
		if that.async {
			if signature?.type == Type.Function {
				++signature.min
				++signature.max
			}
			else {
				that.parameters.push({
					type: Type.Function
					min: 1
					max: 1
				})
			}
			
			++that.min
			++that.max
		}
		
		if parent._data.type? {
			that.type = $signature.type($type.type(parent._data.type, parent.scope(), parent), parent.scope())
		}
		
		if parent._data.throws? {
			that.throws = [t.name for t in parent._data.throws]
		}
		
		return that
	} // }}}
}