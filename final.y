%{
#include<iostream>
#include<string>
#include <map>
#include <vector>
using namespace std;
int yylex(void);
void yyerror(const char *message);

  
struct Node{
    char op;
    int intval;
    int isFunFlag;
    char* name;
    Node *left;
    Node *right;
    Node *mid;
};
struct vardec{
	string var_id;
	int id_val;
	Node* funexp;
	Node* funpara;
	vector<vardec> idinfo;
};
vardec tmp;
vardec ntmp;
vector<vardec> decc;
vector<vardec> fundecc;
vector<vardec> namedfundecc;
int isdec;
int isEqual;
int equalnum;
int first;
int isDefine = 0;
int isFun = 0;
int findfunvar = 0;
string isnamedfun="";
int findnamedfun=0;


struct Node* root = NULL;
struct Node* funid = NULL;
struct Node* funexp = NULL;
Node* malloc_node(Node*,Node*,char);

void Traversal(Node*);
int Add(Node*);
int Sub(Node*);
int Multiply(Node*);
int Divide(Node*);
int Mod(Node*);
int And(Node*);
int Or(Node*);
int Greater(Node*);
int Smaller(Node*);
int Equal_to(Node*);
void Bind(Node*, Node*);
%}

%union {
int intval;
int boolval;
char* strval;
struct Node *nodes;
}

%token PRINT_NUM PRINT_BOOL MOD AND OR NOT IF LAMBDA DEFINE
%token<intval> NUM
%token<boolval> BOOL
%token<strval> ID
%type<nodes> program stmts stmt print_stmt exps exp num_op logical_op
%type<nodes> plus minus multiply divide modules and_op or_op not_op
%type<nodes> greater smaller equal
%type<nodes> if_exp test_exp then_exp else_exp
%type<nodes> def_stmt variable variables
%type<nodes> fun_exp fun_id fun_body fun_call fun_name param params

%left '+' '-'
%left '*' '/'  MOD
%left '(' ')'
%%
program         : stmts                         { root = $1; }
                ;
stmts           : stmt stmts                    { $$=malloc_node($1,$2,' '); }
                | stmt                          { $$=$1; }
                ;
stmt            : exp                           { $$=$1; }
                | print_stmt                    { $$=$1; }
                | def_stmt                      { $$=$1; }
                ;
print_stmt      : '(' PRINT_NUM exp ')'         { $$=malloc_node($3,NULL,'p'); }
                | '(' PRINT_BOOL exp ')'        { $$=malloc_node($3,NULL,'P'); }
                ;
exps            : exp exps                      { $$=malloc_node($1,$2,'e'); }
                | exp                           { $$=$1; }
                ;
exp             : NUM                           { $$=malloc_node(NULL,NULL,'n'); $$->intval=$1; }
                | num_op                        { $$=$1; }
                | BOOL                          { $$=malloc_node(NULL,NULL,'b'); $$->intval=$1; }
                | logical_op                    { $$=$1; }
                | if_exp                        { $$=$1; }        
                | variable                      { $$=$1; }
                | fun_exp                       { $$=$1; }
                | fun_call                      { $$=$1; }
                ;
num_op          : plus                          { $$=$1; }
                | minus                         { $$=$1; }
                | multiply                      { $$=$1; }
                | divide                        { $$=$1; }
                | modules                       { $$=$1; }
                | greater                       { $$=$1; }
                | smaller                       { $$=$1; }
                | equal                         { $$=$1; }
                ;
plus            : '(' '+' exp exps ')'          { $$=malloc_node($3,$4,'+'); }
                ;
minus           : '(' '-' exp exp ')'           { $$=malloc_node($3,$4,'-'); }
                ;
multiply        : '(' '*' exp exps ')'          { $$=malloc_node($3,$4,'*'); }
                ;
divide          : '(' '/' exp exp ')'           { $$=malloc_node($3,$4,'/'); }
                ;
modules         : '(' MOD exp exp ')'           { $$=malloc_node($3,$4,'%'); }
                ;
greater         : '(' '>' exp exp ')'           { $$=malloc_node($3,$4,'>'); }
                ;
smaller         : '(' '<' exp exp ')'           { $$=malloc_node($3,$4,'<'); }
                ;
equal           : '(' '=' exp exp ')'           { $$=malloc_node($3,$4,'='); }
                ;

logical_op      : and_op                        { $$=$1; }
                | or_op                         { $$=$1; }
                | not_op                        { $$=$1; }
                ;
and_op          : '(' AND exp exps ')'          { $$=malloc_node($3,$4,'&'); }
                ;
or_op           : '(' OR exp exps ')'           { $$=malloc_node($3,$4,'|'); }
                ;
not_op          : '(' NOT exp')'                { $$=malloc_node($3,NULL,'~'); }
                ;
if_exp          : '(' IF test_exp then_exp else_exp ')' { $$=malloc_node($3,$5,'i'); $$->mid=$4; }
                ;
test_exp        : exp                           { $$=$1; }
                ;   
then_exp        : exp                           { $$=$1; }
                ;
else_exp        : exp                           { $$=$1; }
                ;
