#pragma once
#include <godot_cpp/godot.hpp>
#include <gdextension_interface.h>

void initialize_orbital_module(godot::ModuleInitializationLevel p_level);
void uninitialize_orbital_module(godot::ModuleInitializationLevel p_level);