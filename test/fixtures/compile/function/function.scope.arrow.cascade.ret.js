const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.value = Helper.function(() => {
				return Helper.function(() => {
					return this.value();
				}, (fn, ...args) => {
					if(args.length === 0) {
						return fn.call(this);
					}
					throw Helper.badArgs();
				});
			}, (fn, ...args) => {
				if(args.length === 0) {
					return fn.call(this);
				}
				throw Helper.badArgs();
			});
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};