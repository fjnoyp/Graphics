#include "Expr.h"


const string Expr::VarX = "VarX"; 
const string Expr::VarY = "VarY"; 
const string Expr::Cos = "Cos"; 
const string Expr::Sin = "Sin";
const string Expr::Average = "Average"; 
const string Expr::Times = "Time"; 
const string Expr::Circle = "Circle";
const string Expr::ASin = "ASin"; 


Expr::Expr(Expr* otherE1, Expr* otherE2, std::string otherExprType, bool dubInput) :  e1(otherE1), e2(otherE2), exprType(otherExprType), doubleInput(dubInput){
    
}
Expr::Expr(Expr* otherE1, std::string otherExprType,bool dubInput) : e1(otherE1), exprType(otherExprType), doubleInput(dubInput){

    //ASK WHY THESE DIDN'T WORK: 
    //shared_ptr<Expr>(otherE1); 
    //e1(otherExprType); 
    //e1 = shared_ptr<Expr>(otherE1); 
    
}
Expr::Expr(std::string otherExprType) : exprType(otherExprType), doubleInput(false){
}

string* Expr::toString(string* theString){
    std::cout << " " ; 
    std::cout << exprType; 
    std::cout << " " ; 
    theString->append( exprType ); 
    if( e1){ e1->toString(theString); }
    if( e2){ e2->toString(theString); }
    return theString; 
}

float Expr::eval(float x, float y, float step){



    if( exprType==VarX){
        return x;
    }
    else if( exprType==VarY){
        return y; 
    }
    else if(!doubleInput){
         if( exprType==Cos){
             return cos( e1->eval(x,y,step)*M_PI*step );   
        }
        else if( exprType==Sin){
            return sin( e1->eval(x,y,step)*M_PI*step ); 
        }
        else if(exprType==ASin){
            return asin( e1->eval(x,y,step)*M_PI*step ); 
        }

    }
    else{
        if( exprType==Average){
            //was 1.3f 
            return (e1->eval(x,y,step)+e2->eval(x,y,step))/13.0f; 
        }
        else if(exprType==Times){
            return e1->eval(x,y,step) + e2->eval(x,y,step); 
        }
        else if(exprType==Circle){
            float x1 = e1->eval(x,y,step); 
            float y1 = e2->eval(x,y,step); 
            return ((x1*x1)+(y1*y1));///3.0f;
        }
        //average, median, radius, etc. 
        // e1->eval(x,y) e2->eval(x,y)
    }
    return 0.0f; 

}


