Front-end logic often involves some form of templating work, be it to mark up raw data or display dynamic UI elements. So far, the way of dealing with this has been one of two ways: via quoted strings injected into the DOM by means of `innerHTML` or `insertAdjacentHTML`; or via an added layer of JavaScript abstractions, JSX being the most recent example. Both methods have their pros and cons:

- crude string juggling is easy to achieve and piggybacks on the browser's native HTML parser. String quoting is error-prone though, and quickly trickles down into fuzzy parsing issues. It is also not very efficient: this back-and-forth between the main thread and the parser has a cost, using the `innerHTML` API only makes things worse.

- frameworks and libraries like JSX have a non-negligible cost in terms of CPU and memory usage, although arguably this cost is quickly amortized as the number of dynamic UI component grows. One might find this intermediary layer lacking in what native DOM APIs can achieve though, and the memory footprint of keeping node references non-negligible.

## Basic usage

Fibi will take whatever comes from standard input and write the corresponding DOM API program on the standard output. For example, `echo "Hello" | ./fibi | prettier` will produce

```
function(context) {
  var v0 = document.createDocumentFragment()
  v0.insertBefore(document.createTextNode('Hello\n'), v0.firstChild)
  return v0
}
```

Yes, whitespaces are kept, browser rendering engines are responsible for dealing with it. Here is a more exhaustive example:

```
<div class="frame">
    <div class="frame__background">
        <img class="frame__background-image" src="image.jpg">
    </div>
    <div class="frame__foreground">
        <h2 class="frame__content-title">header</h2>
        <p class="frame__content-text">text</p>
    </div>
</aside>
```

... which results in:

```
function(context) {
  var v0 = document.createDocumentFragment()
  v0.insertBefore(document.createTextNode('\n'), v0.firstChild)
  var v1 = document.createElement('div')
  v0.insertBefore(v1, v0.firstChild)
  v1.setAttribute('class', 'frame')
  v1.insertBefore(document.createTextNode('\n'), v1.firstChild)
  var v4 = document.createElement('div')
  v1.insertBefore(v4, v1.firstChild)
  v4.setAttribute('class', 'frame__foreground')
  v4.insertBefore(document.createTextNode('\n    '), v4.firstChild)
  var v6 = document.createElement('p')
  v4.insertBefore(v6, v4.firstChild)
  v6.setAttribute('class', 'frame__content-text')
  v6.insertBefore(document.createTextNode('text'), v6.firstChild)
  v4.insertBefore(document.createTextNode('\n        '), v4.firstChild)
  var v5 = document.createElement('h2')
  v4.insertBefore(v5, v4.firstChild)
  v5.setAttribute('class', 'frame__content-title')
  v5.insertBefore(document.createTextNode('header'), v5.firstChild)
  v4.insertBefore(document.createTextNode('\n        '), v4.firstChild)
  v1.insertBefore(document.createTextNode('\n    '), v1.firstChild)
  var v2 = document.createElement('div')
  v1.insertBefore(v2, v1.firstChild)
  v2.setAttribute('class', 'frame__background')
  v2.insertBefore(document.createTextNode('\n    '), v2.firstChild)
  var v3 = document.createElement('img')
  v2.insertBefore(v3, v2.firstChild)
  v3.setAttribute('class', 'frame__background-image')
  v3.setAttribute('src', 'image.jpg')
  v2.insertBefore(document.createTextNode('\n        '), v2.firstChild)
  v1.insertBefore(document.createTextNode('\n    '), v1.firstChild)
  return v0
}
```

Loading that code in the browser console and calling it shows it produces the expected result:

## Expressions



## TODO

- [ ] Return bindings
- [ ] Expression values and operational semantics
- [x] Expressions in text nodes
- [ ] Control structures: looping, branching, mapping
- [ ] Tests
- [ ] Option to use ES6 let syntax
- [ ] Option to return a module, native, AMD or CommonJS
- [ ] Option to normalise whitespace (normally done by the rendering engine)
