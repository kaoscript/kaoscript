var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	for(let __ks_0 = 0, __ks_1 = klaw(path.join(__dirname, "fixtures"), (() => {
		const d = new Dictionary();
		d.nodir = true;
		d.traverseAll = true;
		d.filter = function(item) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(item === void 0 || item === null) {
				throw new TypeError("'item' is not nullable");
			}
			return item.path.slice(-5) === ".json";
		};
		return d;
	})()), __ks_2 = __ks_1.length, file; __ks_0 < __ks_2; ++__ks_0) {
		file = __ks_1[__ks_0];
		prepare(file.path);
	}
};