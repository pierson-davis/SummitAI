#!/usr/bin/env python3
"""
SummitAI Elevation Model Comprehensive Test Suite

This script tests the accuracy and consistency of the elevation model used in SummitAI.
It analyzes the relationship between steps, elevation, and mountain progress calculations.

Key Issues to Test:
1. HealthKit elevation calculation (flights to meters conversion)
2. Mountain step-to-elevation mapping accuracy
3. Camp progression logic consistency
4. Real-world accuracy of step-to-elevation ratios
5. Mountain height vs. actual elevation gain discrepancies
"""

import math
import json
from dataclasses import dataclass
from typing import List, Dict, Tuple, Optional
from datetime import datetime, timedelta

@dataclass
class MountainTestData:
    name: str
    height: float  # Total height in meters
    base_elevation_start: float  # Starting elevation in meters
    total_elevation_gain: float  # Actual elevation gain to climb
    base_steps: int  # Total steps required
    camps: List[Dict]  # Camp data with steps and elevation requirements

@dataclass
class TestResult:
    test_name: str
    passed: bool
    expected: float
    actual: float
    error_percentage: float
    message: str

class ElevationModelTester:
    def __init__(self):
        # HealthKit conversion constants
        self.FEET_PER_FLIGHT = 10.0
        self.METERS_PER_FOOT = 0.3048
        self.METERS_PER_FLIGHT = self.FEET_PER_FLIGHT * self.METERS_PER_FOOT
        
        # Real-world step-to-elevation ratios (steps per meter of elevation gain)
        self.REAL_WORLD_RATIOS = {
            "easy_hiking": 15,      # Easy trails: ~15 steps per meter
            "moderate_hiking": 25,  # Moderate trails: ~25 steps per meter
            "difficult_hiking": 40, # Difficult trails: ~40 steps per meter
            "technical_climbing": 60, # Technical climbing: ~60 steps per meter
            "extreme_climbing": 100  # Extreme conditions: ~100+ steps per meter
        }
        
        # Load mountain test data
        self.mountains = self._load_mountain_test_data()
    
    def _load_mountain_test_data(self) -> List[MountainTestData]:
        """Load mountain data from the Swift code for testing"""
        return [
            MountainTestData(
                name="Mount Kilimanjaro",
                height=5895,
                base_elevation_start=1828,
                total_elevation_gain=4067,
                base_steps=101675,
                camps=[
                    {"name": "Base Camp", "altitude": 1828, "steps": 0, "elevation": 0},
                    {"name": "Camp 1 - Mandara", "altitude": 2700, "steps": 21800, "elevation": 872},
                    {"name": "Camp 2 - Horombo", "altitude": 3720, "steps": 47300, "elevation": 1892},
                    {"name": "Camp 3 - Kibo", "altitude": 4700, "steps": 71800, "elevation": 2872},
                    {"name": "Uhuru Peak", "altitude": 5895, "steps": 101675, "elevation": 4067}
                ]
            ),
            MountainTestData(
                name="Mount Everest",
                height=8848,
                base_elevation_start=5364,
                total_elevation_gain=3484,
                base_steps=348400,
                camps=[
                    {"name": "Base Camp", "altitude": 5364, "steps": 0, "elevation": 0},
                    {"name": "Camp 1", "altitude": 6065, "steps": 70100, "elevation": 701},
                    {"name": "Camp 2", "altitude": 6400, "steps": 103600, "elevation": 1036},
                    {"name": "Camp 3", "altitude": 7200, "steps": 183600, "elevation": 1836},
                    {"name": "Camp 4", "altitude": 8000, "steps": 263600, "elevation": 2636},
                    {"name": "Summit", "altitude": 8848, "steps": 348400, "elevation": 3484}
                ]
            ),
            MountainTestData(
                name="Mount Fuji",
                height=3776,
                base_elevation_start=2305,
                total_elevation_gain=1471,
                base_steps=22065,
                camps=[
                    {"name": "Base Camp", "altitude": 2305, "steps": 0, "elevation": 0},
                    {"name": "Station 5", "altitude": 2390, "steps": 1275, "elevation": 85},
                    {"name": "Station 8", "altitude": 3100, "steps": 11925, "elevation": 795},
                    {"name": "Summit", "altitude": 3776, "steps": 22065, "elevation": 1471}
                ]
            ),
            MountainTestData(
                name="Mount Rainier",
                height=4392,
                base_elevation_start=1500,
                total_elevation_gain=2892,
                base_steps=115680,
                camps=[
                    {"name": "Base Camp", "altitude": 1500, "steps": 0, "elevation": 0},
                    {"name": "Camp Muir", "altitude": 3000, "steps": 60000, "elevation": 1500},
                    {"name": "Summit", "altitude": 4392, "steps": 115680, "elevation": 2892}
                ]
            ),
            MountainTestData(
                name="Mont Blanc",
                height=4808,
                base_elevation_start=1000,
                total_elevation_gain=3808,
                base_steps=228480,
                camps=[
                    {"name": "Base Camp", "altitude": 1000, "steps": 0, "elevation": 0},
                    {"name": "Refuge du Goûter", "altitude": 3000, "steps": 120000, "elevation": 2000},
                    {"name": "Summit", "altitude": 4808, "steps": 228480, "elevation": 3808}
                ]
            ),
            MountainTestData(
                name="El Capitan",
                height=2121,
                base_elevation_start=1207,
                total_elevation_gain=914,
                base_steps=54840,
                camps=[
                    {"name": "Base", "altitude": 1207, "steps": 0, "elevation": 0},
                    {"name": "Pitch 10", "altitude": 1400, "steps": 11580, "elevation": 193},
                    {"name": "Pitch 20", "altitude": 1600, "steps": 23580, "elevation": 393},
                    {"name": "Pitch 30", "altitude": 1800, "steps": 35580, "elevation": 593},
                    {"name": "Summit", "altitude": 2121, "steps": 54840, "elevation": 914}
                ]
            )
        ]
    
    def test_healthkit_elevation_conversion(self) -> List[TestResult]:
        """Test HealthKit flights to meters conversion accuracy"""
        results = []
        
        # Test cases: flights climbed -> expected meters
        test_cases = [
            (1, 3.048),      # 1 flight = 10 feet = 3.048 meters
            (10, 30.48),     # 10 flights = 100 feet = 30.48 meters
            (100, 304.8),    # 100 flights = 1000 feet = 304.8 meters
            (1000, 3048.0),  # 1000 flights = 10000 feet = 3048 meters
        ]
        
        for flights, expected_meters in test_cases:
            actual_meters = flights * self.METERS_PER_FLIGHT
            error_percentage = abs(actual_meters - expected_meters) / expected_meters * 100
            
            results.append(TestResult(
                test_name=f"HealthKit Conversion: {flights} flights",
                passed=error_percentage < 0.01,  # Less than 0.01% error
                expected=expected_meters,
                actual=actual_meters,
                error_percentage=error_percentage,
                message=f"Converted {flights} flights to {actual_meters:.3f}m (expected {expected_meters:.3f}m)"
            ))
        
        return results
    
    def test_mountain_step_to_elevation_ratios(self) -> List[TestResult]:
        """Test if mountain step-to-elevation ratios are realistic"""
        results = []
        
        for mountain in self.mountains:
            # Calculate overall step-to-elevation ratio
            total_steps = mountain.base_steps
            total_elevation = mountain.total_elevation_gain
            steps_per_meter = total_steps / total_elevation if total_elevation > 0 else 0
            
            # Determine expected ratio based on mountain difficulty
            if mountain.name == "Mount Fuji":
                expected_ratio = self.REAL_WORLD_RATIOS["easy_hiking"]
                difficulty = "Easy"
            elif mountain.name == "Mount Kilimanjaro":
                expected_ratio = self.REAL_WORLD_RATIOS["moderate_hiking"]
                difficulty = "Moderate"
            elif mountain.name == "Mount Rainier":
                expected_ratio = self.REAL_WORLD_RATIOS["difficult_hiking"]
                difficulty = "Difficult"
            elif mountain.name == "Mount Everest":
                expected_ratio = self.REAL_WORLD_RATIOS["extreme_climbing"]
                difficulty = "Extreme"
            elif mountain.name == "Mont Blanc":
                expected_ratio = self.REAL_WORLD_RATIOS["technical_climbing"]
                difficulty = "Technical"
            elif mountain.name == "El Capitan":
                expected_ratio = self.REAL_WORLD_RATIOS["technical_climbing"]
                difficulty = "Technical"
            else:
                expected_ratio = self.REAL_WORLD_RATIOS["moderate_hiking"]
                difficulty = "Unknown"
            
            # Calculate error percentage
            error_percentage = abs(steps_per_meter - expected_ratio) / expected_ratio * 100
            
            # Determine if the ratio is realistic (within 50% of expected)
            is_realistic = error_percentage < 50
            
            results.append(TestResult(
                test_name=f"{mountain.name} Step-to-Elevation Ratio",
                passed=is_realistic,
                expected=expected_ratio,
                actual=steps_per_meter,
                error_percentage=error_percentage,
                message=f"{mountain.name}: {steps_per_meter:.1f} steps/meter (expected ~{expected_ratio} for {difficulty.lower()} hiking)"
            ))
        
        return results
    
    def test_camp_progression_consistency(self) -> List[TestResult]:
        """Test if camp progression is consistent (steps and elevation increase monotonically)"""
        results = []
        
        for mountain in self.mountains:
            camps = mountain.camps
            step_issues = []
            elevation_issues = []
            
            # Check step progression
            for i in range(1, len(camps)):
                if camps[i]["steps"] < camps[i-1]["steps"]:
                    step_issues.append(f"Camp {i} has fewer steps than previous camp")
            
            # Check elevation progression
            for i in range(1, len(camps)):
                if camps[i]["elevation"] < camps[i-1]["elevation"]:
                    elevation_issues.append(f"Camp {i} has less elevation than previous camp")
            
            # Check altitude progression
            altitude_issues = []
            for i in range(1, len(camps)):
                if camps[i]["altitude"] < camps[i-1]["altitude"]:
                    altitude_issues.append(f"Camp {i} has lower altitude than previous camp")
            
            all_issues = step_issues + elevation_issues + altitude_issues
            passed = len(all_issues) == 0
            
            results.append(TestResult(
                test_name=f"{mountain.name} Camp Progression",
                passed=passed,
                expected=0,
                actual=len(all_issues),
                error_percentage=0,
                message=f"{mountain.name}: {'PASS' if passed else 'FAIL'} - {len(all_issues)} progression issues found"
            ))
            
            if all_issues:
                for issue in all_issues:
                    results.append(TestResult(
                        test_name=f"{mountain.name} - {issue}",
                        passed=False,
                        expected=0,
                        actual=1,
                        error_percentage=0,
                        message=issue
                    ))
        
        return results
    
    def test_elevation_gain_vs_mountain_height(self) -> List[TestResult]:
        """Test if elevation gain matches mountain height calculations"""
        results = []
        
        for mountain in self.mountains:
            calculated_elevation_gain = mountain.height - mountain.base_elevation_start
            actual_elevation_gain = mountain.total_elevation_gain
            error_percentage = abs(calculated_elevation_gain - actual_elevation_gain) / calculated_elevation_gain * 100
            
            results.append(TestResult(
                test_name=f"{mountain.name} Elevation Gain Calculation",
                passed=error_percentage < 1.0,  # Less than 1% error
                expected=calculated_elevation_gain,
                actual=actual_elevation_gain,
                error_percentage=error_percentage,
                message=f"{mountain.name}: Calculated {calculated_elevation_gain:.0f}m, Actual {actual_elevation_gain:.0f}m"
            ))
        
        return results
    
    def test_camp_elevation_consistency(self) -> List[TestResult]:
        """Test if camp elevation requirements match camp altitudes"""
        results = []
        
        for mountain in self.mountains:
            camps = mountain.camps
            base_altitude = mountain.base_elevation_start
            
            for i, camp in enumerate(camps):
                if i == 0:  # Base camp
                    expected_elevation = 0
                else:
                    expected_elevation = camp["altitude"] - base_altitude
                
                actual_elevation = camp["elevation"]
                error_percentage = abs(expected_elevation - actual_elevation) / max(expected_elevation, 1) * 100
                
                results.append(TestResult(
                    test_name=f"{mountain.name} - {camp['name']} Elevation",
                    passed=error_percentage < 5.0,  # Less than 5% error
                    expected=expected_elevation,
                    actual=actual_elevation,
                    error_percentage=error_percentage,
                    message=f"{camp['name']}: Expected {expected_elevation:.0f}m, Actual {actual_elevation:.0f}m"
                ))
        
        return results
    
    def test_realistic_daily_progress(self) -> List[TestResult]:
        """Test if daily progress calculations are realistic"""
        results = []
        
        # Test realistic daily step counts and elevation gains
        daily_test_cases = [
            (5000, 50),    # Light day: 5000 steps, 50m elevation
            (10000, 200),  # Moderate day: 10000 steps, 200m elevation
            (15000, 500),  # Active day: 15000 steps, 500m elevation
            (20000, 800),  # Intense day: 20000 steps, 800m elevation
        ]
        
        for steps, elevation in daily_test_cases:
            steps_per_meter = steps / elevation if elevation > 0 else 0
            
            # Check if ratio is realistic (between 10-100 steps per meter)
            is_realistic = 10 <= steps_per_meter <= 100
            
            results.append(TestResult(
                test_name=f"Daily Progress: {steps} steps, {elevation}m elevation",
                passed=is_realistic,
                expected=25,  # Expected ~25 steps per meter
                actual=steps_per_meter,
                error_percentage=abs(steps_per_meter - 25) / 25 * 100,
                message=f"Daily progress: {steps_per_meter:.1f} steps/meter ({'Realistic' if is_realistic else 'Unrealistic'})"
            ))
        
        return results
    
    def test_mountain_completion_accuracy(self) -> List[TestResult]:
        """Test if mountain completion requirements are accurate"""
        results = []
        
        for mountain in self.mountains:
            summit_camp = mountain.camps[-1]  # Last camp should be summit
            
            # Check if summit steps match base steps
            steps_match = summit_camp["steps"] == mountain.base_steps
            elevation_match = summit_camp["elevation"] == mountain.total_elevation_gain
            altitude_match = summit_camp["altitude"] == mountain.height
            
            all_match = steps_match and elevation_match and altitude_match
            
            results.append(TestResult(
                test_name=f"{mountain.name} Summit Accuracy",
                passed=all_match,
                expected=1,
                actual=1 if all_match else 0,
                error_percentage=0,
                message=f"{mountain.name}: Steps={steps_match}, Elevation={elevation_match}, Altitude={altitude_match}"
            ))
        
        return results
    
    def run_all_tests(self) -> Dict[str, List[TestResult]]:
        """Run all elevation model tests"""
        print("🧪 Running SummitAI Elevation Model Comprehensive Tests...")
        print("=" * 60)
        
        test_results = {
            "healthkit_conversion": self.test_healthkit_elevation_conversion(),
            "step_to_elevation_ratios": self.test_mountain_step_to_elevation_ratios(),
            "camp_progression": self.test_camp_progression_consistency(),
            "elevation_gain_calculation": self.test_elevation_gain_vs_mountain_height(),
            "camp_elevation_consistency": self.test_camp_elevation_consistency(),
            "daily_progress_realism": self.test_realistic_daily_progress(),
            "mountain_completion_accuracy": self.test_mountain_completion_accuracy()
        }
        
        return test_results
    
    def generate_report(self, test_results: Dict[str, List[TestResult]]) -> str:
        """Generate a comprehensive test report"""
        report = []
        report.append("# SummitAI Elevation Model Test Report")
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("")
        
        total_tests = 0
        passed_tests = 0
        
        for category, results in test_results.items():
            report.append(f"## {category.replace('_', ' ').title()}")
            report.append("")
            
            category_passed = 0
            for result in results:
                total_tests += 1
                if result.passed:
                    passed_tests += 1
                    category_passed += 1
                
                status = "✅ PASS" if result.passed else "❌ FAIL"
                report.append(f"- **{result.test_name}**: {status}")
                report.append(f"  - {result.message}")
                if not result.passed and result.error_percentage > 0:
                    report.append(f"  - Error: {result.error_percentage:.1f}%")
                report.append("")
            
            report.append(f"**Category Summary**: {category_passed}/{len(results)} tests passed")
            report.append("")
        
        # Overall summary
        report.append("## Overall Summary")
        report.append("")
        report.append(f"**Total Tests**: {total_tests}")
        report.append(f"**Passed**: {passed_tests}")
        report.append(f"**Failed**: {total_tests - passed_tests}")
        report.append(f"**Success Rate**: {(passed_tests/total_tests)*100:.1f}%")
        report.append("")
        
        # Key findings
        report.append("## Key Findings")
        report.append("")
        
        # Analyze step-to-elevation ratios
        ratio_results = test_results["step_to_elevation_ratios"]
        unrealistic_ratios = [r for r in ratio_results if not r.passed]
        if unrealistic_ratios:
            report.append("### ⚠️ Unrealistic Step-to-Elevation Ratios")
            for result in unrealistic_ratios:
                report.append(f"- {result.test_name}: {result.actual:.1f} steps/meter (expected ~{result.expected})")
            report.append("")
        
        # Analyze progression issues
        progression_results = test_results["camp_progression"]
        progression_issues = [r for r in progression_results if not r.passed]
        if progression_issues:
            report.append("### ⚠️ Camp Progression Issues")
            for result in progression_issues:
                report.append(f"- {result.message}")
            report.append("")
        
        # Analyze elevation calculation issues
        elevation_results = test_results["elevation_gain_calculation"]
        elevation_issues = [r for r in elevation_results if not r.passed]
        if elevation_issues:
            report.append("### ⚠️ Elevation Calculation Issues")
            for result in elevation_issues:
                report.append(f"- {result.message}")
            report.append("")
        
        return "\n".join(report)

def main():
    """Main test execution"""
    tester = ElevationModelTester()
    
    # Run all tests
    test_results = tester.run_all_tests()
    
    # Generate and print report
    report = tester.generate_report(test_results)
    print(report)
    
    # Save report to file
    with open("SummitAI/elevation_model_test_report.md", "w") as f:
        f.write(report)
    
    print("\n📊 Test report saved to: SummitAI/elevation_model_test_report.md")
    
    # Print summary
    total_tests = sum(len(results) for results in test_results.values())
    passed_tests = sum(sum(1 for r in results if r.passed) for results in test_results.values())
    
    print(f"\n🎯 Test Summary: {passed_tests}/{total_tests} tests passed ({(passed_tests/total_tests)*100:.1f}%)")
    
    if passed_tests < total_tests:
        print("⚠️  Some tests failed - elevation model needs attention!")
    else:
        print("✅ All tests passed - elevation model is accurate!")

if __name__ == "__main__":
    main()
