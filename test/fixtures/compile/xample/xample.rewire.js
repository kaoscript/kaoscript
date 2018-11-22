module.exports = function() {
	function rewire(option) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(option === void 0 || option === null) {
			throw new TypeError("'option' is not nullable");
		}
		let files = [];
		let __ks_0 = option.split(",");
		for(let __ks_1 = 0, __ks_2 = __ks_0.length, item; __ks_1 < __ks_2; ++__ks_1) {
			item = __ks_0[__ks_1];
			item = item.split("=");
			files.push({
				input: item[0],
				output: item[1]
			});
		}
		return files;
	}
};