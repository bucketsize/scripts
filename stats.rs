use std::fs;
use std::io::{self, BufRead};
use std::path::Path;

#[derive(Debug)]
pub struct RamStats {
    pub total_ram_gb: f64,
    pub used_ram_gb: f64,
    pub free_ram_gb: f64,
    pub occupancy_percent: f64,
}

#[derive(Debug)]
pub struct BatteryStats {
    pub charge_percent: f64,
    pub status: String,
    pub time_to_full: Option<String>,
    pub time_to_empty: Option<String>,
    pub present: bool,
}

impl BatteryStats {
    /// Check multiple battery paths and return stats for any battery found
    pub fn get_battery_stats() -> Option<BatteryStats> {
        let battery_paths = [0, 2, 3, 4, 5, 6, 7];

        for bat in &battery_paths {
            let path = Path::new("/sys/class/power_supply/BAT").join(bat.to_string());
            
            if path.exists() && path.is_dir() {
                if let Some(stats) = Self::parse_battery(&path) {
                    return Some(stats);
                }
            }
        }

        None
    }

    /// Parse individual battery directory for stats
    fn parse_battery(path: &Path) -> Option<BatteryStats> {
        let charge_percent = Self::read_u64_file(&path.join("capacity"))?.try_into().ok()?;
        let status = Self::read_string_file(&path.join("status")).unwrap_or_else(|_| "unknown".to_string());
        let time_to_full = Self::read_u64_file(&path.join("time_to_full")).map(|seconds| Self::format_seconds(seconds));
        let time_to_empty = Self::read_u64_file(&path.join("time_to_empty")).map(|seconds| Self::format_seconds(seconds));

        // Check if battery is present
        let present = Self::read_string_file(&path.join("present")).unwrap() == "1";

        Some(BatteryStats {
            charge_percent,
            status,
            time_to_full,
            time_to_empty,
            present,
        })
    }

    /// Read u64 value from file
    fn read_u64_file(path: &Path) -> Option<u64> {
        fs::read_to_string(path)
            .ok()?
            .trim()
            .parse()
            .ok()
    }

    /// Read string from file
    fn read_string_file(path: &Path) -> io::Result<String> {
        let content = fs::read_to_string(path)?;
        Ok(content.trim().to_string())
    }

    /// Format seconds into human-readable time
    fn format_seconds(seconds: u64) -> String {
        if seconds == u64::MAX {
            return "unknown".to_string();
        }

        let hours = seconds / 3600;
        let minutes = (seconds % 3600) / 60;
        let remaining_seconds = seconds % 60;

        if hours > 0 {
            format!("{}h {}m {}s", hours, minutes, remaining_seconds)
        } else if minutes > 0 {
            format!("{}m {}s", minutes, remaining_seconds)
        } else {
            format!("{}s", remaining_seconds)
        }
    }

    /// Format the stats as a human-readable string
    pub fn to_string(&self) -> String {
        if !self.present {
            return "No battery detected".to_string();
        }
        
        let status = if self.status.is_empty() {
            "unknown"
        } else {
            self.status.as_str()
        };

        let charge = format!("{}%", self.charge_percent);
        let time_msg = match status {
            "charging" if self.time_to_full.is_some() => 
                format!(" (est. {})", self.time_to_full.as_ref().unwrap()),
            "discharging" if self.time_to_empty.is_some() => 
                format!(" (est. {} left)", self.time_to_empty.as_ref().unwrap()),
            _ => String::new(),
        };

        format!(
            "Battery Statistics:\n  Charge: {}\n  Status: {}{}\n  Present: {}",
            charge, status.to_lowercase(), time_msg, self.present
        )
    }
}

