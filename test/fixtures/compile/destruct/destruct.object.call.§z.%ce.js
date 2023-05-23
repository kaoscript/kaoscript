const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isIPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber})
	};
	class Position {
		static __ks_new_0(...args) {
			const o = Object.create(Position.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(line, column) {
			this.line = line;
			this.column = column;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isNumber;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return Position.prototype.__ks_cons_0.call(that, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function getLine() {
		return getLine.__ks_rt(this, arguments);
	};
	getLine.__ks_0 = function(position) {
		return position.line;
	};
	getLine.__ks_rt = function(that, args) {
		const t0 = __ksType.isIPosition;
		if(args.length === 1) {
			if(t0(args[0])) {
				return getLine.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	getLine.__ks_0(Position.__ks_new_0(1, 1));
};