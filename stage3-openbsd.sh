
if [ `uname -s` != "OpenBSD" ]; then
  echo "You have to run this on Openbsd!"
  exit 1
fi

if [ ! -e "stage1-openbsd/libs" ]; then
  echo "stage1-openbsd does not exist!"
  exit 1
fi

if [ ! -e "stage2-linux/rust-libs" ]; then
  echo "stage2-linux does not exist!"
  exit 1
fi


CC="/usr/local/bin/egcc"
LIBGCC="gcc"
RL=stage2-linux/rust-libs

#SUP_LIBS="-Wl,-whole-archive -lmorestack -Wl,-no-whole-archive -lrust_builtin -lrustllvm -lcompiler-rt -lbacktrace -lcontext_switch -lhoedown -lminiz -lrustrt_native -luv -luv_support"
SUP_LIBS="-Wl,-whole-archive -lmorestack -Wl,-no-whole-archive -lrust_builtin -lrustllvm -lcompiler-rt -lbacktrace -lcontext_switch -lhoedown -lminiz -lrustrt_native"

LLVM_LIBS="-lLLVMLTO -lLLVMObjCARCOpts -lLLVMLinker -lLLVMipo -lLLVMVectorize -lLLVMBitWriter -lLLVMIRReader -lLLVMAsmParser -lLLVMR600CodeGen -lLLVMR600Desc -lLLVMR600Info -lLLVMR600AsmPrinter -lLLVMSystemZDisassembler -lLLVMSystemZCodeGen -lLLVMSystemZAsmParser -lLLVMSystemZDesc -lLLVMSystemZInfo -lLLVMSystemZAsmPrinter -lLLVMHexagonCodeGen -lLLVMHexagonAsmPrinter -lLLVMHexagonDesc -lLLVMHexagonInfo -lLLVMNVPTXCodeGen -lLLVMNVPTXDesc -lLLVMNVPTXInfo -lLLVMNVPTXAsmPrinter -lLLVMCppBackendCodeGen -lLLVMCppBackendInfo -lLLVMMSP430CodeGen -lLLVMMSP430Desc -lLLVMMSP430Info -lLLVMMSP430AsmPrinter -lLLVMXCoreDisassembler -lLLVMXCoreCodeGen -lLLVMXCoreDesc -lLLVMXCoreInfo -lLLVMXCoreAsmPrinter -lLLVMMipsDisassembler -lLLVMMipsCodeGen -lLLVMMipsAsmParser -lLLVMMipsDesc -lLLVMMipsInfo -lLLVMMipsAsmPrinter -lLLVMAArch64Disassembler -lLLVMAArch64CodeGen -lLLVMAArch64AsmParser -lLLVMAArch64Desc -lLLVMAArch64Info -lLLVMAArch64AsmPrinter -lLLVMAArch64Utils -lLLVMARMDisassembler -lLLVMARMCodeGen -lLLVMARMAsmParser -lLLVMARMDesc -lLLVMARMInfo -lLLVMARMAsmPrinter -lLLVMPowerPCDisassembler -lLLVMPowerPCCodeGen -lLLVMPowerPCAsmParser -lLLVMPowerPCDesc -lLLVMPowerPCInfo -lLLVMPowerPCAsmPrinter -lLLVMSparcDisassembler -lLLVMSparcCodeGen -lLLVMSparcAsmParser -lLLVMSparcDesc -lLLVMSparcInfo -lLLVMSparcAsmPrinter -lLLVMTableGen -lLLVMDebugInfo -lLLVMOption -lLLVMX86Disassembler -lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMSelectionDAG -lLLVMAsmPrinter -lLLVMX86Desc -lLLVMMCDisassembler -lLLVMX86Info -lLLVMX86AsmPrinter -lLLVMX86Utils -lLLVMJIT -lLLVMLineEditor -lLLVMMCAnalysis -lLLVMInstrumentation -lLLVMInterpreter -lLLVMCodeGen -lLLVMScalarOpts -lLLVMInstCombine -lLLVMTransformUtils -lLLVMipa -lLLVMAnalysis -lLLVMProfileData -lLLVMMCJIT -lLLVMTarget -lLLVMRuntimeDyld -lLLVMObject -lLLVMMCParser -lLLVMBitReader -lLLVMExecutionEngine -lLLVMMC -lLLVMCore -lLLVMSupport"

RUST_DEPS="$RL/librustc.rlib $RL/libtime.rlib $RL/librustc_llvm.rlib $RL/libarena.rlib $RL/libgetopts.rlib $RL/librustc_back.rlib $RL/libsyntax.rlib $RL/libserialize.rlib $RL/librbml.rlib $RL/libdebug.rlib $RL/libflate.rlib $RL/libterm.rlib $RL/liblog.rlib $RL/libnative.rlib $RL/libgraphviz.rlib $RL/libfmt_macros.rlib $RL/libstd.rlib $RL/libsync.rlib $RL/librustrt.rlib $RL/libcollections.rlib $RL/libunicode.rlib $RL/liballoc.rlib $RL/liblibc.rlib $RL/librand.rlib $RL/libcore.rlib"

mkdir -p stage3-openbsd/bin
mkdir -p stage3-openbsd/lib

${CC} -o stage3-openbsd/bin/rustc stage2-linux/driver.o ${RUST_DEPS} -L./stage1-openbsd/libs/llvm -L./stage1-openbsd/libs $SUP_LIBS $LLVM_LIBS -lrt -lpthread -l${LIBGCC} -lc -lm -lz -ledit -ltinfo -lstdc++ 

cp stage1-openbsd/libs/libcompiler-rt.a stage3-openbsd/lib
cp stage1-openbsd/libs/libmorestack.a stage3-openbsd/lib
cp stage2-linux/rust-libs/*.rlib stage3-openbsd/lib

./stage3-openbsd/bin/rustc -Lstage3-openbsd/lib hw.rs && ./hw
