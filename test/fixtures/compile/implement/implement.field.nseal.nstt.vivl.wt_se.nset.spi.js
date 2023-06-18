require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Shape = require("./.implement.field.nseal.gss.ks.j5k8r9.ksb")().Shape;
	Shape.__ks_new_1 = function(...args) {
		const o = Object.create(Shape.prototype);
		o.__ks_init();
		o.__ks_cons_1(...args);
		return o;
	};
	Shape.prototype.__ks_cons_1 = function(color, name) {
		if(color === void 0 || color === null) {
			color = "black";
		}
		if(name === void 0 || name === null) {
			name = "circle";
		}
		this._color = color;
		this._name = name;
	};
	Shape.prototype.__ks_func_name_0 = function() {
		return this._name;
	};
	Shape.prototype.__ks_func_toString_0 = function() {
		return "I'm drawing a " + this._color + " " + this._name + ".";
	};
	Shape.prototype.__ks_cons_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return Shape.prototype.__ks_cons_1.call(that, Helper.getVararg(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		}
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return Shape.prototype.__ks_cons_1.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	Shape.prototype.__ks_func_name_rt = function(that, proto, args) {
		if(args.length === 0) {
			return proto.__ks_func_name_0.call(that);
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