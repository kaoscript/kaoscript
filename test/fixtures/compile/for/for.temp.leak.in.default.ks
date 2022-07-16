func init(data, builder) {
	const block = builder.newBlock()

	for statement in data.block(data.body).statements {
		block.statement(statement)
	}

	block.done()

	let source = ''

	for fragment in builder.toArray() {
		source += fragment.code
	}

	return source
}