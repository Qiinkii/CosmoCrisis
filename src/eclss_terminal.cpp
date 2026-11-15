#include "eclss_terminal.hpp"
#include "player_controller.hpp"
#include "ship_telemetry.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/canvas_layer.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/rigid_body3d.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void EclssTerminal::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_telemetry_path", "path"), &EclssTerminal::set_telemetry_path);
    ClassDB::bind_method(D_METHOD("get_telemetry_path"), &EclssTerminal::get_telemetry_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "telemetry_path"), "set_telemetry_path", "get_telemetry_path");

    ClassDB::bind_method(D_METHOD("set_repair_ui_path", "path"), &EclssTerminal::set_repair_ui_path);
    ClassDB::bind_method(D_METHOD("get_repair_ui_path"), &EclssTerminal::get_repair_ui_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "repair_ui_path"), "set_repair_ui_path", "get_repair_ui_path");

    ClassDB::bind_method(D_METHOD("set_cartridge_slot_path", "path"), &EclssTerminal::set_cartridge_slot_path);
    ClassDB::bind_method(D_METHOD("get_cartridge_slot_path"), &EclssTerminal::get_cartridge_slot_path);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "cartridge_slot_path"), "set_cartridge_slot_path", "get_cartridge_slot_path");

    ClassDB::bind_method(D_METHOD("set_required_item_id", "id"), &EclssTerminal::set_required_item_id);
    ClassDB::bind_method(D_METHOD("get_required_item_id"), &EclssTerminal::get_required_item_id);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "required_item_id"), "set_required_item_id", "get_required_item_id");

    ClassDB::bind_method(D_METHOD("install_cartridge", "player"), &EclssTerminal::install_cartridge);
}

void EclssTerminal::set_telemetry_path(const NodePath &path) { telemetry_path = path; }
NodePath EclssTerminal::get_telemetry_path() const { return telemetry_path; }

void EclssTerminal::set_repair_ui_path(const NodePath &path) { repair_ui_path = path; }
NodePath EclssTerminal::get_repair_ui_path() const { return repair_ui_path; }

void EclssTerminal::set_cartridge_slot_path(const NodePath &path) { cartridge_slot_path = path; }
NodePath EclssTerminal::get_cartridge_slot_path() const { return cartridge_slot_path; }

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
        ui_node->call("open_repair_minigame", pc, telemetry, this);
    } else {
        UtilityFunctions::printerr("EclssTerminal: не знайдено UI або метод open_repair_minigame!");
    }
}

void EclssTerminal::install_cartridge(Node *player) {
    PlayerController *pc = Object::cast_to<PlayerController>(player);
    if (pc == nullptr) return;

    Node3D *slot = Object::cast_to<Node3D>(get_node_or_null(cartridge_slot_path));
    if (slot == nullptr) {
        UtilityFunctions::printerr("EclssTerminal: не знайдено CartridgeSlot!");
        return;
    }

    // Направление от панели (если куб толкает внутрь щитка — поставь минус перед slot->...)
    Vector3 outward = slot->get_global_transform().basis.get_column(2).normalized();

    // 1. Аккуратно выталкиваем старый картридж, чтобы он просто упал вниз на пол
    if (slot->get_child_count() > 0) {
        Node3D *old_cart = Object::cast_to<Node3D>(slot->get_child(0));
        if (old_cart != nullptr) {
            old_cart->reparent(get_tree()->get_current_scene(), true);
            // Выносим чуть дальше от стенки щитка (0.25 м), чтобы коллайдеры не пересекались
            old_cart->set_global_position(slot->get_global_position() + outward * 0.25);

            RigidBody3D *old_rb = Object::cast_to<RigidBody3D>(old_cart);
            if (old_rb != nullptr) {
                old_rb->set_collision_layer(1);
                old_rb->set_collision_mask(1);
                old_rb->set_linear_velocity(Vector3(0, 0, 0));
                old_rb->set_angular_velocity(Vector3(0, 0, 0));
                old_rb->set_angular_damp(5.0); // Гасим лишнее кручение в воздухе и на полу
                old_rb->set_freeze_enabled(false);
                // Слабый толчок вперёд от гнезда, дальше работает только гравитация
                old_rb->apply_central_impulse(outward * 0.5);
            }

            Interactable *old_inter = Object::cast_to<Interactable>(old_cart->get_node_or_null("Interactable"));
            if (old_inter != nullptr) {
                old_inter->set_is_pickup(true);
                old_inter->set_prompt_text(String::utf8("Использованный картридж"));
                old_inter->set_collision_layer(2);
                old_inter->set_monitoring(true);
                old_inter->set_monitorable(true);
            }
        }
    }
    // 2. Забираємо новий картридж з руки гравця та фіксуємо у гнізді термінала
    Node3D *new_cart = pc->take_held_item();
    if (new_cart != nullptr) {
        new_cart->reparent(slot, false);
        new_cart->set_position(Vector3(0, 0, 0));
        new_cart->set_rotation(Vector3(0, 0, 0));
   }
}