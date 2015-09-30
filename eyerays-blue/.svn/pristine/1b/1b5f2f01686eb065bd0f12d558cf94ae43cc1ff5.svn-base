#ifndef RayTracer_h
#define RayTracer_h

#include <G3D/G3DAll.h>

class RayTracer : public ReferenceCountedObject {
	public:
		class Settings {
			public:
				int width;
				int height;
				bool multithreaded;
				bool useTree;
				Settings();
		};

		class Stats {
			public:
				int lights;
				int triangles;
				/** width x height */
				int pixels;
				float buildTriTreeTimeMilliseconds;
				float rayTraceTimeMilliseconds;
				Stats();
		};

	protected:
		/** Array of random number generators so that each threadID may
		have its own without using locks. */
		Array< shared_ptr<Random> > m_rnd;

		// The following are only valid during a call to render()
		shared_ptr<Image> m_image;
		shared_ptr<LightingEnvironment> m_lighting;
		shared_ptr<Camera> m_camera;
		Settings m_settings;
		TriTree m_triTree;

		RayTracer();

		/** Called from GThread::runConcurrently2D(), which is invoked
		in traceAllPixels() */
		void traceOnePixel(int x, int y, int threadID);

		/** Called from render(). Writes to m_image. */
		void traceAllPixels(int numThreads);

		/**
		\param ray in world space
		\param maxDistance Don’t trace farther than this
		\param anyHit If true, return any surface hit, even if it is
		not the first
		\return The surfel hit, or NULL if none was hit
		*/
		shared_ptr<Surfel> castRay
			(const Ray& ray, float maxDistance = finf(), bool anyHit = false) const;

		Radiance3 L_scatteredDirect
			(const shared_ptr<Surfel>& surfel, const Vector3& wo, Random& rnd) const;

	public:
		static shared_ptr<RayTracer> create();

		/** Render the specified image */
		shared_ptr<Image> render
			(const Settings& settings,
			const Array< shared_ptr<Surface> >& surfaceArray,
			const shared_ptr<LightingEnvironment>& lighting,
			const shared_ptr<Camera>& camera,
			Stats& stats);
};

#endif

