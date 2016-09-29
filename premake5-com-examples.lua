includeexternal ("premake5-include.lua")

workspace "com-examples"
    language "C++"
    location "build/%{_ACTION}"    

    configurations { "Debug", "Release", "TRACE", "TRACE_MT" }
    platforms { "Win32", "x64" }    

    filter { "kind:StaticLib", "platforms:Win32" }
        targetdir "lib/x86/%{_ACTION}" 
    filter { "kind:StaticLib", "platforms:x64" }
        targetdir "lib/x64/%{_ACTION}" 
    filter { "kind:SharedLib", "platforms:Win32" }
        implibdir "lib/x86/%{_ACTION}" 
    filter { "kind:SharedLib", "platforms:x64" }
        implibdir "lib/x64/%{_ACTION}" 
    filter { "kind:ConsoleApp or WindowedApp or SharedLib", "platforms:Win32" }
        targetdir "bin/x86/%{_ACTION}/%{wks.name}"         
    filter { "kind:ConsoleApp or WindowedApp or SharedLib", "platforms:x64" }
        targetdir "bin/x64/%{_ACTION}/%{wks.name}" 
        

    filter { "platforms:Win32" }
        system "Windows"
        architecture "x32"
        libdirs 
        {
            "lib/x86/%{_ACTION}",
            "lib/x86/%{_ACTION}/boost-1_56",
            "lib/x86/%{_ACTION}/boost-1_60",
            "bin/x86/%{_ACTION}"            
        }
    
    filter { "platforms:x64" }
        system "Windows"
        architecture "x64"   
        libdirs
        {
            "lib/x64/%{_ACTION}",
            "lib/x64/%{_ACTION}/boost-1_56",
            "lib/x64/%{_ACTION}/boost-1_60",
            "bin/x64/%{_ACTION}"
        }

    filter "configurations:Debug"
        defines { "DEBUG" }
        flags { "Symbols" }

    filter "configurations:Release"
        defines { "NDEBUG" }
        flags { "Symbols" }
        optimize "Speed"  
    
    filter "configurations:TRACE"
        defines { "NDEBUG", "TRACE_TOOL" }
        flags { "Symbols" }
        optimize "Speed"  
        buildoptions { "/Od" } 
        includedirs
        {            
            "3rdparty"    
        }  
        links { "tracetool.lib" }         

    filter "configurations:TRACE_MT"
        defines { "NDEBUG", "TRACE_TOOL" }
        flags { "Symbols" }
        optimize "On"  
        buildoptions { "/Od" }  
        includedirs
        {            
            "3rdparty"    
        }    
        links { "tracetool_mt.lib" }        

    configuration "vs*"
        warnings "Extra"                    -- 开启最高级别警告
        defines
        {
            "WIN32",
            "WIN32_LEAN_AND_MEAN",
            "_WIN32_WINNT=0x501",           -- 支持到 xp
            "_CRT_SECURE_NO_WARNINGS",        
            "_CRT_SECURE_NO_DEPRECATE",            
            "STRSAFE_NO_DEPRECATE",
            "_CRT_NON_CONFORMING_SWPRINTFS"
        }
        buildoptions
        {
            "/wd4267",                      -- 关闭 64 位检测
            "/wd4996"
        }    
        
    print("test")

    function create_console_project(name, dir, mbcs)        
        project(name)          
        kind "ConsoleApp"                          
        if mbcs == "mbcs" then
            characterset "MBCS"
        end
        flags { "NoManifest", "WinMain", "StaticRuntime" }       
        defines {  }
        files
        {                                  
            dir .. "/%{prj.name}/**.h",
            dir .. "/%{prj.name}/**.cpp", 
            dir .. "/%{prj.name}/**.c", 
            dir .. "/%{prj.name}/**.rc" 
        }
        removefiles
        {               
        }
        includedirs
        {                   
            "3rdparty"   
        }       
        links
        {
            "Wtsapi32.lib"
        }
    end

    function create_com_dll_project(name, dir, mbcs)
        project(name)                   
        kind "SharedLib"
        if mbcs == "mbcs" then
            characterset "MBCS"
        end
        flags { "StaticRuntime", "NoManifest" }
        files
        {
            dir .. "/%{prj.name}/**.h",
            dir .. "/%{prj.name}/**.cpp", 
            --dir .. "/%{prj.name}/**.c", 
            dir .. "/%{prj.name}/**.rc",
            dir .. "/%{prj.name}/**.rgs",
            dir .. "/%{prj.name}/**.idl",
            dir .. "/%{prj.name}/**.def"
        }
        removefiles
        {               
        }
        includedirs
        {   
            "3rdparty"
        }
        vpaths 
        {
            ["Headers"] = { "**.h", "**.hxx", "**.hpp" },
            ["Sources"] = { "**.cpp", "**.c", "**.rc", "**.idl", "**.def" },
            ["Resource"] = { "**.rgs" },
        }
        pchsource(dir .. "/%{prj.name}/StdAfx.cpp")
        pchheader "StdAfx.h" 
        filter "files:**.c"
            flags { "NoPCH" }
    end


    function create_com_test_project(name, dir, mbcs)
        project(name)                   
        kind "WindowedApp"
        if mbcs == "mbcs" then
            characterset "MBCS"
        end
        flags { "StaticRuntime", "NoManifest", "MFC", "WinMain" }
        files
        {
            dir .. "/%{prj.name}/**.h",
            dir .. "/%{prj.name}/**.cpp", 
            --dir .. "/%{prj.name}/**.c", 
            dir .. "/%{prj.name}/**.rc",
            dir .. "/%{prj.name}/**.rc2",
            dir .. "/%{prj.name}/**.rgs",
            dir .. "/%{prj.name}/**.idl",
            dir .. "/%{prj.name}/**.def"
        }
        removefiles
        {               
        }
        includedirs
        {   
            "3rdparty"
        }
        vpaths 
        {
            ["Headers"] = { "**.h", "**.hxx", "**.hpp" },
            ["Sources"] = { "**.cpp", "**.c", "**.rc", "**.idl", "**.def" },
            ["Resource"] = { "**.rc2" },
        }
        pchsource(dir .. "/%{prj.name}/StdAfx.cpp")
        pchheader "StdAfx.h" 
        filter "files:**.c"
            flags { "NoPCH" }
    end
    
  


    group "com-examples"
        create_com_dll_project("com_connection_server", "com_examples")
        create_com_test_project("com_connection_client", "com_examples")
        
 



        