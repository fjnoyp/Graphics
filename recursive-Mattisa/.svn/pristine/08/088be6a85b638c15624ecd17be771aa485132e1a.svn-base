#ifndef Expr_h
#define Expr_h

#include <iostream> //for cout 
#include <math.h>
#include <string>

using namespace std;

/**

An abstract representation of a mathematical function.  This class represents a math function that can then be evaluated over some interval.  

Note that the static const string variables are used to set an Expression to be a certain type.  
 */
class Expr {

 public: 
    static const string VarX; 
    static const string VarY;
    static const string Cos; 
    static const string Sin; 
    static const string Average; 
    static const string Times;
    static const string Circle;
    static const string ASin;


    /**
       An expression might have a nested expression, for example this expression could be cos ( expr1 ) where expr1 would be another expression with other nested expression etc. 
     */
    shared_ptr<Expr> e1; 
    /**
       Some expressions take two inputs like Average or Circle 
     */
    shared_ptr<Expr> e2; 

    /**
       Stores the type of expression this Expr is.  This string must be one of the static string variables defined for an Expr 
     */
    std::string exprType; 
    bool doubleInput; 


    /**
       Constructor takes in other expressions for the nested expression case.  The third constructor is for "terminal" expressions, ie when the Art::build() method's depth input is 0 and terminates expression expansion.  doubleInput to distinguish between single and double input math functions.  The otherExprType parameter is most important as it is what sets the type of math function this newly created Expr is. 
     */
    Expr(Expr* otherE1, Expr* otherE2, std::string otherExprType, bool dubInput); 
    Expr(Expr* otherE1, std::string otherExprType,bool dubInput); 
    Expr(std::string otherExprType); 

    string* toString(string* theString); 
    /**
       Recursive method, calls eval on its nested expressions.  step is an important variable, it sets the constant that is multiplied by the input in the case of a trigonometric function, by increasing the step value over time, we get the cool changes in our 2d art animation.  See the 2d art animation for an example of what eval over slowly incrementing step parameters looks like. 
     */
    float eval(float x, float y, float step); 
    
};

#endif


