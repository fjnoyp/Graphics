#include <G3D/G3DAll.h>

/** Application framework. */
class App : public GApp {
protected:

    shared_ptr<Texture> m_environmentMap;

    Array<shared_ptr<Texture> > m_veniceTexture;

    float time; 

    void resetTime(); 
    void makeGUI(); 
public:
    
    App(const GApp::Settings& settings = GApp::Settings());

    virtual void onInit() override;

    virtual void onGraphics3D(RenderDevice* rd, Array<shared_ptr<Surface> >& surface3D) override;
};

//////////////////////////////////////////////////////////////////////////////


App::App(const GApp::Settings& settings) : GApp(settings) {
}


void App::onInit() {
    GApp::onInit();

    setFrameDuration(1.0f / 60.0f);
    showRenderingStats  = false;

    createDeveloperHUD();
    developerWindow->sceneEditorWindow->setVisible(false);
    developerWindow->cameraControlWindow->setVisible(false);
    developerWindow->setVisible(true);
    developerWindow->videoRecordDialog->setEnabled(true);

    Texture::Specification e;
    e.filename = System::findDataFile("cubemap/islands/islands_*.jpg");
    e.encoding.format = ImageFormat::SRGB8();
    m_environmentMap = Texture::create(e);

    for (int i = 0; i < 4; ++i) {
        m_veniceTexture.append(Texture::fromFile(format("iChannel%d.jpg", i)));
    }

    debugCamera()->setFieldOfViewAngle(40 * units::degrees());

    makeGUI(); 
}

void App::makeGUI() {
    // Initialize the developer HUD (using the existing scene)
    createDeveloperHUD();
    debugWindow->setVisible(true);
    developerWindow->videoRecordDialog->setEnabled(true);

    GuiPane* infoPane = debugPane->addPane("Info", GuiTheme::ORNATE_PANE_STYLE);

    // Example of how to add debugging controls
    infoPane->addLabel("You can add GUI controls");
    infoPane->addLabel("in App::onInit().");
    infoPane->addButton("reset time", this, &App::resetTime); 
    infoPane->pack();

    // More examples of debugging GUI controls:
    // debugPane->addCheckBox("Use explicit checking", &explicitCheck);
    // debugPane->addTextBox("Name", &myName);
    // debugPane->addNumberBox("height", &height, "m", GuiTheme::LINEAR_SLIDER, 1.0f, 2.5f);
    // button = debugPane->addButton("Run Simulator");

    debugWindow->pack();
    debugWindow->setRect(Rect2D::xywh(0, 0, (float)window()->width(), debugWindow->rect().height()));
}

void App::resetTime(){
    time = 0; 
}


void App::onGraphics3D(RenderDevice* rd, Array<shared_ptr<Surface> >& allSurfaces) {
    // Bind the main framebuffer
    rd->push2D(m_framebuffer); {
        rd->clear();

        Args args;

        // Prepare the arguments for the shader function invoked below
        args.setUniform("cameraToWorldMatrix",    activeCamera()->frame());

        m_environmentMap->setShaderArgs(args, "environmentMap_", Sampler::cubeMap());
        args.setUniform("environmentMap_MIPConstant", log2(float(m_environmentMap->width() * sqrt(3.0f))));

        args.setUniform("tanHalfFieldOfViewY",  float(tan(activeCamera()->projection().fieldOfViewAngle() / 2.0f)));

        // Projection matrix, for writing to the depth buffer. This
        // creates the input that allows us to use the depth of field
        // effect below.
        Matrix4 projectionMatrix;
        activeCamera()->getProjectUnitMatrix(rd->viewport(), projectionMatrix);
        args.setUniform("projectionMatrix22", projectionMatrix[2][2]);
        args.setUniform("projectionMatrix23", projectionMatrix[2][3]);

        // Textures for the venice example
        for (int i = 0; i < m_veniceTexture.size(); ++i) {
            args.setUniform(format("iChannel%d", i), m_veniceTexture[i], Sampler::defaults());
        }

        // Set the domain of the shader to the viewport rectangle
        args.setRect(rd->viewport());

        //Set the time variable 
        args.setUniform("time",time); 
        time += 0.01f; 

        // Call the program in trace.pix for every pixel within the
        // domain, using many threads on the GPU. This call returns
        // immediately on the CPU and the code executes asynchronously
        // on the GPU.
        //LAUNCH_SHADER("trace-analytic.pix", args);
        LAUNCH_SHADER("trace-me.pix", args);

        // Post-process special effects
        m_depthOfField->apply(rd, m_framebuffer->texture(0), 
                              m_framebuffer->texture(Framebuffer::DEPTH), 
                              activeCamera(), Vector2int16());
        
    } rd->pop2D();

    swapBuffers();

    rd->clear();

    // Perform gamma correction, bloom, and SSAA, and write to the native window frame buffer
    m_film->exposeAndRender(rd, activeCamera()->filmSettings(), m_framebuffer->texture(0));
}


//////////////////////////////////////////////////////////////////////

G3D_START_AT_MAIN();

int main(int argc, const char* argv[]) {
    {
        G3DSpecification g3dSpec;
        g3dSpec.audio = false;
        initGLG3D(g3dSpec);
    }

    GApp::Settings settings(argc, argv);

    settings.window.caption = "Simple GPU Ray Tracer";
    settings.window.width   = 840;
    settings.window.height  = 480;

    return App(settings).run();
}

