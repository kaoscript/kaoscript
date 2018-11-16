module.exports = function() {
	let foo = [1, 2];
	let bar = [];
	bar.push.apply(bar, [].concat([0], foo));
};