import '../_/_array.ks'

extern console

func foo(...items) {
	console.log(items.last())
}