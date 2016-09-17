var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Greetings {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new Error("Wrong number of arguments");
			}
		}
		__ks_func_foo_0(...args) {
			console.log(args);
		}
		foo() {
			return Greetings.prototype.__ks_func_foo_0.apply(this, arguments);
		}
		__ks_func_bar_0() {
		}
		__ks_func_bar_1(name, ...messages) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			console.log(name, messages);
		}
		bar() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_bar_0.apply(this);
			}
			else {
				return Greetings.prototype.__ks_func_bar_1.apply(this, arguments);
			}
		}
		__ks_func_baz_0() {
		}
		__ks_func_baz_1() {
			if(arguments.length < 1) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			var foo = arguments[++__ks_i];
			if(arguments.length > 1) {
				var bar = arguments[++__ks_i];
			}
			else  {
				var bar = "bar";
			}
			if(arguments.length > 2) {
				var qux = arguments[++__ks_i];
			}
			else  {
				var qux = "qux";
			}
			console.log(foo, bar, qux);
		}
		baz() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_baz_0.apply(this);
			}
			else if(arguments.length >= 1 && arguments.length <= 3) {
				return Greetings.prototype.__ks_func_baz_1.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_qux_0() {
		}
		__ks_func_qux_1(name, priority, ...messages) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(priority === undefined || priority === null) {
				priority = 1;
			}
			console.log(name, priority, messages);
		}
		qux() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_qux_0.apply(this);
			}
			else {
				return Greetings.prototype.__ks_func_qux_1.apply(this, arguments);
			}
		}
		__ks_func_corge_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			console.log(name);
		}
		__ks_func_corge_1() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			var name = arguments[++__ks_i];
			var message = arguments[++__ks_i];
			if(arguments.length > 2) {
				var priority = arguments[++__ks_i];
			}
			else  {
				var priority = 1;
			}
			console.log(name, priority, message);
		}
		corge() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_corge_0.apply(this, arguments);
			}
			else if(arguments.length >= 2 && arguments.length <= 3) {
				return Greetings.prototype.__ks_func_corge_1.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_grault_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			console.log(name);
		}
		__ks_func_grault_1() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			var name = arguments[++__ks_i];
			if(arguments.length > 2) {
				var priority = arguments[++__ks_i];
			}
			else  {
				var priority = 1;
			}
			var message = arguments[++__ks_i];
			console.log(name, priority, message);
		}
		grault() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_grault_0.apply(this, arguments);
			}
			else if(arguments.length >= 2 && arguments.length <= 3) {
				return Greetings.prototype.__ks_func_grault_1.apply(this, arguments);
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_garply_0(name) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			if(!Type.isString(name)) {
				throw new Error("Invalid type for parameter 'name'");
			}
			console.log(name);
		}
		__ks_func_garply_1() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			if(Type.isString(arguments[++__ks_i])) {
				var name = arguments[__ks_i];
			}
			else throw new Error("Invalid type for parameter 'name'")
			if(Type.isString(arguments[++__ks_i])) {
				var message = arguments[__ks_i];
			}
			else throw new Error("Invalid type for parameter 'message'")
			if(arguments.length > 2) {
				if(Type.isNumber(arguments[__ks_i + 1])) {
					var priority = arguments[++__ks_i];
				}
				else  {
					throw new Error("Invalid type for parameter 'priority'");
				}
			}
			else  {
				var priority = 1;
			}
			console.log(name, priority, message);
		}
		__ks_func_garply_2() {
			if(arguments.length < 2) {
				throw new Error("Wrong number of arguments");
			}
			let __ks_i = -1;
			if(Type.isString(arguments[++__ks_i])) {
				var name = arguments[__ks_i];
			}
			else throw new Error("Invalid type for parameter 'name'")
			if(arguments.length > 2) {
				if(Type.isNumber(arguments[__ks_i + 1])) {
					var priority = arguments[++__ks_i];
				}
				else  {
					throw new Error("Invalid type for parameter 'priority'");
				}
			}
			else  {
				var priority = 1;
			}
			if(Type.isArray(arguments[++__ks_i])) {
				var messages = arguments[__ks_i];
			}
			else throw new Error("Invalid type for parameter 'messages'")
			console.log(name, priority, messages);
		}
		garply() {
			if(arguments.length === 1) {
				return Greetings.prototype.__ks_func_garply_0.apply(this, arguments);
			}
			else if(arguments.length >= 2 && arguments.length <= 3) {
				if(Type.isString(arguments[1])) {
					return Greetings.prototype.__ks_func_garply_1.apply(this, arguments);
				}
				else {
					return Greetings.prototype.__ks_func_garply_2.apply(this, arguments);
				}
			}
			throw new Error("Wrong number of arguments");
		}
		__ks_func_waldo_0() {
		}
		__ks_func_waldo_1(name, ...messages) {
			if(name === undefined || name === null) {
				throw new Error("Missing parameter 'name'");
			}
			var priority = 1;
			console.log(name, priority, messages);
		}
		waldo() {
			if(arguments.length === 0) {
				return Greetings.prototype.__ks_func_waldo_0.apply(this);
			}
			else {
				return Greetings.prototype.__ks_func_waldo_1.apply(this, arguments);
			}
		}
	}
	Greetings.__ks_reflect = {
		inits: 0,
		constructors: [
		],
		instanceVariables: {
		},
		classVariables: {
		},
		instanceMethods: {
			foo: [
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			],
			bar: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				},
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			],
			baz: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				},
				{
					access: 3,
					min: 1,
					max: 3,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: 3
						}
					]
				}
			],
			qux: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				},
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			],
			corge: [
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
				},
				{
					access: 3,
					min: 2,
					max: 3,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 3
						}
					]
				}
			],
			grault: [
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
				},
				{
					access: 3,
					min: 2,
					max: 3,
					parameters: [
						{
							type: "Any",
							min: 2,
							max: 3
						}
					]
				}
			],
			garply: [
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
				},
				{
					access: 3,
					min: 2,
					max: 3,
					parameters: [
						{
							type: "String",
							min: 2,
							max: 2
						},
						{
							type: "Number",
							min: 0,
							max: 1
						}
					]
				},
				{
					access: 3,
					min: 2,
					max: 3,
					parameters: [
						{
							type: "String",
							min: 1,
							max: 1
						},
						{
							type: "Number",
							min: 0,
							max: 1
						},
						{
							type: "Array",
							min: 1,
							max: 1
						}
					]
				}
			],
			waldo: [
				{
					access: 3,
					min: 0,
					max: 0,
					parameters: [
					]
				},
				{
					access: 3,
					min: 1,
					max: Infinity,
					parameters: [
						{
							type: "Any",
							min: 1,
							max: Infinity
						}
					]
				}
			]
		},
		classMethods: {
		}
	};
}