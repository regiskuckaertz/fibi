Front-end logic often involves some form of templating work, be it to mark up raw data or display dynamic UI elements. 

## Examples

Fibi will take whatever comes from standard input and write the corresponding DOM API program on the standard output. For example, `echo "Hello" | ./fibi | prettier` will produce

```
function(context) {
  var v0 = document.createDocumentFragment()
  v0.insertBefore(document.createTextNode('Hello\n'), v0.firstChild)
  return v0
}
```

Yes, all whitespace are kept.

## TODO

- [ ] Return bindings
- [ ] Expression values and operational semantics
- [ ] Expressions in text nodes
- [ ] Control structures: looping, branching, mapping
- [ ] Tests
