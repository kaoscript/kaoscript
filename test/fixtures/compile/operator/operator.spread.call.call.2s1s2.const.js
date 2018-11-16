module.exports = function() {
	const foo = [1, 2];
	const bar = [];
	const qux = [3, 2];
	bar.push(0, 4, ...foo, 1, ...qux, 7, 9);
};