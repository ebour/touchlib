
#ifndef __TOUCHLIB_PLATFORM__
#define __TOUCHLIB_PLATFORM__

#ifdef WIN32
#    ifdef _BUILDINGDLL
#         define TOUCHLIB_EXPORT __declspec( dllexport )
#         define TOUCHLIB_CORE_EXPORT
#         define TOUCHLIB_FILTER_EXPORT
#    else
#         define TOUCHLIB_EXPORT __declspec( dllimport )
#         define TOUCHLIB_CORE_EXPORT
#         define TOUCHLIB_FILTER_EXPORT
#    endif
#include <windows.h>
#include <process.h>
#include <tchar.h>
#define THREAD_HANDLE HANDLE
#define THREAD_MUTEX_HANDLE HANDLE
#else
#    define TOUCHLIB_EXPORT
#    define TOUCHLIB_CORE_EXPORT
#    define TOUCHLIB_FILTER_EXPORT
#    define strcmpi strcasecmp
#define THREAD_HANDLE pthread_t
#define THREAD_MUTEX_HANDLE pthread_mutex_t
#define _TCHAR char
#endif

#endif // __TOUCHLIB_PLATFORM__
