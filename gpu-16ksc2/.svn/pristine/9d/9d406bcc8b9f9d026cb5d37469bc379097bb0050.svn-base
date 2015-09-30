#ifndef Scene_glsl // -*- c++ -*-
#define Scene_glsl

/*
PURPOSE OF THE CODE: 

This code contains the distance functions to be used for the implicit surface equations.  It also contains the intersect method that returns the proper surfel information for each pixel hit.

 */

#include "Surfel.glsl"
//#include <g3dmath.glsl>



//Store as instance variables to allow all functions to know our current material and current time 
Material ourMat; 
float ourTime = 0; 
float eps = .005; 


//All distance functions are adapted from Inigo Quilez: http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

//truncated method names for easier use in the distance functions 

//Domain Operations ======================================
vec3 opTwist(vec3 X){
    float timeStep = 1;//ourTime; 

    float c = cos(X.y/ (3+10.0f * abs(cos(timeStep)))); 
    float s = sin(X.y/ (3+10.0f * abs(cos(timeStep)))); 

    mat2 m = mat2(c,s,-s,c); 
    return vec3(m*X.xz,X.y); 
}

//Transform the input point for mod repetitions and twist effects 
vec3 transformPoint(vec3 X, float modValue){
    return mod( X , vec3(modValue,0,modValue) ) - (vec3(modValue,0,modValue)/2); 
}


//Distance Operations ======================================
// polynomial smooth min
//Note this method is not generic, it has been specifically tailored 
//to blend the sphere (b) with the entire city function (a) 
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );

    Color3 color1 = Color3(1, 1, 1); 
    Color3 color2 = Color3(1, 1, 0); 
    color1 = color1 - (h-1)*Color3(7,2,0); 
    
    //updates our material 
    ourMat = Material( color1, 1,1,2000);


    return mix( b, a, h ) - k*h*(1.0-h);
}

//subtraction 
float sOp(float d1, float d2){
    return max(d1,-d2); 
}
float iOp(float d1, float d2){
    return max(d1,d2); 
}
float uOp(float d1, float d2){
    return min(d1,d2); 
    //snow melt effect on city: 
    //return smin(d1,d2,abs(10*cos(ourTime))); 
}

//Keeping for archive, this method messes with mod city 
int randomOne(vec3 rander){
    vec3 intRand = vec3( int(rander.x), 0, int(rander.z) ); 
    //return int( mod( sin( intRand.x+intRand.z ), 2) ); 

    //original attempt, not working 
    return int(mod( (rander.x+rander.z),2) ); 

    //desired end behavior 
    //return int(mod( sin(10000*rander.x + 0), 2)); 

    //return int(mod( sin(ourDivX + ourDivZ + rander) , 2 )); 
}


//Geometric Primitives ==========================================================

// Signed distance function for a sphere.  Negative inside of the sphere.
float spher(in vec3 X, in vec3 center, float radius){ 
    return length(X-center) - radius;
}
float rect(in vec3 p, in vec3 center, in vec3 b){
    p = p - center; 
    vec3 d = abs(p) - b; 
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)); 
}
//h.x = height, h.y = length 
//float prism( vec3 p, vec2 h )
float prism(in vec3 p, in vec3 center, in vec2 h){
    p = p - center; 
    vec3 q = abs(p); 
    return max(q.z-h.y , max(q.x*0.866025+p.y*0.5,-p.y) - h.x * 0.5); 
}