impl RamStats {
    /// Parse /proc/meminfo and calculate RAM statistics
    pub fn from_proc_meminfo() -> Result<Self, io::Error> {
        let file = fs::File::open("/proc/meminfo")?;
        let reader = io::BufReader::new(file);

        let mut total_kb: u64 = 0;
        let mut available_kb: u64 = 0;

        for line in reader.lines() {
            let line = line?;
            let parts: Vec<&str> = line.split(':').collect();

            if parts.len() < 2 {
                continue;
            }

            let key = parts[0].trim();
            let value_str = parts[1].trim();
            let value_kb: u64 = value_str
                .split_whitespace()
                .next()
                .and_then(|s| s.parse().ok())
                .unwrap_or(0);

            match key {
                "MemTotal" => total_kb = value_kb,
                "MemAvailable" | "MemFree" => available_kb = value_kb,
                _ => continue,
            }
        }

        if total_kb == 0 {
            return Err(io::Error::new(
                io::ErrorKind::NotFound,
                "Could not find MemTotal in /proc/meminfo",
            ));
        }

        let total_gb = total_kb as f64 / 1024.0 / 1024.0;
        let used_gb = total_gb - (available_kb as f64 / 1024.0 / 1024.0);
        let occupancy_percent = (used_gb / total_gb) * 100.0;

        Ok(RamStats {
            total_ram_gb: total_gb,
            used_ram_gb: used_gb,
            free_ram_gb: available_kb as f64 / 1024.0 / 1024.0,
            occupancy_percent,
        })
    }

    /// Format the stats as a human-readable string
    pub fn to_string(&self) -> String {
        format!(
            "RAM Statistics:\n  Total RAM: {:.2} GB\n  Used RAM: {:.2} GB ({:.1}%)\n  Free RAM: {:.2} GB",
            self.total_ram_gb, self.used_ram_gb, self.occupancy_percent, self.free_ram_gb
        )
    }
}

fn main() {
    // Display RAM stats
    match RamStats::from_proc_meminfo() {
        Ok(stats) => {
            println!("{}", stats.to_string());
            println!();
        }
        Err(e) => {
            eprintln!("Error reading RAM stats: {}", e);
        }
    }

    // Display battery stats
    if let Some(battery) = BatteryStats::get_battery_stats() {
        println!("{}", battery.to_string());
    } else {
        println!("Battery Statistics: No battery detected");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ram_stats_parsing() {
        // Mock the /proc/meminfo reading for testing
        let mock_meminfo = "MemTotal:       8388608 kB\nMemAvailable:  2097152 kB\nMemFree:      2097152 kB\nBuffers:       524288 kB\nCached:      1048576 kB";
        let original_read_to_string = std::fs::read_to_string;
        std::fs::read_to_string = |_| Ok(mock_meminfo.to_string());

        let stats = RamStats::from_proc_meminfo().unwrap();

        // Restore original function
        std::fs::read_to_string = original_read_to_string;

        // Verify calculations
        assert_eq!(stats.total_ram_gb, 8.0); // 8388608 KB = 8 GB
        assert_eq!(stats.free_ram_gb, 2.0);  // 2097152 KB = 2 GB
        assert_eq!(stats.used_ram_gb, 6.0);  // 8 - 2 = 6 GB
        assert!((stats.occupancy_percent - 75.0).abs() < 0.01); // 6/8 = 75%
    }

    #[test]
    fn test_battery_stats_formatting() {
        let battery = BatteryStats {
            charge_percent: 85.0,
            status: "charging".to_string(),
            time_to_full: Some("2h 30m 0s".to_string()),
            time_to_empty: None,
            present: true,
        };

        let output = battery.to_string();
        assert!(output.contains("85%"));
        assert!(output.contains("charging"));
        assert!(output.contains("2h 30m 0s"));
    }

    #[test]
    fn test_battery_stats_discharging() {
        let battery = BatteryStats {
            charge_percent: 45.0,
            status: "discharging".to_string(),
            time_to_full: None,
            time_to_empty: Some("1h 15m 30s".to_string()),
            present: true,
        };

        let output = battery.to_string();
        assert!(output.contains("45%"));
        assert!(output.contains("discharging"));
        assert!(output.contains("1h 15m 30s left"));
    }

    #[test]
    fn test_battery_stats_no_battery() {
        let battery = BatteryStats {
            charge_percent: 0.0,
            status: String::new(),
            time_to_full: None,
            time_to_empty: None,
            present: false,
        };

        let output = battery.to_string();
        assert!(output.contains("No battery detected"));
    }

    #[test]
    fn test_format_seconds() {
        assert_eq!(BatteryStats::format_seconds(0), "0s");
        assert_eq!(BatteryStats::format_seconds(59), "59s");
        assert_eq!(BatteryStats::format_seconds(60), "1m 0s");
        assert_eq!(BatteryStats::format_seconds(3661), "1h 1m 1s");
        assert_eq!(BatteryStats::format_seconds(3661), "1h 1m 1s");
        assert_eq!(BatteryStats::format_seconds(u64::MAX), "unknown");
    }
}
