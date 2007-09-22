#ifndef __TOUCHSCREEN_FILTER_SIMPLE_HIGHPASS__
#define __TOUCHSCREEN_FILTER_SIMPLE_HIGHPASS__

#include <TouchlibFilter.h>

/**
 * This filter is used for filtering out sharp-edged objects from an image.
 *
 * @author Seb
 */
class TOUCHLIB_FILTER_EXPORT SimpleHighpassFilter : public Filter
{
public:


	// ----  constructor/destructor  ---------------------------------------------


	SimpleHighpassFilter(char *);
	virtual ~SimpleHighpassFilter();


	// ----  overridden/implemented member functions  ----------------------------


	void kernel();
	void getParameters(ParameterMap &pMap);
	void setParameter(const char *name, const char *value);
	void showOutput(bool value, int windowx, int windowy);


private:

	
	// ----  constants  ----------------------------------------------------------


	static const int DEFAULT_BLUR_LEVEL		= 10;
	static const int DEFAULT_NOISE_LEVEL		= 3;
	static const char *TRACKBAR_LABEL_BLUR;
	static const char *TRACKBAR_LABEL_NOISE;


	// ----  instance variables  -------------------------------------------------


	int blurLevel;
	int blurLevelSlider;
	int noiseLevel;
	int noiseLevelSlider;
};

#endif // __TOUCHSCREEN_FILTER_SIMPLE_HIGHPASS__