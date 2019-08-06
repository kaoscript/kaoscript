[kaoscript](https://github.com/kaoscript/kaoscript)
===================================================

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![NPM Version](https://img.shields.io/npm/v/kaoscript.svg?colorB=green)](https://www.npmjs.com/package/kaoscript)
[![Dependency Status](https://badges.depfu.com/badges/b4ee54ddcf803c9d89234cca147e59b2/overview.svg)](https://depfu.com/github/kaoscript/kaoscript)
[![Build Status](https://travis-ci.org/kaoscript/kaoscript.svg?branch=master)](https://travis-ci.org/kaoscript/kaoscript)
[![CircleCI](https://circleci.com/gh/kaoscript/kaoscript/tree/master.svg?style=shield)](https://circleci.com/gh/kaoscript/kaoscript/tree/master)
[![Coverage Status](https://img.shields.io/coveralls/kaoscript/kaoscript/master.svg)](https://coveralls.io/github/kaoscript/kaoscript)
[![Known Vulnerabilities](https://snyk.io/test/github/kaoscript/kaoscript/badge.svg)](https://snyk.io/test/github/kaoscript/kaoscript)

[![NPM](https://nodei.co/npm/kaoscript.png?downloads=true&stars=true)](https://www.npmjs.com/package/kaoscript)

What's kaoscript?
-----------------

kaoscript is programming language combining features from ES7, CoffeeScript, TypeScript, Rust, Swift, C# and more.

Currently, kaoscript is transpiled to JavaScript.

Features
--------

- **easy syntax**: close to ES6 and Swift
- **fully OOP**: extendable native classes but fully compatible with the node.js
- **partial/impl paradigm**
- **async/await**: don't need ES7
- **check variables existences**
- **automatically declare variable**: `i = 0` => `let i = 0`
- **array range**
- **for/to, for/til, for/in, for/of, for/range, until**: no more `for(;;)`
- **comprehensions**
- **typed or not** `let i = 0` or `let i: Number = 0`
- **automatic typing**: on assignement with operator `:=`
- **type alias**: `type float = Number`
- **generics**
- **chained operations**: `1 < x < 10`
- **enum**
- **namespace**
- **import/export**: `import` is the equivalent of node.js `require`
- **require**: declare requirements (only for a module)
- **extern/declare**: explicit global scope
- **typed import**: import non-kaoscript objects and indicate their types
- **function overloading**
- **advanced parameters**
- **error handling**: by default, it's à la Java but it's configurable
- **attributes**
- **conditional compilation**
- **macro**

Documentation
-------------

The official documentation is available at [kaoscript.tech](https://www.kaoscript.tech/).

License
-------

[MIT](http://www.opensource.org/licenses/mit-license.php) &copy; Baptiste Augrain