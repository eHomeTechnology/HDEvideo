#ifndef _DTV_CORE_H_
#define _DTV_CORE_H_

class MuxWriter;
class DtvCore {
public:
	static int toAudio(const char* data, int length, const char* path);
private:
	static void writeHead(MuxWriter *mWriter);
	static void writeData(MuxWriter *mWriter, const char* data, int length);
	static void writeTail(MuxWriter *mWriter);
	static void gen_wav1(int amp, double f0, short* wav);
	static void gen_wav3(int amp, double *f, short* wav);
};

#endif