def_stmt        : '(' DEFINE variable exp ')'   { $$ = malloc_node($3, $4, 'd'); $3->intval=$4->intval; $$->isFunFlag=$4->isFunFlag; }
                ;
variable        : ID                            { $$ = malloc_node(NULL, NULL, 'v'); $$->name = $1;}
                ;




fun_exp         : '(' LAMBDA fun_id fun_body ')'   { $$ = malloc_node($3, $4, 'f'); $$->isFunFlag=1;} 
                ;
fun_id          : '(' variables ')'                   { $$ = $2; }
                ;
variables       : variable variables            { $$ = malloc_node($1, $2, 'v'); }
                |                               { $$ = malloc_node(NULL, NULL, 'v'); }
                ;
fun_body        : exp                           { $$ = $1;}
                ;
fun_call        : '(' fun_exp params ')'         { $$ = malloc_node($2, $3, 'f'); }
                | '(' fun_name params ')'        { $$ = malloc_node($2, $3, 'C'); }
                ;
params          : param params                  { $$ = malloc_node($1, $2, 'n'); }
                |                               { $$ = malloc_node(NULL, NULL, 'n'); }
                ;
param           : exp                           { $$ = $1; }
                ;
fun_name        : variable                       { $$ = malloc_node($1, NULL, 'a'); $$->name = $1->name;}
                ;
%%

Node* malloc_node(Node* leftc,Node* rightc,char op)
{
    Node *newp = new Node;
    newp->left = leftc;
    newp->right = rightc;
    newp->mid = NULL;
    newp->name = NULL;
    newp->op = op;
    newp->intval = 0;

    return newp;
}

void Traversal(Node* node)
{
    if(node == NULL)
    {
        return;
    }
    if(node->op!='~'&& node->op!='P'&& node->op!='p'&& node->op!='i'&&node->op!='d'&&node->op!='v'&&node->op!='f'&&node->op!='C')
    {
        Traversal(node->left);
        Traversal(node->right);
    }
    switch(node->op)
    {
    case '+':
        node->intval = Add(node);
        break;
    case '-':
        node->intval = Sub(node);
        break;
    case '*':
        node->intval = Multiply(node);
        break;
    case '/':
        node->intval = Divide(node);
        break;
    case '%':
        node->intval = Mod(node);
        break;
    case '&':
        node->intval = And(node);
        break;
    case '|':
        node->intval = Or(node);
        break;
    case '~':
        Traversal(node->left);
        node->intval = !node->left->intval;
        break;
    case '>':
        node->intval = Greater(node);
        break;
    case '<':
        node->intval = Smaller(node);
        break;
    case '=':
        isEqual = 1;
        equalnum = 0;
        Equal_to(node);
        node->intval = isEqual;
        break;
    case 'p':
        Traversal(node->left);
        printf("%d\n",node->left->intval);
        findfunvar = 0;
        break;
    case 'P':
        Traversal(node->left);
        if(node->left->intval)
            printf("#t\n");
        else
            printf("#f\n");
        break;
    case 'd':
        if(!node->isFunFlag)
        {
            Traversal(node->right);
            tmp.var_id=node->left->name;
            tmp.id_val=node->right->intval;
            decc.push_back(tmp);
        }
		else
        {
            if(node->right->left->left == NULL)
        	{
                ntmp.var_id = node->left->name;
            	ntmp.funexp=node->right->right;
            	namedfundecc.push_back(ntmp); 
            }
            else
            {
				ntmp.var_id = node->left->name;
            	ntmp.funexp=node->right->right;
				ntmp.funpara=node->right->left;
            	namedfundecc.push_back(ntmp);
             }
        }
        break;
    case 'i':
        Traversal(node->left);
        Traversal(node->mid);
        Traversal(node->right);
        if(node->left->intval)
            node->intval = node->mid->intval;
        else
            node->intval = node->right->intval;
        break;
    case 'f':
        Bind(node->left->left, node->right);
        findfunvar=1;
        Traversal(node->left->right);
        node->intval = node->left->right->intval;
        fundecc.clear();
        findfunvar=0;
        break;
    case 'v':
        if(!findfunvar&&!findnamedfun)
        {
            for(int i=0; i< decc.size(); i++)
            {
                if(node->name==decc.at(i).var_id)
                {
                    isdec=1;
                    node->intval=decc.at(i).id_val;
                }
            }
        }
        else if(findfunvar&&!findnamedfun)
        {
            for(int i=0; i< fundecc.size(); i++)
            {
                if(node->name==fundecc.at(i).var_id)
                {
                    node->intval=fundecc.at(i).id_val;
                }
            }
        }
		else if(findnamedfun)
		{
			
			for(int i=0; i< namedfundecc.size(); i++)
            {
                if(isnamedfun==namedfundecc.at(i).var_id)
                {
					for(int j=0; j< namedfundecc.at(i).idinfo.size(); j++)
    				{
                		if(node->name==namedfundecc.at(i).idinfo.at(j).var_id)
                		{	
                   			 node->intval=namedfundecc.at(i).idinfo.at(j).id_val;
                   			 
               			}
          			}
                }
            }

		}
        break;
	    case 'C': 
            Traversal(node->right);
			for(int i=0; i< namedfundecc.size(); i++)
            {
                if(node->left->name==namedfundecc.at(i).var_id)
                {
                    ntmp=namedfundecc.at(i);
					break;
                }
            }
			findnamedfun=1;
			isnamedfun=node->left->name;
            Bind(ntmp.funpara, node->right);
            Traversal(ntmp.funexp);
            node->intval = ntmp.funexp->intval;
			findnamedfun=0;
            break;
    default:
        break;
    }
}

