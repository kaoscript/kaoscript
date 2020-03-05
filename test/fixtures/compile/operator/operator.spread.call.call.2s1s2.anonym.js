module.exports = function() {
	let foo = (() => {
		return [1, 2];
	})();
	let bar = [];
	let qux = (() => {
		return [3, 2];
	})();
	bar.push.apply(bar, [].concat([0, 4], foo, [1], qux, [7, 9]));
};