module.exports = function() {
	let foo = (function() {
		return [1, 2];
	})();
	let bar = [];
	bar.push(...foo);
};