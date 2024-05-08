const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		if(Type.isArray(values)) {
			console.log(values[0]);
			const result = (() => {
				const a = [];
				for(let __ks_1 = 0, __ks_0 = values.length, value; __ks_1 < __ks_0; ++__ks_1) {
					value = values[__ks_1];
					a.push((() => {
						const o = new OBJ();
						o.value = value;
						return o;
					})());
				}
				return a;
			})();
			console.log(result[0].value);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};