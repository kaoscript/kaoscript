const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isIPosition: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber})
	};
	const Position = Helper.struct(function(line, column) {
		const _ = new OBJ();
		_.line = line;
		_.column = column;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
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
	getLine.__ks_0(Position.__ks_new(1, 1));
};