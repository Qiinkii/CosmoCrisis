#!/usr/bin/env python
import os
import sys

ARGUMENTS["api_version"] = ARGUMENTS.get("api_version", "4.7")

env = SConscript("godot-cpp/SConstruct")
env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

library = env.SharedLibrary(
    "game/bin/liborbital_crisis{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
    source=sources,
)

Default(library)