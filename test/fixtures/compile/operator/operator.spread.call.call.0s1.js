module.exports = function() {
	let foo = (() => {
		return [1, 2];
	})();
	let bar = [];
	bar.push.apply(bar, [].concat(foo, [99]));
};