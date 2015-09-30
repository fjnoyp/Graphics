#include "RayTracer.h"
 RayTracer::Settings::Settings() :
	width(160),
	height(90),
	multithreaded(true),
	useTree(false) {
		# ifdef G3D_DEBUG
			// If we’re debugging, we probably don’t want threads by default
			multithreaded = false;
		# endif
	}

RayTracer::Stats::Stats() :
	lights(0),
	triangles(0),
	pixels(0),
	buildTriTreeTimeMilliseconds(0),
	rayTraceTimeMilliseconds(0),
        primaryRayCount(0),
        indirectRayCount(0),
        shadowRayCount(0),
        totalRayCount(0) 
     {}

RayTracer::RayTracer() {
	m_rnd.resize(System::numCores());
	for (int i = 0; i < m_rnd.size(); ++i) {
		// Use a different seed for each and do not be threadsafe
		m_rnd[i] = shared_ptr<Random>(new Random(i, false));
	} 
}

shared_ptr<RayTracer> RayTracer::create() {
    
	return shared_ptr<RayTracer>(new RayTracer());
}

shared_ptr<Image> RayTracer::render
	(const Settings& settings,
	const Array< shared_ptr<Surface> >& surfaceArray,
	const shared_ptr<LightingEnvironment>& lighting,
	const shared_ptr<Camera>& camera,
	Stats& stats) {

	RealTime start;
	debugAssert(notNull(lighting) && notNull(camera));
	// Implemented: store member pointers to the arguments
	// so that they can propagate inside the callbacks
	m_settings = settings;
	m_lighting = lighting;
	m_camera = camera;
        
    //initialize ray count stats
    m_indirectRayCount = 0;
    m_shadowRayCount = 0;
    m_totalRayCount = 0;
    
	// Build the TriTree
	start = System::time();
	m_triTree.setContents(surfaceArray);
	stats.buildTriTreeTimeMilliseconds = float((System::time() - start) / units::milliseconds());
	
	// Allocate the image
	m_image = Image::create(settings.width, settings.height,
	ImageFormat::RGB32F());
	
	// Render the image
	start = System::time();
	const int numThreads = settings.multithreaded ? GThread::NUM_CORES : 1;
	traceAllPixels(numThreads);
	stats.rayTraceTimeMilliseconds = float((System::time() - start) / units::milliseconds());
	
	// Implemented: Fill out other stats
	shared_ptr<Image> temp(m_image);
	stats.lights = m_lighting->lightArray.length();// - m_lighting->numShadowCastingLights();
	stats.triangles = m_triTree.size();
	stats.pixels = settings.width * settings.height;
        
    //Ray count stats
    stats.primaryRayCount = m_settings.raysPerPixel*stats.pixels;
    stats.indirectRayCount = m_indirectRayCount;
    stats.shadowRayCount = m_shadowRayCount; 
    stats.totalRayCount = stats.primaryRayCount + stats.indirectRayCount + stats.shadowRayCount;
    

	// Implemented: Reset pointers to NULL to allow garbage collection
	m_lighting.reset();
	m_camera.reset();

	return temp;

}

void RayTracer::traceOnePixel(int x, int y, int threadID){
    Radiance3 radiance; 


    if(m_settings.raysPerPixel == 1){
        const Ray& primary(m_camera->worldRay(x+0.5f, y+0.5f, Rect2D(Vector2(m_settings.width, m_settings.height))));
	const shared_ptr<Surfel> surfelHit(RayTracer::castRay(primary));
        if(surfelHit){
            radiance += RayTracer::L_o(surfelHit, -primary.direction(), m_settings.recursion, *m_rnd[threadID]); 
        }
    }
    //If trace more than one ray per pixel, randomly trace ray from [0,1] [0,1] relative pixel coordinate 
    else{
        G3D::Random random(G3D::System::time()); 
        for(int i = 0; i<m_settings.raysPerPixel; ++i){
            const Ray& primary(m_camera->worldRay(x+random.uniform(), y+random.uniform(), 
                                                  Rect2D(Vector2(m_settings.width, m_settings.height))));
            const shared_ptr<Surfel> surfelHit(RayTracer::castRay(primary));
            if(surfelHit){
                radiance += RayTracer::L_o(surfelHit, -primary.direction(), m_settings.recursion, *m_rnd[threadID]); 
            }
        }
        radiance /= (float)m_settings.raysPerPixel; 
    }
    m_image->set(Point2int32(x,y), radiance);   


}

void RayTracer::traceAllPixels(int numThreads) {
	GThread::runConcurrently2D(Point2int32(0,0), Point2int32(m_settings.width, m_settings.height), this, 
                               &RayTracer::traceOnePixel, numThreads);
}

