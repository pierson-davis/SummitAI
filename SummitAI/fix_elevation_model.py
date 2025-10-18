#!/usr/bin/env python3
"""
SummitAI Elevation Model Fix Script

This script automatically fixes the elevation model issues identified in the test suite.
It recalculates step requirements and camp elevations using realistic ratios.
"""

import re
from dataclasses import dataclass
from typing import Dict, List, Tuple

@dataclass
class MountainFix:
    name: str
    difficulty: str
    height: float
    base_elevation_start: float
    total_elevation_gain: float
    camps: List[Dict]
    current_base_steps: int
    new_base_steps: int
    step_ratio: float

class ElevationModelFixer:
    def __init__(self):
        # Realistic step-to-elevation ratios based on difficulty
        self.step_ratios = {
            "beginner": 15.0,      # Easy trails: ~15 steps per meter
            "intermediate": 25.0,  # Moderate trails: ~25 steps per meter
            "advanced": 40.0,      # Difficult trails: ~40 steps per meter
            "expert": 60.0,        # Technical climbing: ~60 steps per meter
            "extreme": 100.0       # Extreme conditions: ~100+ steps per meter
        }
        
        # Mountain difficulty mapping
        self.mountain_difficulties = {
            "Mount Fuji": "beginner",
            "Mount Kilimanjaro": "intermediate", 
            "Mount Rainier": "advanced",
            "Mont Blanc": "expert",
            "El Capitan": "expert",
            "Mount Everest": "extreme"
        }
        
        # Load mountain data for fixing
        self.mountains = self._load_mountain_data()
    
    def _load_mountain_data(self) -> List[MountainFix]:
        """Load mountain data with current values for fixing"""
        return [
            MountainFix(
                name="Mount Kilimanjaro",
                difficulty="intermediate",
                height=5895,
                base_elevation_start=1828,
                total_elevation_gain=4067,
                camps=[
                    {"name": "Base Camp", "altitude": 1828, "steps": 0, "elevation": 0},
                    {"name": "Camp 1 - Mandara", "altitude": 2700, "steps": 25000, "elevation": 500},
                    {"name": "Camp 2 - Horombo", "altitude": 3720, "steps": 75000, "elevation": 1200},
                    {"name": "Camp 3 - Kibo", "altitude": 4700, "steps": 150000, "elevation": 2000},
                    {"name": "Uhuru Peak", "altitude": 5895, "steps": 283752, "elevation": 4067}
                ],
                current_base_steps=283752,
                new_base_steps=0,  # Will be calculated
                step_ratio=0.0     # Will be calculated
            ),
            MountainFix(
                name="Mount Everest",
                difficulty="extreme",
                height=8848,
                base_elevation_start=5364,
                total_elevation_gain=3484,
                camps=[
                    {"name": "Base Camp", "altitude": 5364, "steps": 0, "elevation": 0},
                    {"name": "Camp 1", "altitude": 6065, "steps": 500000, "elevation": 800},
                    {"name": "Camp 2", "altitude": 6400, "steps": 1000000, "elevation": 1500},
                    {"name": "Camp 3", "altitude": 7200, "steps": 1800000, "elevation": 2500},
                    {"name": "Camp 4", "altitude": 8000, "steps": 2800000, "elevation": 3500},
                    {"name": "Summit", "altitude": 8848, "steps": 3399000, "elevation": 3484}
                ],
                current_base_steps=3399000,
                new_base_steps=0,
                step_ratio=0.0
            ),
            MountainFix(
                name="Mount Fuji",
                difficulty="beginner",
                height=3776,
                base_elevation_start=2305,
                total_elevation_gain=1471,
                camps=[
                    {"name": "Base Camp", "altitude": 2305, "steps": 0, "elevation": 0},
                    {"name": "Station 5", "altitude": 2390, "steps": 2000, "elevation": 200},
                    {"name": "Station 8", "altitude": 3100, "steps": 6000, "elevation": 500},
                    {"name": "Summit", "altitude": 3776, "steps": 9413, "elevation": 1471}
                ],
                current_base_steps=9413,
                new_base_steps=0,
                step_ratio=0.0
            ),
            MountainFix(
                name="Mount Rainier",
                difficulty="advanced",
                height=4392,
                base_elevation_start=1500,
                total_elevation_gain=2892,
                camps=[
                    {"name": "Base Camp", "altitude": 1500, "steps": 0, "elevation": 0},
                    {"name": "Camp Muir", "altitude": 3000, "steps": 40000, "elevation": 400},
                    {"name": "Summit", "altitude": 4392, "steps": 125112, "elevation": 2892}
                ],
                current_base_steps=125112,
                new_base_steps=0,
                step_ratio=0.0
            ),
            MountainFix(
                name="Mont Blanc",
                difficulty="expert",
                height=4808,
                base_elevation_start=1000,
                total_elevation_gain=3808,
                camps=[
                    {"name": "Base Camp", "altitude": 1000, "steps": 0, "elevation": 0},
                    {"name": "Refuge du Goûter", "altitude": 3000, "steps": 80000, "elevation": 500},
                    {"name": "Summit", "altitude": 4808, "steps": 200000, "elevation": 3808}
                ],
                current_base_steps=200000,
                new_base_steps=0,
                step_ratio=0.0
            ),
            MountainFix(
                name="El Capitan",
                difficulty="expert",
                height=2121,
                base_elevation_start=1207,
                total_elevation_gain=914,
                camps=[
                    {"name": "Base", "altitude": 1207, "steps": 0, "elevation": 0},
                    {"name": "Pitch 10", "altitude": 1400, "steps": 15000, "elevation": 200},
                    {"name": "Pitch 20", "altitude": 1600, "steps": 30000, "elevation": 400},
                    {"name": "Pitch 30", "altitude": 1800, "steps": 50000, "elevation": 600},
                    {"name": "Summit", "altitude": 2121, "steps": 66840, "elevation": 914}
                ],
                current_base_steps=66840,
                new_base_steps=0,
                step_ratio=0.0
            )
        ]
    
    def calculate_fixed_values(self) -> List[MountainFix]:
        """Calculate fixed step requirements and camp elevations"""
        fixed_mountains = []
        
        for mountain in self.mountains:
            # Get the appropriate step ratio for this mountain's difficulty
            step_ratio = self.step_ratios[mountain.difficulty]
            
            # Calculate new base steps using realistic ratio
            new_base_steps = int(mountain.total_elevation_gain * step_ratio)
            
            # Calculate fixed camp elevations and steps
            fixed_camps = []
            for i, camp in enumerate(mountain.camps):
                if i == 0:  # Base camp
                    fixed_camp = {
                        "name": camp["name"],
                        "altitude": camp["altitude"],
                        "steps": 0,
                        "elevation": 0
                    }
                else:
                    # Calculate elevation from altitude difference
                    elevation = camp["altitude"] - mountain.base_elevation_start
                    # Calculate steps proportionally
                    steps = int(elevation * step_ratio)
                    
                    fixed_camp = {
                        "name": camp["name"],
                        "altitude": camp["altitude"],
                        "steps": steps,
                        "elevation": elevation
                    }
                
                fixed_camps.append(fixed_camp)
            
            # Create fixed mountain
            fixed_mountain = MountainFix(
                name=mountain.name,
                difficulty=mountain.difficulty,
                height=mountain.height,
                base_elevation_start=mountain.base_elevation_start,
                total_elevation_gain=mountain.total_elevation_gain,
                camps=fixed_camps,
                current_base_steps=mountain.current_base_steps,
                new_base_steps=new_base_steps,
                step_ratio=step_ratio
            )
            
            fixed_mountains.append(fixed_mountain)
        
        return fixed_mountains
    
    def generate_swift_code(self, fixed_mountains: List[MountainFix]) -> str:
        """Generate Swift code with fixed mountain definitions"""
        swift_code = []
        
        for mountain in fixed_mountains:
            swift_code.append(f"    static let {mountain.name.lower().replace(' ', '').replace('mount', '').replace('mont', '')} = Mountain(")
            swift_code.append(f"        name: \"{mountain.name}\",")
            swift_code.append(f"        height: {mountain.height},")
            swift_code.append(f"        location: \"{self._get_location(mountain.name)}\",")
            swift_code.append(f"        difficulty: .{mountain.difficulty},")
            swift_code.append(f"        description: \"{self._get_description(mountain.name)}\",")
            swift_code.append(f"        imageName: \"{mountain.name.lower().replace(' ', '').replace('mount', '').replace('mont', '')}\",")
            swift_code.append(f"        isPaywalled: {self._is_paywalled(mountain.name)},")
            swift_code.append(f"        camps: [")
            
            for camp in mountain.camps:
                swift_code.append(f"            Camp(name: \"{camp['name']}\", altitude: {camp['altitude']}, stepsRequired: {camp['steps']}, elevationRequired: {camp['elevation']}, description: \"{self._get_camp_description(camp['name'])}\", unlockedMessage: \"{self._get_unlocked_message(camp['name'])}\", isBaseCamp: {camp['name'].lower().find('base') != -1}, isSummit: {camp['name'].lower().find('summit') != -1 or camp['name'].lower().find('peak') != -1}),")
            
            swift_code.append(f"        ],")
            swift_code.append(f"        baseSteps: {mountain.new_base_steps},")
            swift_code.append(f"        baseElevation: {mountain.total_elevation_gain},")
            swift_code.append(f"        baseElevationStart: {mountain.base_elevation_start},")
            swift_code.append(f"        totalElevationGain: {mountain.total_elevation_gain},")
            swift_code.append(f"        difficultyMultiplier: {self._get_difficulty_multiplier(mountain.difficulty)},")
            swift_code.append(f"        estimatedDays: {self._get_estimated_days(mountain.name)},")
            swift_code.append(f"        climbingSeason: .{self._get_climbing_season(mountain.name)},")
            swift_code.append(f"        weatherPatterns: {self._get_weather_patterns(mountain.name)},")
            swift_code.append(f"        hazards: {self._get_hazards(mountain.name)},")
            swift_code.append(f"        equipmentRequirements: {self._get_equipment(mountain.name)},")
            swift_code.append(f"        historicalData: .{mountain.name.lower().replace(' ', '').replace('mount', '').replace('mont', '')}")
            swift_code.append(f"    )")
            swift_code.append("")
        
        return "\n".join(swift_code)
    
    def _get_location(self, mountain_name: str) -> str:
        locations = {
            "Mount Kilimanjaro": "Tanzania, Africa",
            "Mount Everest": "Nepal/Tibet, Asia", 
            "Mount Fuji": "Japan, Asia",
            "Mount Rainier": "Washington, USA",
            "Mont Blanc": "France/Italy, Europe",
            "El Capitan": "Yosemite, USA"
        }
        return locations.get(mountain_name, "Unknown")
    
    def _get_description(self, mountain_name: str) -> str:
        descriptions = {
            "Mount Kilimanjaro": "The highest peak in Africa and the highest free-standing mountain in the world. A non-technical climb but requires excellent fitness and acclimatization.",
            "Mount Everest": "The world's highest peak and ultimate mountaineering challenge. Requires extreme fitness, technical skills, and months of preparation.",
            "Mount Fuji": "Japan's most iconic mountain and a sacred symbol. A popular day hike with well-maintained trails.",
            "Mount Rainier": "The most glaciated peak in the contiguous United States. Requires glacier travel skills and crevasse rescue knowledge.",
            "Mont Blanc": "The highest peak in the Alps and Western Europe. Requires alpine climbing skills and experience with high altitude.",
            "El Capitan": "The legendary granite monolith in Yosemite Valley. Requires advanced rock climbing skills and multi-day commitment."
        }
        return descriptions.get(mountain_name, "A challenging mountain climb.")
    
    def _is_paywalled(self, mountain_name: str) -> bool:
        paywalled = ["Mount Everest", "Mont Blanc", "El Capitan"]
        return mountain_name in paywalled
    
    def _get_camp_description(self, camp_name: str) -> str:
        if "base" in camp_name.lower():
            return "Starting point of your expedition"
        elif "summit" in camp_name.lower() or "peak" in camp_name.lower():
            return "The summit of the mountain"
        else:
            return f"Intermediate camp on the mountain"
    
    def _get_unlocked_message(self, camp_name: str) -> str:
        if "base" in camp_name.lower():
            return "Welcome to the mountain!"
        elif "summit" in camp_name.lower() or "peak" in camp_name.lower():
            return "Congratulations! You've reached the summit!"
        else:
            return f"You've reached {camp_name}!"
    
    def _get_difficulty_multiplier(self, difficulty: str) -> float:
        multipliers = {
            "beginner": 3.0,
            "intermediate": 8.0,
            "advanced": 12.0,
            "expert": 15.0,
            "extreme": 25.0
        }
        return multipliers.get(difficulty, 8.0)
    
    def _get_estimated_days(self, mountain_name: str) -> int:
        days = {
            "Mount Kilimanjaro": 7,
            "Mount Everest": 35,
            "Mount Fuji": 1,
            "Mount Rainier": 3,
            "Mont Blanc": 5,
            "El Capitan": 4
        }
        return days.get(mountain_name, 5)
    
    def _get_climbing_season(self, mountain_name: str) -> str:
        seasons = {
            "Mount Kilimanjaro": "spring",
            "Mount Everest": "spring",
            "Mount Fuji": "summer",
            "Mount Rainier": "summer",
            "Mont Blanc": "summer",
            "El Capitan": "summer"
        }
        return seasons.get(mountain_name, "summer")
    
    def _get_weather_patterns(self, mountain_name: str) -> str:
        patterns = {
            "Mount Kilimanjaro": "[.clear, .cloudy, .windy]",
            "Mount Everest": "[.clear, .cloudy, .windy, .storm, .blizzard]",
            "Mount Fuji": "[.clear, .cloudy]",
            "Mount Rainier": "[.clear, .cloudy, .windy, .storm]",
            "Mont Blanc": "[.clear, .cloudy, .windy, .storm]",
            "El Capitan": "[.clear, .cloudy, .windy]"
        }
        return patterns.get(mountain_name, "[.clear, .cloudy]")
    
    def _get_hazards(self, mountain_name: str) -> str:
        hazards = {
            "Mount Kilimanjaro": "[.altitudeSickness, .frostbite]",
            "Mount Everest": "[.altitudeSickness, .avalanches, .crevasses, .frostbite]",
            "Mount Fuji": "[]",
            "Mount Rainier": "[.crevasses, .avalanches, .altitudeSickness]",
            "Mont Blanc": "[.altitudeSickness, .avalanches, .rockfall]",
            "El Capitan": "[.rockfall]"
        }
        return hazards.get(mountain_name, "[]")
    
    def _get_equipment(self, mountain_name: str) -> str:
        equipment = {
            "Mount Kilimanjaro": "[.helmet, .rope]",
            "Mount Everest": "[.iceAxe, .crampons, .helmet, .oxygenBottle, .rope, .gps]",
            "Mount Fuji": "[]",
            "Mount Rainier": "[.iceAxe, .crampons, .helmet, .rope]",
            "Mont Blanc": "[.iceAxe, .crampons, .helmet, .rope]",
            "El Capitan": "[.rope, .helmet]"
        }
        return equipment.get(mountain_name, "[]")
    
    def generate_comparison_report(self, fixed_mountains: List[MountainFix]) -> str:
        """Generate a comparison report showing before/after values"""
        report = []
        report.append("# SummitAI Elevation Model Fix Report")
        report.append("")
        report.append("## Summary of Changes")
        report.append("")
        
        for mountain in fixed_mountains:
            report.append(f"### {mountain.name}")
            report.append("")
            report.append(f"**Difficulty**: {mountain.difficulty.title()}")
            report.append(f"**Step Ratio**: {mountain.step_ratio} steps/meter")
            report.append("")
            report.append("| Metric | Before | After | Change |")
            report.append("|--------|--------|-------|--------|")
            report.append(f"| Base Steps | {mountain.current_base_steps:,} | {mountain.new_base_steps:,} | {((mountain.new_base_steps - mountain.current_base_steps) / mountain.current_base_steps * 100):+.1f}% |")
            report.append("")
            report.append("**Camp Details**:")
            report.append("")
            report.append("| Camp | Altitude | Steps (Before) | Steps (After) | Elevation (Before) | Elevation (After) |")
            report.append("|------|----------|----------------|---------------|-------------------|------------------|")
            
            for camp in mountain.camps:
                # Find original camp data
                original_camp = next((c for c in mountain.camps if c["name"] == camp["name"]), camp)
                steps_before = original_camp.get("steps", 0)
                elevation_before = original_camp.get("elevation", 0)
                steps_after = camp["steps"]
                elevation_after = camp["elevation"]
                
                report.append(f"| {camp['name']} | {camp['altitude']}m | {steps_before:,} | {steps_after:,} | {elevation_before}m | {elevation_after}m |")
            
            report.append("")
        
        return "\n".join(report)

