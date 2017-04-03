module.exports = function() {
	var __ks_Object = {};
	__ks_Object.__ks_sttc_defaults_0 = function(...args) {
		return __ks_Object._cm_merge.apply(__ks_Object, [].concat({}, args));
	};
	__ks_Object._cm_defaults = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Object.__ks_sttc_defaults_0.apply(null, args);
	};
	__ks_Object.__ks_sttc_merge_0 = function(...args) {
		return {};
	};
	__ks_Object._cm_merge = function() {
		var args = Array.prototype.slice.call(arguments);
		return __ks_Object.__ks_sttc_merge_0.apply(null, args);
	};
	function init(data) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(data === void 0 || data === null) {
			throw new TypeError("'data' is not nullable");
		}
		return __ks_Object._cm_defaults(data, {
			foo: "bar"
		});
	}
}