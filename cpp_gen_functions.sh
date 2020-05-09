#!/bin/bash

class_header_declaration()
{
    class_name="${1}"
    echo "class ${class_name}"
    echo "{"
    echo "public:"
    echo "    /// Creates class value"
    echo "    ${class_name}();"
    echo ""
    echo "    /// Removes class value"
    echo "    virtual ~${class_name}();"
    echo "private:"
    echo "    struct Impl;"
    echo "    Impl* m_p_impl;"
    echo "};"
}

class_source_declaration()
{
    class_name="${1}"
    echo "struct ${class_name}::Impl"
    echo "{"
    echo "public:"
    echo "    Impl(){}"
    echo "    virtual ~Impl(){}"
    echo "};"
    echo ""
    echo "${class_name}::${class_name}()"
    echo "    :m_p_impl(new Impl)"
    echo "{"
    echo "}"
    echo ""
    echo "${class_name}::~${class_name}()"
    echo "{"
    echo "    delete m_p_impl;"
    echo "    m_p_impl = 0;"
    echo "}"
}

class_header_file()
{
    class_name="${1}"
    directory="${2}"
    file_name="${directory}/${class_name}.h"
    namespace="${3}"
    include_guard="${namespace^^}_${class_name^^}_H"

    echo "/// @file ${file_name}"
    echo ""
    echo "#ifndef ${include_guard}"
    echo "#define ${include_guard}"
    echo ""
    echo "namespace ${namespace}"
    echo "{"
    echo ""
    class_header_declaration "${class_name}"
    echo ""
    echo "}"
    echo ""
    echo "#endif /* ${include_guard} */"
}

class_source_file()
{
    class_name="${1}"
    directory="${2}"
    file_name="${directory}/${class_name}.cpp"
    namespace="${3}"

    echo "/// @file ${file_name}"
    echo ""
    echo "#include <${directory}/${class_name}.h>"
    echo ""
    echo "namespace ${namespace}"
    echo "{"
    echo ""
    class_source_declaration "${class_name}"
    echo ""
    echo "}"
}

class_test_source_file()
{
    class_name="${1}"
    directory="${2}"
    file_name="${directory}/test/${class_name}_test.cpp"
    namespace="${3}"

    echo "/// @file ${file_name}"
    echo ""
    echo "#include <${directory}/${class_name}.h>"
    echo "#include <catch2/catch.hpp>"
    echo "#include <${directory}/${class_name}.h> // Testing include guard"
    echo ""
    echo "using namespace ${namespace};"
    echo ""
    echo "TEST_CASE( \"${class_name}_test\", \"stack\" )"
    echo "{"
    echo "    ${class_name} c;"
    echo "}"
}

default_catch_test_source_file()
{
    direction=${1}
    file_name="${directory}/test/catch_definition_test.cpp"

    echo "/// @file ${file_name}"
    echo "#include <catch2/catch.hpp>"
    echo ""
    echo "#define CATCH_CONFIG_MAIN  // This tells Catch to provide a main() - only do this in one cpp file"
    echo ""
    echo "TEST_CASE( \"catch_definition_test\", \"boilerplate\" )"
    echo "{"
    echo "    REQUIRE(1 == 1);"
    echo "}"
}

class_def()
{
    class_name="${1}"  
    directory="${2}"
    namespace="${3}"

    class_header="${directory}/${class_name}.h"
    class_source="${directory}/${class_name}.cpp"
    class_test_source="${directory}/test/${class_name}_test.cpp"

    class_header_file "${class_name}" "${directory}" "${namespace}" > "${class_header}"
    class_source_file "${class_name}" "${directory}" "${namespace}" > "${class_source}"
    class_test_source_file "${class_name}" "${directory}" "${namespace}" > "${class_test_source}"
}

cmakelists_basic_def()
{
    project_name=${1}
    repo_name=${2}

    echo "cmake_minimum_required(VERSION 2.6.0)"
    echo ""
    echo "set(PROJ_NAME ${project_name})"
    echo "set(REPO_NAME ${repo_name})"
    echo ""
    echo "project(\"\${PROJ_NAME}-\${REPO_NAME}\")"
    echo ""
    echo "set(PROJ_DIR \${CMAKE_CURRENT_SOURCE_DIR})"
    echo "set(SRC_ROOT_DIR \${PROJ_DIR}/src/\${PROJ_NAME}/\${REPO_NAME})"
    echo ""
    echo "include_directories(\"\${PROJ_DIR}/catch2/single_include\")"
    echo "include_directories(\"\${PROJ_DIR}/src/\")"
    echo ""
    echo "set(VERSION_MAJOR 0)"
    echo "set(VERSION_MINOR 1)"
    echo "set(VERSION_PATCH 0)"
    echo ""
    echo "set(CMAKE_CXX_FLAGS \"-g -std=c++11\")"
    echo ""
    echo "set(SOURCE_DIRECTORIES \${SRC_ROOT_DIR})"
    echo ""
    echo 'set(all_source_files "")'
    echo "foreach(source_dir \${SOURCE_DIRECTORIES})"
    echo "  message(\"Finding everything in \${source_dir}\")"
    echo "  file(GLOB dir_src_files \${source_dir}/*.cpp)"
    echo "  set(all_source_files \${all_source_files}"
    echo "                       \${dir_src_files})"
    echo "endforeach()"
    echo ""
    echo "file(GLOB test_executable_files \${SRC_ROOT_DIR}/test/*_test.cpp)"
    echo ""
    echo "set(LIB_NAME_SHARED \${PROJ_NAME}_\${REPO_NAME})"
    echo "set(LIB_NAME_STATIC \${PROJ_NAME}_\${REPO_NAME}_s)"
    echo 'set(LIB_TEST_NAME "test_${PROJ_NAME}_${REPO_NAME}")'
    echo ""
    echo "message(\"Building static library \${LIB_NAME_STATIC} with \${all_source_files}\")"
    echo "add_library(\${LIB_NAME_STATIC} STATIC \${all_source_files})"
    echo "message(\"Building shared library \${LIB_NAME_SHARED} with \${all_source_files}\")"
    echo "add_library(\${LIB_NAME_SHARED} SHARED \${all_source_files})"
    echo ""
    echo "add_executable(\${LIB_TEST_NAME} \${test_executable_files})"
    echo "target_link_libraries(\${LIB_TEST_NAME} \${LIB_NAME_STATIC})"
}

make_def()
{
    project_name=${1}
    repo_name=${2}

    echo "all:"
    echo "	@echo \"test, lib, clean\""
    echo ""
    echo "test: lib "
    echo "	build/test_${project_name}_${repo_name}"
    echo "	"
    echo "lib:"
    echo "	@mkdir -p build"
    echo "	@cd build; cmake .."
    echo "	@cd build; make"
    echo ""
    echo "clean:"
    echo "	@rm -rf build"
}

basic_test()
{
    rm -rf .gitmodule catch2
    git submodule add -f git@github.com:catchorg/catch2.git
    git submodule update -f

    rm -rf build src Makefile CMakeLists.txt

    mkdir -p src/phobos2390/example_namespace/test
    pushd src
    class_def Example_class phobos2390/example_namespace Example_namespace
    default_catch_test_source_file phobos2390/example_namespace > phobos2390/example_namespace/test/catch_definition_test.cpp
    popd
    cmakelists_basic_def phobos2390 example_namespace > CMakeLists.txt
    make_def phobos2390 example_namespace > Makefile

    make clean test
}

basic_test