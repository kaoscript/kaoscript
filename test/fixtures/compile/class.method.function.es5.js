var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function $format(message) {
		if(message === undefined || message === null) {
			throw new Error("Missing parameter 'message'");
		}
		else if(!Type.isString(message)) {
			throw new Error("Invalid type for parameter 'message'");
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
			if(messages === undefined || messages === null) {
				throw new Error("Missing parameter 'messages'");
			}
			else if(!Type.isArray(messages)) {
				throw new Error("Invalid type for parameter 'messages'");
			}
			this._messages = messages;
		}
		__ks_cons(args) {
			if(args.length === 1) {
				LetterBox.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_build_01_0() {
			return this._messages.map(Helper.vcurry(function(message) {
				if(message === undefined || message === null) {
					throw new Error("Missing parameter 'message'");
				}
				return this.format(message);
			}, this));
		}
		build_01() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_01_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_build_02_0() {
			return this._messages.map(Helper.vcurry(function() {
				if(arguments.length < 2) {
					throw new Error("Wrong number of arguments");
				}
				let __ks_i = -1;
				var message = arguments[++__ks_i];
				if(arguments.length > 2) {
					var foo = arguments[++__ks_i];
				}
				else {
					var foo = 42;
				}
				var bar = arguments[++__ks_i];
				return this.format(message);
			}, this));
		}
		build_02() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_02_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_build_03_0() {
			return this._messages.map(Helper.vcurry(function() {
				if(arguments.length < 2) {
					throw new Error("Wrong number of arguments");
				}
				let __ks_i = -1;
				var message = arguments[++__ks_i];
				if(arguments.length > 2) {
					var foo = arguments[++__ks_i];
				}
				else {
					var foo = null;
				}
				var bar = arguments[++__ks_i];
				return this.format(message);
			}, this));
		}
		build_03() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_03_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_build_04_0() {
			return this._messages.map(Helper.vcurry(function(message) {
				if(arguments.length < 2) {
					throw new Error("Wrong number of arguments");
				}
				if(message === undefined || message === null) {
					throw new Error("Missing parameter 'message'");
				}
				let __ks_i;
				let foo = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
				var bar = arguments[__ks_i];
				return this.format(message);
			}, this));
		}
		build_04() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_04_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_build_05_0() {
			return this._messages.map(function(message) {
				if(arguments.length < 2) {
					throw new Error("Wrong number of arguments");
				}
				if(message === undefined || message === null) {
					throw new Error("Missing parameter 'message'");
				}
				let __ks_i;
				let foo = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
				var bar = arguments[__ks_i];
				return $format(message);
			});
		}
		build_05() {
			if(arguments.length === 0) {
				return LetterBox.prototype.__ks_func_build_05_0.apply(this);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_format_0(message) {
			if(message === undefined || message === null) {
				throw new Error("Missing parameter 'message'");
			}
			else if(!Type.isString(message)) {
				throw new Error("Invalid type for parameter 'message'");
			}
			return message.toUpperCase();
		}
		format() {
			if(arguments.length === 1) {
				return LetterBox.prototype.__ks_func_format_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		static __ks_sttc_compose_00_0(box) {
			if(box === undefined || box === null) {
				throw new Error("Missing parameter 'box'");
			}
			return box._messages.map(function(message) {
				if(message === undefined || message === null) {
					throw new Error("Missing parameter 'message'");
				}
				return box.format(message);
			});
		}
		static compose_00() {
			if(arguments.length === 1) {
				return LetterBox.__ks_sttc_compose_00_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		static __ks_sttc_compose_01_0(box) {
			if(box === undefined || box === null) {
				throw new Error("Missing parameter 'box'");
			}
			return box._messages.map(function(message) {
				if(arguments.length < 2) {
					throw new Error("Wrong number of arguments");
				}
				if(message === undefined || message === null) {
					throw new Error("Missing parameter 'message'");
				}
				let __ks_i;
				let foo = arguments.length > 2 ? Array.prototype.slice.call(arguments, 1, __ks_i = arguments.length - 1) : (__ks_i = 1, []);
				var bar = arguments[__ks_i];
				return box.format(message);
			});
		}
		static compose_01() {
			if(arguments.length === 1) {
				return LetterBox.__ks_sttc_compose_01_0.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
	}
	LetterBox.__ks_reflect = {
		inits: 0,
		constructors: [
			{
				access: 3,
				min: 1,
				max: 1,
				parameters: [
					{
						type: "Array",
						min: 1,
						max: 1
					}
				]
			}
		],
		destructors: 0,
		instanceVariables: {
			_messages: {
				access: 1,
				type: "Array"
			}
		},
		classVariables: {},
		instanceMethods: {
			build_01: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			],
			build_02: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			],
			build_03: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			],
			build_04: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			],
			build_05: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: []
				}
			],
			format: [
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: "String",
							min: 1,
							max: 1
						}
					]
				}
			]
		},
		classMethods: {
			compose_00: [
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 1
						}
					]
				}
			],
			compose_01: [
				{
					access: 3,
					min: 1,
					max: 1,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 1
						}
					]
				}
			]
		}
	};
}