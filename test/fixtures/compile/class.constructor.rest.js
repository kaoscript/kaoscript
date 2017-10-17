module.exports = function() {
	class Message {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(...messages) {
			this._messages = messages;
		}
		__ks_cons(args) {
			Message.prototype.__ks_cons_0.apply(this, args);
		}
	}
	return {
		Message: Message
	};
};