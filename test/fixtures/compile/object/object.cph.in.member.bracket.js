const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(datas) {
		const values = (() => {
			const o = new OBJ();
			for(let __ks_1 = 0, __ks_0 = datas.length, data; __ks_1 < __ks_0; ++__ks_1) {
				data = datas[__ks_1];
				o[data.index] = data.value;
			}
			return o;
		})();
		return values["hello"];
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};