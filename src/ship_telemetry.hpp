#pragma once

#include <godot_cpp/classes/node.hpp>

class ShipTelemetry : public godot::Node {
    GDCLASS(ShipTelemetry, godot::Node)

private:
    double print_timer = 0.0;

    double co2_level = 0.04;
    double flight_progress = 0.0;
    double flight_speed = 0.5;
    double cockpit_pressure = 101.3;
    double engineering_pressure = 101.3;
    
    bool is_eclss_working = true;
    bool is_hull_breached = false;
    bool is_bulkhead_closed = false;
    bool is_mission_active = true;
protected:
    static void _bind_methods();

public:
    ShipTelemetry() = default;
    ~ShipTelemetry() override = default;

    // Вбудований метод Godot, який викликається щокадру (аналог Update)
    void _process(double delta) override;

    // Гетери стетери для інкапсульованих змінних
    double get_co2_level() const;
    void set_co2_level(double p_level);

    double get_flight_progress() const;
    void set_flight_progress(double p_val);

    double get_flight_speed() const;
    void set_flight_speed(double p_val);

    double get_cockpit_pressure() const;
    void set_cockpit_pressure(double p_val);

    double get_engineering_pressure() const;
    void set_engineering_pressure(double p_val);

    bool get_is_eclss_working() const;
    void set_is_eclss_working(bool working);
    
    bool get_is_hull_breached() const;
    void set_is_hull_breached(bool breached);

    bool get_is_bulkhead_closed() const;
    void set_is_bulkhead_closed(bool close);

    bool get_is_mission_active() const;
    void set_is_mission_active(bool active);

    // // Методи керування аваріями
    void trigger_co2_failure();
    void repair_co2_system();
    void trigger_hull_breach();
    void repair_hull_breach();
};