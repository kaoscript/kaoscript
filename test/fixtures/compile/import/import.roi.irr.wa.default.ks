#![libstd(off)]

import '../require/require.alt.roi.system.ks'

import './import.roi.rr.ks'(Array)

var m = Array.map([1..10], (value, index) => value * index)

export Array