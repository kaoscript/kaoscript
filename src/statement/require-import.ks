class RequireOrImportDeclaration extends Statement {
	private {
		_declarators = []
	}
	analyse() { // {{{
		const directory = this.directory()
		const module = this.module()
		
		let metadata, variable
		for declarator in @data.declarations {
			metadata = $import.resolve(declarator, directory, module, this)
			
			if metadata.importVarCount > 0 {
				for name, alias of metadata.importVariables {
					variable = metadata.exports[name]
					
					variable.requirement = alias
					
					module.require(variable, RequireKind::RequireOrImport, {
						data: @data
						metadata: metadata
						node: this
					})
				}
			}
			else if metadata.importAll {
				for name, variable of metadata.exports {
					variable.requirement = name
					
					module.require(variable, RequireKind::RequireOrImport, {
						data: @data
						metadata: metadata
						node: this
					})
				}
			}
			
			if metadata.importAlias.length {
				$throw('Not Implemented')
			}
		}
	} // }}}
	fuse() { // {{{
	} // }}}
	toStatementFragments(fragments, mode) { // {{{
	} // }}}
}