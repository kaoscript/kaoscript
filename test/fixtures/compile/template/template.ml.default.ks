func book2xml({ id, author, title, genre, price }) {
	return ```
		<book id="bk\(id)">
			<author>\(author)</author>
			<title>\(title)</title>
			<genre>\(genre)</genre>
			<price>\(price)</price>
		</book>
		```
}
