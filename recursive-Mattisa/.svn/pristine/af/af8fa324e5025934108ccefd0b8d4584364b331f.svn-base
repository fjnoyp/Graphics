/** \file App.cpp */
#include "App.h"



// Tells C++ to invoke command-line main() function even on OS X and Win32.
G3D_START_AT_MAIN();

int main(int argc, const char* argv[]) {
	{
		G3DSpecification g3dSpec;
		g3dSpec.audio = false;
		initGLG3D(g3dSpec);
	}

    GApp::Settings settings(argc, argv);

    // Change the window and other startup parameters by modifying the
    // settings class.  For example:
    settings.window.caption			= argv[0];
    //settings.window.debugContext = true;
    // Some popular resolutions:
    // settings.window.width        = 640;  settings.window.height       = 400;
    // settings.window.width		= 1024; settings.window.height       = 768;
    settings.window.width         = 1280; settings.window.height       = 720;
    //settings.window.width        = 1920; settings.window.height       = 1080;
    // settings.window.width		= OSWindow::primaryDisplayWindowSize().x; settings.window.height = OSWindow::primaryDisplayWindowSize().y;

    // Set to true for a significant performance boost if your app can't render at 60fps,
    // or if you *want* to render faster than the display.
    settings.window.asynchronous	    = true;
    settings.depthGuardBandThickness    = Vector2int16(64, 64);
    settings.colorGuardBandThickness    = Vector2int16(16, 16);
    settings.dataDir			        = FileSystem::currentDirectory();
    settings.screenshotDirectory	    = "../journal/";

    return App(settings).run();
}


App::App(const GApp::Settings& settings) : GApp(settings) {
}


// Called before the application loop begins.  Load data here and
// not in the constructor so that common exceptions will be
// automatically caught.
void App::onInit() {
    //PARAMETERS FOR OUR ART GENERATOR 
    //artTimeIncrement = M_PI/400.0f; 
    artTimeIncrement = M_PI/100.0f; 
    int depth(9); 

    //uint32 seed(13411422); //mountain like cool! (used in last lab's generator)
    //uint32 seed(819032515); //water like 
    //uint32 seed(674578); //somewhat water like 
    uint32 seed(9999999); //really like water

    //uint32 seed(1380); //water droplets


    //uint32 seed(1111111111113); //a massive circular ripple 

    artGenerator = Art::create( artTimeIncrement, depth, seed); 

    recording = false;
    //END OUR CODE 

    GApp::onInit();


    // Call setScene(shared_ptr<Scene>()) or setScene(MyScene::create()) to replace
    // the default scene here.
    
    showRenderingStats      = false;

    makeGUI();

    m_lastLightingChangeTime = 0.0;
    // For higher-quality screenshots:
    // developerWindow->videoRecordDialog->setScreenShotFormat("PNG");
    // developerWindow->videoRecordDialog->setCaptureGui(false);
    developerWindow->cameraControlWindow->moveTo(Point2(developerWindow->cameraControlWindow->rect().x0(), 0));
    loadScene(
              "Reflections"
              //		"G3D Cornell Box" // Load something simple
         //    developerWindow->sceneEditorWindow->selectedSceneName()  // Load the first scene encountered 
        );
}


