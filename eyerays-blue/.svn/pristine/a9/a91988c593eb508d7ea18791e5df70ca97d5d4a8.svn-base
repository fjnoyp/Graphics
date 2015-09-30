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
	rayTraceTimeMilliseconds(0) {}

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

	// Implemented: Reset pointers to NULL to allow garbage collection
	m_lighting.reset();
	m_camera.reset();

	return temp;

}

void RayTracer::traceOnePixel(int x, int y, int threadID){
	const Ray& primary(m_camera->worldRay(x+0.5f, y+0.5f, Rect2D(Vector2(m_settings.width, m_settings.height))));
	const shared_ptr<Surfel> surfelHit(RayTracer::castRay(primary));
	if(!surfelHit) {
            m_image->set(Point2int32(x,y), Radiance3(0.0f, 0.0f, 0.0f));
        } else {
            m_image->set(Point2int32(x,y),RayTracer::L_scatteredDirect(surfelHit, -primary.direction(), *m_rnd[threadID]));
        }
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

Radiance3 RayTracer::L_scatteredDirect(const shared_ptr<Surfel>& surfel, 
                                       const Vector3& wo,
                                       Random& rnd) const {
    Radiance3 L(0.0f, 0.0f, 0.0f); // W/m^2*sr
    const Array<shared_ptr<Light> >& lightArray = m_lighting->lightArray; 
    
    //Add direct illumination from each light
    for(int i = 0; i<lightArray.size(); ++i) {
         const shared_ptr<UniversalSurfel>& u = dynamic_pointer_cast<UniversalSurfel>(surfel);
        debugAssertM(notNull(u), "Encountered a Surfel that was not a UniversalSurfel"); 
        Vector3 Y = lightArray[i]->position().xyz(); // m^3
        Vector3 X = surfel->position; // m^3
        float r = (Y - X).magnitude(); // m
        Vector3 wi = (Y - X).direction(); // unit vector
        Vector3 n = surfel->shadingNormal; // unit vector
        if(wi.dot(n) > 0 && wo.dot(n) > 0) {
            Biradiance3 Bi  = lightArray[i]->bulbPower()/(4*pi()*square(r)); //W/m^2
            L += abs(wi.dot(n)) * Bi * (u->lambertianReflectivity/ pi()); // W/m^2*sr
        }
    }
    return L;
}




