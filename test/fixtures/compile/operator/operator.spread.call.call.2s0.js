module.exports = function() {
	let foo = (() => {
		return [1, 2];
	})();
	let bar = [];
	bar.push.apply(bar, [].concat([0, 4], foo));
};