void App::makeGUI() {
    // Initialize the developer HUD (using the existing scene)
    createDeveloperHUD();
    debugWindow->setVisible(true);
    developerWindow->videoRecordDialog->setEnabled(true);

    // GuiPane* infoPane = debugPane->addPane("Info", GuiTheme::ORNATE_PANE_STYLE);

    // Example of how to add debugging controls
    // infoPane->addLabel("You can add GUI controls");
    // infoPane->addLabel("in App::onInit().");
    // infoPane->addButton("Exit", this, &App::endProgram);
    // infoPane->pack();

    // More examples of debugging GUI controls:
    // debugPane->addCheckBox("Use explicit checking", &explicitCheck);
    // debugPane->addTextBox("Name", &myName);
    // debugPane->addNumberBox("height", &height, "m", GuiTheme::LINEAR_SLIDER, 1.0f, 2.5f);
    // button = debugPane->addButton("Run Simulator");

    //default settings
    m_rayTracerSettings.multithreaded = true;
    m_rayTracerSettings.useTree = true;
    m_rayTracerSettings.castShadows = false; 
    m_rayTracerSettings.raysPerPixel = 5; 
    m_rayTracerSettings.width =640;
    m_rayTracerSettings.height = 360;
    m_rayTracerSettings.recursion = 100;
    
    GuiPane* rtPane(debugPane->addPane("RayTracer", GuiTheme::ORNATE_PANE_STYLE)); 
    m_resolutionList = rtPane->addDropDownList( "Resolution",
                                                Array<String>("16 x 9", "160 x 90","320 x 180", "640 x 360", "1280 x 720"), 
                                                NULL, 
                                                GuiControl::Callback(this, &App::onResolutionChange));
    rtPane->addCheckBox("Multithreaded", &m_rayTracerSettings.multithreaded);
    rtPane->addCheckBox("Use Tree", &m_rayTracerSettings.useTree);
    rtPane->addNumberBox("Rays per Pixel", &m_rayTracerSettings.raysPerPixel);
    rtPane->addNumberBox("Recursion", &m_rayTracerSettings.recursion);
    rtPane->addCheckBox("Use Shadows", &m_rayTracerSettings.castShadows);
    rtPane->addButton("Render", this , &App::onRenderButton);
    rtPane->pack();

    GuiPane* statsPane(debugPane->addPane("Ray Tracer Stats", GuiTheme::ORNATE_PANE_STYLE));
    statsPane->moveRightOf(rtPane);
    statsPane->addNumberBox("Lights", &m_rayTracerStats.lights); 
    statsPane->addNumberBox("Triangles", &m_rayTracerStats.triangles);
    statsPane->addNumberBox("Build Time", &m_rayTracerStats.buildTriTreeTimeMilliseconds, "ms"); 
    statsPane->addNumberBox("Trace Time", &m_rayTracerStats.rayTraceTimeMilliseconds, "ms");
    statsPane->addNumberBox("Primary Rays", &m_rayTracerStats.primaryRayCount);
    statsPane->addNumberBox("Indirect Rays", &m_rayTracerStats.indirectRayCount);
    statsPane->addNumberBox("Shadow Rays", &m_rayTracerStats.shadowRayCount);
    statsPane->addNumberBox("Total Rays", &m_rayTracerStats.totalRayCount);
    statsPane->pack();   

    GuiPane* videoPane(debugPane->addPane("Video", GuiTheme::ORNATE_PANE_STYLE)); 
    videoPane->moveRightOf(statsPane);
    videoPane->addNumberBox("Video Length", &framesToCapture);
    videoPane->addButton("Record", this, &App::onVideoButton);
    videoPane->addCheckBox("Activate Terrain Changer (will disable GUI)", &runTerChanger);
    videoPane->pack();
    
    debugWindow->pack();
    debugWindow->setRect(Rect2D::xywh(0, 0, (float)window()->width(), debugWindow->rect().height()));
}




//method that runs when we click on the render button 
void App::onRenderButton() {

    rayTracer = RayTracer::create();

    
    debugPrintf("Rendering image\n");
    scene()->onPose(m_posed3D); 
    shared_ptr<LightingEnvironment> le = shared_ptr<LightingEnvironment>(new LightingEnvironment(scene()->lightingEnvironment())); 
    show(rayTracer->render(m_rayTracerSettings, m_posed3D, le, activeCamera(), m_rayTracerStats),
         "Hello!");
}

void App::onVideoButton() {
    rayTracer = RayTracer::create();

    ourTime = 0;

    framesToCapture = 200.0f; 
    float frameDuration = 1.0f / 25.0f; //25 fps 
    setFrameDuration(frameDuration);

    scene()->setTime(GameTime(0.0));
    recording = true;
    debugPrintf("Start Recording.\n");
    video = G3D::VideoOutput::create("frames/video.mp4", G3D::VideoOutput::Settings(G3D::VideoOutput::CODEC_ID_MPEG4, m_rayTracerSettings.width, m_rayTracerSettings.height));
}

void App::onResolutionChange() {
    TextInput ti(TextInput::FROM_STRING, m_resolutionList->selectedValue().text());
    m_rayTracerSettings.width = ti.readNumber();
    ti.readSymbol("x");
    m_rayTracerSettings.height = ti.readNumber();
}

