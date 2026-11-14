#include "eclss_terminal.hpp"
#include "player_controller.hpp"
#include "ship_telemetry.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/canvas_layer.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void EclssTerminal::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_telemetry_path", "path"), &EclssTerminal::set_telemetry_path);
    ClassDB::bind_method(D_METHOD("get_telemetry_path"), &EclssTerminal::get_telemetry_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "telemetry_path"), "set_telemetry_path", "get_telemetry_path");

    ClassDB::bind_method(D_METHOD("set_repair_ui_path", "path"), &EclssTerminal::set_repair_ui_path);
    ClassDB::bind_method(D_METHOD("get_repair_ui_path"), &EclssTerminal::get_repair_ui_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "repair_ui_path"), "set_repair_ui_path", "get_repair_ui_path");

    ClassDB::bind_method(D_METHOD("set_required_item_id", "id"), &EclssTerminal::set_required_item_id);
    ClassDB::bind_method(D_METHOD("get_required_item_id"), &EclssTerminal::get_required_item_id);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "required_item_id"), "set_required_item_id", "get_required_item_id");
}

void EclssTerminal::set_telemetry_path(const NodePath &path) { telemetry_path = path; }
NodePath EclssTerminal::get_telemetry_path() const { return telemetry_path; }

void EclssTerminal::set_repair_ui_path(const NodePath &path) { repair_ui_path = path; }
NodePath EclssTerminal::get_repair_ui_path() const { return repair_ui_path; }

void EclssTerminal::set_required_item_id(const String &id) { required_item_id = id; }
String EclssTerminal::get_required_item_id() const { return required_item_id; }

void EclssTerminal::interact(Node *player) {
    Interactable::interact(player);

    ShipTelemetry *telemetry = get_node<ShipTelemetry>(telemetry_path);
    if (telemetry == nullptr) {
        UtilityFunctions::printerr("EclssTerminal: не знайдено ShipTelemetry!");
        return;
    }
    if (telemetry->get_is_eclss_working()) {
        UtilityFunctions::print("ECLSS працює в штатному режимі.");
        return;
    }

    PlayerController *pc = Object::cast_to<PlayerController>(player);
    if (pc == nullptr) return;

    if (pc->get_held_item_id() != required_item_id) {
        UtilityFunctions::print("Потрібен картридж гідроксиду літію (LiOH)!");
        return;
    }

    Node *ui_node = get_node_or_null(repair_ui_path);
    if (ui_node != nullptr && ui_node->has_method("open_repair_minigame")) {
        pc->set_can_move(false);
        Input::get_singleton()->set_mouse_mode(Input::MOUSE_MODE_VISIBLE);
        ui_node->call("open_repair_minigame", pc, telemetry);
    } else {
        UtilityFunctions::printerr("EclssTerminal: не знайдено UI або метод open_repair_minigame!");
    }
}