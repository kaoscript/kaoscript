func load() => { firstname: 'John', lastname: 'Doe' }

with load() {
	echo(`Hello \(.firstname) \(.lastname)`)
}