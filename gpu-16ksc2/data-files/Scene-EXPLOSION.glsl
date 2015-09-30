#ifndef Scene_glsl // -*- c++ -*-
#define Scene_glsl

/*

NOT PROJECT CODE, I AM KEEPING THIS CODE FOR MY OWN USE 

 */

/*
PURPOSE OF THE CODE: 

This code contains the distance functions to be used for the implicit surface equations.  It also contains the intersect method that returns the proper surfel information for each pixel hit.

 */

#include "Surfel.glsl"
//#include <g3dmath.glsl>

struct Sphere {
    Point3      center;
    float       radius;
    Material    material;
};

struct Rectangle {
    Point3 center; 
    Vector3 b; 
    Material material; 
}; 

float ourTime = 0; 
//float eps = .0005; 
float eps = .005; 
//float eps = 500; 


//DISTANCE ===============================================
//THESE OPS AHVE TO SET THE NORMAL !!!! BASED ON WHICH ONE TEY RETURNED 
//But we only give resulsts how do we backtrace? 
float subtractionOp(float d1, float d2){
    return max(d1,-d2); 
}
Material subtractionOpMaterial(float d1, float d2, inout Material material1, inout Material material2){
    if( d1 > - d2){ return material1; } 
    else{ return material2; } 
}

float intersectionOp(float d1, float d2){
    return max(d1,d2); 
}
Material intersectionOpMaterial(float d1, float d2, inout Material material1, inout Material material2){
    if( d1 > d2){ return material2; } 
    else{ return material1; } 
}


float unionOp(float d1, float d2){
    return min(d1,d2); 
}
Material unionOpMaterial(float d1, float d2, inout Material material1, inout Material material2){
    if( d1 < d2){ return material2; } 
    else{ return material1; } 
}




// Signed distance function for a sphere.  Negative inside of the sphere.
float sphereDistanceEstimate(in Point3 X, in Sphere sphere){
    return length(X-sphere.center) - sphere.radius;
}

// b is vector from center to first quadrant corner 
float rectangleDistanceEstimate(Point3 X, Rectangle square) {

    //need som modification based on function of point relative to the center of the object
    Vector3 d = abs(X - square.center) - (square.b);//*(1+cos(ourTime)*(1+sin(ourTime+1))));
    return min(maxComponent(d), 0) + length(max(d, Vector3(0, 0, 0)));
}

//t.x is total radius, t.y is lobe radius 
float cylinderDistanceEstimate(Point3 X, vec2 t){
    vec2 q = vec2(length(X.xz)-t.x,X.y); 
    return length(q)-t.y; 
}

Sphere spher0 = Sphere(Point3(-1,0,3), 1.5, Material(Color3(0.7, 0.9, 0.3), 1.0, 1.0, 100));
//Sphere spher1 = Sphere(Point3(-1,0,2.5), 1.5, Material(Color3(0.7, 0.9, 0.3), 1.0, 1.0, 100));
Rectangle rect0 = Rectangle(Point3(-2,0,3),Vector3(1,1,1),Material(Color3(0,1,0), 0.0, 1.0, 100)); 

Point3 opTwist(Point3 X){
    float timeStep = 1;//ourTime; 

    float c = cos(X.y/ (3+10.0f * abs(cos(timeStep)))); 
    float s = sin(X.y/ (3+10.0f * abs(cos(timeStep)))); 

    mat2 m = mat2(c,s,-s,c); 
    return Point3(m*X.xz,X.y); 
}

//Transform the input point for mod repetitions and twist effects 
Point3 transformPoint(Point3 X){

    //AMAZING EXPLOSION OF IMPLOSION EFFECT 
    //int modValue = int( length(X)+100-ourTime*10 ); 
    //int modValue = int( length(X)-100 ); 

    int modValue = int( length(X)+1-ourTime*10 ); 

    //adds a spiral gas giant like effect, the circle poles change over surface when changing between the two different non twist vs. twist versions : 
    //    float tVar = abs(cos(ourTime/1)); 
    //    X = tVar*X + (1-tVar)*opTwist(X); 


    return mod( X , Vector3(modValue,modValue,modValue) ) - (Vector3(modValue,modValue,modValue)/2); 
}

float sceneDistance(in Point3 X){
   return sphereDistanceEstimate(X,spher0); 
}

