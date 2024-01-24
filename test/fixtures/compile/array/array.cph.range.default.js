module.exports = function() {
	const a = (() => {
		const a = [];
		for(let i = 0; i <= 10; ++i) {
			a.push(i);
		}
		return a;
	})();
};