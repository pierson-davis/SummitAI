#!/usr/bin/env python3
"""
Script to add StreakManager.swift and StreakView.swift to the Xcode project
"""

import re
import uuid

def add_files_to_xcode_project():
    # Read the project file
    with open('SummitAI.xcodeproj/project.pbxproj', 'r') as f:
        content = f.read()
    
    # Generate UUIDs for the new files
    streak_manager_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    streak_view_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    streak_manager_build_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    streak_view_build_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
    
    # Find the PBXFileReference section
    file_ref_pattern = r'(/\* Begin PBXFileReference section \*/\n)(.*?)(/\* End PBXFileReference section \*/)'
    match = re.search(file_ref_pattern, content, re.DOTALL)
    
    if not match:
        print("Could not find PBXFileReference section")
        return False
    
    # Add StreakManager.swift file reference
    streak_manager_ref = f'\t\t{streak_manager_uuid} /* StreakManager.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StreakManager.swift; sourceTree = "<group>"; }};\n'
    
    # Add StreakView.swift file reference  
    streak_view_ref = f'\t\t{streak_view_uuid} /* StreakView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StreakView.swift; sourceTree = "<group>"; }};\n'
    
    # Insert the new file references
    new_file_refs = match.group(1) + streak_manager_ref + streak_view_ref + match.group(2)
    content = content.replace(match.group(0), new_file_refs)
    
    # Find the PBXBuildFile section
    build_file_pattern = r'(/\* Begin PBXBuildFile section \*/\n)(.*?)(/\* End PBXBuildFile section \*/)'
    match = re.search(build_file_pattern, content, re.DOTALL)
    
    if not match:
        print("Could not find PBXBuildFile section")
        return False
    
    # Add build file entries
    streak_manager_build = f'\t\t{streak_manager_build_uuid} /* StreakManager.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {streak_manager_uuid} /* StreakManager.swift */; }};\n'
    streak_view_build = f'\t\t{streak_view_build_uuid} /* StreakView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {streak_view_uuid} /* StreakView.swift */; }};\n'
    
    # Insert the new build files
    new_build_files = match.group(1) + streak_manager_build + streak_view_build + match.group(2)
    content = content.replace(match.group(0), new_build_files)
    
    # Find the Services group and add StreakManager.swift
    services_pattern = r'(SummitAI/Services.*?children = \()(.*?)(\);.*?name = Services;)'
    match = re.search(services_pattern, content, re.DOTALL)
    
    if match:
        streak_manager_group = f'\t\t\t\t{streak_manager_uuid} /* StreakManager.swift */,\n'
        new_services = match.group(1) + streak_manager_group + match.group(2) + match.group(3)
        content = content.replace(match.group(0), new_services)
    
    # Find the Components group and add StreakView.swift
    components_pattern = r'(SummitAI/Views/Components.*?children = \()(.*?)(\);.*?name = Components;)'
    match = re.search(components_pattern, content, re.DOTALL)
    
    if match:
        streak_view_group = f'\t\t\t\t{streak_view_uuid} /* StreakView.swift */,\n'
        new_components = match.group(1) + streak_view_group + match.group(2) + match.group(3)
        content = content.replace(match.group(0), new_components)
    
    # Find the PBXSourcesBuildPhase section and add the files
    sources_pattern = r'(/\* Begin PBXSourcesBuildPhase section \*/\n.*?files = \()(.*?)(\);.*?/\* End PBXSourcesBuildPhase section \*/)'
    match = re.search(sources_pattern, content, re.DOTALL)
    
    if match:
        streak_manager_sources = f'\t\t\t\t{streak_manager_build_uuid} /* StreakManager.swift in Sources */,\n'
        streak_view_sources = f'\t\t\t\t{streak_view_build_uuid} /* StreakView.swift in Sources */,\n'
        new_sources = match.group(1) + streak_manager_sources + streak_view_sources + match.group(2) + match.group(3)
        content = content.replace(match.group(0), new_sources)
    
    # Write the updated project file
    with open('SummitAI.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)
    
    print("Successfully added StreakManager.swift and StreakView.swift to Xcode project")
    return True

if __name__ == "__main__":
    add_files_to_xcode_project()
