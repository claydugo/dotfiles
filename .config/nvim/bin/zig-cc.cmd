@echo off
rem zig as a C compiler for tree-sitter parser builds on Windows (no MSVC needed).
rem The tree-sitter CLI is an MSVC-target build, so the cc crate passes the LLVM
rem quad triple x86_64-pc-windows-msvc; zig's target parser only understands the
rem arch-os-abi triple, so rewrite it to the gnu ABI (which zig fully supports and
rem which produces a standard loadable parser DLL).
setlocal enabledelayedexpansion
set "args=%*"
set "args=!args:x86_64-pc-windows-msvc=x86_64-windows-gnu!"
set "args=!args:aarch64-pc-windows-msvc=aarch64-windows-gnu!"
zig cc !args!
