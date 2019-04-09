func foobar(scope, name) {
	if (variable ?= scope.getVariable(name)) && (variable.name() != name || variable.scope() != scope) {
		return variable.discard()
	}
	else {
		return null
	}
}