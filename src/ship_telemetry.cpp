#include "ship_telemetry.hpp"
#include <random>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void ShipTelemetry::_bind_methods(){
    ClassDB::bind_method(D_METHOD("get_co2_level"), &ShipTelemetry::get_co2_level);
    ClassDB::bind_method(D_METHOD("set_co2_level", "p_level"), &ShipTelemetry::set_co2_level);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "co2_level"), "set_co2_level", "get_co2_level");

    ClassDB::bind_method(D_METHOD("get_flight_progress"), &ShipTelemetry::get_flight_progress);
    ClassDB::bind_method(D_METHOD("set_flight_progress", "p-val"), &ShipTelemetry::set_flight_progress);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "flight_progress"), "set_flight_progress", "get_flight_progress");

    ClassDB::bind_method(D_METHOD("get_flight_speed"), &ShipTelemetry::get_flight_speed);
    ClassDB::bind_method(D_METHOD("set_flight_speed", "p_val"), &ShipTelemetry::set_flight_speed);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "flight_speed"), "set_flight_speed", "get_flight_speed");

    ClassDB::bind_method(D_METHOD("get_cockpit_pressure"), &ShipTelemetry::get_cockpit_pressure);
    ClassDB::bind_method(D_METHOD("set_cockpit_pressure", "p_val"), &ShipTelemetry::set_cockpit_pressure);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "cockpit_pressure"), "set_cockpit_pressure", "get_cockpit_pressure");

    ClassDB::bind_method(D_METHOD("get_engineering_pressure"), &ShipTelemetry::get_engineering_pressure);
    ClassDB::bind_method(D_METHOD("set_engineering_pressure", "p_val"), &ShipTelemetry::set_engineering_pressure);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "engineering_pressure"), "set_engineering_pressure", "get_engineering_pressure");

    ClassDB::bind_method(D_METHOD("get_is_eclss_working"), &ShipTelemetry::get_is_eclss_working);
    ClassDB::bind_method(D_METHOD("set_is_eclss_working", "working"), &ShipTelemetry::set_is_eclss_working);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_eclss_working"), "set_is_eclss_working", "get_is_eclss_working");

    ClassDB::bind_method(D_METHOD("get_is_hull_breached"), &ShipTelemetry::get_is_hull_breached);
    ClassDB::bind_method(D_METHOD("set_is_hull_breached", "breached"), &ShipTelemetry::set_is_hull_breached);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_hull_breached"), "set_is_hull_breached", "get_is_hull_breached");

    ClassDB::bind_method(D_METHOD("get_is_bulkhead_closed"), &ShipTelemetry::get_is_bulkhead_closed);
    ClassDB::bind_method(D_METHOD("set_is_bulkhead_closed", "close"), &ShipTelemetry::set_is_bulkhead_closed);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_bulkhead_closed"), "set_is_bulkhead_closed", "get_is_bulkhead_closed");

    ClassDB::bind_method(D_METHOD("get_is_player_in_engineering"), &ShipTelemetry::get_is_player_in_engineering);
    ClassDB::bind_method(D_METHOD("set_is_player_in_engineering", "val"), &ShipTelemetry::set_is_player_in_engineering);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_player_in_engineering"), "set_is_player_in_engineering", "get_is_player_in_engineering");

    ClassDB::bind_method(D_METHOD("get_is_mission_active"), &ShipTelemetry::get_is_mission_active);
    ClassDB::bind_method(D_METHOD("set_is_mission_active", "active"), &ShipTelemetry::set_is_mission_active);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_mission_active"), "set_is_mission_active", "get_is_mission_active");

    ClassDB::bind_method(D_METHOD("trigger_co2_failure"), &ShipTelemetry::trigger_co2_failure);
    ClassDB::bind_method(D_METHOD("repair_co2_system"), &ShipTelemetry::repair_co2_system);
    ClassDB::bind_method(D_METHOD("trigger_hull_breach"), &ShipTelemetry::trigger_hull_breach);
    ClassDB::bind_method(D_METHOD("repair_hull_breach"), &ShipTelemetry::repair_hull_breach);

    ADD_SIGNAL(MethodInfo("telemetry_updated"));
    ADD_SIGNAL(MethodInfo("mission_failed", PropertyInfo(Variant::STRING, "reason")));
    ADD_SIGNAL(MethodInfo("mission_completed"));
    ADD_SIGNAL(MethodInfo("hull_breach_spawned", PropertyInfo(Variant::INT, "location_id")));
}

