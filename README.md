# Putnam

## Syntatic code checker for Haskell

##### Motivation :: 
``
With facebook new's features to Haskell hot-swap code become easier. Although there're some dangerous capabilties on it given that bad code ( specially bad typed code ) could crash a hot-swappable server. This tool aim to avoid this kind of thing by proving, in similar terms of facebook's retrie, tools that will make a check before a code merge or to scan code's folder in search for bad typed code. 
`` 

### ⚠️ Disclaimer
###### This project is still in beta phase, which means that there may be bugs and glitches. There're some restrictions about the performance and source language choose. This project is written in LiveScript for prototyping reasons and this must change in the future. 

## Usage

### Development mode :: 

##### Dependencies :: 
```powershell  
Livescript
Node
npm 
```

##### To build Putnam :: 
```poweshell 
npm install livescript
npm install prelude-ls
npm install colors
npm install sleep
npm install diff 
```

### User-only mode :: 

*You can use the standalone executable instead of building it from source in the future* 

## 🎉 We're ready to go 
To start using the app we need to know it's functionalities by using the arguments :
```console
lsc putnam.ls --help
```
After it you'll be able to see all the options that can be passed to the app : 
```console
lsc putnam.ls [-option] [file] expression 

--run     [single file] :: Check the current file  
--run-m   [single file] :: Check the expression inside the file  
--folder  [folder path] :: Will search for errors in all folder's files
--watch   [single file] :: Watches a single file and searching for errors
--watch-d [single file] :: Watches a single file and searching for errors and changes
--watch-d-m [single file] :: Watches a single file for diff and use the inside written expression
```

## Real Example
#### Example 1 : running analysis for single file 

Given the following **file1.hs** : 

```haskell
foo :: a -> b -> b
foo x y = y 

bar :: q -> p -> p
bar x y = y 
```

and the the follow expression :
```haskell
forall T. a -> b -> b
```

one can run the app like 
```console
lsc putnam.ls --run file.1.hs "forall T. a -> b -> b"
```

and will get the following result 
```
Starting analysis
Using file: file1.hs at [ 10|1|2021 ]
Running ./diff.txt


0: 
1:foo :: a -> b -> b
2:foo x y = y
3:
4:bar :: q -> p -> p
 ^^^^ Not permitted
```

The app just searched all signatures and found the ones which do not match !

#### Example 2 : running watching mode for a single file

Consider the following file **file2.hs**:

```haskell
foo :: a -> b -> b
foo x y = y 
```

Consider the same file again but with **different** options   

```console
lsc putnam.ls --watch-d file1.hs "forall T. a -> b -> b"
```
 Now the app will keep an eye on the file and wait for changes, let's say we change it once
 
```diff
foo :: a -> b -> b
foo x y = y 

+bar :: q -> p -> p
+bar x y = y 
```

and then the terminal will show

```
Starting analysis
Using file: file2.hs at [ 10|1|2021 ]

[ Success : no issues found ]
Waiting changes... ◒

0:
1:foo :: a -> b -> b
2:foo x y = y
3:
4:bar :: q -> p -> p
 ^^^^ Not permitted

Waiting changes... ◓
```

#### Example 3 : use expression inside the file and watch it for diff

Consider the following file **file3.hs**:

```haskell
--Expr forall T. a -> b -> b

foo :: a -> b -> b
foo x y = y 
```

As in the examples above let's change it :

```diff
Expr forall T. a -> b -> b

foo :: a -> b -> b
foo x y = y 

+bar :: q -> p -> p
+bar x y = y 
```

We can use the expression inside the target file using :

```console
lsc --run-m file3.hs 
lsc --watch-d-m file3.hs 
```

Which will result :

```
Starting analysis
Using file: file2.hs at [ 10|1|2021 ]

[ Success : no issues found ]
Waiting changes... ◒

bar :: q -> p -> p
 ^^^^ Not permitted

Waiting changes... ◓
```


As we can see at first there was no issues , and then, while the app was watching the file, an issue appeared on the diff and was shown to the user. 

# 🏗️ Under development...
- [X] Haskell like expressions 
- [ ] New possible kinds of expressions
- [X] Haskell library integration 
- [ ] UI diff tracker ( may we use a git's gui ? ) 
