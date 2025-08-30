import Foundation

struct Plan: Decodable {
    let meta: Meta
    let globalGuidelines: GlobalGuidelines
    let weeks: [Week]

    enum CodingKeys: String, CodingKey {
        case meta
        case globalGuidelines = "global_guidelines"
        case weeks
    }
}

struct Meta: Decodable {
    let athlete: String
    let raceDate: String
    let goal: String
    let targetPaceKm: String
    let trainingWindowLocal: String
    let environment: String
    let version: String

    enum CodingKeys: String, CodingKey {
        case athlete
        case raceDate = "race_date"
        case goal
        case targetPaceKm = "target_pace_km"
        case trainingWindowLocal = "training_window_local"
        case environment
        case version
    }
}

struct GlobalGuidelines: Decodable {
    let effortBasedOutdoors: EffortBased
    let heatIndexSwitch: [HeatIndex]
    let coolingFueling: CoolingFueling

    enum CodingKeys: String, CodingKey {
        case effortBasedOutdoors = "effort_based_outdoors"
        case heatIndexSwitch = "heat_index_switch"
        case coolingFueling = "cooling_fueling"
    }
}

struct EffortBased: Decodable {
    let description: String
    let easyHrCapBpm: Int
    let notes: [String]

    enum CodingKeys: String, CodingKey {
        case description
        case easyHrCapBpm = "easy_hr_cap_bpm"
        case notes
    }
}

struct HeatIndex: Decodable {
    let condition: String
    let action: String
}

struct CoolingFueling: Decodable {
    let pre: String
    let during: String
    let post: String
}

struct Week: Identifiable, Decodable {
    let id = UUID()
    let number: Int?
    let numberRange: [Int]?
    let dateRange: String
    let type: WeekType
    let days: [Day]?
    let weeklyVolumeKm: String?
    let notes: [String]?
    let sessionCategories: [SessionCategory]?

    enum WeekType: String, Decodable { case detailed, guideline }

    enum CodingKeys: String, CodingKey {
        case number
        case numberRange = "number_range"
        case dateRange = "date_range"
        case type
        case days
        case weeklyVolumeKm = "weekly_volume_km"
        case notes
        case sessions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decodeIfPresent(Int.self, forKey: .number)
        numberRange = try container.decodeIfPresent([Int].self, forKey: .numberRange)
        dateRange = try container.decode(String.self, forKey: .dateRange)
        type = try container.decode(WeekType.self, forKey: .type)
        days = try container.decodeIfPresent([Day].self, forKey: .days)
        weeklyVolumeKm = try container.decodeIfPresent(String.self, forKey: .weeklyVolumeKm)
        notes = try container.decodeIfPresent([String].self, forKey: .notes)

        if let sessionsDict = try container.decodeIfPresent([String: AnyDecodable].self, forKey: .sessions) {
            var cats: [SessionCategory] = []
            for (key, value) in sessionsDict {
                if let arr = value.value as? [[String: Any]] {
                    let items = arr.map { dict -> String in
                        if let option = dict["option"], let session = dict["session"] {
                            return "\(option): \(session)"
                        } else if let session = dict["session"] {
                            return "\(session)"
                        } else {
                            return dict.values.map { "\($0)" }.joined(separator: " ")
                        }
                    }
                    cats.append(SessionCategory(name: key, items: items))
                } else if let arr = value.value as? [String] {
                    cats.append(SessionCategory(name: key, items: arr))
                } else if let str = value.value as? String {
                    cats.append(SessionCategory(name: key, items: [str]))
                }
            }
            sessionCategories = cats
        } else {
            sessionCategories = nil
        }
    }

    var storageKey: String {
        if let n = number { return "\(n)" }
        if let r = numberRange { return "\(r.first ?? 0)-\(r.last ?? 0)" }
        return dateRange
    }

    var displayNumber: String {
        if let n = number { return "\(n)" }
        if let r = numberRange { return "\(r.first ?? 0)–\(r.last ?? 0)" }
        return ""
    }

    var totalMinutes: Int {
        days?.compactMap { $0.durationMin }.reduce(0,+) ?? 0
    }
}

struct SessionCategory: Identifiable {
    let id = UUID()
    let name: String
    let items: [String]
}

struct Day: Identifiable, Decodable {
    let id = UUID()
    let day: String
    let type: String
    let details: [String: String]
    let durationMin: Int?

    enum CodingKeys: CodingKey {
        case day, type, extras, format, duration_min, hr_cap_bpm, env, zone, strides, blocks, grade_percent, drink_ml, hr_max_bpm, total_min, note, cross_train_min, strength_min, focus, repeats, warmup_min, recover_min, cooldown_min, steady_min, mp_feel_min, pace_km, work_min, intensity, hr_bpm, finish
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        day = try container.decode(String.self, forKey: .day)
        type = try container.decode(String.self, forKey: .type)

        var temp: [String: String] = [:]
        var duration: Int? = nil

        for key in container.allKeys where key != .day && key != .type {
            if key == .duration_min {
                if let intVal = try? container.decode(Int.self, forKey: .duration_min) {
                    duration = intVal
                    temp[key.stringValue] = "\(intVal)"
                } else if let strVal = try? container.decode(String.self, forKey: .duration_min) {
                    duration = Int(strVal.split(separator: "–").first ?? "")
                    temp[key.stringValue] = strVal
                }
            } else if let str = try? container.decode(String.self, forKey: key) {
                temp[key.stringValue] = str
            } else if let int = try? container.decode(Int.self, forKey: key) {
                temp[key.stringValue] = "\(int)"
            } else if let arrStr = try? container.decode([String].self, forKey: key) {
                temp[key.stringValue] = arrStr.joined(separator: ", ")
            } else if let arrInt = try? container.decode([Int].self, forKey: key) {
                temp[key.stringValue] = arrInt.map(String.init).joined(separator: ", ")
            } else if let arrDict = try? container.decode([[String: String]].self, forKey: key) {
                let data = (try? JSONSerialization.data(withJSONObject: arrDict)) ?? Data()
                temp[key.stringValue] = String(data: data, encoding: .utf8) ?? ""
            }
        }
        details = temp
        durationMin = duration
    }

    var summary: String {
        details.map { "\($0.key): \($0.value)" }.sorted().joined(separator: ", ")
    }
}

struct AnyDecodable: Decodable {
    let value: Any
    init(from decoder: Decoder) throws {
        if let int = try? Int(from: decoder) { value = int }
        else if let dbl = try? Double(from: decoder) { value = dbl }
        else if let str = try? String(from: decoder) { value = str }
        else if let arr = try? [AnyDecodable](from: decoder) { value = arr.map{ $0.value } }
        else if let dict = try? [String: AnyDecodable](from: decoder) { value = dict.mapValues{ $0.value } }
        else { value = "" }
    }
}
