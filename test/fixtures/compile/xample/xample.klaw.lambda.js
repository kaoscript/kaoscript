const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	for(let __ks_2 = klaw(path.join(__dirname, "fixtures"), (() => {
		const o = new OBJ();
		o.nodir = true;
		o.traverseAll = true;
		o.filter = Helper.function((item) => {
			return item.path.slice(-5) === ".json";
		}, (that, fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		});
		return o;
	})()), __ks_1 = 0, __ks_0 = Helper.length(__ks_2), file; __ks_1 < __ks_0; ++__ks_1) {
		file = __ks_2[__ks_1];
		prepare(file.path);
	}
};