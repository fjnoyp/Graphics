#ifndef Art_h
#define Art_h
#include <G3D/G3DAll.h>
#include "Expr.h" 

/**

This class is what generates our random art.  It takes in a time increment, the depth of the random expression to generate, and a seed number.  From calling nextImage() one is able to get the next image step in the 2d random art animation.  

 */
class Art {
 protected:
    float step; //next input 
    float ourTime;
    float timeIncrement; 

    /**
       Our randomly generated expressions, one for each color: r, g, b
     */
    shared_ptr<Expr> expression1; 
    shared_ptr<Expr> expression2; 
    shared_ptr<Expr> expression3; 

    Art(float timeIncr, int genDepth, uint32 num); 

    /**
       Scales our inputs to be less than 1.  The behavior of the trigonometric functions in our random math expression is less desirable as input > 1. 
     */
    float toReal(int i, int N); 
    shared_ptr<Image> doRandomGray(float step);


 public:
    //constructor method
    /**
       time increment is how fast we step through the different art frames of the randomly generated 2d art animation. 
       genDepth is related to the generation of the random function.  Check the Expr class for more details on how the random math function is created/represented and the Art::build() on how depth is used 
     */
    static shared_ptr<Art> create(float timeIncr, int genDepth, uint32 num);

    /**
       Get the next random art image
     */
    shared_ptr<Image> nextImage(); 

    /**
       Called to create a random expression.  This is a recursive method call where depth determines how many more recursive expansions we will use. 
     */
    Expr* build(int depth, G3D::Random& randomGenerator); 

};

#endif





