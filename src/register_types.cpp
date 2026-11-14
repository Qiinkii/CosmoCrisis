#include <godot_cpp/core/defs.hpp>
#include "ship_telemetry.hpp"
#include "register_types.hpp"
#include "interactable.hpp"
#include "player_controller.hpp"

void initialize_orbital_module(godot::ModuleInitializationLevel p_level){
    if(p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
        return;

    GDREGISTER_CLASS(ShipTelemetry);
    GDREGISTER_CLASS(Interactable);
    GDREGISTER_CLASS(PlayerController);
}

void uninitialize_orbital_module(godot::ModuleInitializationLevel p_level){
    if(p_level != godot::MODULE_INITIALIZATION_LEVEL_SCENE)
        return;
}

extern "C" GDExtensionBool GDE_EXPORT orbital_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization){
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialize_orbital_module);
    init_obj.register_terminator(uninitialize_orbital_module);
    init_obj.set_minimum_library_initialization_level(godot::MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}