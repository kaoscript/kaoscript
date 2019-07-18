module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_sttc_clone_0 = function() {
		return this;
	};
	__ks_Object._cm_clone = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 0) {
			return __ks_Object.__ks_sttc_clone_0();
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const foobar = {
		qux: 42
	};
	return {
		foobar: foobar
	};
};