//NOTE: for material regularity sceneDistance and sceneDistanceMaterial must be in synch 
float tranSceneDistance(Point3 X){ 

    /*
    return subtractionOp( intersectionOp( rectangleDistanceEstimate( X, rect0),  
                                           sphereDistanceEstimate( X, spher0)), 
                           sphereDistanceEstimate(X,spher1)); 
    */

    //return cylinderDistanceEstimate(X,vec2(2,.2)); 
    //return cylinderDistanceEstimate(X,vec2(2,3 + abs(  cos(ourTime)  )/.5f)); //.2+abs(cos(ourTime)))); 


    return sceneDistance(transformPoint(X))*.5; 


    //    return sphereDistanceEstimate(newX,spher0); 
    //return rectangleDistanceEstimate(X,rect0); 

    //POSSIBLES 
    //Combining a cylinder distance estimate with an optwist results in strange behavior at top of the surface 
}


Material sceneDistanceMaterial(Point3 P){
    /*
    return subtractionOpMaterial( rectangleDistanceEstimate( X, rect0),  
                                  sphereDistanceEstimate( X, spher0), rect0.material, 
                                  spher0.material); 
    */
    //return spher0.material; 
    float l = length(P);//*50; 
    
    float l2 = l; 

    return Material(Color3(P.x/l,P.y/l,P.z/l),P.x/l2,P.y/l2,P.z/l2); 
}

Vector3 getNormal(Point3 P){

    P = transformPoint(P); 
    return normalize(Vector3( sceneDistance(P+Vector3(eps,0,0)),
                              sceneDistance(P+Vector3(0,eps,0)),
                              sceneDistance(P+Vector3(0,0,eps)))/eps); 
}



bool intersect(Point3 P, Vector3 w, inout float distance, inout Surfel surfel, float time){
    const int maxIterations = 200; 

    //lower values gives better close quality, higher values gives better long distance viewing 
    const float closeEnough = 1e-4; 
    
    float t = 0; 

    int modValue = 10;     

    //    rect0.center.y = cos(time); 
    ourTime = time; 

    for(int i = 0; i<maxIterations; ++i){
        float dt = tranSceneDistance(P+w*t); 
        t += max(dt,0.0); 

        if(t>distance){
            return false; 
        }

        if(dt <= closeEnough){

            surfel.position = P + w*t; 
            distance = t; 

            surfel.normal = getNormal( P+w*(t-dt*2)); 

            //Interesting Behavior: adding at time function to the material returned allows for easy change to materials over time :
            //surfel.material = sceneDistanceMaterial(opTwist(surfel.position)); 

            //Interesting Behavior: relating the color of the object to its position in world space 
            surfel.material = sceneDistanceMaterial(surfel.position); 
            return true; 
        }
    }
    return false; 
}

























//Intersect for Sphere 
bool intersectSphere(Sphere sphere, Rectangle rect, Point3 P, Vector3 w, inout float distance, inout Surfel surfel, float time) {

    const int maxIterations = 100; 
    const float closeEnough = 1e-2;  //ISSUES WITH IMPRECISION CAUSING BUMP RAY NOT ENOUGH
    float t = 0; 

    for(int i = 0; i<maxIterations; ++i){

        //float dt = sphereDistanceEstimate( (P+ w*t), sphere ); 
        float dt = subtractionOp( rectangleDistanceEstimate( (P+w*t), rect), 
                                  sphereDistanceEstimate( (P+w*t), sphere)); 
        t += dt; 

        if(dt<closeEnough && t<distance){
            surfel.position = P + w*t; 
            surfel.normal = normalize(surfel.position - sphere.center); 
            surfel.material = sphere.material; 
            distance = t; 

            return true; 
        }

    }

    return false; 
}

//Intersect for Rectangle
bool intersectRectangle(Rectangle rect, Point3 P, Vector3 w, inout float distance, inout Surfel surfel, float time) {

    const int maxIterations = 100; 
    const float closeEnough = 1e-2;  //ISSUES WITH IMPRECISION CAUSING BUMP RAY NOT ENOUGH
    float t = 0; 

    for(int i = 0; i<maxIterations; ++i){

        float dt = rectangleDistanceEstimate( (P+ w*t), rect ); 
        t += dt; 

        if(dt<closeEnough && t<distance){
            surfel.position = P + w*t; 
            surfel.normal = normalize(surfel.position - rect.center); 
            surfel.material = rect.material; 
            distance = t; 

            return true; 
        }

    }

    return false; 
}
#endif
