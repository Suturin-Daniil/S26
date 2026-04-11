import serial

PORT = 'COM16'
BAUD_RATE = 115200

ser = serial.Serial(PORT, BAUD_RATE)
print("Listening on", PORT)

while True:
    try:
        line = ser.readline().decode(errors='ignore').strip()

        if not line:
            continue

        print("RAW:", line)

        parts = line.split(',')

        if parts[0] == "POS" and len(parts) == 6:
            lat = float(parts[1])
            lon = float(parts[2])
            alt = float(parts[3])
            airspeed = float(parts[4])
            gps_status = int(parts[5])

            print(
                f"Lat={lat:.7f}, Lon={lon:.7f}, Alt={alt:.1f}m | "
                f"AS={airspeed:.2f} m/s | GPS={gps_status}"
            )

    except Exception as e:
        print("Error:", e)