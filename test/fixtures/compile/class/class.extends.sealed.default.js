module.exports = function() {
	class NotImplementedError extends Error {
		constructor(message) {
			if(message === void 0 || message === null) {
				message = "Not Implemented";
			}
			super();
			this.constructor.prototype.__ks_init();
			this.message = message;
		}
		__ks_init() {
		}
	}
};