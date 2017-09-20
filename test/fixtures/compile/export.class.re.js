require("kaoscript/register");
module.exports = function() {
	var Shape = require("./export.class.default.ks")().Shape;
	class ReShape extends Shape {
		__ks_init() {
			Shape.prototype.__ks_init.call(this);
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