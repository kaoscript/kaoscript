module.exports = function() {
	const foo = (() => {
		return [1, 2];
	})();
	const bar = [];
	bar.push(...foo);
};