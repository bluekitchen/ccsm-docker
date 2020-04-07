#!/bin/bash
 
FULL_PATH=$(realpath $0)
PROJ_DIR=$(dirname $FULL_PATH)
echo "Project dir: $PROJ_DIR"

# add CCSM to clang
LLVM_CLANG_CMAKELISTS=${PROJ_DIR}/llvm-project/clang/CMakeLists.txt
grep -q -F CCSM_DIR ${LLVM_CLANG_CMAKELISTS} || cat <<EOT >> ${LLVM_CLANG_CMAKELISTS}

# ccsm additions
set(CCSM_DIR ${PROJ_DIR}/ccsm)
add_subdirectory(\${CCSM_DIR}/src \${CMAKE_CURRENT_BINARY_DIR}/ccsm)
EOT

# add fix to compile with libxml2 from Mac Homebrew
LLVM_LIB_CMAKELISTS=${PROJ_DIR}/llvm-project/llvm/lib/CMakeLists.txt
cat <<EOT > ${PROJ_DIR}/opt-local-include.txt
# fix include for libxml2 from Mac Homebrew
set(CMAKE_C_FLAGS   "-I/opt/local/include ${CMAKE_C_FLAGS}"  )
set(CMAKE_CXX_FLAGS "-I/opt/local/include ${CMAKE_CXX_FLAGS}")
EOT
grep -q -F Homebrew ${LLVM_LIB_CMAKELISTS} || (cat ${PROJ_DIR}/opt-local-include.txt ${LLVM_LIB_CMAKELISTS} > ${PROJ_DIR}/tmp.txt && mv ${PROJ_DIR}/tmp.txt ${LLVM_LIB_CMAKELISTS})
rm ${PROJ_DIR}/opt-local-include.txt

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS=clang ../llvm-project/llvm
make ccsm

cd ${PROJ_DIR}

# result: build/bin/ccsm
echo "ccsm is available as $PROJ_DIR/build/ccsm"
