#pragma once
#include <godot_cpp/classes/area3d.hpp>
#include <godot_cpp/variant/string.hpp>

class Interactable: public godot::Area3D {
    GDCLASS(Interactable, godot::Area3D);

private:   
    godot::String prompt_text = "Interact";
    godot::String item_id = "";
    bool is_pickup = false;

protected:
    static void _bind_methods();

public:
    godot::String get_prompt_text() const;
    void set_prompt_text(godot::String text);

    godot::String get_item_id() const;
    void set_item_id(godot::String id);

    bool get_is_pickup() const;
    void set_is_pickup(bool pick);

    virtual void interact(godot::Node *player);
};