void App::onGraphics3D(RenderDevice* rd, Array<shared_ptr<Surface> >& allSurfaces) {
    // This implementation is equivalent to the default GApp's. It is repeated here to make it
    // easy to modify rendering. If you don't require custom rendering, just delete this
    // method from your application and rely on the base class.

    // screenPrintf("Print to the screen from anywhere in a G3D program with this command.");
    if (! scene()) {
        return;
    }
    m_gbuffer->setSpecification(m_gbufferSpecification);
    m_gbuffer->resize(m_framebuffer->width(), m_framebuffer->height());

    // Share the depth buffer with the forward-rendering pipeline
    m_framebuffer->set(Framebuffer::DEPTH, m_gbuffer->texture(GBuffer::Field::DEPTH_AND_STENCIL));
    m_depthPeelFramebuffer->resize(m_framebuffer->width(), m_framebuffer->height());

    Surface::AlphaMode coverageMode = Surface::ALPHA_BLEND;

    // Bind the main framebuffer
    rd->pushState(m_framebuffer); {
        rd->clear();
        rd->setProjectionAndCameraMatrix(activeCamera()->projection(), activeCamera()->frame());

        m_gbuffer->prepare(rd, activeCamera(), 0, -(float)previousSimTimeStep(), m_settings.depthGuardBandThickness, m_settings.colorGuardBandThickness);
        
        // Cull and sort
        Array<shared_ptr<Surface> > sortedVisibleSurfaces;
        Surface::cull(activeCamera()->frame(), activeCamera()->projection(), rd->viewport(), allSurfaces, sortedVisibleSurfaces);
        Surface::sortBackToFront(sortedVisibleSurfaces, activeCamera()->frame().lookVector());
        
        const bool renderTransmissiveSurfaces = false;

        // Intentionally copy the lighting environment for mutation
        LightingEnvironment environment = scene()->lightingEnvironment();
        environment.ambientOcclusion = m_ambientOcclusion;
       
        // Render z-prepass and G-buffer.
        Surface::renderIntoGBuffer(rd, sortedVisibleSurfaces, m_gbuffer, activeCamera()->previousFrame(), activeCamera()->expressivePreviousFrame(), renderTransmissiveSurfaces, coverageMode);

        // This could be the OR of several flags; the starter begins with only one motivating algorithm for depth peel
        const bool needDepthPeel = environment.ambientOcclusionSettings.useDepthPeelBuffer;
        if (needDepthPeel) {
            rd->pushState(m_depthPeelFramebuffer); {
                rd->clear();
                rd->setProjectionAndCameraMatrix(activeCamera()->projection(), activeCamera()->frame());
                Surface::renderDepthOnly(rd, sortedVisibleSurfaces, CullFace::BACK, renderTransmissiveSurfaces, coverageMode, m_framebuffer->texture(Framebuffer::DEPTH), environment.ambientOcclusionSettings.depthPeelSeparationHint);
            } rd->popState();
        }

        if (! m_settings.colorGuardBandThickness.isZero()) {
            rd->setGuardBandClip2D(m_settings.colorGuardBandThickness);
        }        

        // Compute AO
        m_ambientOcclusion->update(rd, environment.ambientOcclusionSettings, activeCamera(), m_framebuffer->texture(Framebuffer::DEPTH), m_depthPeelFramebuffer->texture(Framebuffer::DEPTH), m_gbuffer->texture(GBuffer::Field::CS_NORMAL), m_gbuffer->texture(GBuffer::Field::SS_POSITION_CHANGE), m_settings.depthGuardBandThickness - m_settings.colorGuardBandThickness);

        const RealTime lightingChangeTime = G3D::max(scene()->lastEditingTime(), G3D::max(scene()->lastLightChangeTime(), scene()->lastVisibleChangeTime()));
        bool updateShadowMaps = false;
        if (lightingChangeTime > m_lastLightingChangeTime) {
            m_lastLightingChangeTime = lightingChangeTime;
            updateShadowMaps = true;
        }
        // No need to write depth, since it was covered by the gbuffer pass
        rd->setDepthWrite(false);
        // Compute shadow maps and forward-render visible surfaces
        Surface::render(rd, activeCamera()->frame(), activeCamera()->projection(), sortedVisibleSurfaces, allSurfaces, environment, coverageMode, updateShadowMaps, m_settings.depthGuardBandThickness - m_settings.colorGuardBandThickness, sceneVisualizationSettings());      
                
        // Call to make the App show the output of debugDraw(...)
        drawDebugShapes();
        const shared_ptr<Entity>& selectedEntity = (notNull(developerWindow) && notNull(developerWindow->sceneEditorWindow)) ? developerWindow->sceneEditorWindow->selectedEntity() : shared_ptr<Entity>();
        scene()->visualize(rd, selectedEntity, sceneVisualizationSettings());

        // Post-process special effects
        m_depthOfField->apply(rd, m_framebuffer->texture(0), m_framebuffer->texture(Framebuffer::DEPTH), activeCamera(), m_settings.depthGuardBandThickness - m_settings.colorGuardBandThickness);
        
        m_motionBlur->apply(rd, m_framebuffer->texture(0), m_gbuffer->texture(GBuffer::Field::SS_EXPRESSIVE_MOTION), 
                            m_framebuffer->texture(Framebuffer::DEPTH), activeCamera(), 
                            m_settings.depthGuardBandThickness - m_settings.colorGuardBandThickness);

    } rd->popState();

    // We're about to render to the actual back buffer, so swap the buffers now.
    // This call also allows the screenshot and video recording to capture the
    // previous frame just before it is displayed.
    swapBuffers();

	// Clear the entire screen (needed even though we'll render over it, since
    // AFR uses clear() to detect that the buffer is not re-used.)
    rd->clear();

    // Perform gamma correction, bloom, and SSAA, and write to the native window frame buffer
    m_film->exposeAndRender(rd, activeCamera()->filmSettings(), m_framebuffer->texture(0));



    //OUR STUFF
    // loadscene("Blue");
    // Example GUI dynamic layout code.  Resize the debugWindow to fill
    // the screen horizontally.
    debugWindow->setRect(Rect2D::xywh(0, 0, (float)window()->width(), debugWindow->rect().height()));
    
    //prints out film progress so far 
    /*
    cout << "\n"; 
    cout << (ourTime); 
    cout << " ";
    cout << (framesToCapture); 
    cout << "\n"; 

    cout <<"scene time: ";
    cout << scene()->time(); 
    */

    if(recording && (ourTime < framesToCapture)){
        shared_ptr<LightingEnvironment> le = shared_ptr<LightingEnvironment>(new LightingEnvironment(scene()->lightingEnvironment())); 
        scene()->onPose(m_posed3D); 
        shared_ptr<Image> next = rayTracer->render(m_rayTracerSettings, m_posed3D, le, activeCamera(), m_rayTracerStats);    
        video->append(G3D::Texture::fromImage("name",next));
        scene()->setTime(ourTime/10.0f);
        ourTime += 1; 
    } else if(recording) {
        video->commit();
        //framesToCapture = 0.0;
        recording = false;
        debugPrintf("Finished Recording. Frames: %f\n", ourTime); 
    }

    if(runTerChanger) {
        changeTerrain(); 
    }

}