int Add(Node *node)
{
    int sum = 0;
    if(node->left != NULL)
    {
        sum += node->left->intval;
        if(node->left->op == 'e')
        {
            sum += Add(node->left);
        }
    }
    if(node->right != NULL)
    {
        sum += node->right->intval;
        if(node->right->op == 'e')
        {
            sum += Add(node->right);
        }
    }
    return sum;
}
int Sub(Node *node)
{
    return node->left->intval - node->right->intval;
}
int Multiply(Node *node)
{
    int sum = 1;
    if(node->left != NULL)
    {
        if(node->left->op == 'e')
        {
            sum *= Multiply(node->left);
        }
        else
        {
            sum *= node->left->intval;
        }
    }
    if(node->right != NULL)
    {
        if(node->right->op == 'e')
        {
            sum *= Multiply(node->right);
        }
        else
        {
            sum *= node->right->intval;
        }
    }
    return sum;
}
int Divide(Node *node)
{
    return node->left->intval / node->right->intval;
}
int Mod(Node *node)
{
    return node->left->intval % node->right->intval;
}
int Greater(Node *node)
{
    return node->left->intval > node->right->intval;
}
int Smaller(Node *node)
{
    return node->left->intval < node->right->intval;
}
int Equal_to(Node *node)
{
    if(node->left != NULL)
    {
        if(node->left->op == 'e')
        {
            Equal_to(node->left);
        }
        else
        {
            if(first==0)
            {
                equalnum=node->left->intval;
                first=1;
            }
            else
            {
                if(node->left->intval != equalnum)
                    isEqual=0;
            }
        }
    }
    if(node->right != NULL)
    {
        if(node->right->op == 'e')
        {
            Equal_to(node->right);
        }
        else
        {
            if(first==0)
            {
                equalnum=node->right->intval;
                first=1;
            }
            else
            {
                if(node->right->intval != equalnum)
                    isEqual=0;
            }
        }
    }
}

int And(Node *node)
{
    int sum = 1;
    if(node->left != NULL)
    {
        if(node->left->op == 'e')
        {
            sum = sum & And(node->left);
        }
        else
        {
            sum = sum & node->left->intval;
        }
    }
    if(node->right != NULL)
    {
        if(node->right->op == 'e')
        {
            sum = sum & And(node->right);
        }
        else
        {
            sum = sum & node->right->intval;
        }
    }
    return sum;
}
int Or(Node *node)
{
    int sum = 0;
    if(node->left != NULL)
    {
        if(node->left->op == 'e')
        {
            sum = sum | Or(node->left);
        }
        else
        {
            sum = sum | node->left->intval;
        }
    }
    if(node->right != NULL)
    {
        if(node->right->op == 'e')
        {
            sum = sum | Or(node->right);
        }
        else
        {
            sum = sum | node->right->intval;
        }
    }
    return sum;
}
void Bind(Node *varname, Node *varval)
{
    if(varname == NULL || varval == NULL)
    {
        return;
    }
    if(varname->op=='v' && varval->op=='C')
    {
	if(varname->name != NULL && findnamedfun)
        {
            ntmp.var_id = varname->name;
            ntmp.id_val=varval->intval;
			for(int i=0; i< namedfundecc.size(); i++)
            {
                if(isnamedfun==namedfundecc.at(i).var_id)
                {
					namedfundecc.at(i).idinfo.push_back(ntmp);
                }
            } 
        }

    }
    if(varname->op=='v' && varval->op=='n')
    {
        Bind(varname->left, varval->left);
        Bind(varname->right, varval->right);
        if(varname->name != NULL && varval != NULL&& !findnamedfun)
        {
            tmp.var_id = varname->name;
            tmp.id_val=varval->intval;
            fundecc.push_back(tmp);
        }
		if(varname->name != NULL && varval != NULL&& findnamedfun)
        {
            ntmp.var_id = varname->name;
            ntmp.id_val=varval->intval;
			for(int i=0; i< namedfundecc.size(); i++)
            {
                if(isnamedfun==namedfundecc.at(i).var_id)
                {
					namedfundecc.at(i).idinfo.push_back(ntmp);
                }
            } 
        }

    }
}
void freeAST(struct Node* node){ // free with postorder
    if(node != NULL) {
        freeAST(node->left);
        freeAST(node->mid);
        freeAST(node->right);
        free(node);
    }
}


void yyerror (const char *message)
{
    fprintf (stderr, "%s\n",message);
}

int main(int argc, char *argv[])
{
    yyparse();
    Traversal(root);
    freeAST(root);
    return(0);
}
