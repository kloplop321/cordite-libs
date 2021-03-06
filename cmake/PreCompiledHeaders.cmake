# Precompiled Header Macros for Cordite Projects
# Instructs the MSVC toolset to use the precompiled header PRECOMPILED_HEADER
# for each source file given in the collection named by SOURCE_VARIABLE_NAME.
function(msvc_pch PRECOMPILED_HEADER SOURCE_VARIABLE_NAME)
  if(MSVC)
    set(files ${${SOURCE_VARIABLE_NAME}})
    
    # Generate precompiled header translation unit
    get_filename_component(pch_basename ${PRECOMPILED_HEADER} NAME_WE)
    set(pch_abs ${CMAKE_CURRENT_SOURCE_DIR}/${PRECOMPILED_HEADER})
    set(pch_unity ${CMAKE_CURRENT_BINARY_DIR}/${pch_basename}.cpp)
    FILE(WRITE ${pch_unity} "// Precompiled header unity generated by CMake\n")
    FILE(APPEND ${pch_unity} "#include <${pch_abs}>\n")
    set_source_files_properties(${pch_unity}  PROPERTIES COMPILE_FLAGS "/Yc\"${pch_abs}\"")
    
    # Update properties of source files to use the precompiled header.
    # Additionally, force the inclusion of the precompiled header at beginning of each source file.
    foreach(source_file ${files} )
      set_source_files_properties(
        ${source_file} 
        PROPERTIES COMPILE_FLAGS
        "/Yu\"${pch_abs}\" /FI\"${pch_abs}\""
      )
    endforeach(source_file)
    
    # Finally, update the source file collection to contain the precompiled header translation unit
    set(${SOURCE_VARIABLE_NAME} ${pch_unity} ${${SOURCE_VARIABLE_NAME}} PARENT_SCOPE)
  endif(MSVC)
endfunction(msvc_pch)


# GCC Precompiled Header Support
# The GCC PCH will end up in the binary directory, so make sure to include 
# the ${CMAKE_CURRENT_BINARY_DIR} in the includes
# "includes" name of the variable for all include paths 
#	(don't put in ${PROJECT_NAME_INCLUDES}, put in PROJECT_NAME_INCLUDES)
# "target_name" We need something to bind to so it compiles when there are changes
# "header_name" this is where you put "stdafx" not "stdafx.h"
macro(gcc_pch includes target_name header_name)
	#supposedly if you are compiling for multiple arch's it freaks out.
	if(CMAKE_COMPILER_IS_GNUCXX AND NOT APPLE)
	#begin GCC Precompiled header
	get_filename_component(base_header_name ${header_name}.h NAME_WE)
	if(NOT ${CMAKE_BUILD_TYPE} STREQUAL "None")
		string(TOUPPER "CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}" build_name_flags)
	    set(compile_flags ${${build_name_flags}})
	    
	    # Add all the project included directories
	    foreach(included ${${includes}})
	        list(APPEND compile_flags "-I${included}")
	    endforeach()
	else()
		set(compile_flags "")
	endif()
	get_directory_property(defines_global COMPILE_DEFINITIONS)
	list(APPEND defines ${defines_global})
	foreach(define ${defines})
		list(APPEND all_defines "-D${define}")
	endforeach()
	list(APPEND compile_flags ${all_defines})
	#prepare for gcc
	separate_arguments(compile_flags)

	#Finally time to build!
	# We don't use custom target because it will rebuild all the time
	set(gch_path "${CMAKE_CURRENT_BINARY_DIR}/${base_header_name}.h.gch")
	add_custom_target("${target_name}" ALL DEPENDS "${gch_path}")
	add_custom_command(
		OUTPUT "${gch_path}"
		COMMAND ${CMAKE_CXX_COMPILER} ${compile_flags} "${CMAKE_CURRENT_SOURCE_DIR}/${header_name}.h" -o "${gch_path}"
		MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${header_name}.h
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		VERBATIM
	)

	#end GCC Precompiled header
	endif()
endmacro()

# Xcode Precompiled header support
# "header_name" this is where you put "stdafx" not "stdafx.h"
# "target_name" This is the target which USES the header
macro(xcode_pch header_name target_name)
	if(APPLE)
		set_target_properties(
			${target_name} PROPERTIES
			XCODE_ATTRIBUTE_GCC_PREFIX_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/${header_name}.h"
			XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER "YES"
		)
	endif()
endmacro()