void App::changeTerrain(){
    shared_ptr<Image> image = artGenerator->nextImage(); 
    
    const G3D::String theText("random art image"); 
    const shared_ptr<G3D::Texture> pointer(G3D::Texture::fromImage( theText, image));     
    image->convert(G3D::ImageFormat::RGB8()); 
    image->save("heightfield.png"); 
    G3D::ArticulatedModel::clearCache();
    loadScene("Blue"); 
}

void App::loadScene(const String& sceneName){ 

    const String oldSceneName = scene()->name();

    // Load the scene
    try {
        const Any& any = scene()->load(sceneName);

        // If the debug camera was active and the scene is the same as before, retain the old camera.  Otherwise,
        // switch to the default camera specified by the scene.

        if ((oldSceneName != scene()->name()) || (activeCamera()->name() != "(Debug Camera)")) {

            // Because the CameraControlWindow is hard-coded to the
            // m_debugCamera, we have to copy the camera's values here
            // instead of assigning a pointer to it.
            m_debugCamera->copyParametersFrom(scene()->defaultCamera());
            m_debugController->setFrame(m_debugCamera->frame());

            setActiveCamera(scene()->defaultCamera());
        }

        onAfterLoadScene(any, sceneName);

    } catch (const ParseError& e) {
        const String& msg = e.filename + format(":%d(%d): ", e.line, e.character) + e.message;
        debugPrintf("%s", msg.c_str());
        logPrintf("%s", msg.c_str());
        drawMessage(msg);
        System::sleep(5);
        scene()->clear();
    }

    // Trigger one frame of rendering, to force shaders to load and compile
    m_posed3D.fastClear();
    m_posed2D.fastClear();
    if (scene()) {
        onPose(m_posed3D, m_posed2D);
    }
    onGraphics(renderDevice, m_posed3D, m_posed2D);

    // Reset our idea of "now" so that simulation doesn't see a huge lag
    // due to the scene load time.
    //    m_lastTime = m_now = System::time() - 0.0001f;

}