shared_ptr<Surfel> RayTracer::castRay(const Ray& ray,
                                      float maxDistance,
                                      bool anyHit) const {
    // Distance from P to X
    float distance(maxDistance);
    shared_ptr<Surfel> surfel;
    
    if (m_settings.useTree) {
        // Treat the triTree as a tree
        surfel = m_triTree.intersectRay(ray, distance, anyHit);
		
    } else {
        // Treat the triTree as an array
        Tri::Intersector intersector;
        
        for (int t = 0; t < m_triTree.size(); ++t) {
            const Tri& tri = m_triTree[t];
            intersector(ray, m_triTree.cpuVertexArray(), tri,
                        anyHit, distance);
        }
        surfel = intersector.surfel();
	}
    
	return surfel;
}

//Reflected or refracted light that could hit other surfaces
Radiance3 RayTracer::L_i(const Point3& point, const Vector3& wi, int bouncesLeft, Random& rnd) const{
    // debugPrintf("inside L_i\n");
    const Ray lightRay(point, wi); 
    const shared_ptr<Surfel>& surfelHit(RayTracer::castRay(lightRay.bumpedRay(0.0001f))); 
    return L_o(surfelHit, -wi, bouncesLeft, rnd);
}  


//Reflected and refracted light
Radiance3 RayTracer::L_scatteredSpecularInDirect(const shared_ptr<Surfel>& surfel,
                                                 const Vector3& wo,
                                                 int bouncesLeft, Random& rnd) const {
    // debugPrintf("inside L_scatteredSpecularInDirect\n");
    Radiance3 L(0.0f,0.0f,0.0f); //W/m^2*sr
    
    if(notNull(surfel) && bouncesLeft > 0){
        //increment total number of indirect(impulse) rays
        m_indirectRayCount += 1; //m_indirect...?
                
        G3D::UniversalSurfel::ImpulseArray impulses;
        const shared_ptr<UniversalSurfel>& u(dynamic_pointer_cast<UniversalSurfel>(surfel)); 
        u->getImpulses(PathDirection::EYE_TO_SOURCE,wo, impulses);
        for (int i = 0; i < impulses.size(); ++i){
            Vector3 wi(impulses[i].direction);
            L+= L_i(u->position, wi, bouncesLeft, rnd) *impulses[i].magnitude;
        }
    }
    return L;
}

// The Whitted approximation of light
Radiance3 RayTracer::L_o(const shared_ptr<Surfel>& surfel, const Vector3& wo, int bouncesLeft, Random& rnd)const {
    
    Radiance3 L_ambient (Color3(0,0,0));
    
    
    if(notNull(surfel)){
        // add ambient value 
        L_ambient =  (0.001 * surfel-> reflectivity(rnd))  ;
    }
    
    return (L_ambient + L_scatteredDirect(surfel,wo, rnd) +
            L_scatteredSpecularInDirect(surfel,wo,bouncesLeft-1,rnd) 
            );
   
}


Radiance3 RayTracer::L_scatteredDirect(const shared_ptr<Surfel>& surfel, 
                                       const Vector3& wo,
                                       Random& rnd) const {
    Radiance3 L(Color3(0,0,0)); // W/m^2*sr
    if (!surfel){
        return L;
    } 
    
    const Array<shared_ptr<Light> >& lightArray(m_lighting->lightArray); 
    
    //Add direct illumination from each light
    for(int i = 0; i<lightArray.size(); ++i) {
        
        Vector3 Y(lightArray[i]->position().xyz()); // m^3
        Vector3 X(surfel->position); // m^3

        // check for shadows
        if(m_settings.castShadows && lightArray[i]->castsShadows()){
            
            //increment total number of shadow rays
            m_shadowRayCount += 1;

            //Check for intersections from light source towards surfel
            const Ray lightRay(Y, (X-Y).direction()); 
            const shared_ptr<Surfel> surfelHit(RayTracer::castRay( lightRay.bumpedRay(0.0001), (X-Y).length() - 0.1 ) ); 
            if(surfelHit) continue; 
        }

        float r((Y - X).magnitude()); // m
        Vector3 wi((Y - X).direction()); // unit vector
        Vector3 n(surfel->shadingNormal); // unit vector
      
        if(wi.dot(n) > 0 && wo.dot(n) > 0 && lightArray[i]->inFieldOfView(wi)) {
            Biradiance3 Bi(lightArray[i]->bulbPower()/(4*pi()*square(r))); //W/m^2
            L += abs(wi.dot(n)) * Bi * (surfel->finiteScatteringDensity(wi,wo)); // W/m^2*sr
        }
    }
    //Add emitted radiance 
    L += surfel->emittedRadiance(wo); 
    return L;
}




