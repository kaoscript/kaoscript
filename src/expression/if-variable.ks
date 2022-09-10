class IfVariableDeclarationExpression extends Expression {
	private late {
		@autotype: Boolean
		@await: Boolean
		@declarators: Array			= []
		@destructuring: Boolean		= false
		@immutable: Boolean
		@init
	}
	analyse() { # {{{
		@immutable = !@data.rebindable
		@autotype = @immutable || @data.autotype
		@await = @data.await

		for var data in @data.variables {
			var late declarator

			switch data.name.kind {
				NodeKind::ArrayBinding => {
					declarator = new VariableBindingDeclarator(data, this)
				}
				NodeKind::Identifier => {
					declarator = new VariableIdentifierDeclarator(data, this)
				}
				NodeKind::ObjectBinding => {
					declarator = new VariableBindingDeclarator(data, this)
				}
				=> {
					console.info(data)
					throw new NotImplementedException(this)
				}
			}

			declarator.analyse()

			@declarators.push(declarator)
		}

		@init = $compile.expression(@data.init, this)
		@init.analyse()
	} # }}}
	override prepare(target) { # {{{
		@init.prepare(target)

		if @autotype {
			@declarators[0].type(@init.type())
		}

		for var declarator in @declarators {
			declarator.prepare()
		}
	} # }}}
	translate() { # {{{
		@init.translate()

		for declarator in @declarators {
			declarator.translate()
		}
	} # }}}
	isImmutable() => @immutable
	toFragments(fragments, mode) { # {{{
		if @await {
			throw new NotImplementedException(this)
		}
		else {
			fragments
				.code($runtime.type(this) + '.isValue(')
				.compile(@declarators[0])
				.code($equals)
				.compile(@init)
				.code(')')
		}
	} # }}}
}
