/**
  \file App.h

  The G3D 10.00 default starter app is configured for OpenGL 3.3 and
  relatively recent GPUs.
 */
#ifndef App_h
#define App_h
#include <G3D/G3DAll.h>
#include "RayTracer.h"
#include <math.h>
#include "Expr.h" 
#include "Art.h"

/** Application framework. */
class App : public GApp {
protected:
    
    //our parameter variables 
    float artTimeIncrement; 
    float ourTime; 
    //end

    //our variables 
    shared_ptr<Art> artGenerator; 

    bool runTerChanger; 
    bool recording;

    float framesToCapture;
    shared_ptr<G3D::VideoOutput> video;

    //end

    RealTime                m_lastLightingChangeTime;
    GuiDropDownList*        m_resolutionList;

    shared_ptr<RayTracer> rayTracer; 
    RayTracer::Settings     m_rayTracerSettings;
    RayTracer::Stats        m_rayTracerStats;

    /** Called from onInit */
    void makeGUI();

public:
    
    App(const GApp::Settings& settings = GApp::Settings());

    virtual void onInit() override;
    virtual void onAI() override;
    virtual void onNetwork() override;
    virtual void onSimulation(RealTime rdt, SimTime sdt, SimTime idt) override;
    virtual void onPose(Array<shared_ptr<Surface> >& posed3D, Array<shared_ptr<Surface2D> >& posed2D) override;

    // You can override onGraphics if you want more control over the rendering loop.
    // virtual void onGraphics(RenderDevice* rd, Array<shared_ptr<Surface> >& surface, Array<shared_ptr<Surface2D> >& surface2D) override;

    virtual void onGraphics3D(RenderDevice* rd, Array<shared_ptr<Surface> >& surface3D) override;

    /**
       We retooled this method to both support video recording when the recording boolean is set to true and to support changes in time to the terrain by getting the next art piece from our Art variable and then loading that the png and reloading the scene. 
     */
    virtual void onGraphics2D(RenderDevice* rd, Array<shared_ptr<Surface2D> >& surface2D) override;

    virtual bool onEvent(const GEvent& e) override;
    virtual void onUserInput(UserInput* ui) override;
    virtual void onCleanup() override;

    /**
       We changed this method so that it would not popup a loading scene method.  Unfortunately, the original method refers to and modifies private variables of GApp which we are no longer able to update as before.  We did not notice any changes in vbehavior from omitting those private variable changes however. 
     */
    virtual void loadScene(const String& sceneName) override; 
    
    /** Sets m_endProgram to true. */
    virtual void endProgram();

    void onResolutionChange();
    void onRenderButton();
    /**
       This method is called when the video button is pressed.  It creates a raytracer to use, creates the art generator then sets the recording boolean to true.  It also creates the video output which will be appending the images created from render. 
     */
    void onVideoButton();

    /**
       Creates a 2d random art image using the art class, writes out the art as a png and then reloads the scene and cleares the cache 
     */
    void changeTerrain(); 


    //not working with raytracer, keeping for possible future use 
    void readHeightField(shared_ptr<Image> grayscale, String offFile, float vertScale, float horScale, float textScale);
};

#endif

