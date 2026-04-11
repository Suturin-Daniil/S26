-- usb adapter подключен к uart4, необходимые изменения параметров:
-- uart4 (serial6), uart8 (serial5): user logic, 5v tolerent
-- SERIAL4_BAUD = 115 (115200)
-- SERIAL4_PROTOCOL = 28 (Scripting)

local CONFIG = {
    UART_PORT = 0,
    UPDATE_MS = 500,
    UART_BAUD_RATE = 115200
}
local uart = nil

function send_telemetry()
    if not uart then return end

    local pos = get_position()
    if not pos then return end
    local airspeed = get_airspeed()

    local msg = string.format(
        "POS,%.7f,%.7f,%.2f,%.2f\n",
        pos.lat,
        pos.lng,
        pos.alt,
        airspeed or -1
    )

    uart:write(msg)
end

function get_position()
    local loc = ahrs:get_location()
    if not loc then return nil end

    return {
        lat = loc:lat() / 1e7,
        lng = loc:lng() / 1e7,
        alt = loc:alt() / 100,
    }
end

function get_airspeed()
    return ahrs:airspeed_estimate()
end

function init()
    uart = serial:find_serial(CONFIG.UART_PORT)

    if uart then
        uart:begin(CONFIG.UART_BAUD_RATE)
        gcs:send_text(6, "UART OK")
    else
        gcs:send_text(4, "UART FAIL")
    end
end

function update()
    if not uart then
        init()
    end

    send_telemetry()

    return update, CONFIG.UPDATE_MS
end

return update, 1000