void App::onAI() {
    GApp::onAI();
    // Add non-simulation game logic and AI code here
}


void App::onNetwork() {
    GApp::onNetwork();
    // Poll net messages here
}


void App::onSimulation(RealTime rdt, SimTime sdt, SimTime idt) {
    GApp::onSimulation(rdt, sdt, idt);
}

bool App::onEvent(const GEvent& event) {
    // Handle super-class events
    if (GApp::onEvent(event)) { return true; }

    // If you need to track individual UI events, manage them here.
    // Return true if you want to prevent other parts of the system
    // from observing this specific event.
    //
    // For example,
    // if ((event.type == GEventType::GUI_ACTION) && (event.gui.control == m_button)) { ... return true; }
    // if ((event.type == GEventType::KEY_DOWN) && (event.key.keysym.sym == GKey::TAB)) { ... return true; }

    return false;
}


void App::onUserInput(UserInput* ui) {
    GApp::onUserInput(ui);
    (void)ui;
    // Add key handling here based on the keys currently held or
    // ones that changed in the last frame.
}


void App::onPose(Array<shared_ptr<Surface> >& surface, Array<shared_ptr<Surface2D> >& surface2D) {
    GApp::onPose(surface, surface2D);

    // Append any models to the arrays that you want to later be rendered by onGraphics()
}


void App::onGraphics2D(RenderDevice* rd, Array<shared_ptr<Surface2D> >& posed2D) {
    // Render 2D objects like Widgets.  These do not receive tone mapping or gamma correction.
    Surface2D::sortAndRender(rd, posed2D);
}


void App::onCleanup() {
    // Called after the application loop ends.  Place a majority of cleanup code
    // here instead of in the constructor so that exceptions can be caught.
}


void App::endProgram() {
    m_endProgram = true;
}


//code to make a low-polygonal heightfield in OFF format, scale increases size of polygons
void App::readHeightField(shared_ptr<Image> grayscale, String offFile, float vertScale, float horScale, float textScale) {
    int scale = 2;
    int width = grayscale->width();
    int height = grayscale->height();
    int u = (int)floor(width/scale);
    int v = (int)floor(height/scale);
    String vertexString = "";
    String faceString = "";
    for(int i =0; i < u; i++) {
        for(int j =0; j < v; j++) {
            Point2int32 pos(i*scale, j*scale);
            Color4 color;
            grayscale->get(pos, color);
            float blackness = color.r;
            // now we want to make a vertex with that height                                                                                                                                                                            
            vertexString += format("%f %f %f %d %d\n", (i*horScale), (1 - blackness) * textScale, j*vertScale, i, j);

            if(j < v - 1 && i < u - 1) {

                faceString += format("3 %d %d %d\n", (v*i + j),
 (v*i + j + 1), (v*(i+1) + j));

                faceString += format("3 %d %d %d\n", (v*i + j + 1), (v*(i+1) + j +1),  (v*(i+1) + j));

            }
        }
    }

    // write to file                                                                                                                                                                                                                    
    FILE* f = fopen(offFile.c_str(), "w");
    debugAssert(f != NULL);
    fprintf(f, "STOFF\n%d %d %d\n", u*v, 2*(u-1)*(v-1), 3*(u)*(v-1)); // V - E + F = 2                                                                                                                       
    fprintf(f, vertexString.c_str());
    fprintf(f, faceString.c_str());
    // remember to close file                                                                                                                                                                                                           
    fclose(f);
    f = NULL;
    debugPrintf("Wrote file.\n");

}


