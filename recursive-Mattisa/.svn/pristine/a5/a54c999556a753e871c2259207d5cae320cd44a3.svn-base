#include "Art.h"

Art::Art(float timeIncr, int depth, uint32 num) : timeIncrement(timeIncr) {

    G3D::Random randomGenerator1(num); 
    G3D::Random randomGenerator2(num+1234); 
    G3D::Random randomGenerator3(num+9713); 
 
    expression1 = shared_ptr<Expr>(build(depth,randomGenerator1)); 
    expression2 = shared_ptr<Expr>(build(depth,randomGenerator2));
    expression3 = shared_ptr<Expr>(build(depth,randomGenerator3));
    
    ourTime = 0; 
}

//recommended -> timeIncrement ~ M_PI/400.0f;
shared_ptr<Art> Art::create(float timeIncrement, int depth, uint32 num){
    return shared_ptr<Art>(new Art(timeIncrement, depth, num)); 
}

shared_ptr<Image> Art::nextImage(){
    step = ourTime; //.9f*(cos(ourTime)+1.0f); //other random functions need to be bounded 
    ourTime += timeIncrement; 
    
    cout << "curTime:";
    cout << (ourTime); 
    cout << "\n"; 

    return doRandomGray(step+.25f); 
}

//This is code translated from Stephen Freund's Lab 4 version in ML  

//Converts an integer i from range -N to N into a real in -1 1 
float Art::toReal(int i, int N){
    return (float)(i)/(float)(N); 
}

//Builds a random mathematical expression 
Expr* Art::build(int depth, G3D::Random& randomGenerator){ 
    if(depth==0){
        int randomNum = randomGenerator.integer(1,2); 
        if(randomNum==1){ return new Expr( Expr::VarX); }
        else{ return new Expr( Expr::VarY); }
    }
    else{
        int randomNum = randomGenerator.integer(1,100); 
    
        if(randomNum<16){
            return new Expr(build(depth-1,randomGenerator),Expr::Cos,false); 
        }
        else if(randomNum<32){
            return new Expr(build(depth-1,randomGenerator),Expr::Sin,false); 
        }
        else if(randomNum<48){
            return new Expr(build(depth-1,randomGenerator),build(depth-1,randomGenerator),Expr::Average,true);
        }
        else if(randomNum<64){
            return new Expr(build(depth-1,randomGenerator),build(depth-1,randomGenerator),Expr::Times,true);
        }
        else if(randomNum<80){
            return new Expr(build(depth-1,randomGenerator),build(depth-1,randomGenerator),Expr::Circle,true);
        }
        else{
            return new Expr(build(depth-1,randomGenerator),Expr::ASin,true);
        }

    }
}

//Create a random image by evaluating the random function over a continuous interval 
shared_ptr<Image> Art::doRandomGray(float step){
    cout << "curent step";
    cout << step;
    cout << "\n"; 
    //uint32 num(13514); makes regular choppy heightfield 
    //uint32 num(9087); really choppy melting terrain
    // uint32 num(56224); cooler 
    // uint32 num(24623); forgot
    //     uint32 seed(13411);  nice waves rally nice 
    //N+1 by N+1 pixels 

    int N = 100; 
    
    shared_ptr<Image> image = Image::create(N*2+1,N*2+1,ImageFormat::RGB32F());
    
    for(int x = 0; x<2*N; ++x){
        for(int y = 0; y<2*N; ++y){

            //convert grid locations to -1,1

            float px = toReal(x,N); 
            float py = toReal(y,N); 

            //apply given random function
            float c1 = expression1->eval(px,py,step); 
            float c2 = expression1->eval(px,py,step); 
            float c3 = expression3->eval(px,py,step); 

            //the image positions 
            int imgX = x; 
            int imgY = y; 

            const Color3 color(c1,c2,c3); 
            image->set( Point2int32( abs(imgX), abs(imgY) ), color); 
        }
    }
    return image; 
}



