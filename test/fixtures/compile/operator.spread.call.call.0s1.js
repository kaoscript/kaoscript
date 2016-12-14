module.exports = function() {
	let foo = [1, 2];
	let bar = [];
	bar.push.apply(bar, [].concat(foo, 99));
}