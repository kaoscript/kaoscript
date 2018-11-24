module.exports = function() {
	let __ks_0 = klaw(path.join(__dirname, "fixtures"), {
		nodir: true,
		traverseAll: true,
		filter(item) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(item === void 0 || item === null) {
				throw new TypeError("'item' is not nullable");
			}
			return item.path.slice(-5) === ".json";
		}
	});
	for(let __ks_1 = 0, __ks_2 = __ks_0.length, file; __ks_1 < __ks_2; ++__ks_1) {
		file = __ks_0[__ks_1];
		prepare(file.path);
	}
};