//h.x = radius, h.y = height 
float cyl( vec3 p, in vec3 center, vec2 h )
{
    p = p - center; 
    vec2 d = abs(vec2(length(p.xz),p.y)) - h;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float length8(Vector2 v) {
    return pow(pow(v.x, 8) + pow(v.y, 8), 1.0 /8.0);
}
//t.x = inner space, t.y = width 
float tor( vec3 p, in vec3 center, vec2 t )
{
    p = p - center; 
    vec2 q = vec2(length8(p.xz)-t.x,p.y);
    return length8(q)-t.y;
}

//GENERIC CITY GENERATION CODE =============================================

//our step values for the city 
float modValue1 = 8; 
float modValue2 = 14; 
float modValue3 = 18; 
float modValue4 = 24; 
float modValue5 = 26; 

float modValue6 = 30; 

float modValue7 = 6; 
float modValue8 = 4; 
float modValue9 = 35; 

//the mod stepped points 
vec3 p1; 
vec3 p2; 
vec3 p3; 
vec3 p4; 
vec3 p5; 

vec3 p6; 
vec3 p7; 
vec3 p8; 
vec3 p9; 

//Object creation code (some of the methods call the other methods 
//before those original methods are declared) 
float eb1(in vec3 p, in vec3 c, in vec3 d); 
float ec1(in vec3 p, in vec3 c); 

float et1(in vec3 p, in vec3 c, in vec3 d); 
float ett1(in vec3 p, in vec3 c, in vec3 d);
float ett1c(in vec3 p, in vec3 c, in vec3 d);

//Box and Decorated Tower 
float et4(in vec3 p, in vec3 c, in vec3 d){
    return uOp( eb1(p,vec3(c.x+d.x,c.y,c.z),d), et1(p,vec3(c.x+d.x,c.y,c.z),d)); 
}
//Dome tower 
float et3(in vec3 p, in vec3 c, in vec3 d){
    float sF = 2; 

    //must move the point before the rotation or else we will be 
    //moving along the wrong axis 
    vec4 rot4P = inverse(yaw4x4( pi/8 )) * vec4(p.x-c.x, p.y-c.y*d.y*.85, p.z-c.z, 1); 

    return uOp( et1(p,c,d), spher(p,vec3(c.x,c.y+d.y+d.x*7,c.z),d.x)); 
}

//expansion tower 2, 2 et1's around a box 
float et2(in vec3 p, in vec3 c, in vec3 d){
    float sF = 4; //shrink factor 

    return uOp( uOp( eb1(p,c,d), et1( p, vec3(c.x-d.x,c.y,c.z-d.z), vec3(d.x/sF,d.y/(.3*sF),d.z/sF))),
                uOp( eb1(p,c,d), et1( p, vec3(c.x+d.x,c.y,c.z+d.z), vec3(d.x/sF,d.y/(.3*sF),d.z/sF))));
}

//expansion tower 1 single decorated tower
float et1(in vec3 p, in vec3 c, in vec3 d){
    float sF = 1.2; //shrink factor 

    return uOp( uOp( rect(p, c, d), rect(p, vec3( c.x, c.y+d.y, c.z), vec3(d.x/sF,d.y/sF,d.z/sF) )), 
                ett1( p,vec3( c.x, c.y+d.y*2, c.z), vec3(d.x/sF,d.y/sF,d.z/sF) ) ); 
    
}

//expansion top tower 1 
float ett1(in vec3 p, in vec3 c, in vec3 d){
    float sF = 1.2; //shrink factor 

    vec4 rot4P = inverse(yaw4x4( pi/8 )) * vec4(p.x-c.x, p.y-c.y, p.z-c.z, 1); 

    //return uOp( rect( rot4P.xyz , vec3(c.x,c.y,c.z) , vec3(d.x/sF,d.y/sF,d.z/sF)), ett1c(p,c,d)); 
    return uOp( rect( rot4P.xyz , vec3(0,0,0) , vec3(d.x/sF,d.y/sF,d.z/sF)), ett1c(p,c,d)); 

}
//copy ett1 to allow for "recursive calls"
float ett1c(in vec3 p, in vec3 c, in vec3 d){
    float sF = 1.2; //shrink factor 

    vec4 rot4P = inverse(yaw4x4( pi/4 )) * vec4(p.x-c.x, p.y-c.y, p.z-c.z, 1); 

    return rect( rot4P.xyz , vec3(0,0,0) , vec3(d.x/sF,d.y/sF,d.z/sF)); 

}

// b = base building (base building 1) 
// p = point, c = center 
float eb1(in vec3 p, in vec3 c, in vec3 d){
    float w = d.x;
    float h = d.y; 
    float l = d.z; 

    //return tor( p, c, vec2(.3,.1) ); 
    return rect(p, c, vec3(l,h,w));// eb2(p, vec3(c.x,c.y+h,c.z), d) ); 
}

//torus base building
float eb2(in vec3 p, in vec3 c, in vec2 d){
    return tor( p, c, d ); 
}

//cylinder base building 
float eb3(in vec3 p, in vec3 c, in vec2 h){
    return cyl(p,c,h); 
}

//CITY GENERATION CODE (Note hard coded inputs) ================================================
//Methods created so that sceneDistance equation is more readable 
float base1(vec3 P){
    return eb1(P, vec3(0,0,0), vec3(3,.3,3)); 
}
float base2(vec3 P){
    return eb2(P, vec3(0,1,0), vec2(2,.6)); 
}
float tower1(vec3 P){
    return et1(P, vec3(0,1.5,0), vec3(.5,2,.5)); 
}
float tower2(vec3 P){
    return et2(P, vec3(0,1.5,0), vec3(1,2,1)); 
}
float tower3(vec3 P){
    return et2(P, vec3(0,1.5,0), vec3(1,2,1)); 
}
float tower4(vec3 P){
    return et3(P, vec3(0,1.5,0), vec3(1,4,1)); 
}
float tower5(vec3 P){
    return et4(P, vec3(0,.8,0), vec3(.5,1.5,.5)); 
}
float tower6(vec3 P){
    return et1(P, vec3(0,0,0), vec3(1.2,4,1.2));
}
//smoke stack tower 
float sTower1(vec3 P){
    float h = 5; 
    return uOp( uOp( eb1(P, vec3(0,h/3,0), vec3(.6,h/3,.6)), eb3(P, vec3(0,h,0), vec2(.2,h))), 
                eb1(P, vec3(.3,h-.5,0), vec3(.3,h/4,.3))); 
}
float extraBoxes(vec3 P){
    return eb1(P, vec3(0,0,0), vec3(1,1,1)); 
}

//THE DISTANCE EQUATION (not called) 
float sceneDistance(vec3 P){
     return uOp(uOp( uOp(uOp( uOp(uOp( uOp( uOp( base1(p1), tower1(p2)), tower2(p3)), base2(p4) ), sTower1(p5)), 
                              tower4(p6)), tower5(p7)), extraBoxes(p8)), tower6(p9)); 
}


//NOTE: for material regularity sceneDistance and sceneDistanceMaterial must be in synch 

//DISTANCE EQUATION, Transform point before the call 
float tranSceneDistance(vec3 p){

    //Mod domain change to have repetition effects for buildings 
     p1 = transformPoint(p,modValue1); 
     p2 = transformPoint(p,modValue2); 
     p3 = transformPoint(p,modValue3); 
     p4 = transformPoint(p,modValue4); 
     p5 = transformPoint(p,modValue5); 
     p6 = transformPoint(p,modValue6); 
     p7 = transformPoint(p,modValue7); 
     p8 = transformPoint(p,modValue8); 
     p9 = transformPoint(p,modValue9); 

     //Current radius of our exploding sphere 
     float curRadius = 200 * abs(cos(ourTime)); 

     //Get a smooth min between city and the exploding circle sphere 
     return smin( uOp(uOp( uOp(uOp( uOp(uOp( uOp( uOp( base1(p1), tower1(p2)), tower2(p3)), base2(p4) ), sTower1(p5)),
                                    tower4(p6)), tower5(p7)), extraBoxes(p8)), et1(p9,vec3(0,0,0), vec3(1.2,4,1.2))), spher( p, vec3(0,80,0), curRadius), 100);

}

vec3 getNormal(in vec3 P){

    //Runs Quickly "fake normal" 
    /*
    return normalize(vec3( base1(P+vec3(eps,0,0)),
                              base1(P+vec3(0,eps,0)),
                              base1(P+vec3(0,0,eps)))/eps); 
    */

    //Real normal 
    return normalize(vec3( tranSceneDistance(P+vec3(eps,0,0)),
                              tranSceneDistance(P+vec3(0,eps,0)),
                              tranSceneDistance(P+vec3(0,0,eps)))/eps); 
}


//Method called from trace-me.pix 
bool intersect(vec3 P, vec3 w, inout float distance, inout Surfel surfel, float time){
    ourTime = time; 

    //best is at 100 
    const int maxIterations = 50; 

    //lower values gives better close quality, higher values gives better long distance viewing 
    const float closeEnough = 1e-4; 
    
    float t = 0; 
    float dt; 

    for(int i = 0; i<maxIterations; ++i){
        dt = tranSceneDistance(P+w*t); 
        t += max(dt,0.0); 

         if(t>distance){
            return false; 
        }

        if(dt <= closeEnough){

            surfel.position = P + w*t; 
            distance = t; 

            surfel.normal = getNormal( P+w*(t)); 

            //ourMat determined by another function, sMin 
            surfel.material = ourMat; 
            return true; 
        }
    }
    return false; 
}

# endif 













