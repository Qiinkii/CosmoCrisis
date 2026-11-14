#pragma once
#include "interactable.hpp"
#include <godot_cpp/variant/node_path.hpp>

class EclssTerminal : public Interactable {
    GDCLASS(EclssTerminal, Interactable);

private:
    godot::NodePath telemetry_path;
    godot::NodePath repair_ui_path;
    godot::String required_item_id = "lioh_cartridge";

protected:
    static void _bind_methods();

public:
    void set_telemetry_path(const godot::NodePath &path);
    godot::NodePath get_telemetry_path() const;

    void set_repair_ui_path(const godot::NodePath &path);
    godot::NodePath get_repair_ui_path() const;

    void set_required_item_id(const godot::String &id);
    godot::String get_required_item_id() const;

    void interact(godot::Node *player) override;
};