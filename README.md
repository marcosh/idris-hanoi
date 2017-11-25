# IDRIS TOWER OF Hanoi

A super type safe implementation of the game of the tower of Hanoi

### HOW TO USE IT

You can compile it using

```
idris Hanoi.idr -p effects -o hanoi
```

and then play it using

```
./hanoi
```

### IN THE BROWSER

You can compile it with

```
idris Hanoi.idr -p effects -o hanoi.js --codegen javascript
```

and open `hanoi.html` to play the game in the browser console
