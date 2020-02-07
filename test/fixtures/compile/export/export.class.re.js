require("kaoscript/register");
module.exports = function() {
	var Shape = require("../export/export.class.default.ks")().Shape;
	class ReShape extends Shape {
		__ks_init_1() {
			this._name = "";
		}
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
			ReShape.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			Shape.prototype.__ks_cons.call(this, args);
		}
	}
	const r = new ReShape("red");
	return {
		ReShape: ReShape
	};
};