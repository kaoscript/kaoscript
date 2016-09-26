[kaoscript](https://github.com/kaoscript/kaoscript)
=================================================================

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
![Dependencies](https://img.shields.io/david/kaoscript/kaoscript.svg)
[![Build Status](https://img.shields.io/travis/kaoscript/kaoscript.svg)](https://travis-ci.org/kaoscript/kaoscript)
[![Waffle.io](https://img.shields.io/badge/kanban-waffle.io-blue.svg)](https://waffle.io/kaoscript/kaoscript)

Kaoscript is a language that compile to regular Javascript.
It takes ideas from ES6, ES7, CoffeeScript, Swift, Rust, Dart, Spider, TypeScript, Haxe, C#, Java.

Why?
----

I have only one main reason: it's **not recommended to extends natives classes** to avoid any conflict with a JavaScript engine or a dependency.
It because it breaks your code consistency.
For example, to call the array's functions `map` and `clone`, it is written differently:
- `array.map(...)`
- `_.clone(array)`

So how *kaoscript* is different?

*kaoscript* compiles `array.clone()` to `_.clone(array)` so you can keep your code consistency.


Additionally, I don't mind callbacks but **async/await are easier to read** but it will be only available for ES7.

Features
--------

- **easy syntax**: close to ES6 and Swift
- **fully OOP**: extendable native classes but fully compatible with the node.js
- **partial/impl paradigm**
- **async/await**: don't wait ES7
- **check variables existences**
- **automatically declare variable**: `i = 0` => `let i = 0`
- **array range**
- **for/to, for/til, for/in, for/of, for/range, until**: no more `for(;;)`
- **comprehensions**
- **typed or not** `let i = 0` or `let i: Number = 0`
- **type alias**: `type float = Number`
- **generics**
- **automatic typing**: on assignement with operator `:=`
- **chained operations**: `1 < x < 10`
- **enum**
- **import/export**: `import` is the equivalent of node.js `require`
- **require**: declare requirements (only for a module)
- **extern**: explicit global scope
- **attributes**
- **advanced parameters**

Getting Started
---------------

With [node](http://nodejs.org) previously installed:

	npm install -g kaoscript

Executes the file `hello.ks`:
```
#![bin]

extern console

console.log('Hello World!')
```
with the command line `kaoscript hello.ks`, you will get `Hello World!`.

Module
------

By default, a koascript file is a module.
The global atttribute `#![bin]` indicates that the file is a binary file (i.e. it executes itself like usual javascript file)

For Node, a module file will look as:
```
module.exports = function() {
	...your code...
}
```

Alien Dependencies
------------------

There are three basics ways to add external dependencies:
- `extern`: from the global scope (`extern console`)
- `import`: from other dependencies (`import readFile from fs`)
- `require`: from the module parameters (`require foo` -> `module.exports = function(foo)`)

Two combined ways:
- `extern|require`: first look into the global scope, and if not found, look into the module parameters
- `require|extern`: first look into the module parameters, and if not found, look into the global scope


Array
-----

```kaoscript
let foo = [1, 2, 3]
```

```kaoscript
let a = [1..5]
// 1, 2, 3, 4, 5

let b = [1..<5]
// 1, 2, 3, 4

let c = [1<..5]
// 2, 3, 4, 5

let d = [1<..<5]
// 2, 3, 4

let e = [1..6..2]
// 1, 3, 5

let f = [1<..<6..2]
// 3, 5

let g = [5..1]
// 5, 4, 3, 2, 1

let h = [5..1..2]
// 5, 3, 1

let i = [1..2..0.3]
// 1.0, 1.3, 1.6, 1.9
```

```kaoscript
let min = 1
let max = 5

let a = [min..max]
// 1, 2, 3, 4, 5
```

Function
--------

```kaoscript
import * from ./_number.ks

extern console, parseFoat

func alpha(n?, percentage = false) -> float {
	let i: Number = parseFoat(n)
	
	return 1 if i is NaN else (percentage ? i / 100 : i).limit(0, 1).round(3)
}
```

Async/Await
-----------

```kaoscript
import * from ./_string.ks
import exec from child_process

const df_regex = /([\/[a-z0-9\-\_\s]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+(\/.*)/i

func disks() async {
	let stdout: string, stderr = await exec('df -k')
	
	let disks = []
	let matches: Array<String?>
	for line in stdout.lines() {
		matches = df_regex.exec(line)
		
		if matches {
			disks.push({
				device: matches[1].trim(),
				mount: matches[9],
				total: matches[2].toInt() * 1024,
				used: matches[3].toInt() * 1024,
				available: matches[4].toInt() * 1024
			})
		}
	}
	
	return disks
}

let d = await disks()
````

Loop
----

```kaoscript
for x from 0 to 10 {
	console.log(x)
}
// 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

for x from 0 til 10 {
	console.log(x)
}
// 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
```

```kaoscript
heroes = ['leto', 'duncan', 'goku']

for hero, index in heroes when index % 2 == 0
{
	console.log(hero)
}
// leto, goku
```

```kaoscript
heroes = ['leto', 'duncan', 'goku']

for hero in heroes until hero == 'duncan'
{
	console.log(hero)
}
// leto
```

```kaoscript
likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for key, value of likes {
	console.log(`\(key) likes \(value)`)
}
// leto likes spice
// paul likes chani
// duncan likes murbella
```

Comprehensions
--------------

```kaoscript
likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

spicyHeroes = [hero for hero, like of likes when like == 'spice']
// spicyHeroes = ['leto']
```

Class
-----

```kaoscript
extern console: {
	log(...args)
}

class Shape {
	private {
		_color: string
	}
	
    Shape(@color)
	// automatically the instance variable '_color' as the parameter 'color'
	
	// getter/setter
	color() => this._color
	color(@color) => this
    
    draw() -> string {
        return `I'm drawing with a \(this._color) pen.`
    }
}

class Rectangle extends Shape {
    draw() {
        return `\(super()) I'm drawing a \(this._color) rectangle.`
    }
}

let r = new Rectangle('black')

console.log(r.draw())
// I'm drawing with a black pen. I'm drawing a black rectangle.


impl Shape {
	draw(shape) -> string {
		return `I'm drawing a \(this._color) \(shape).`
	}
}
// adds dynamically the method 'draw(shape)' to the class 'Shape'

let s = new Shape('red')

console.log(s.draw())
// I'm drawing with a red pen

console.log(s.draw('circle'))
// I'm drawing a red circle.
```

Override core class
-------------------

```kaoscript
extern console, isNaN

extern final class Number {
}
// 'final' avoid to directly extends the class Number

impl Number {
	mod(max) -> Number {
		if isNaN(this) {
			return 0
		}
		else {
			let n = this % max
			if n < 0 {
				return n + max
			}
			else {
				return n
			}
		}
	}
}
// adds dynamically the method 'mod' to the class 'Number'

let i = 42

console.log(i.mod(2))
// throw an error that 'mod' is not defined

let j: Number = 42
// typed as a Number

console.log(j.mod(2))
// <- 0
// javascript code: console.log(__ks_Number._im_mod(j, 2))
```

Parameters
----------

```kaoscript
require expect: func

func foo(u?, v, x, y?, z?) {
	return [u, v, x, y, z]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([null, 1, 2, null, null])

expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null])

expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5])
```

Enum
----

```kaoscript
extern console

enum Color {
	Red
	Green
	Blue
}

let color = Color::Red

console.log(color)
// 0
```

```kaoscript
enum CardSuit<string> {
	Clubs
	Diamonds
	Hearts
	Spades
}

let card = CardSuit::Clubs

console.log(card)
// clubs
```

Switch
------

```kaoscript
extern console

let number = 13

switch number {
	1               => console.log("One!")
	2, 3, 5, 7, 11  => console.log("This is a prime")
	13..19          => console.log("A teen")
	                => console.log("Ain't special")
}
```

Runtime
-------

Kaoscript needs a runtime, to add dynamics functions on classes and to type checking, and imports it only when required.

The default runtime (`@kaoscript/runtime`) is been kept at the bare minimum.

You can use your own runtime with a global attribute like `#![cfg(runtime(package="yourpackage"))]`.
Or configure the name of the runtime's variables like `#![cfg(runtime(Type="YourType"))]`.

Temporary Limitation
--------------------

The current compiler targets and requires Node6

Todo
----

- context packages (node4, node6, IE, FF, or Chromium)
- get more people involved ;)
- syntax highlight
- better documentation
- operator overloading
- class: versioning
- class: properties
- mixins
- traits
- struct
- full support of generics
- full support of enum
- double dot (Dart)
- Exception management (Java)
- boolean conditions
- macro
- full support of attributes

Changelog
---------

### 0.2.1

- binary evaluates script

### 0.2.0

- require runtime only when needed
- use your own runtime

### 0.1.0

- initial release

License
-------

Copyright &copy; 2016 Baptiste Augrain

Licensed under the [MIT license](http://www.opensource.org/licenses/mit-license.php).