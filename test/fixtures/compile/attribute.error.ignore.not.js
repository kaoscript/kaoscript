module.exports = function() {
	var __ks_Error = {};
	class Exception extends Error {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
	}
	throw new Error();
}