//--------------------------------------------------------------------------------------
// File: pchfx.h
//
// Direct3D 11 shader effects precompiled header
//
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
//
// http://go.microsoft.com/fwlink/p/?LinkId=271568
//--------------------------------------------------------------------------------------

#pragma once

#pragma warning(disable : 4619 4616 4102 4127 4201 4505 4706 5205 6326)
// C4619/4616 #pragma warning warnings
// C4102 The label is defined but never referenced. The compiler ignores the label.
// C4127 conditional expression is constant
// C4201 nonstandard extension used : nameless struct/union
// C4505 unreferenced function with internal linkage has been removed
// C4706 assignment within conditional expression
// C5205 delete of an abstract class 'X' that has a non-virtual destructor results in undefined behavior
// C6326 Potential comparison of a constant with another constant

#ifndef NOMINMAX
#define NOMINMAX 1
#endif

#include <algorithm>

#if defined(_XBOX_ONE) && defined(_TITLE)
#include <d3d11_x.h>
#include <D3DCompiler_x.h>
#define DCOMMON_H_INCLUDED
#define NO_D3D11_DEBUG_NAME
#else
#include <d3d11_1.h>
#include <D3DCompiler.h>
#endif

#ifndef _WIN32_WINNT_WIN8
#define _WIN32_WINNT_WIN8 0x0602
#endif

#undef DEFINE_GUID
#include "INITGUID.h"

#include "d3dx11effect.h"

#define UNUSED -1

//////////////////////////////////////////////////////////////////////////

#define offsetof_fx( a, b ) (uint32_t)offsetof( a, b )

#ifdef _DEBUG
extern void __cdecl D3DXDebugPrintf(UINT lvl, _In_z_ _Printf_format_string_ LPCSTR szFormat, ...);
#define DPF D3DXDebugPrintf
#else
#define DPF
#endif

#include "d3dxGlobal.h"

#include <cstddef>
#include <cstdlib>

#include "Effect.h"
#include "EffectStateBase11.h"
#include "EffectLoad.h"

