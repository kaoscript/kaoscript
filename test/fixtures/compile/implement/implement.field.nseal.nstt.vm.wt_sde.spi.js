require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Shape = require("./.implement.field.nseal.gss.ks.j5k8r9.ksb")().Shape;
	Shape.prototype.__ks_func_name_0 = function() {
		return this._name;
	};
	Shape.prototype.__ks_func_name_1 = function(name) {
		this._name = name;
		return this;
	};
	Shape.prototype.__ks_func_toString_0 = function() {
		return "I'm drawing a " + this._color + " " + this._name + ".";
	};
	Shape.prototype.__ks_init_0 = Shape.prototype.__ks_init;
	Shape.prototype.__ks_init = function() {
		this.__ks_init_0();
		this._name = "circle";
	};
	Shape.prototype.__ks_func_name_rt = function(that, proto, args) {
		const t0 = Type.isString;
		if(args.length === 0) {
			return proto.__ks_func_name_0.call(that);
		}
		if(args.length === 1) {
			if(t0(args[0])) {
				return proto.__ks_func_name_1.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	Shape.prototype.name = function() {
		return this.__ks_func_name_rt.call(null, this, this, arguments);
	};
	Shape.prototype.__ks_func_toString_rt = function(that, proto, args) {
		if(args.length === 0) {
			return proto.__ks_func_toString_0.call(that);
		}
		throw Helper.badArgs();
	};
	Shape.prototype.toString = function() {
		return this.__ks_func_toString_rt.call(null, this, this, arguments);
	};
	const shape = Shape.__ks_sttc_makeBlue_0();
	console.log(shape.__ks_func_toString_0());
};