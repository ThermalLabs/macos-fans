import Foundation

struct FanReading {
    let index: Int
    let actualRPM: Int
    let targetRPM: Int
    let minRPM: Int
    let maxRPM: Int
}

struct ThermalReading {
    let cpuProximityTemp: Double  // °C
}

/// Reads fan speed and temperature data from the SMC.
/// Currently returns stub data — real IOKit implementation comes next.
final class SMCReader: Sendable {
    func readFans() -> [FanReading] {
        // TODO: open SMC via IOKit and read F0Ac, F0Tg, F0Mn, F0Mx for each fan
        return []
    }

    func readTemperatures() -> ThermalReading? {
        // TODO: read TC0P (CPU proximity) and other keys via IOKit
        return nil
    }
}