def main():
    """Main execution function"""
    print("🔧 SummitAI Elevation Model Fix Script")
    print("=" * 50)
    
    fixer = ElevationModelFixer()
    
    # Calculate fixed values
    print("📊 Calculating fixed values...")
    fixed_mountains = fixer.calculate_fixed_values()
    
    # Generate comparison report
    print("📋 Generating comparison report...")
    report = fixer.generate_comparison_report(fixed_mountains)
    
    # Save report
    with open("SummitAI/elevation_model_fix_report.md", "w") as f:
        f.write(report)
    
    print("✅ Fix report saved to: SummitAI/elevation_model_fix_report.md")
    
    # Generate Swift code
    print("💻 Generating Swift code...")
    swift_code = fixer.generate_swift_code(fixed_mountains)
    
    # Save Swift code
    with open("SummitAI/fixed_mountain_definitions.swift", "w") as f:
        f.write(swift_code)
    
    print("✅ Swift code saved to: SummitAI/fixed_mountain_definitions.swift")
    
    # Print summary
    print("\n📈 Summary of Changes:")
    for mountain in fixed_mountains:
        change_percent = ((mountain.new_base_steps - mountain.current_base_steps) / mountain.current_base_steps * 100)
        print(f"- {mountain.name}: {mountain.current_base_steps:,} → {mountain.new_base_steps:,} steps ({change_percent:+.1f}%)")
    
    print("\n🎯 Next Steps:")
    print("1. Review the fix report: SummitAI/elevation_model_fix_report.md")
    print("2. Update Mountain.swift with the new definitions")
    print("3. Run tests to verify fixes")
    print("4. Test the app with new values")

if __name__ == "__main__":
    main()
