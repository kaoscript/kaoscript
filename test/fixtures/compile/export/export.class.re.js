require("kaoscript/register");
module.exports = function() {
	var Shape = require("../export/.export.class.default.ks.j5k8r9.ksb")().Shape;
	class ReShape extends Shape {
		static __ks_new_0(...args) {
			const o = Object.create(ReShape.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_init() {
			super.__ks_init();
			this._name = "";
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
	}
	const r = ReShape.__ks_new_0("red");
	return {
		ReShape
	};
};