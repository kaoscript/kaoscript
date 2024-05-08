module.exports = function() {
	const flag = true;
	const foo = flag ? [] : null;
	return {
		foo
	};
};