
# Mini-LISP

## Built with

* C++
* Lex
* Yacc

## Environment

* Windows 10
* Ubuntu 20.04

## Feature
All of basic features

|   | Feature | discription | 
| ---- | ---- | ----------- |
| 1 | Syntax Validation | Print “syntax error” when parsing invalid syntax |
| 2 | Print | Implement print-num statement |
| 3 | Numerical Operations | Implement all numerical operations |
| 4 | Logical Operations | Implement all logical operations |
| 5 | if Expression | Implement if expression |
| 6 | Variable Definition | Able to define a variable |
| 7 | Function | Able to declare and call an anonymous function |
| 8 | Named Function | Able to declare and call a named function |


## How to implement
```
bison -d -o y.tab.c pro.y
g++ -c -g -I.. y.tab.c
flex -o lex.yy.c pro.l
g++ -c -g -I.. lex.yy.c
g++ -o pro y.tab.o lex.yy.o -ll
./pro < Input_data.lsp
```
## Process
### To give an simple idea
#### Few steps will show how it gets the result for operator '+'
* This is the example input of plus operation 
  * green words represent the terminal defined in the pro.l file <br>
![](https://i.imgur.com/vLZwRj6.png)
* by this part of grammar, we can easily know the reduction process

```
program         : stmts
                ;
stmts           : stmt stmts 
                | stmt
                ;
stmt            : exp                                        
                ;
exps            : exp exps 
                | exp                         
                ;
exp             : NUM                       
                | num_op   
                ;
num_op          : plus     
                ;
plus            : '(' '+' exp exps ')' 
                ;
```
<br>

![](https://i.imgur.com/1MSUURF.png)


* Focus on the subtree related to the operator '+', this is the subtree AST we built in pro.y file during parsing
![](https://i.imgur.com/1bF1jVE.png)

* To get the result of input, below are the steps while traversing the subtree, after these steps we can get the result and it's also stored in the value field of node '+'<br>
![](https://i.imgur.com/4I3Mg56.png)
<br>

* follow the rules, we can finish other num-operation and logical-operation

### Define variable and function
* sructure definition<br>

```
struct Node{
    char op;
    int intval;
    int isFunFlag;
    char* name;
    Node *left;
    Node *right;
    Node *mid;
};
```
```
struct vardec{
	string var_id;
	int id_val;
	Node* funexp;
	Node* funpara;
	vector<vardec> idinfo;
};
```
* the variable are stored in vector decc if the input is defining pure numbers
* the variable are stored in vector fundecc if the input satisfy the anonymous function call
  *  the variables stored in different vectors that the parameters inside the anonymous function will not affect the definition of outside scope
* all of the named functions are put in namedfundecc, the function name as the var_id, the function parameters' name stored in ```pointer* funpara```
  after traversal, the input value will bind with each correspond parameters and put in that namedfundecc element's idinfo <br>
```
vardec tmp;
vardec ntmp;
vector<vardec> decc;
vector<vardec> fundecc;
vector<vardec> namedfundecc;
```

<!-- GETTING STARTED -->
