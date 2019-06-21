class IfVariableDeclarationExpression extends Expression {
	private {
		_autotype: Boolean
		_await: Boolean
		_declarators: Array			= []
		_destructuring: Boolean		= false
		_immutable: Boolean
		_init
	}
	analyse() { // {{{
		@immutable = !@data.rebindable
		@autotype = @immutable || @data.autotype
		@await = @data.await

		let declarator
		for data in @data.variables {
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
	} // }}}
	prepare() { // {{{
		@init.prepare()

		if @autotype {
			@declarators[0].type(@init.type())
		}

		for declarator in @declarators {
			declarator.prepare()
		}
	} // }}}
	translate() { // {{{
		@init.translate()

		for declarator in @declarators {
			declarator.translate()
		}
	} // }}}
	isImmutable() => @immutable
	toFragments(fragments, mode) { // {{{
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
	} // }}}
}