void ShipTelemetry::_process(double delta){
    if(Engine::get_singleton()->is_editor_hint()){
        return;
    }

    if(!is_mission_active){
        return;
    }

    flight_progress += flight_speed * delta;
    if(flight_progress >= 100){
        flight_progress = 100;
        is_mission_active = false;
        emit_signal("mission_completed");
        return;
    }
    if(!co2_crisis_triggered && flight_progress >= 15.0){
        co2_crisis_triggered = true;
        is_eclss_working = false;
        UtilityFunctions::print(String::utf8("УВАГА! Впав тиск водню в реакторі Сабатьє!"));
    }
    if(!breach_crisis_triggered && flight_progress >= 50){
        breach_crisis_triggered = true;
        trigger_hull_breach();
    }
    if(is_eclss_working){
        co2_level = Math::move_toward(co2_level, 0.04, 0.08 * delta);
    }
    else{
        co2_level += 0.05 * delta;
    }

    if(is_hull_breached){
        engineering_pressure = MAX(0.0, engineering_pressure - 2.2 * delta);
    }
    else{
        engineering_pressure = Math::move_toward(engineering_pressure, 101.3, 5.0 * delta);
    }

    if(!is_bulkhead_closed){
        double diff = cockpit_pressure - engineering_pressure;
        double flow = diff * 0.8 * delta;
        cockpit_pressure -= flow;
        engineering_pressure += flow;
    }

    if(co2_level >= 2.0){
        is_mission_active = false;
        emit_signal("mission_failed", "Гостра гіперкапнія: парціальний тиск CO2 перевищив 15 мм рт. ст.");
        return;
    }

    if(cockpit_pressure <= 50.0){
        is_mission_active = false;
        emit_signal("mission_failed", "Декомпресія: атмосферний тиск впав нижче межі Армстронга/гіпоксії (50 кПа).");
        return;
    }

    emit_signal("telemetry_updated");

    print_timer += delta;
    if(print_timer >= 1.0){
        print_timer = 0.0;
        UtilityFunctions::print("Progress: ", flight_progress, " | CO2: ", co2_level, " | Speed: ", flight_speed);
        UtilityFunctions::print("CockPit: ", cockpit_pressure, " | Engineering: ", engineering_pressure);
    }
}

double ShipTelemetry::get_co2_level() const{
    return co2_level;
}

void ShipTelemetry::set_co2_level(double p_level){
    co2_level = p_level;
}

double ShipTelemetry::get_flight_progress() const{
    return flight_progress;
}

void ShipTelemetry::set_flight_progress(double p_val){
    flight_progress = p_val;
}

double ShipTelemetry::get_flight_speed() const{
    return flight_speed;
}

void ShipTelemetry::set_flight_speed(double p_val) {
    flight_speed = p_val;
}

double ShipTelemetry::get_cockpit_pressure() const{
    return cockpit_pressure;
}

void ShipTelemetry::set_cockpit_pressure(double p_val){
    cockpit_pressure = p_val;
}

double ShipTelemetry::get_engineering_pressure() const{
    return engineering_pressure;
}

void ShipTelemetry::set_engineering_pressure(double p_val){
    engineering_pressure = p_val;
}

bool ShipTelemetry::get_is_eclss_working() const{
    return is_eclss_working;
}

void ShipTelemetry::set_is_eclss_working(bool working){
    is_eclss_working = working;
}

bool ShipTelemetry::get_is_hull_breached() const{
    return is_hull_breached;
}

void ShipTelemetry::set_is_hull_breached(bool breached){
    is_hull_breached = breached;
}

bool ShipTelemetry::get_is_bulkhead_closed() const{
    return is_bulkhead_closed;
}

void ShipTelemetry::set_is_bulkhead_closed(bool close){
    is_bulkhead_closed = close;
}

bool ShipTelemetry::get_is_mission_active() const{
    return is_mission_active;
}

void ShipTelemetry::set_is_mission_active(bool active){
    is_mission_active = active;
}

void ShipTelemetry::trigger_co2_failure(){
    is_eclss_working = false;
}

void ShipTelemetry::repair_co2_system(){
    is_eclss_working = true;
}

void ShipTelemetry::trigger_hull_breach(){
    static std::random_device rd;
    static std::mt19937_64 gen(rd());
    std::uniform_int_distribution<int> range(1,4);

    active_breach_id = range(gen);
    is_hull_breached = true;
    emit_signal("hull_breach_spawned", active_breach_id);
}

void ShipTelemetry::repair_hull_breach(){
    is_hull_breached = false;
}

bool ShipTelemetry::get_is_player_in_engineering() const{
    return is_player_in_engineering;
}

void ShipTelemetry::set_is_player_in_engineering(bool val){
    is_player_in_engineering = val;
}