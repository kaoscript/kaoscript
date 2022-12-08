const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	for(let __ks_0 = 0, __ks_1 = klaw(path.join(__dirname, "fixtures"), (() => {
		const d = new OBJ();
		d.nodir = true;
		d.traverseAll = true;
		d.filter = Helper.function((item) => {
			return item.path.slice(-5) === ".json";
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(this, args[0]);
				}
			}
			throw Helper.badArgs();
		});
		return d;
	})()), __ks_2 = __ks_1.length, file; __ks_0 < __ks_2; ++__ks_0) {
		file = __ks_1[__ks_0];
		prepare(file.path);
	}
};