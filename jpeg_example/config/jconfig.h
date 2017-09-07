#ifdef IPHONE
#include "jconfig.iphoneos"
#elif defined(ANDROID)
#include "jconfig.mac"
#undef USE_MAC_MEMMGR
#undef USE_CCOMMAND
#elif defined(__APPLE__)
#include "jconfig.mac"
#undef USE_MAC_MEMMGR
#undef USE_CCOMMAND
#elif defined(_WIN32)
#include "jconfig.vc"
#else
#include "jconfig.linux"
#endif
