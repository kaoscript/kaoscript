var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function $format(message) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(message === void 0 || message === null) {
			throw new TypeError("'message' is not nullable");
		}
		else if(!Type.isString(message)) {
			throw new TypeError("'message' is not of type 'String'");
		}
		return message.toUpperCase();
	}
	class LetterBox {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(messages) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(messages === void 0 || messages === null) {
				throw new TypeError("'messages' is not nullable");
			}
			else if(!Type.isArray(messages)) {
				throw new TypeError("'messages' is not of type 'Array<String>'");
			}
			this._messages = messages;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				LetterBox.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_build_01_0() {
			return this._messages.map((function(message) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				return this.format(message);
			}).bind(this));
		}
		build_01() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_01_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_build_02_0() {
			return this._messages.map((function(message) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				let __ks_i = 0;
				let __ks__;
				let foo = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 42;
				let bar = arguments[++__ks_i];
				if(bar === void 0 || bar === null) {
					throw new TypeError("'bar' is not nullable");
				}
				return this.format(message);
			}).bind(this));
		}
		build_02() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_02_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_build_03_0() {
			return this._messages.map((function(message) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				let __ks_i = 0;
				let __ks__;
				let foo = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
				let bar = arguments[++__ks_i];
				if(bar === void 0 || bar === null) {
					throw new TypeError("'bar' is not nullable");
				}
				return this.format(message);
			}).bind(this));
		}
		build_03() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_03_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_build_04_0() {
			return this._messages.map((function(message) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				let __ks_i = 0;
				let foo = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
				let bar = arguments[__ks_i];
				if(bar === void 0 || bar === null) {
					throw new TypeError("'bar' is not nullable");
				}
				return this.format(message);
			}).bind(this));
		}
		build_04() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_04_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_build_05_0() {
			return this._messages.map(function(message) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				let __ks_i = 0;
				let foo = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
				let bar = arguments[__ks_i];
				if(bar === void 0 || bar === null) {
					throw new TypeError("'bar' is not nullable");
				}
				return $format(message);
			});
		}
		build_05() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_05_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_format_0(message) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(message === void 0 || message === null) {
				throw new TypeError("'message' is not nullable");
			}
			else if(!Type.isString(message)) {
				throw new TypeError("'message' is not of type 'String'");
			}
			return message.toUpperCase();
		}
		format() {
			if(arguments.length === 1) {
				return LetterBox.prototype.__ks_func_format_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_compose_00_0(box) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(box === void 0 || box === null) {
				throw new TypeError("'box' is not nullable");
			}
			return box._messages.map(function(message) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				return box.format(message);
			});
		}
		static compose_00() {
			if(arguments.length === 1) {
				return LetterBox.__ks_sttc_compose_00_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		static __ks_sttc_compose_01_0(box) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(box === void 0 || box === null) {
				throw new TypeError("'box' is not nullable");
			}
			return box._messages.map(function(message) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(message === void 0 || message === null) {
					throw new TypeError("'message' is not nullable");
				}
				let __ks_i = 0;
				let foo = Array.prototype.slice.call(arguments, ++__ks_i, __ks_i = arguments.length - 1);
				let bar = arguments[__ks_i];
				if(bar === void 0 || bar === null) {
					throw new TypeError("'bar' is not nullable");
				}
				return box.format(message);
			});
		}
		static compose_01() {
			if(arguments.length === 1) {
				return LetterBox.__ks_sttc_compose_01_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};