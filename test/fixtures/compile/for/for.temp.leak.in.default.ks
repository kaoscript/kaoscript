func init(data, builder) {
	var block = builder.newBlock()

	for statement in data.block(data.body).statements {
		block.statement(statement)
	}

	block.done()

	var dyn source = ''

	for fragment in builder.toArray() {
		source += fragment.code
	}

	return source
}