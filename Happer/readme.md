# Happer⚒️


#### What is it ? 
###### Happer is a **dsl** made to manipulate *putnam.ls* cli and automatize certain tasks. Happer interpreter is a ruby-based dsl but it's shipped in a single executable or single source .rb file 

#### How to use ?
###### It is very simple if you're already used to ruby language elixir or crystal or co-related languages
##### To start, in the source folder you just need to 
```console
Happer script.rb 
```
( if you have executable version )
###### inside this script you can have the following structures 
```ruby 
defc 
defp 
do_run
do_merge
```
#### Using : *defc*  
###### with **defc** you can pass arguments as following 
```ruby 

defc "name" do
	chunk :code
    target :name
    given "rule" do 
    	forallT "type0", "type1"
    end 
end 

```
###### this code is all **defc** can do by now and it's equivalent to 
```console
lsc putnam.ls --run-l [chunk] "forall T. type0 -> type1"
```
###### each of the lines written in Haskell in the :code section is evaluated against the written rule in the given section. 

#### Using : *defp*
###### with **defp** you can pass arguments as following 
```ruby 

defp "name" do
	source :file0
	target :file1
	given :rule1 do
		forallT "type0", "type1"
	end  
end
```
###### this code then will evoke the following structure 
```console
lsc putnam.ls --run [file0] "forall T. type0 -> type1"
```

#### Using **do_run** and **do_merge**

```ruby
do_run :name
do_merge :name
```

###### For the operator **run** the language will only single evaluate the block and return the spawned process of putnam session
###### In the operator **do_merge** each **def** has a different behavior 

#### Example of **defp** and **do_merge**


```ruby

defp :name do
	source :file0
	target :file1
	given :rule1 do
		forallT "type0", "type1"
	end  
end
do_merge :name

``` 

###### given that we have the following files

```haskell
# file1 
foo :: a -> b 

bar :: c -> d 

{- slot -}

``` 
```haskell
# file0

compareTemperature :: Node -> Report
compareTemperature x = y

``` 

###### when *do_merge* is called the files are merged in the area where is established **{- slot -}** given the result of the file1

```diff

# file1 
foo :: a -> b 

bar :: c -> d 

+compareTemperature :: Node -> Report
+compareTemperature x = y

{- slot -}

```

#### Example of **defc** and **do_merge**

```ruby

my_chunk = <<HASKELL

compareTemperature :: Node -> Report
compareTemperature x = y 

HASKELL

defc :name do
	chunk my_chunk
	target "file1.hs"
	given :rule1 do
		forallT "Node", "Report"
	end 
end 

do_merge :name

```
###### Here we have a Haskell code chunk *my_chunk* and the same file as the defp example, the same as the defp will be done here but without the need to save the chunk into an external file.

#### Name :: 
###### *The name comes from the fusion of sapper , which are the combat engineers that help with repairs and build defenses and Haskell language*
 
